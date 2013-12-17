#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseNonVentileesController < DepensesController
  include UIEnhancements::SubList
  helper :SubList

  sub_list 'DepenseNonVentileeFactures', 'depense_non_ventilee' do |new_depense_non_ventilee_facture|
  end

  auto_complete_for :depense_non_ventilee, :fournisseur

  before_filter :set_lignes_editables, :set_lignes_consultables
  before_filter :is_my_ligne_research_in_session?

  # GET /depense_non_ventilees
  # GET /depense_non_ventilees.xml
  def index
    setup_order_by :name => 'non_ventilees', :default_field => 'date_commande', :default_direction => 'desc'
    setup_depenses_filter
    setup_items_per_page
    setup_depenses_dates
    setup_depenses_facture
    setup_type_montant(@ligne.contrat.come_from_inria?)

    depenses = @ligne.depense_non_ventilees.all(:conditions => @filter_condition + @date_condition)
    @depense_non_ventilees = sort_and_paginate_depenses(depenses)
    setup_depenses_totals(depenses, DepenseNonVentilee)
    respond_to do |format|
      format.html {
        if !@ligne.contrat.is_consultable? current_user
            flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'accéder à la ligne "+@ligne.nom+".").html_safe()
            redirect_to lignes_path
        end
      }
      format.js {
        render :partial => 'list.html.erb'
      }
      format.xml  { render :xml => @depense_non_ventilees }
      format.csv { render :text => export_csv(depenses,'non_ventilee') }
    end
  end

  # GET /depense_non_ventilees/1
  # GET /depense_non_ventilees/1.xml
  def show
    @ligne = Ligne.find(params[:ligne_id])
    @depense_non_ventilee = DepenseNonVentilee.find(params[:id])

    # test si la reference existe dans une autre depense, pour message d'avertissement
    if !@depense_non_ventilee.reference.blank? && search_all_exact_references(@depense_non_ventilee.reference).size > 1
      @ref_exist = true
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @depense_non_ventilee }
    end
  end

  # GET /depense_non_ventilees/new
  # GET /depense_non_ventilees/new.xml
  def new
    @ligne = Ligne.find(params[:ligne_id])
    @depense_non_ventilee = DepenseNonVentilee.new
    @non_modifiables = @depense_non_ventilee.get_non_modifiables

    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de dépense non ventilée pour la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_non_ventilees_path(@ligne)
    end
  end

  # GET /depense_non_ventilees/1/edit
  def edit
    @ligne = Ligne.find(params[:ligne_id])
    @depense_non_ventilee = DepenseNonVentilee.find(params[:id])
    @non_modifiables = @depense_non_ventilee.get_non_modifiables

    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'éditer les dépenses non ventilée de la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_non_ventilee_path(@ligne, @depense_non_ventilee)
    end
  end

  # POST /depense_equipements/1/duplicate
  def duplicate
    @ligne = Ligne.find(params[:ligne_id])
    @depense_non_ventilee = DepenseNonVentilee.find(params[:id])
    @new_depense_non_ventilee = @depense_non_ventilee.dup
    @new_depense_non_ventilee.reference=""
    @new_depense_non_ventilee.verrou = 'Aucun'
    @new_depense_non_ventilee.verrou_listchamps = nil
    @new_depense_non_ventilee.commande_solde= false
    @new_depense_non_ventilee.verif = 0
    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de dépense non ventilée sur la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_non_ventilee_path(@ligne)
    end
    @new_depense_non_ventilee.save
    flash[:notice] = ('La dépense a bien été dupliquée.').html_safe()
    respond_to do |format|
      format.html { redirect_to edit_ligne_depense_non_ventilee_path(@ligne, @new_depense_non_ventilee) }
    end
  end

  # POST /depense_non_ventilees
  # POST /depense_non_ventilees.xml
  def create
    params[:depense_non_ventilee] = clean_date_params(params[:depense_non_ventilee])
    @ligne = Ligne.find(params[:ligne_id])
    @depense_non_ventilee = DepenseNonVentilee.new(params[:depense_non_ventilee])
    @depense_non_ventilee.ligne = @ligne
    @non_modifiables = @depense_non_ventilee.get_non_modifiables

    success = true
    success &&= initialize_depense_non_ventilee_factures
    success &&= @depense_non_ventilee.save

    # Pour une mise à jour correcte de date_min et date_max
    @depense_non_ventilee.update_dates_min_max
    @depense_non_ventilee.save

    respond_to do |format|
      if success
        flash[:notice] = ('La dépense non ventilée a bien été crée.').html_safe()
        format.html { redirect_to ligne_depense_non_ventilee_path(@ligne, @depense_non_ventilee) }
      else
        prepare_depense_non_ventilee_factures
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /depense_non_ventilees/1
  # PUT /depense_non_ventilees/1.xml
  def update
    params[:depense_non_ventilee] = clean_date_params(params[:depense_non_ventilee])
    @ligne = Ligne.find(params[:ligne_id])
    @depense_non_ventilee = DepenseNonVentilee.find(params[:id])
    @non_modifiables = @depense_non_ventilee.get_non_modifiables
    @depense_non_ventilee.update_attributes(params[:depense_non_ventilee])

    success = true
    success &&= initialize_depense_non_ventilee_factures
    success &&= @depense_non_ventilee.save

    respond_to do |format|
      @ligne =  @depense_non_ventilee.ligne
      if success
        if (params[:ajuster_montant])
          @depense_non_ventilee.montant_engage = @depense_non_ventilee.montant_factures('ttc')
        end
        # Pour une mise à jour correcte de date_min et date_max
        @depense_non_ventilee.update_dates_min_max
        @depense_non_ventilee.verif = false
        @depense_non_ventilee.save
        flash[:notice] = ('La dépense non ventilée a bien été mise à jour.').html_safe()
        format.html { redirect_to ligne_depense_non_ventilee_path(@ligne, @depense_non_ventilee) }
      else
        prepare_depense_non_ventilee_factures
        format.html { render :action => "edit" }
      end
    end
  end

  def build_migration_form
    @depense_non_ventilee = DepenseNonVentilee.find(params[:id])
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
    @depense_non_ventilee = DepenseNonVentilee.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # DELETE /depense_non_ventilees/1
  # DELETE /depense_non_ventilees/1.xml
  def destroy
    @ligne = Ligne.find(params[:ligne_id])
    @depense_non_ventilee = DepenseNonVentilee.find(params[:id])
    @depense_non_ventilee.destroy

    respond_to do |format|
      format.html { redirect_to(ligne_depense_non_ventilees_path(@ligne)) }
      format.xml  { head :ok }
    end
  end

end
