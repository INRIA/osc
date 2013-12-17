#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseMissionsController < DepensesController
  include UIEnhancements::SubList
  helper :SubList

  sub_list 'DepenseMissionFactures', 'depense_mission' do |new_depense_mission_facture|
  end

  before_filter :set_lignes_editables, :set_lignes_consultables
  before_filter :is_my_ligne_research_in_session?

  # GET /depense_missions
  # GET /depense_missions.xml
  def index
    setup_order_by :name => 'mission', :default_field => 'date_depart', :default_direction => 'desc'
    setup_depenses_filter
    setup_items_per_page
    setup_depenses_dates
    setup_depenses_facture
    setup_type_montant(@ligne.contrat.come_from_inria?)

    depenses = @ligne.depense_missions.all(:conditions => @filter_condition + @date_condition)
    @depense_missions = sort_and_paginate_depenses(depenses)
    setup_depenses_totals(depenses, DepenseMission)
    @colspan_totals = 8
    
    respond_to do |format|
      format.html {
        if !@ligne.contrat.is_consultable? current_user
            flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la ligne "+@ligne.nom+"."
            redirect_to lignes_path
        end
      }
      format.js {
        render :partial => 'list.html.erb'
      }
      format.xml  { render :xml => @depense_missions }
      format.csv { render :text => export_csv(depenses,'mission') }
    end
  end

  # GET /depense_missions/1
  # GET /depense_missions/1.xml
  def show
    @ligne = Ligne.find(params[:ligne_id])
    @depense_mission = DepenseMission.find(params[:id])

    # test si la reference existe dans une autre depense, pour message d'avertissement
    if !@depense_mission.reference.blank? && search_all_exact_references(@depense_mission.reference).size > 1
      @ref_exist = true
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @depense_mission }
    end
  end

  # GET /depense_missions/new
  # GET /depense_missions/new.xml
  def new
    @ligne = Ligne.find(params[:ligne_id])
    @depense_mission = DepenseMission.new
    @non_modifiables = @depense_mission.get_non_modifiables

    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de mission pour la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_missions_path(@ligne)
    end
  end

  # GET /depense_missions/1/edit
  def edit
    @ligne = Ligne.find(params[:ligne_id])
    @depense_mission = DepenseMission.find(params[:id])
    @non_modifiables = @depense_mission.get_non_modifiables

    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'éditer les mission de la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_mission_path(@ligne, @depense_mission)
    end
  end

  # POST /depense_missions/1/duplicate
  def duplicate
    @ligne = Ligne.find(params[:ligne_id])
    @depense_mission = DepenseMission.find(params[:id])
    @non_modifiables = []
    @new_depense_mission = @depense_mission.dup
    @new_depense_mission.reference=""
    @new_depense_mission.verrou = 'Aucun'
    @new_depense_mission.verrou_listchamps = nil
    @new_depense_mission.commande_solde= false
    @new_depense_mission.verif = 0
    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de dépense en mission sur la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_mission_path(@ligne)
    end
    @new_depense_mission.save
    flash[:notice] = ('La dépense a bien été dupliquée.').html_safe()
    respond_to do |format|
      format.html { redirect_to edit_ligne_depense_mission_path(@ligne, @new_depense_mission) }
    end
  end

  # POST /depense_missions
  # POST /depense_missions.xml
  def create
    params[:depense_mission] = clean_date_params(params[:depense_mission])
    @ligne = Ligne.find(params[:ligne_id])
    @depense_mission = DepenseMission.new(params[:depense_mission])
    @depense_mission.ligne = @ligne
    @non_modifiables = @depense_mission.get_non_modifiables
    success = true
    success &&= initialize_depense_mission_factures
    success &&= @depense_mission.save

    # Pour une mise à jour correcte de date_min et date_max
    @depense_mission.update_dates_min_max
    @depense_mission.save

    respond_to do |format|
      if success
        flash[:notice] = ('La mission a bien été crée.').html_safe()
        format.html { redirect_to ligne_depense_mission_path(@ligne, @depense_mission) }
      else
        prepare_depense_mission_factures
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /depense_missions/1
  # PUT /depense_missions/1.xml
  def update
    params[:depense_mission] = clean_date_params(params[:depense_mission])
    @ligne = Ligne.find(params[:ligne_id])
    @depense_mission = DepenseMission.find(params[:id])
    @non_modifiables = @depense_mission.get_non_modifiables
    @depense_mission.update_attributes(params[:depense_mission])

    success = true
    success &&= initialize_depense_mission_factures
    success &&= @depense_mission.save

    respond_to do |format|
      @ligne =  @depense_mission.ligne
      if success
        if (params[:ajuster_montant])
          @depense_mission.montant_engage = @depense_mission.montant_factures('ttc')
        end
        # Pour une mise à jour correcte de date_min et date_max
        @depense_mission.update_dates_min_max
        @depense_mission.verif = false
        @depense_mission.save
        flash[:notice] = ('La mission a bien été mise à jour.').html_safe()
        format.html { redirect_to ligne_depense_mission_path(@ligne, @depense_mission) }
      else
        prepare_depense_mission_factures
        format.html { render :action => "edit" }
      end
    end
  end

  def build_migration_form
    @depense_mission = DepenseMission.find(params[:id])
    dotation_contrat_type_ids = ContratType.find_all_dotation_type_id
    req = "Select lignes.id,lignes.nom from lignes 
                         inner join sous_contrats on sous_contrats.id = lignes.sous_contrat_id
                         inner join contrats on contrats.id = sous_contrats.contrat_id
                         inner join notifications on notifications.contrat_id = contrats.id
                         where notifications.contrat_type_id not IN (?) and lignes.id IN (?) ORDER BY nom" 
    @available_lignes = Ligne.find_by_sql([req,dotation_contrat_type_ids, @ids_lignes_editables]).collect { |p| [ p.nom, p.id ] }
   respond_to do |format|
      format.js {
        render :partial => "migration_form"
      }
    end
  end

  def ask_delete
    @ligne = Ligne.find(params[:ligne_id])
    @depense_mission = DepenseMission.find(params[:id])
    respond_to do |format|
      format.html
    end
  end


  # DELETE /depense_missions/1
  # DELETE /depense_missions/1.xml
  def destroy
    @ligne = Ligne.find(params[:ligne_id])
    @depense_mission = DepenseMission.find(params[:id])
    @depense_mission.destroy

    respond_to do |format|
      format.html { redirect_to(ligne_depense_missions_path(@ligne)) }
      format.xml  { head :ok }
    end
  end

end
