#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseFonctionnementsController < DepensesController
  include UIEnhancements::SubList
  helper :SubList

  sub_list 'DepenseFonctionnementFactures', 'depense_fonctionnement' do |new_depense_fonctionnement_facture|
  end

  auto_complete_for :depense_fonctionnement, :fournisseur

  before_filter :set_lignes_editables, :set_lignes_consultables
  before_filter :is_my_ligne_research_in_session?

  # GET /depense_fonctionnements
  # GET /depense_fonctionnements.xml
  def index
    setup_order_by :name => 'fonctionnement', :default_field => 'date_commande', :default_direction => 'desc'
    setup_depenses_filter
    setup_items_per_page
    setup_depenses_dates
    setup_depenses_facture
    setup_type_montant(@ligne.contrat.come_from_inria?)

    depenses = @ligne.depense_fonctionnements.all(:conditions => @filter_condition + @date_condition)
    @depense_fonctionnements = sort_and_paginate_depenses(depenses)
    setup_depenses_totals(depenses, DepenseFonctionnement)

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
      format.xml  { render :xml => @depense_fonctionnements }
      format.csv { render :text => export_csv(depenses,'fonctionnement') }
    end
  end

  # GET /depense_fonctionnements/1
  # GET /depense_fonctionnements/1.xml
  def show
    @ligne = Ligne.find(params[:ligne_id])
    @depense_fonctionnement = DepenseFonctionnement.find(params[:id])

    # test si la reference existe dans une autre depense, pour message d'avertissement
    if !@depense_fonctionnement.reference.blank? && search_all_exact_references(@depense_fonctionnement.reference).size > 1
      @ref_exist = true
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @depense_fonctionnement }
    end
  end

  # GET /depense_fonctionnements/new
  # GET /depense_fonctionnements/new.xml
  def new
    @ligne = Ligne.find(params[:ligne_id])
    @depense_fonctionnement = DepenseFonctionnement.new
    @non_modifiables = @depense_fonctionnement.get_non_modifiables

    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de dépense en fonctionnement pour la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_fonctionnements_path(@ligne)
    end
  end

  # GET /depense_fonctionnements/1/edit
  def edit
    @ligne = Ligne.find(params[:ligne_id])
    @depense_fonctionnement = DepenseFonctionnement.find(params[:id])
    @non_modifiables = @depense_fonctionnement.get_non_modifiables

    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'éditer les dépenses en fonctionnement de la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_fonctionnement_path(@ligne, @depense_fonctionnement)
    end
  end

  # POST /depense_equipements/1/duplicate
  def duplicate
    @ligne = Ligne.find(params[:ligne_id])
    @depense_fonctionnement = DepenseFonctionnement.find(params[:id])
    @non_modifiables = []
    @new_depense_fonctionnement = @depense_fonctionnement.dup
    @new_depense_fonctionnement.reference=""
    @new_depense_fonctionnement.verrou = 'Aucun'
    @new_depense_fonctionnement.verrou_listchamps = nil
    @new_depense_fonctionnement.commande_solde= false
    @new_depense_fonctionnement.verif = 0
    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de dépense en fonctionnement sur la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_fonctionnement_path(@ligne)
    end
    @new_depense_fonctionnement.save
    flash[:notice] = ('La dépense a bien été dupliquée.').html_safe()
    respond_to do |format|
      format.html { redirect_to edit_ligne_depense_fonctionnement_path(@ligne, @new_depense_fonctionnement) }
    end
  end

  # POST /depense_fonctionnements
  # POST /depense_fonctionnements.xml
  def create
    params[:depense_fonctionnement] = clean_date_params(params[:depense_fonctionnement])
    @ligne = Ligne.find(params[:ligne_id])
    @depense_fonctionnement = DepenseFonctionnement.new(params[:depense_fonctionnement])
    @non_modifiables = @depense_fonctionnement.get_non_modifiables
    @depense_fonctionnement.ligne = @ligne

    success = true
    success &&= initialize_depense_fonctionnement_factures
    success &&= @depense_fonctionnement.save

    # Pour une mise à jour correcte de date_min et date_max
    @depense_fonctionnement.update_dates_min_max
    @depense_fonctionnement.save

    respond_to do |format|
      if success
        flash[:notice] = ('La dépense en fonctionnement a bien été crée.').html_safe()
        format.html { redirect_to ligne_depense_fonctionnement_path(@ligne, @depense_fonctionnement) }
      else
        prepare_depense_fonctionnement_factures
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /depense_fonctionnements/1
  # PUT /depense_fonctionnements/1.xml
  def update
    params[:depense_fonctionnement] = clean_date_params(params[:depense_fonctionnement])
    @ligne = Ligne.find(params[:ligne_id])
    @depense_fonctionnement = DepenseFonctionnement.find(params[:id])
    @non_modifiables = @depense_fonctionnement.get_non_modifiables

    @depense_fonctionnement.update_attributes(params[:depense_fonctionnement])

    success = true
    success &&= initialize_depense_fonctionnement_factures
    success &&= @depense_fonctionnement.save

    respond_to do |format|
      @ligne =  @depense_fonctionnement.ligne
      if success
        if (params[:ajuster_montant])
          @depense_fonctionnement.montant_engage = @depense_fonctionnement.montant_factures('ttc')
        end
        @depense_fonctionnement.update_dates_min_max
        @depense_fonctionnement.verif = false
        @depense_fonctionnement.save
        flash[:notice] = ('La dépense en fonctionnement a bien été mise à jour.').html_safe()
        format.html { redirect_to ligne_depense_fonctionnement_path(@ligne, @depense_fonctionnement) }
      else
        prepare_depense_fonctionnement_factures
        format.html { render :action => "edit" }
      end
    end
  end

  def build_migration_form
    @depense_fonctionnement = DepenseFonctionnement.find(params[:id])
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
    @depense_fonctionnement = DepenseFonctionnement.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # DELETE /depense_fonctionnements/1
  # DELETE /depense_fonctionnements/1.xml
  def destroy
    @ligne = Ligne.find(params[:ligne_id])
    @depense_fonctionnement = DepenseFonctionnement.find(params[:id])
    @depense_fonctionnement.destroy

    respond_to do |format|
      format.html { redirect_to(ligne_depense_fonctionnements_path(@ligne)) }
      format.xml  { head :ok }
    end
  end

end
