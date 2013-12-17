#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class VersementsController < DepensesController
  before_filter :is_my_ligne_research_in_session?

  before_filter :set_lignes_editables, :set_lignes_consultables, :before_affichage_versement

  # GET /versements
  # GET /versements.xml
  def index
    setup_order_by :name => 'versements', :default_field => 'date_effet', :default_direction => 'desc'
    setup_versements_filter_cookies
    setup_versements_dates_cookies
    setup_items_per_page

    versements = @ligne.versements.all(:conditions => @condition)
    sort_field = @order_by_field.to_sym
    versements.sort! { |a,b| a.send(sort_field) <=> b.send(sort_field) }
    versements.reverse! if @order_by_direction != "asc"
    @versements = versements.paginate(
      :page       => params[:page],
      :per_page   => @items_per_page)
    setup_versements_totals(versements)
    respond_to do |format|
      format.html {    
        if !@ligne.contrat.is_consultable? current_user
          flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la ligne "+@ligne.nom+"."
          redirect_to lignes_path
        end
      }
      format.js {
        render :partial => "list"
      }
      format.xml  { render :xml => @versements }
      format.csv { render :text => export_csv(versements,'credit') }
    end
  end

  # GET /versements/1
  # GET /versements/1.xml
  def show
    @versement = Versement.find(params[:id])
    @ligne = Ligne.find(@versement.ligne_id)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @versement }
    end
  end

  # GET /versements/new
  # GET /versements/new.xml
  def new
    @ligne = Ligne.find(params[:ligne_id])
    @versement = Versement.new
    @non_modifiable = []
    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = "Vos droits dans l'application ne vous permettent pas de créer de versement pour la ligne "+@ligne.nom+"."
      redirect_to ligne_versements_path(@ligne)
    end
  end

  # GET /versements/1/edit
  def edit
    @ligne = Ligne.find(params[:ligne_id])
    @versement = Versement.find(params[:id])
    @non_modifiable = []
    if (@versement.verrou == 'SI INRIA') and @versement.verrou_listchamps
      verrou_listchamps_tableau = @versement.verrou_listchamps.split(';')
      for champ in verrou_listchamps_tableau do
        @non_modifiable << champ
      end
    end

    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'éditer les versement de la ligne "+@ligne.nom+"."
      redirect_to ligne_versement_path(@ligne, @versement)
    elsif ((@versement.verrou == 'Droit de modification') && (!@ligne.contrat.is_editable? current_user))
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'éditer ce versement."
      redirect_to ligne_versement_path(@ligne, @versement)
    end
  end

  # POST /depense_equipements/1/duplicate
  def duplicate
    @ligne = Ligne.find(params[:ligne_id])
    @versement = Versement.find(params[:id])
    @new_versement = @versement.dup
    @new_versement.reference=""
    @new_versement.verrou = 'Aucun'
    @new_versement.verrou_listchamps = nil
    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = "Vos droits dans l'application ne vous permettent pas de créer de versement sur la ligne "+@ligne.nom+"."
      redirect_to ligne_versement_path(@ligne)
    end
    @new_versement.save
    respond_to do |format|
      format.html { redirect_to edit_ligne_versement_path(@ligne, @new_versement) }
    end
  end

  # POST /versements
  # POST /versements.xml
  def create
    params[:versement] = clean_date_params(params[:versement])
    @ligne = Ligne.find(params[:ligne_id])
    @versement = Versement.new(params[:versement])
    if (params[:verrou_modification])
      @versement.verrou = "Droit de modification"
    elsif !params[:verrou_modification]
      @versement.verrou = "Aucun"
    end
    @versement.ligne = @ligne
    @non_modifiable = []
    respond_to do |format|
      if @versement.save
        flash[:notice] = 'Le crédit a bien été créé.'
        format.html { redirect_to ligne_versement_path(@ligne, @versement) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /versements/1
  # PUT /versements/1.xml
  def update
    params[:versement] = clean_date_params(params[:versement])
    @ligne = Ligne.find(params[:ligne_id])
    @versement = Versement.find(params[:id])
    if !@versement.come_from_inria?
      if (params[:verrou_modification])
        @versement.verrou = "Droit de modification"
        @versement.save
      elsif !params[:verrou_modification]
        @versement.verrou = "Aucun"
        @versement.save
      end
    end
    @non_modifiable = []
    respond_to do |format|
      @ligne =  @versement.ligne
      if @versement.update_attributes(params[:versement])
        flash[:notice] = 'Le crédit a bien été mis à jour.'
        format.html { redirect_to ligne_versement_path(@ligne, @versement) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def build_migration_form
    @versement = Versement.find(params[:id])
    @available_lignes = Ligne.find(:all,
                                   :select => "id, nom",
                                   :order => 'nom',
                                   :conditions =>["id IN (?)", @ids_lignes_editables]).collect { |p| [ p.nom, p.id ] }
    respond_to do |format|
      format.js {
        render :partial => "migration_form"
      }
    end
  end

  def ask_delete
    @ligne = Ligne.find(params[:ligne_id])
    @versement = Versement.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # DELETE /versements/1
  # DELETE /versements/1.xml
  def destroy
    @ligne = Ligne.find(params[:ligne_id])
    @versement = Versement.find(params[:id])
    @versement.destroy

    respond_to do |format|
      format.html { redirect_to ligne_versements_path(@ligne) }
    end
  end

  private

  def before_affichage_versement
    @ligne = Ligne.find(params[:ligne_id])
    @contrat_dotation = @ligne.contrat_dotation
    setup_type_montant(@ligne.contrat.come_from_inria?)
    #calcul des versements et dépenses totaux pour une ligne:
    @total_versements_ligne = @ligne.versements.find(:all).sum{ |d| d.montant }
    total_depenses_commun_ligne = @ligne.depense_communs.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant) }
    total_depenses_equipement_ligne = @ligne.depense_equipements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant)  }
    total_depenses_fonctionnement_ligne = @ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant)  }
    total_depenses_mission_ligne = @ligne.depense_missions.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant)  }
    total_depenses_salaire_ligne = @ligne.depense_salaires.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant)  }
    total_depenses_non_ventile_ligne = @ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant)  }
    total_depenses_ligne = total_depenses_commun_ligne + total_depenses_fonctionnement_ligne + total_depenses_equipement_ligne + total_depenses_mission_ligne + total_depenses_salaire_ligne + total_depenses_non_ventile_ligne
    if (@ligne.sous_contrat.sous_contrat_notification)
      @total_a_ouvrir = @ligne.sous_contrat.sous_contrat_notification.ma_total - @ligne.sous_contrat.sous_contrat_notification.ma_frais_gestion_mutualises - @ligne.sous_contrat.sous_contrat_notification.ma_frais_gestion_mutualises_local
    else
      @total_a_ouvrir = @ligne.contrat.notification.ma_total - @ligne.contrat.notification.ma_frais_gestion_mutualises - @ligne.contrat.notification.ma_frais_gestion_mutualises_local
    end
    @reste_a_ouvrir = @total_a_ouvrir - @total_versements_ligne
    @reste_a_depenser = @total_a_ouvrir - total_depenses_ligne
  end

  def setup_versements_filter_cookies
    if !params['filter'].nil?
      @filter = params['filter']
      cookies[:versements_filter] = @filter
    else
      if !cookies[:versements_filter].nil?
        @filter = cookies[:versements_filter]
      else
        @filter = 'all'
      end
    end

    case @filter
        when "all"            then @condition = "1 = 1"
        when "fonctionnement" then @condition = "ventilation = 'Fonctionnement'"
        when "equipement"     then @condition = "ventilation = 'Equipement'"
        when "mission"        then @condition = "ventilation = 'Mission'"
        when "salaire"        then @condition = "ventilation = 'Salaire'"
        when "non_ventile"    then @condition = "ventilation = 'Non ventilé'"
    end
  end

  def setup_versements_dates_cookies
    @ligne = Ligne.find(params[:ligne_id])
    if !params['date_start'].nil?
      cookies['date_start_'+@ligne.id.to_s] = params['date_start'].to_s
      cookies['date_end_'+@ligne.id.to_s] = params['date_end'].to_s
      @current_date_start = params['date_start'].to_s
      @current_date_end   = params['date_end'].to_s
    else
      if !cookies['date_start_'+@ligne.id.to_s].nil?
        @current_date_start = cookies['date_start_'+@ligne.id.to_s].to_s
        @current_date_end   = cookies['date_end_'+@ligne.id.to_s].to_s
      else
        @current_date_start = @ligne.date_debut.to_s
        @current_date_end   = @ligne.date_fin_selection.to_s
      end
    end
    @condition += " AND (( date_effet >= '"+@current_date_start+"') && ( date_effet <= '"+@current_date_end+"'))"

    @date_start = @ligne.date_debut
    @date_end   = @ligne.date_fin_selection
    @total_day  = @date_end - @date_start

    if @current_date_start.to_date == @date_start && @current_date_end.to_date == @date_end
      @all_selected = true
    else
      @all_selected = false
    end
  end


  def setup_versements_totals(versements)
    @display_subtotals = (@items_per_page.to_i < versements.length)
    @colspan_totals = 5

    @total_versements = versements.inject(0) { |s,v| s += v.montant }
    @subtotal_versements = 0 # computed in the view for performance
  end

end
