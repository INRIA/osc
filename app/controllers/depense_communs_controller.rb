#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseCommunsController < DepensesController
  include UIEnhancements::SubList
  helper :SubList

  sub_list 'DepenseCommunFactures', 'depense_commun' do |new_depense_commun_facture|
  end

  auto_complete_for :depense_commun, :fournisseur

  before_filter :set_lignes_editables, :set_lignes_consultables
  before_filter :is_my_ligne_research_in_session?

  # GET /depense_communs
  # GET /depense_communs.xml
  def index
    setup_order_by :name => 'commun', :default_field => 'date_commande', :default_direction => 'desc'
    setup_depenses_filter
    setup_items_per_page
    setup_depenses_dates
    setup_depenses_facture
    setup_type_montant(@ligne.contrat.come_from_inria?)

    if  @order_by_field == 'budgetaire_reference'
      depenses = DepenseCommun.find_all_by_ligne_id(@ligne.id,
        :include    => :budgetaire_reference,
        :conditions => @filter_condition + @date_condition)

      depenses.sort! { |a,b|
        a.budgetaire_reference.code <=> b.budgetaire_reference.code }

      depenses.reverse! if @order_by_direction != "asc"

      @depense_communs = depenses.paginate(
        :page       => params[:page],
        :per_page   => @items_per_page)

      setup_depenses_totals(depenses, DepenseCommun)

    else
      depenses = @ligne.depense_communs.all(:conditions => @filter_condition + @date_condition)
      @depense_communs = sort_and_paginate_depenses(depenses)
      setup_depenses_totals(depenses, DepenseCommun)
    end

    @colspan_totals = 8 # override default
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
      format.xml  { render :xml => @depense_communs }
      format.csv { render :text => export_csv(depenses,'commun') }
    end
  end

  # GET /depense_communs/new
  # GET /depense_communs/new.xml
  def new
    @ligne = Ligne.find(params[:ligne_id])
    @depense_commun = DepenseCommun.new
    @budgetaire_references = BudgetaireReference.find(:all, :order => :code).collect {|p| [ p.code+" "+p.intitule, p.id ] }

    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de dépense en commun pour la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_communs_path(@ligne)
    end
  end

  # POST /depense_communs
  # POST /depense_communs.xml
  def create
    params[:depense_commun] = clean_date_params(params[:depense_commun])
    @ligne = Ligne.find(params[:ligne_id])
    @depense_commun = DepenseCommun.new(params[:depense_commun])
    @budgetaire_references = BudgetaireReference.find(:all, :order => :code).collect {|p| [ p.code+" "+p.intitule, p.id ] }
    @depense_commun.ligne = @ligne

    success = true
    success &&= initialize_depense_commun_factures
    success &&= @depense_commun.save

    # Pour une mise à jour correcte de date_min et date_max
    @depense_commun.update_dates_min_max
    @depense_commun.save
    
    respond_to do |format|
      if success
        flash[:notice] = ('La dépense en commun a bien été crée.').html_safe()
        format.html { redirect_to ligne_depense_commun_path(@ligne, @depense_commun) }
      else
        prepare_depense_commun_factures
        format.html { render :action => "new" }
      end
    end
  end

  # GET /depense_communs/1/edit
  def edit
    @ligne = Ligne.find(params[:ligne_id])
    @depense_commun = DepenseCommun.find(params[:id])
    @budgetaire_references = BudgetaireReference.find(:all, :order => :code).collect {|p| [ p.code+" "+p.intitule, p.id ] }

    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'éditer les dépenses en commun de la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_commun_path(@ligne, @depense_commun)
    end
  end

  # PUT /depense_communs/1
  # PUT /depense_communs/1.xml
  def update
    params[:depense_commun] = clean_date_params(params[:depense_commun])
    @ligne = Ligne.find(params[:ligne_id])
    @depense_commun = DepenseCommun.find(params[:id])
    @budgetaire_references = BudgetaireReference.find(:all, :order => :code).collect {|p| [ p.code+" "+p.intitule, p.id ] }

    @depense_commun.update_attributes(params[:depense_commun])

    success = true
    success &&= initialize_depense_commun_factures
    success &&= @depense_commun.save

    respond_to do |format|
      @ligne =  @depense_commun.ligne
      if success
        if (params[:ajuster_montant])
          @depense_commun.montant_engage = @depense_commun.montant_factures('ttc')
        end
        @depense_commun.update_dates_min_max
        @depense_commun.verif = false
        @depense_commun.save
        flash[:notice] = ('La dépense en commun a bien été mise à jour.').html_safe()
        format.html { redirect_to ligne_depense_commun_path(@ligne, @depense_commun) }
      else
        prepare_depense_commun_factures
        format.html { render :action => "edit" }
      end
    end
  end

  # POST /depense_communs/1/duplicate
  def duplicate
    @ligne = Ligne.find(params[:ligne_id])
    @depense_commun = DepenseCommun.find(params[:id])
    @new_depense_commun = @depense_commun.dup
    @new_depense_commun.reference=""
    @new_depense_commun.commande_solde= false
    @new_depense_commun.verif = 0
    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de dépense en commun sur la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_commun_path(@ligne)
    end
    @new_depense_commun.save
    flash[:notice] = ('La dépense a bien été dupliquée.').html_safe()
    respond_to do |format|
      format.html { redirect_to edit_ligne_depense_commun_path(@ligne, @new_depense_commun) }
    end
  end

  def show
    @ligne = Ligne.find(params[:ligne_id])
    @depense_commun = DepenseCommun.find(params[:id])

    # test si la reference existe dans une autre depense, pour message d'avertissement
    if !@depense_commun.reference.blank? && search_all_exact_references(@depense_commun.reference).size > 1
      @ref_exist = true
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @depense_commun }
    end
  end

  def build_migration_form
    @depense_commun = DepenseCommun.find(params[:id])
    dotation_contrat_type_ids = ContratType.find_all_dotation_type_id
    req = "Select lignes.id,lignes.nom from lignes 
                         inner join sous_contrats on sous_contrats.id = lignes.sous_contrat_id
                         inner join contrats on contrats.id = sous_contrats.contrat_id
                         inner join notifications on notifications.contrat_id = contrats.id
                         where notifications.contrat_type_id IN (?) and lignes.id IN (?) ORDER BY nom" 
    @available_lignes = Ligne.find_by_sql([req,dotation_contrat_type_ids, @ids_lignes_editables]).collect { |p| [ p.nom, p.id ] }
    respond_to do |format|
      format.js {
        render :partial => "migration_form"
      }
    end
  end
  
  def ask_delete
    @ligne = Ligne.find(params[:ligne_id])
    @depense_commun = DepenseCommun.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # DELETE /depense_communs/1
  # DELETE /depense_communs/1.xml
  def destroy
    @ligne = Ligne.find(params[:ligne_id])
    @depense_commun = DepenseCommun.find(params[:id])
    @depense_commun.destroy

    respond_to do |format|
      format.html { redirect_to(ligne_depense_communs_path(@ligne)) }
      format.xml  { head :ok }
    end
  end
end
