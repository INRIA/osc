#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class LignesController < ApplicationController

  before_filter :compute_rights_in_session, :only => [:index]
  before_filter :set_lignes_consultables, :only => [:index, :search, :new, :create, :show, :search_in_create, :my_last_search]
  before_filter :set_lignes_editables, :only =>  [:index, :search, :new, :create, :show, :search_in_create, :my_last_search]

  before_filter :set_contrats_consultables, :only => [:new, :create, :search_in_create, :my_last_search]
  before_filter :set_contrats_editables, :only =>  [:new, :create, :search_in_create, :my_last_search]
  before_filter :set_contrats_budget_editables, :only =>  [:new, :create, :search_in_create, :my_last_search]
  before_filter :set_mes_equipes, :only =>[:index, :search, :my_last_search]

  before_filter :is_my_ligne_research_in_session?, :except =>[:index,:search]
  before_filter :set_my_ligne_research_in_session, :only => [:index, :search]

  before_filter :before_bilan, :only => :bilan
  before_filter :before_affichage_ligne, :except => [:index, :search, :new, :create, :search_in_create, :toggle_show_justification_data_preferences, :my_last_search]

  def search
    @nom = (params[:nom].blank? ? "Nom" : params[:nom])
    @projet = (params[:projet].blank? ? "Equipe" : params[:projet])
    cookies[:nom_ligne] = @nom
    cookies[:projet_ligne] = @projet
    cookies[:filtre_projet] = params[:filtre_projet]

    # criteres de recherche en session
    my_criteria = Hash.new
    my_criteria[:nom_ligne] = @nom
    my_criteria[:projet] = @projet
    my_criteria[:selection_ligne] = @selection = 'default' unless params[:def] != 'default'
    my_criteria[:selection_ligne] = @selection = 'desactivees' unless params[:desactivees] != 'desactivees'
    my_criteria[:selection_ligne] = @selection = 'clos' unless params[:clos] != 'clos'
    my_criteria[:selection_ligne] = @selection = 'tous' unless params[:tous] != 'tous'
    my_criteria[:filtre_projet] = params[:filtre_projet]
    set_my_ligne_research_in_session(my_criteria)

    my_private_search(@nom,@projet,@selection,params)

    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html  'list', :partial => 'list'
          if @count < 2
            page.replace_html 'ajax_result', @count.to_s+" ligne trouvée"
          else
            page.replace_html 'ajax_result', @count.to_s+" lignes trouvées"
          end
        end
      }
    end
  end

  def my_last_search
    my_search_criteria = my_ligne_research_in_session
    mes_projets_nom_query = ["SELECT p.nom from projets p where p.id in (?) ORDER BY p.nom",@ids_mes_equipes]
    @mes_equipes_nom = Projet.find_by_sql(mes_projets_nom_query).collect{|d| d.nom}

    @nom = my_search_criteria[:nom_ligne]
    @projet = my_search_criteria[:projet]
    @selection = (my_search_criteria[:selection_ligne].blank? ? "default" : my_search_criteria[:selection_ligne])
    params[:filtre_projet] = my_search_criteria[:filtre_projet]
    if params[:filtre_projet]== 'filtre_projet_active'
      @filtre_mes_projets = true
    end
        
    my_private_search(@nom,@projet, @selection, params)
    my_private_stats

    render :action => "index"
  end

  def toggle_show_justification_data_preferences
    if cookies[:show_justification_data] == 'no'
      value = 'yes'
    else
      value = 'no'
    end
    cookies[:show_justification_data] = value
    render :text => "cookie updated to " + value
  end

  # GET /lignes
  def index
    mes_projets_nom_query = ["SELECT p.nom from projets p where p.id in (?) ORDER BY p.nom",@ids_mes_equipes]
    @mes_equipes_nom = Projet.find_by_sql(mes_projets_nom_query).collect{|d| d.nom}
    
    if cookies[:nom_ligne]
      @nom = cookies[:nom_ligne]
    else
      @nom = 'Nom'
    end
    if cookies[:filtre_projet] and cookies[:filtre_projet] == 'filtre_projet_active'
      @filtre_mes_projets = true
      params[:filtre_projet] = cookies[:filtre_projet]
    else
      @filtre_mes_projets = false
    end
    if cookies[:projet_ligne]
      @projet = cookies[:projet_ligne]
    else
      @projet = 'Equipe'
    end
    @selection = "default"

    my_private_search(@nom,@projet,@selection,params)
    my_private_stats

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lignes }
    end
  end


  def bilan
    @ligne = Ligne.find(params[:id])
    if @current_date_start.to_date == @date_start && @current_date_end.to_date == @date_end
      @all_selected = true
    else
      @all_selected = false
    end
    respond_to do |format|
      format.html {
        if !@ligne.contrat.is_consultable? current_user
            flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la ligne "+@ligne.nom+"."
            redirect_to lignes_path
        end
      }
      
   
      format.js {
        if @detail.blank? ||  @detail == "0" || @detail == "2"
          if @ligne.contrat_dotation
            render :partial => 'bilan_du_commun'
          else
            render :partial => 'bilan'
          end
        else
          if @ligne.contrat_dotation
            render :partial => 'bilan_detail_du_commun'
          else
           render :partial => 'bilan_detail'
          end
        end
      }  
      format.csv { render :text => export_csv } 
    end
  end


  # GET /lignes/1
  def show
    @ligne = Ligne.find(params[:id])
    @contrat = @ligne.contrat
    @last_depense_communs = DepenseCommun.find(:all, :conditions => [ "ligne_id = ?", @ligne.id], :order => "updated_at DESC", :limit => 50)
    @last_depense_fonctionnements = DepenseFonctionnement.find(:all, :conditions => [ "ligne_id = ?", @ligne.id], :order => "updated_at DESC", :limit => 50)
    @last_depense_equipements = DepenseEquipement.find(:all, :conditions => [ "ligne_id = ?", @ligne.id], :order => "updated_at DESC", :limit => 50)
    @last_depense_missions = DepenseMission.find(:all, :conditions => [ "ligne_id = ?", @ligne.id], :order => "updated_at DESC", :limit => 50)
    @last_depense_salaires = DepenseSalaire.find(:all, :conditions => [ "ligne_id = ?", @ligne.id], :order => "updated_at DESC", :limit => 50)
    @last_depense_non_ventilees = DepenseNonVentilee.find(:all, :conditions => [ "ligne_id = ?", @ligne.id], :order => "updated_at DESC", :limit => 50)
    @last_versements = Versement.find(:all, :conditions => [ "ligne_id = ?", @ligne.id], :order => "updated_at DESC", :limit => 50)

    @lasts = Array.new
    for item in @last_depense_communs
      @lasts << {   :type => "Com",
                    :soldee => item.commande_solde,
                    :id => item.id,
                    :date => item.date_commande,
                    :intitule => item.intitule,
                    :montant => item.montant,
                    :created_at => item.created_at,
                    :updated_at => item.updated_at,
                    :created_by => item.created_by,
                    :updated_by => item.updated_by }
    end
    for item in @last_depense_fonctionnements
      @lasts << {   :type => "Fonct",
                    :soldee => item.commande_solde,
                    :id => item.id,
                    :date => item.date_commande,
                    :intitule => item.intitule,
                    :montant => item.montant,
                    :created_at => item.created_at,
                    :updated_at => item.updated_at,
                    :created_by => item.created_by,
                    :updated_by => item.updated_by }
    end

    for item in @last_depense_equipements
      @lasts << {   :type => "Equipement",
                    :soldee => item.commande_solde,
                    :id => item.id,
                    :date => item.date_commande,
                    :intitule => item.intitule,
                    :montant => item.montant,
                    :created_at => item.created_at,
                    :updated_at => item.updated_at,
                    :created_by => item.created_by,
                    :updated_by => item.updated_by }
    end

    for item in @last_depense_non_ventilees
      @lasts << {   :type => "NonVentilee",
                    :soldee => item.commande_solde,
                    :id => item.id,
                    :date => item.date_commande,
                    :intitule => item.intitule,
                    :montant => item.montant,
                    :created_at => item.created_at,
                    :updated_at => item.updated_at,
                    :created_by => item.created_by,
                    :updated_by => item.updated_by }
    end

    for item in @last_depense_missions
         @lasts << { :type => "Mission",
                     :soldee => item.commande_solde,
                     :id => item.id,
                     :date_depart => item.date_depart,
                     :date_retour => item.date_retour,
                     :agent => item.agent,
                     :montant => item.montant,
                     :created_at => item.created_at,
                     :updated_at => item.updated_at,
                     :created_by => item.created_by,
                     :updated_by => item.updated_by }
    end

    for item in @last_depense_salaires
         @lasts << { :type => "Salaire",
                     :soldee => item.commande_solde,
                     :id => item.id,
                     :date_debut => item.date_debut,
                     :date_fin => item.date_fin,
                     :statut => item.statut,
                     :agent => item.nom_agent,
                     :montant => item.montant,
                     :created_at => item.created_at,
                     :updated_at => item.updated_at,
                     :created_by => item.created_by,
                     :updated_by => item.updated_by }
    end

    for item in @last_versements
         @lasts << { :type => "Versement",
                     :id => item.id,
                     :date_effet => item.date_effet,
                     :ventilation => item.ventilation,
                     :origine => item.origine,
                     :montant => item.montant,
                     :created_at => item.created_at,
                     :updated_at => item.updated_at,
                     :created_by => item.created_by,
                     :updated_by => item.updated_by }
    end

    @lasts << { :type => "Ligne",
                :created_at => @ligne.created_at,
                :updated_at => @ligne.updated_at,
                :created_by => @ligne.created_by,
                :updated_by => @ligne.updated_by }

    @lasts = @lasts.sort_by { |a| a[:updated_at] }.reverse


    users_with_role =  User.find_with_role(@contrat.id)
    # Utilisateurs ayant un droit de consultation sur le contrat courant
    @consultation_users = users_with_role[:consultation]
    # Utilisateurs ayant un droit de modification sur le contrat courant
    @modification_users = users_with_role[:modification]
    # Utilisateurs ayant un droit de modification uniquement sur le budget du contrat courant
    @modification_budget_users = users_with_role[:modification_budget]
    @admin_contrat_users =  users_with_role[:admin_contrat]

    groups_with_role =  Group.find_with_role(@contrat.id)
    # Groupes ayant un droit de consultation sur le contrat courant
    @consultation_groups = groups_with_role[:consultation]
    # Groupes ayant un droit de modification sur le contrat courant
    @modification_groups = groups_with_role[:modification]
     # Groupes ayant un droit de modification uniquement sur le budget du contrat courant
    @modification_budget_groups = groups_with_role[:modification_budget]
        @admin_contrat_groups =  groups_with_role[:admin_contrat]

    respond_to do |format|
      format.html {
        if !@ligne.contrat.is_consultable? current_user
            flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la ligne "+@ligne.nom+"."
            redirect_to lignes_path
        end
      }
    end
  end

  def ask_desactivate
    @ligne = Ligne.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  def activate
    @ligne = Ligne.find(params[:id])
    @ligne.activation
    respond_to do |format|
      format.html { redirect_to(@ligne) }
    end
  end
  
  def desactivate
    @ligne = Ligne.find(params[:id])
    @ligne.desactivation
    respond_to do |format|
      format.html { redirect_to(@ligne) }
    end
  end
  
  # GET /lignes/new
  def new
    @ligne = Ligne.new
    sql_query = "SELECT sous_contrats.* from sous_contrats 
                 inner join contrats on contrats.id = sous_contrats.contrat_id
                 inner join notifications on notifications.contrat_id = contrats.id
                 left outer join lignes on lignes.sous_contrat_id = sous_contrats.id 
                 where contrats.etat not in ('refus','cloture')
                 AND lignes.sous_contrat_id is null
                 AND notifications.id is not null 
                 AND contrats.id in (?) 
                 order by contrats.acronyme"
    @sous_contrats = SousContrat.find_by_sql([sql_query,@ids_editables])             
    #@sous_contrats = SousContrat.find(:all, :include => [:contrat,:ligne],
    #      :conditions => [" contrats.etat not in ('refus','cloture') AND contrats.id in (?) and", @ids_editables],
    #      :order => "contrats.acronyme")
  end

  def search_in_create
    sql_query = "SELECT sous_contrats.* from sous_contrats 
                 inner join contrats on contrats.id = sous_contrats.contrat_id
                 inner join notifications on notifications.contrat_id = contrats.id
                 left outer join lignes on lignes.sous_contrat_id = sous_contrats.id 
                 where contrats.etat not in ('refus','cloture')
                 AND lignes.sous_contrat_id is null
                 AND notifications.id is not null 
                 AND contrats.id in (?) 
                 AND (contrats.acronyme like ? OR contrats.num_contrat_etab like ?)
                 order by contrats.acronyme"
    @sous_contrats = SousContrat.find_by_sql([sql_query,@ids_editables,'%'+params[:query]+'%','%'+params[:query]+'%'])     
    
    render :partial => 'list_for_new.html.erb'
  end

  # POST /lignes
  def create
    @ligne = Ligne.new(params[:ligne])
    @sous_contrats = SousContrat.find(:all, :include => [:contrat],
          :conditions => ["contrats.id in (?)", @ids_editables],
          :order => "contrats.acronyme")
    unless @ligne.sous_contrat.contrat.num_contrat_etab.blank?
        @ligne.nom =  @ligne.sous_contrat.contrat.acronyme+"-"+@ligne.sous_contrat.contrat.num_contrat_etab+" - "+@ligne.sous_contrat.entite.nom
    else
        @ligne.nom =  @ligne.sous_contrat.contrat.acronyme+" - "+@ligne.sous_contrat.entite.nom
    end
    respond_to do |format|
      if @ligne.save
        flash[:notice] = 'La ligne à bien été créée.'
        format.html { redirect_to(@ligne) }
      else
        format.html { render :action => "new" }
      end
    end
  end



  def ask_delete
    @ligne = Ligne.find(params[:id])
    respond_to do |format|
      format.html
    end
  end


  # DELETE /lignes/1
  def destroy
    @ligne = Ligne.find(params[:id])
    @ligne.destroy

    respond_to do |format|
      format.html { redirect_to(lignes_url) }
    end
  end

  def before_affichage_ligne
    @ligne = Ligne.find(params[:id])
    setup_type_montant(@ligne.contrat.come_from_inria?)

#    if ((@type_bilan == 'sommes_engagees')&& (@type_montant == 'htr' ))
#      @type_bilan = 'sommes_engagees_htr'
#    elsif ((@type_bilan == 'factures')&& (@type_montant == 'htr' ))
#      @type_bilan = 'factures_htr'
#    end
    if(!@type_bilan)
      @type_bilan = "sommes_engagees"
    end
    
    #calcul des versements et dépenses totaux pour une ligne:
    @total_versements_equipement = @ligne.versements.find(:all, :conditions => { :ventilation => "Equipement" }).sum{ |d| d.montant }
    @total_versements_fonctionnement = @ligne.versements.find(:all, :conditions => { :ventilation => "Fonctionnement" }).sum{ |d| d.montant }
    @total_versements_mission = @ligne.versements.find(:all, :conditions => { :ventilation => "Mission" }).sum{ |d| d.montant }
    @total_versements_non_ventile = @ligne.versements.find(:all, :conditions => { :ventilation => "Non Ventilé" }).sum{ |d| d.montant }
    @total_versements_salaire = @ligne.versements.find(:all, :conditions => { :ventilation => "Salaire" }).sum{ |d| d.montant }
    @total_versements_fem = @total_versements_equipement + @total_versements_fonctionnement + @total_versements_mission
    @total_versements_ligne = @ligne.versements.find(:all).sum{ |d| d.montant }
  
    if @filter_distinct
      @total_depenses_commun_distinct_ligne = @ligne.depense_communs.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01',@type_bilan, @type_montant)  }
      @total_depenses_equipement_distinct_ligne = @ligne.depense_equipements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
      @total_depenses_fonctionnement_distinct_ligne = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
      @total_depenses_mission_distinct_ligne = @ligne.depense_missions.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
      @total_depenses_salaire_distinct_ligne = @ligne.depense_salaires.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
      @total_depenses_non_ventile_distinct_ligne = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
      @total_depense_fem_distinct = @total_depenses_equipement_distinct_ligne + @total_depenses_fonctionnement_distinct_ligne + @total_depenses_mission_distinct_ligne
      @total_depenses_distinct_ligne = @total_depenses_commun_distinct_ligne + @total_depenses_fonctionnement_distinct_ligne + @total_depenses_equipement_distinct_ligne + @total_depenses_mission_distinct_ligne + @total_depenses_salaire_distinct_ligne + @total_depenses_non_ventile_distinct_ligne
      
      @total_depenses_commun_non_distinct_ligne = @ligne.depense_communs.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01',@type_bilan, @type_montant)  }
      @total_depenses_equipement_non_distinct_ligne = @ligne.depense_equipements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
      @total_depenses_fonctionnement_non_distinct_ligne = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
      @total_depenses_mission_non_distinct_ligne = @ligne.depense_missions.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
      @total_depenses_salaire_non_distinct_ligne = @ligne.depense_salaires.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
      @total_depenses_non_ventile_non_distinct_ligne = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
      @total_depense_fem_non_distinct = @total_depenses_equipement_non_distinct_ligne + @total_depenses_fonctionnement_non_distinct_ligne + @total_depenses_mission_non_distinct_ligne
      @total_depenses_non_distinct_ligne = @total_depenses_commun_non_distinct_ligne + @total_depenses_fonctionnement_non_distinct_ligne + @total_depenses_equipement_non_distinct_ligne + @total_depenses_mission_non_distinct_ligne + @total_depenses_salaire_non_distinct_ligne + @total_depenses_non_ventile_non_distinct_ligne
    end
    
    @total_depenses_commun_ligne = @ligne.depense_communs.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',@type_bilan, @type_montant)  }
    @total_depenses_equipement_ligne = @ligne.depense_equipements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
    @total_depenses_fonctionnement_ligne = @ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
    @total_depenses_mission_ligne = @ligne.depense_missions.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
    @total_depenses_salaire_ligne = @ligne.depense_salaires.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }
    @total_depenses_non_ventile_ligne = @ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', @type_bilan, @type_montant) }   
    @total_depense_fem = @total_depenses_equipement_ligne + @total_depenses_fonctionnement_ligne + @total_depenses_mission_ligne
    @total_depenses_ligne = @total_depenses_commun_ligne + @total_depenses_fonctionnement_ligne + @total_depenses_equipement_ligne + @total_depenses_mission_ligne + @total_depenses_salaire_ligne + @total_depenses_non_ventile_ligne

    @bilan_total_equipement = @total_versements_equipement - @total_depenses_equipement_ligne
    @bilan_total_fonctionnement = @total_versements_fonctionnement - @total_depenses_fonctionnement_ligne
    @bilan_total_mission = @total_versements_mission - @total_depenses_mission_ligne
    @bilan_total_fem =  @total_versements_fem - @total_depense_fem
    @bilan_total_salaire =  @total_versements_salaire - @total_depenses_salaire_ligne
    @bilan_total_non_ventile = @total_versements_non_ventile - @total_depenses_non_ventile_ligne
    @bilan_total_ligne = @total_versements_ligne - @total_depenses_ligne

    if (@ligne.sous_contrat.sous_contrat_notification)
      @total_a_ouvrir = @ligne.sous_contrat.sous_contrat_notification.ma_total - @ligne.sous_contrat.sous_contrat_notification.ma_frais_gestion_mutualises - @ligne.sous_contrat.sous_contrat_notification.ma_frais_gestion_mutualises_local
      @total_a_ouvrir_equipement = @ligne.sous_contrat.sous_contrat_notification.ma_equipement
      @total_a_ouvrir_fonctionnement = @ligne.sous_contrat.sous_contrat_notification.ma_fonctionnement + @ligne.sous_contrat.sous_contrat_notification.ma_couts_indirects
      @total_a_ouvrir_mission = @ligne.sous_contrat.sous_contrat_notification.ma_mission
      @total_a_ouvrir_salaire = @ligne.sous_contrat.sous_contrat_notification.ma_salaire
      @total_a_ouvrir_non_ventile = @ligne.sous_contrat.sous_contrat_notification.ma_non_ventile
    else
      @total_a_ouvrir = @ligne.contrat.notification.ma_total - @ligne.contrat.notification.ma_frais_gestion_mutualises - @ligne.contrat.notification.ma_frais_gestion_mutualises_local
      @total_a_ouvrir_equipement = @ligne.contrat.notification.ma_equipement
      @total_a_ouvrir_fonctionnement = @ligne.contrat.notification.ma_fonctionnement + @ligne.contrat.notification.ma_couts_indirects
      @total_a_ouvrir_mission = @ligne.contrat.notification.ma_mission
      @total_a_ouvrir_salaire = @ligne.contrat.notification.ma_salaire
      @total_a_ouvrir_non_ventile = @ligne.contrat.notification.ma_non_ventile
    end
    @reste_a_ouvrir = @total_a_ouvrir - @total_versements_ligne
    @reste_a_ouvrir_equipement = @total_a_ouvrir_equipement - @total_versements_equipement
    @reste_a_ouvrir_fonctionnement = @total_a_ouvrir_fonctionnement - @total_versements_fonctionnement
    @reste_a_ouvrir_mission = @total_a_ouvrir_mission - @total_versements_mission
    @reste_a_ouvrir_salaire = @total_a_ouvrir_salaire - @total_versements_salaire
    @reste_a_ouvrir_non_ventile = @total_a_ouvrir_non_ventile - @total_versements_non_ventile
    
    if @type_bilan != "sommes_engagees"
      @total_depenses_commun_ligne_engagees = @ligne.depense_communs.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant)  }
      @total_depenses_equipement_ligne_engagees = @ligne.depense_equipements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', "sommes_engagees", @type_montant) }
      @total_depenses_fonctionnement_ligne_engagees = @ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', "sommes_engagees", @type_montant) }
      @total_depenses_mission_ligne_engagees = @ligne.depense_missions.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', "sommes_engagees", @type_montant) }
      @total_depenses_salaire_ligne_engagees = @ligne.depense_salaires.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', "sommes_engagees", @type_montant) }
      @total_depenses_non_ventile_ligne_engagees = @ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', "sommes_engagees", @type_montant) }   
      @total_depense_fem_engagees = @total_depenses_equipement_ligne_engagees + @total_depenses_fonctionnement_ligne_engagees + @total_depenses_mission_ligne_engagees
      @total_depenses_ligne_engagees = @total_depenses_commun_ligne_engagees + @total_depenses_fonctionnement_ligne_engagees + @total_depenses_equipement_ligne_engagees + @total_depenses_mission_ligne_engagees + @total_depenses_salaire_ligne_engagees + @total_depenses_non_ventile_ligne_engagees

      @reste_a_depenser = @total_a_ouvrir - @total_depenses_ligne_engagees
      @reste_a_depenser_equipement = @total_a_ouvrir_equipement - @total_depenses_equipement_ligne_engagees
      @reste_a_depenser_fonctionnement = @total_a_ouvrir_fonctionnement - @total_depenses_fonctionnement_ligne_engagees
      @reste_a_depenser_mission = @total_a_ouvrir_mission - @total_depenses_mission_ligne_engagees
      @reste_a_depenser_salaire = @total_a_ouvrir_salaire - @total_depenses_salaire_ligne_engagees
      @reste_a_depenser_non_ventile = @total_a_ouvrir_non_ventile - @total_depenses_non_ventile_ligne_engagees
 
    else
      @reste_a_depenser = @total_a_ouvrir - @total_depenses_ligne
      @reste_a_depenser_equipement = @total_a_ouvrir_equipement - @total_depenses_equipement_ligne
      @reste_a_depenser_fonctionnement = @total_a_ouvrir_fonctionnement - @total_depenses_fonctionnement_ligne
      @reste_a_depenser_mission = @total_a_ouvrir_mission - @total_depenses_mission_ligne
      @reste_a_depenser_salaire = @total_a_ouvrir_salaire - @total_depenses_salaire_ligne
      @reste_a_depenser_non_ventile = @total_a_ouvrir_non_ventile - @total_depenses_non_ventile_ligne
    end
  end


  def before_bilan
    @ligne = Ligne.find(params[:id])
    inria = @ligne.contrat.come_from_inria?
    setup_type_montant(inria)
    

    if !params['periode_number'].nil?
      @periode_number = params['periode_number']
    end
    if !params['periode_id'].nil?
      @periode = EcheancierPeriode.find(params['periode_id'])
    end

    if !params['type_bilan'].nil?
      cookies[:bilan] = params['type_bilan']
      @type_bilan = params['type_bilan']
    else
      if !cookies[:bilan].nil?
        @type_bilan = cookies[:bilan]
      else
        @type_bilan = 'sommes_engagees'
        cookies[:bilan] = @type_bilan
      end
    end
    
    if !params['distinct'].nil?
      cookies[:distinct] = params['distinct']
      @distinct = params['distinct']
    else
      if !cookies[:distinct].nil?
        @distinct = cookies[:distinct]
      else
        @distinct = 'none'
        cookies[:distinct] = @distinct
      end
    end    
    
    if !inria and cookies[:distinct]=='manuelle'
      @distinct = 'none'
      cookies[:distinct] = @distinct
    end
    
    if !params[:with_detail].blank?
      cookies[:detail] = params[:with_detail]
      @detail = params[:with_detail]
    else
      if !cookies[:detail].nil?
        @detail = cookies[:detail]
      else
        @detail = '0'
        cookies[:detail] = @detail
      end
    end

    if @distinct=='justifiable'
      @filter_distinct = "eligible = 1"    
      @filter_non_distinct = "eligible = 0"
    elsif @distinct=='manuelle'
      @filter_distinct = "verrou = 'Aucun'"
      @filter_non_distinct = "verrou != 'Aucun'"
    end
      
    date_debut = Date.new(@ligne.date_debut.year,01,01)
    date_fin   = Date.new(@ligne.date_fin_selection.year,12,31)

    if !params['date_start'].nil?
      cookies['date_start_'+@ligne.id.to_s] = params['date_start'].to_s
      cookies['date_end_'+@ligne.id.to_s]   = params['date_end'].to_s
      @current_date_start = params['date_start'].to_s
      @current_date_end   = params['date_end'].to_s

    else
      if !cookies['date_start_'+@ligne.id.to_s].nil?
        @current_date_start = cookies['date_start_'+@ligne.id.to_s].to_s
        @current_date_end   = cookies['date_end_'+@ligne.id.to_s].to_s
      else
        @current_date_start = date_debut.to_s
        @current_date_end   = @ligne.date_fin_selection.to_s
      end
    end

    @date_start = date_debut
    @date_end   = date_fin
    @total_day  = @date_end - @date_start

  if @detail.blank? || @detail == '0' ||  @detail == "2"
    ### Période définie

    current_date_start_minus_one = @current_date_start.to_date-1
    current_date_end_plus_one = @current_date_end.to_date+1
    #Avant
    if @filter_distinct
      @somme_depense_commun_distinct_pre         = @ligne.depense_communs.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @somme_depense_fonctionnement_distinct_pre = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @somme_depense_equipement_distinct_pre     = @ligne.depense_equipements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @somme_depense_mission_distinct_pre        = @ligne.depense_missions.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @somme_depense_salaire_distinct_pre        = @ligne.depense_salaires.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @somme_depense_non_ventilee_distinct_pre   = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @sous_total_depense_fem_distinct_pre       = @somme_depense_fonctionnement_distinct_pre + @somme_depense_equipement_distinct_pre + @somme_depense_mission_distinct_pre
      @total_depenses_distinct_pre = @somme_depense_commun_distinct_pre + @somme_depense_fonctionnement_distinct_pre + @somme_depense_equipement_distinct_pre + @somme_depense_mission_distinct_pre + @somme_depense_salaire_distinct_pre + @somme_depense_non_ventilee_distinct_pre      
    
      @somme_depense_commun_non_distinct_pre         = @ligne.depense_communs.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @somme_depense_fonctionnement_non_distinct_pre = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @somme_depense_equipement_non_distinct_pre     = @ligne.depense_equipements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @somme_depense_mission_non_distinct_pre        = @ligne.depense_missions.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @somme_depense_salaire_non_distinct_pre        = @ligne.depense_salaires.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @somme_depense_non_ventilee_non_distinct_pre   = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
      @sous_total_depense_fem_non_distinct_pre       = @somme_depense_fonctionnement_non_distinct_pre + @somme_depense_equipement_non_distinct_pre + @somme_depense_mission_non_distinct_pre
      @total_depenses_non_distinct_pre = @somme_depense_commun_non_distinct_pre + @somme_depense_fonctionnement_non_distinct_pre + @somme_depense_equipement_non_distinct_pre + @somme_depense_mission_non_distinct_pre + @somme_depense_salaire_non_distinct_pre + @somme_depense_non_ventilee_non_distinct_pre      
   
    end
    @somme_depense_commun_pre         = @ligne.depense_communs.find(:all).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
    @somme_depense_fonctionnement_pre = @ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
    @somme_depense_equipement_pre     = @ligne.depense_equipements.find(:all).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
    @somme_depense_mission_pre        = @ligne.depense_missions.find(:all).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
    @somme_depense_salaire_pre        = @ligne.depense_salaires.find(:all).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
    @somme_depense_non_ventilee_pre   = @ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant(@date_start.to_s, current_date_start_minus_one.to_s, @type_bilan, @type_montant) }
    @sous_total_depense_fem_pre       = @somme_depense_fonctionnement_pre + @somme_depense_equipement_pre + @somme_depense_mission_pre
    @total_depenses_pre = @somme_depense_commun_pre + @somme_depense_fonctionnement_pre + @somme_depense_equipement_pre + @somme_depense_mission_pre + @somme_depense_salaire_pre + @somme_depense_non_ventilee_pre

    #Pendant
    if @filter_distinct
      @somme_depense_commun_distinct         = @ligne.depense_communs.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @somme_depense_fonctionnement_distinct = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @somme_depense_equipement_distinct     = @ligne.depense_equipements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @somme_depense_mission_distinct        = @ligne.depense_missions.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @somme_depense_salaire_distinct        = @ligne.depense_salaires.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @somme_depense_non_ventilee_distinct   = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @sous_total_depense_fem_distinct       = @somme_depense_fonctionnement_distinct + @somme_depense_equipement_distinct + @somme_depense_mission_distinct
      @total_depenses_distinct = @somme_depense_commun_distinct + @somme_depense_fonctionnement_distinct + @somme_depense_equipement_distinct + @somme_depense_mission_distinct + @somme_depense_salaire_distinct + @somme_depense_non_ventilee_distinct      
    
      @somme_depense_commun_non_distinct         = @ligne.depense_communs.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @somme_depense_fonctionnement_non_distinct = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @somme_depense_equipement_non_distinct     = @ligne.depense_equipements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @somme_depense_mission_non_distinct        = @ligne.depense_missions.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @somme_depense_salaire_non_distinct        = @ligne.depense_salaires.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @somme_depense_non_ventilee_non_distinct   = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
      @sous_total_depense_fem_non_distinct       = @somme_depense_fonctionnement_non_distinct + @somme_depense_equipement_non_distinct + @somme_depense_mission_non_distinct
      @total_depenses_non_distinct = @somme_depense_commun_non_distinct + @somme_depense_fonctionnement_non_distinct + @somme_depense_equipement_non_distinct + @somme_depense_mission_non_distinct + @somme_depense_salaire_non_distinct + @somme_depense_non_ventilee_non_distinct      
   
    end
    @somme_depense_commun         = @ligne.depense_communs.find(:all).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
    @somme_depense_fonctionnement = @ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
    @somme_depense_equipement     = @ligne.depense_equipements.find(:all).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
    @somme_depense_mission        = @ligne.depense_missions.find(:all).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
    @somme_depense_salaire        = @ligne.depense_salaires.find(:all).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
    @somme_depense_non_ventilee   = @ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan, @type_montant) }
    @sous_total_depense_fem       = @somme_depense_fonctionnement + @somme_depense_equipement + @somme_depense_mission
    @total_depenses = @somme_depense_commun + @somme_depense_fonctionnement + @somme_depense_equipement + @somme_depense_mission + @somme_depense_salaire + @somme_depense_non_ventilee

    #Après
    if @filter_distinct
      @somme_depense_commun_distinct_post          = @ligne.depense_communs.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @somme_depense_fonctionnement_distinct_post = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @somme_depense_equipement_distinct_post     = @ligne.depense_equipements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @somme_depense_mission_distinct_post        = @ligne.depense_missions.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @somme_depense_salaire_distinct_post        = @ligne.depense_salaires.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @somme_depense_non_ventilee_distinct_post   = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @sous_total_depense_fem_distinct_post       = @somme_depense_fonctionnement_distinct_post + @somme_depense_equipement_distinct_post + @somme_depense_mission_distinct_post
      @total_depenses_distinct_post = @somme_depense_commun_distinct_post + @somme_depense_fonctionnement_distinct_post + @somme_depense_equipement_distinct_post + @somme_depense_mission_distinct_post + @somme_depense_salaire_distinct_post + @somme_depense_non_ventilee_distinct_post

      @somme_depense_commun_non_distinct_post          = @ligne.depense_communs.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @somme_depense_fonctionnement_non_distinct_post = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @somme_depense_equipement_non_distinct_post     = @ligne.depense_equipements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @somme_depense_mission_non_distinct_post        = @ligne.depense_missions.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @somme_depense_salaire_non_distinct_post        = @ligne.depense_salaires.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @somme_depense_non_ventilee_non_distinct_post   = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
      @sous_total_depense_fem_non_distinct_post       = @somme_depense_fonctionnement_non_distinct_post + @somme_depense_equipement_non_distinct_post + @somme_depense_mission_non_distinct_post
      @total_depenses_non_distinct_post = @somme_depense_commun_non_distinct_post + @somme_depense_fonctionnement_non_distinct_post + @somme_depense_equipement_non_distinct_post + @somme_depense_mission_non_distinct_post + @somme_depense_salaire_non_distinct_post + @somme_depense_non_ventilee_non_distinct_post
   
    end
    @somme_depense_commun_post          = @ligne.depense_communs.find(:all).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
    @somme_depense_fonctionnement_post = @ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
    @somme_depense_equipement_post     = @ligne.depense_equipements.find(:all).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
    @somme_depense_mission_post        = @ligne.depense_missions.find(:all).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
    @somme_depense_salaire_post        = @ligne.depense_salaires.find(:all).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
    @somme_depense_non_ventilee_post   = @ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant(current_date_end_plus_one.to_s, @date_end.to_s, @type_bilan, @type_montant) }
    @sous_total_depense_fem_post       = @somme_depense_fonctionnement_post + @somme_depense_equipement_post + @somme_depense_mission_post
    @total_depenses_post = @somme_depense_commun_post + @somme_depense_fonctionnement_post + @somme_depense_equipement_post + @somme_depense_mission_post + @somme_depense_salaire_post + @somme_depense_non_ventilee_post

    #Versement
    #Avant
    @condition = "(( date_effet >= '"+@date_start.to_s+"') && ( date_effet < '"+@current_date_start+"'))"
    @somme_versements_commun_pre                                            = 0 # les versements du commun se font dans le fonctionnement
    @somme_versements_fonctionnement_pre  = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Fonctionnement')").sum{ |d| d.montant }
    @somme_versements_equipement_pre      = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Equipement')").sum{ |d| d.montant }
    @somme_versements_mission_pre         = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Mission')").sum{ |d| d.montant }
    @somme_versements_salaire_pre         = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Salaire')").sum{ |d| d.montant }
    @somme_versements_non_ventile_pre     = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Non ventilé')").sum{ |d| d.montant }
    @sous_total_versement_fem_pre         = @somme_versements_fonctionnement_pre + @somme_versements_equipement_pre + @somme_versements_mission_pre
    @total_versements_pre = @somme_versements_commun_pre + @somme_versements_fonctionnement_pre + @somme_versements_equipement_pre + @somme_versements_mission_pre + @somme_versements_salaire_pre + @somme_versements_non_ventile_pre

    #Pendant
    @condition = "(( date_effet >= '"+@current_date_start+"') && ( date_effet <= '"+@current_date_end+"'))"
    @somme_versements_commun                                                = 0 # les versements du commun se font dans le fonctionnement
    @somme_versements_fonctionnement  = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Fonctionnement')").sum{ |d| d.montant }
    @somme_versements_equipement      = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Equipement')").sum{ |d| d.montant }
    @somme_versements_mission         = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Mission')").sum{ |d| d.montant }
    @somme_versements_salaire         = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Salaire')").sum{ |d| d.montant }
    @somme_versements_non_ventile     = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Non ventilé')").sum{ |d| d.montant }
    @sous_total_versement_fem              = @somme_versements_fonctionnement + @somme_versements_equipement + @somme_versements_mission
    @total_versements = @somme_versements_commun + @somme_versements_fonctionnement + @somme_versements_equipement + @somme_versements_mission + @somme_versements_salaire + @somme_versements_non_ventile
    #Après
    @condition = "(( date_effet >= '"+(@current_date_end.to_date + 1).to_s+"') && ( date_effet <= '2500-01-01'))"
    @somme_versements_commun_post                                           = 0 # les versements du commun se font dans le fonctionnement
    @somme_versements_fonctionnement_post  = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Fonctionnement')").sum{ |d| d.montant }
    @somme_versements_equipement_post      = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Equipement')").sum{ |d| d.montant }
    @somme_versements_mission_post         = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Mission')").sum{ |d| d.montant }
    @somme_versements_salaire_post         = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Salaire')").sum{ |d| d.montant }
    @somme_versements_non_ventile_post     = @ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Non ventilé')").sum{ |d| d.montant }
    @sous_total_versement_fem_post         = @somme_versements_fonctionnement_post + @somme_versements_equipement_post + @somme_versements_mission_post
    @total_versements_post = @somme_versements_commun_post + @somme_versements_fonctionnement_post + @somme_versements_equipement_post + @somme_versements_mission_post + @somme_versements_salaire_post + @somme_versements_non_ventile_post

    #Totaux
    #@total_commun_pre         = @somme_versements_commun_pre - @somme_depense_commun_pre
    @total_fonctionnement_pre = @somme_versements_fonctionnement_pre - @somme_depense_fonctionnement_pre
    @total_equipement_pre     = @somme_versements_equipement_pre - @somme_depense_equipement_pre
    @total_mission_pre        = @somme_versements_mission_pre - @somme_depense_mission_pre
    @total_salaire_pre        = @somme_versements_salaire_pre - @somme_depense_salaire_pre
    @total_non_ventilee_pre   = @somme_versements_non_ventile_pre - @somme_depense_non_ventilee_pre
    @sous_total_fem_pre       = @sous_total_versement_fem_pre - @sous_total_depense_fem_pre
    @total_pre                = @total_versements_pre - @total_depenses_pre

    #@total_commun         = @somme_versements_commun - @somme_depense_commun
    @total_fonctionnement = @somme_versements_fonctionnement - @somme_depense_fonctionnement
    @total_equipement     = @somme_versements_equipement - @somme_depense_equipement
    @total_mission        = @somme_versements_mission - @somme_depense_mission
    @total_salaire        = @somme_versements_salaire - @somme_depense_salaire
    @total_non_ventilee   = @somme_versements_non_ventile - @somme_depense_non_ventilee
    @sous_total_fem       = @sous_total_versement_fem - @sous_total_depense_fem
    @total                = @total_versements - @total_depenses

    #@total_commun_post        = @somme_versements_commun_post - @somme_depense_commun_post
    @total_fonctionnement_post =  @somme_versements_fonctionnement_post - @somme_depense_fonctionnement_post
    @total_equipement_post     =  @somme_versements_equipement_post - @somme_depense_equipement_post
    @total_mission_post        =  @somme_versements_mission_post - @somme_depense_mission_post
    @total_salaire_post        =  @somme_versements_salaire_post - @somme_depense_salaire_post
    @total_non_ventilee_post   =  @somme_versements_non_ventile_post - @somme_depense_non_ventilee_post
    @sous_total_fem_post       =  @sous_total_versement_fem_post - @sous_total_depense_fem_post
    @total_post                =  @total_versements_post - @total_depenses_post

    @total_recettes_attendues_commun = 0
    @total_recettes_attendues_fonctionnement = 0
    @total_recettes_attendues_equipement = 0
    @total_recettes_attendues_mission = 0
    @total_recettes_attendues_non_ventile = 0
    @total_recettes_attendues_salaire = 0
    @total_recettes_attendues = 0

    if @detail == '2'
      @ligne.periodes.each do |period|
        @total_recettes_attendues_commun += period.depenses_fonctionnement
        @total_recettes_attendues_fonctionnement += period.depenses_fonctionnement
        @total_recettes_attendues_equipement += period.depenses_equipement
        @total_recettes_attendues_mission += period.depenses_missions
        @total_recettes_attendues_non_ventile += period.depenses_non_ventile
        @total_recettes_attendues_salaire += period.depenses_salaires
      end
    end

  else
    @start_year = @date_start.to_date.year
    @end_year = @date_end.to_date.year

    @total_commun = 0
    @total_fonctionnement = 0
    @total_equipement = 0
    @total_mission = 0
    @total_salaire = 0
    @total_non_ventilee = 0
    @sous_total_fem = 0
    @total = 0

    @total_recettes_attendues_commun = 0
    @total_recettes_attendues_fonctionnement = 0
    @total_recettes_attendues_equipement = 0
    @total_recettes_attendues_mission = 0
    @total_recettes_attendues_non_ventile = 0
    @total_recettes_attendues_salaire = 0
    @total_recettes_attendues = 0

    @somme_depense_commun_tab             = Array.new
    @somme_depense_fonctionnement_tab     = Array.new
    @somme_depense_equipement_tab         = Array.new
    @somme_depense_mission_tab            = Array.new
    @somme_depense_salaire_tab            = Array.new
    @somme_depense_non_ventilee_tab       = Array.new
    @sous_total_depense_fem_tab           = Array.new
    @total_depenses_tab                   = Array.new
    @somme_depense_commun_distinct_tab             = Array.new
    @somme_depense_fonctionnement_distinct_tab     = Array.new
    @somme_depense_equipement_distinct_tab         = Array.new
    @somme_depense_mission_distinct_tab            = Array.new
    @somme_depense_salaire_distinct_tab            = Array.new
    @somme_depense_non_ventilee_distinct_tab       = Array.new
    @sous_total_depense_fem_distinct_tab           = Array.new
    @total_depenses_distinct_tab                   = Array.new
    @somme_depense_commun_non_distinct_tab             = Array.new
    @somme_depense_fonctionnement_non_distinct_tab     = Array.new
    @somme_depense_equipement_non_distinct_tab         = Array.new
    @somme_depense_mission_non_distinct_tab            = Array.new
    @somme_depense_salaire_non_distinct_tab            = Array.new
    @somme_depense_non_ventilee_non_distinct_tab       = Array.new
    @sous_total_depense_fem_non_distinct_tab           = Array.new
    @total_depenses_non_distinct_tab                   = Array.new

    @somme_versements_commun_tab           = Array.new
    @somme_versements_fonctionnement_tab  = Array.new
    @somme_versements_equipement_tab      = Array.new
    @somme_versements_mission_tab         = Array.new
    @somme_versements_salaire_tab         = Array.new
    @somme_versements_non_ventile_tab     = Array.new
    @sous_total_versement_fem_tab         = Array.new
    @total_versements_tab                 = Array.new

    @total_fonctionnement_tab =  Array.new
    @total_equipement_tab     =  Array.new
    @total_mission_tab        =  Array.new
    @total_salaire_tab        =  Array.new
    @total_non_ventilee_tab   =  Array.new
    @sous_total_fem_tab       =  Array.new
    @total_tab                =  Array.new
    
    @recettes_attendues_fonctionnement_tab =  Array.new
    @recettes_attendues_equipement_tab     =  Array.new
    @recettes_attendues_mission_tab        =  Array.new
    @recettes_attendues_fem_tab            =  Array.new
    @recettes_attendues_non_ventile_tab    =  Array.new
    @recettes_attendues_salaire_tab        =  Array.new
    @recettes_attendues_tab                =  Array.new
    
    @reste_fonctionnement_tab =  Array.new
    @reste_equipement_tab     =  Array.new
    @reste_mission_tab        =  Array.new
    @reste_salaire_tab        =  Array.new
    @reste_non_ventilee_tab   =  Array.new
    @reste_fem_tab            =  Array.new
    @reste_tab                =  Array.new

    if @detail =='1'
      for year in @start_year..@end_year do
        date_start = Date.new(year,01,01)
        date_end = Date.new(year,12,31)
        if @filter_distinct
          @somme_depense_commun_distinct_tab[year]         = @ligne.depense_communs.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_fonctionnement_distinct_tab[year] = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_equipement_distinct_tab[year]     = @ligne.depense_equipements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_mission_distinct_tab[year]        = @ligne.depense_missions.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_salaire_distinct_tab[year]        = @ligne.depense_salaires.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_non_ventilee_distinct_tab[year]   = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @sous_total_depense_fem_distinct_tab[year]       = @somme_depense_fonctionnement_distinct_tab[year] + @somme_depense_equipement_distinct_tab[year] + @somme_depense_mission_distinct_tab[year]
          @total_depenses_distinct_tab[year] = @somme_depense_commun_distinct_tab[year] + @somme_depense_fonctionnement_distinct_tab[year] + @somme_depense_equipement_distinct_tab[year] + @somme_depense_mission_distinct_tab[year] + @somme_depense_salaire_distinct_tab[year] + @somme_depense_non_ventilee_distinct_tab[year]
        
          @somme_depense_commun_non_distinct_tab[year]         = @ligne.depense_communs.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_fonctionnement_non_distinct_tab[year] = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_equipement_non_distinct_tab[year]     = @ligne.depense_equipements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_mission_non_distinct_tab[year]        = @ligne.depense_missions.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_salaire_non_distinct_tab[year]        = @ligne.depense_salaires.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_non_ventilee_non_distinct_tab[year]   = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @sous_total_depense_fem_non_distinct_tab[year]       = @somme_depense_fonctionnement_non_distinct_tab[year] + @somme_depense_equipement_non_distinct_tab[year] + @somme_depense_mission_non_distinct_tab[year]
          @total_depenses_non_distinct_tab[year] = @somme_depense_commun_non_distinct_tab[year] + @somme_depense_fonctionnement_non_distinct_tab[year] + @somme_depense_equipement_non_distinct_tab[year] + @somme_depense_mission_non_distinct_tab[year] + @somme_depense_salaire_non_distinct_tab[year] + @somme_depense_non_ventilee_non_distinct_tab[year]
          
        end
        @somme_depense_commun_tab[year]         = @ligne.depense_communs.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @somme_depense_fonctionnement_tab[year] = @ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @somme_depense_equipement_tab[year]     = @ligne.depense_equipements.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @somme_depense_mission_tab[year]        = @ligne.depense_missions.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @somme_depense_salaire_tab[year]        = @ligne.depense_salaires.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @somme_depense_non_ventilee_tab[year]   = @ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @sous_total_depense_fem_tab[year]       = @somme_depense_fonctionnement_tab[year] + @somme_depense_equipement_tab[year] + @somme_depense_mission_tab[year]
        @total_depenses_tab[year] = @somme_depense_commun_tab[year] + @somme_depense_fonctionnement_tab[year] + @somme_depense_equipement_tab[year] + @somme_depense_mission_tab[year] + @somme_depense_salaire_tab[year] + @somme_depense_non_ventilee_tab[year]

        condition = "(( date_effet >= '"+date_start.to_s+"') && ( date_effet <= '"+date_end.to_s+"'))"
        @somme_versements_commun_tab[year]          = 0 # les versements du commun se font dans le fonctionnement
        @somme_versements_fonctionnement_tab[year]  = @ligne.versements.find(:all, :conditions => condition+" AND (ventilation = 'Fonctionnement')").sum{ |d| d.montant }
        @somme_versements_equipement_tab[year]      = @ligne.versements.find(:all, :conditions => condition+" AND (ventilation = 'Equipement')").sum{ |d| d.montant }
        @somme_versements_mission_tab[year]         = @ligne.versements.find(:all, :conditions => condition+" AND (ventilation = 'Mission')").sum{ |d| d.montant }
        @somme_versements_salaire_tab[year]         = @ligne.versements.find(:all, :conditions => condition+" AND (ventilation = 'Salaire')").sum{ |d| d.montant }
        @somme_versements_non_ventile_tab[year]     = @ligne.versements.find(:all, :conditions => condition+" AND (ventilation = 'Non ventilé')").sum{ |d| d.montant }
        @sous_total_versement_fem_tab[year]         =  @somme_versements_fonctionnement_tab[year] + @somme_versements_equipement_tab[year] + @somme_versements_mission_tab[year]
        @total_versements_tab[year] = @somme_versements_commun_tab[year] + @somme_versements_fonctionnement_tab[year] + @somme_versements_equipement_tab[year] + @somme_versements_mission_tab[year]  + @somme_versements_salaire_tab[year]  + @somme_versements_non_ventile_tab[year]

        @total_fonctionnement_tab[year] = @somme_versements_fonctionnement_tab[year] - @somme_depense_fonctionnement_tab[year]
        @total_equipement_tab[year]     = @somme_versements_equipement_tab[year] - @somme_depense_equipement_tab[year]
        @total_mission_tab[year]        = @somme_versements_mission_tab[year] - @somme_depense_mission_tab[year]
        @total_salaire_tab[year]        = @somme_versements_salaire_tab[year] - @somme_depense_salaire_tab[year]
        @total_non_ventilee_tab[year]   = @somme_versements_non_ventile_tab[year] - @somme_depense_non_ventilee_tab[year]
        @sous_total_fem_tab[year]       = @sous_total_versement_fem_tab[year] - @sous_total_depense_fem_tab[year]
        @total_tab[year]                = @total_versements_tab[year] - @total_depenses_tab[year]
      end
    elsif @detail =='3' and @ligne.has_periods?
      @ligne.periodes.each_with_index do |period, i|
        date_start = period.date_debut
        date_end = period.date_fin

        if @filter_distinct
          @somme_depense_commun_distinct_tab[i]         = @ligne.depense_communs.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_fonctionnement_distinct_tab[i] = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_equipement_distinct_tab[i]     = @ligne.depense_equipements.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_mission_distinct_tab[i]        = @ligne.depense_missions.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_salaire_distinct_tab[i]        = @ligne.depense_salaires.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_non_ventilee_distinct_tab[i]   = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @sous_total_depense_fem_distinct_tab[i]       = @somme_depense_fonctionnement_distinct_tab[i] + @somme_depense_equipement_distinct_tab[i] + @somme_depense_mission_distinct_tab[i]
          @total_depenses_distinct_tab[i] = @somme_depense_commun_distinct_tab[i] + @somme_depense_fonctionnement_distinct_tab[i] + @somme_depense_equipement_distinct_tab[i] + @somme_depense_mission_distinct_tab[i] + @somme_depense_salaire_distinct_tab[i] + @somme_depense_non_ventilee_distinct_tab[i]
        
          @somme_depense_commun_non_distinct_tab[i]         = @ligne.depense_communs.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_fonctionnement_non_distinct_tab[i] = @ligne.depense_fonctionnements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_equipement_non_distinct_tab[i]     = @ligne.depense_equipements.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_mission_non_distinct_tab[i]        = @ligne.depense_missions.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_salaire_non_distinct_tab[i]        = @ligne.depense_salaires.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @somme_depense_non_ventilee_non_distinct_tab[i]   = @ligne.depense_non_ventilees.find(:all,:conditions => @filter_non_distinct).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
          @sous_total_depense_fem_non_distinct_tab[i]       = @somme_depense_fonctionnement_non_distinct_tab[i] + @somme_depense_equipement_non_distinct_tab[i] + @somme_depense_mission_non_distinct_tab[i]
          @total_depenses_non_distinct_tab[i] = @somme_depense_commun_non_distinct_tab[i] + @somme_depense_fonctionnement_non_distinct_tab[i] + @somme_depense_equipement_non_distinct_tab[i] + @somme_depense_mission_non_distinct_tab[i] + @somme_depense_salaire_non_distinct_tab[i] + @somme_depense_non_ventilee_non_distinct_tab[i]
          
        end
        
        @somme_depense_commun_tab[i]         = @ligne.depense_communs.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @somme_depense_fonctionnement_tab[i] = @ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @somme_depense_equipement_tab[i]     = @ligne.depense_equipements.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @somme_depense_mission_tab[i]        = @ligne.depense_missions.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @somme_depense_salaire_tab[i]        = @ligne.depense_salaires.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @somme_depense_non_ventilee_tab[i]   = @ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant(date_start.to_s, date_end.to_s, @type_bilan, @type_montant) }
        @sous_total_depense_fem_tab[i]       = @somme_depense_fonctionnement_tab[i] + @somme_depense_equipement_tab[i] + @somme_depense_mission_tab[i]
        @total_depenses_tab[i] = @somme_depense_commun_tab[i] + @somme_depense_fonctionnement_tab[i] + @somme_depense_equipement_tab[i] + @somme_depense_mission_tab[i] + @somme_depense_salaire_tab[i] + @somme_depense_non_ventilee_tab[i]

        condition = "(( date_effet >= '"+date_start.to_s+"') && ( date_effet <= '"+date_end.to_s+"'))"
        @somme_versements_commun_tab[i]          = 0 # les versements du commun se font dans le fonctionnement
        @somme_versements_fonctionnement_tab[i]  = @ligne.versements.find(:all, :conditions => condition+" AND (ventilation = 'Fonctionnement')").sum{ |d| d.montant }
        @somme_versements_equipement_tab[i]      = @ligne.versements.find(:all, :conditions => condition+" AND (ventilation = 'Equipement')").sum{ |d| d.montant }
        @somme_versements_mission_tab[i]         = @ligne.versements.find(:all, :conditions => condition+" AND (ventilation = 'Mission')").sum{ |d| d.montant }
        @somme_versements_salaire_tab[i]         = @ligne.versements.find(:all, :conditions => condition+" AND (ventilation = 'Salaire')").sum{ |d| d.montant }
        @somme_versements_non_ventile_tab[i]     = @ligne.versements.find(:all, :conditions => condition+" AND (ventilation = 'Non ventilé')").sum{ |d| d.montant }
        @sous_total_versement_fem_tab[i]         =  @somme_versements_fonctionnement_tab[i] + @somme_versements_equipement_tab[i] + @somme_versements_mission_tab[i]
        @total_versements_tab[i] = @somme_versements_commun_tab[i] + @somme_versements_fonctionnement_tab[i] + @somme_versements_equipement_tab[i] + @somme_versements_mission_tab[i]  + @somme_versements_salaire_tab[i]  + @somme_versements_non_ventile_tab[i]

        @total_fonctionnement_tab[i] = @somme_versements_fonctionnement_tab[i] - @somme_depense_fonctionnement_tab[i]
        @total_equipement_tab[i]     = @somme_versements_equipement_tab[i] - @somme_depense_equipement_tab[i]
        @total_mission_tab[i]        = @somme_versements_mission_tab[i] - @somme_depense_mission_tab[i]
        @total_salaire_tab[i]        = @somme_versements_salaire_tab[i] - @somme_depense_salaire_tab[i]
        @total_non_ventilee_tab[i]   = @somme_versements_non_ventile_tab[i] - @somme_depense_non_ventilee_tab[i]
        @sous_total_fem_tab[i]       = @sous_total_versement_fem_tab[i] - @sous_total_depense_fem_tab[i]
        @total_tab[i]                = @total_versements_tab[i] - @total_depenses_tab[i]
        
        @recettes_attendues_fonctionnement_tab[i] =  period.depenses_fonctionnement
        @recettes_attendues_equipement_tab[i]     =  period.depenses_equipement
        @recettes_attendues_mission_tab[i]        =  period.depenses_missions
        @recettes_attendues_salaire_tab[i]        =  period.depenses_salaires
        @recettes_attendues_non_ventile_tab[i]    =  period.depenses_non_ventile
        @recettes_attendues_fem_tab[i]            =  period.depenses_fonctionnement+period.depenses_equipement+period.depenses_missions
        @recettes_attendues_tab[i]                =  period.depenses_fonctionnement+period.depenses_equipement+period.depenses_missions+period.depenses_salaires+period.depenses_non_ventile
    
        @reste_fonctionnement_tab[i] =  @recettes_attendues_fonctionnement_tab[i] - @somme_depense_fonctionnement_tab[i]
        @reste_equipement_tab[i]     =  @recettes_attendues_equipement_tab[i] - @somme_depense_equipement_tab[i]
        @reste_mission_tab[i]        =  @recettes_attendues_mission_tab[i] - @somme_depense_mission_tab[i] 
        @reste_salaire_tab[i]        =  @recettes_attendues_salaire_tab[i] - @somme_depense_salaire_tab[i]
        @reste_non_ventilee_tab[i]   =  @recettes_attendues_non_ventile_tab[i] - @somme_depense_non_ventilee_tab[i]
        @reste_fem_tab[i]            =  @recettes_attendues_fem_tab[i] - @sous_total_depense_fem_tab[i]
        @reste_tab[i]                =  @recettes_attendues_tab[i] - @total_depenses_tab[i]
      end
    end
    
  end

 end

 private

 def my_private_search(nom,projet,selection,params=nil)
    nom = "" if nom == "Nom"
    if projet and projet!= "Equipe"
      #nom = nom+"%"+projet
      inner_join = " INNER JOIN projets p ON p.id = sc.entite_id"
      and_clause = " AND sc.entite_type = 'Projet'
                     AND p.nom LIKE (?) "
    else
      inner_join =""
      and_clause = ""
    end
    if params[:filtre_projet] and params[:filtre_projet] == 'filtre_projet_active'

      req = ["SELECT distinct l.id FROM lignes l
                  inner join sous_contrats sc on sc.id = l.sous_contrat_id
                  inner join projets p on p.id = sc.entite_id
            WHERE sc.entite_type = 'Projet'
            AND p.id IN (?)", @ids_mes_equipes]    
  
      @ids_lignes_viewables  = Ligne.find_by_sql(req).collect{|l| l.id}
    else
      @ids_lignes_viewables = @ids_lignes_consultables
    end

    @ids_lignes_viewables = ['-1'] if @ids_lignes_viewables.size == 0

    if selection == 'default'
      base_req = " FROM lignes l
                  JOIN sous_contrats sc ON l.sous_contrat_id = sc.id
                  JOIN contrats c ON sc.contrat_id = c.id"+inner_join+"
                  WHERE c.etat != 'cloture'
                  AND l.id IN (?)
                  AND l.active is true
                  AND l.nom LIKE (?)"+and_clause+" order by l.nom"
    elsif selection == 'desactivees'
      base_req = " FROM lignes l
                  JOIN sous_contrats sc ON l.sous_contrat_id = sc.id
                  JOIN contrats c ON sc.contrat_id = c.id"+inner_join+"
                  WHERE c.etat != 'cloture'
                  AND l.id IN (?)
                  AND l.active is false
                  AND l.nom LIKE (?)"+and_clause+" order by l.nom"
    elsif selection == 'clos'
      base_req = " FROM lignes l
                  JOIN sous_contrats sc ON l.sous_contrat_id = sc.id
                  JOIN contrats c ON sc.contrat_id = c.id"+inner_join+"
                  WHERE c.etat = 'cloture'
                  AND l.id IN (?)
                  AND l.nom LIKE (?)"+and_clause+" order by l.nom"
    elsif selection == 'tous'
      base_req = " FROM lignes l
                  JOIN sous_contrats sc ON l.sous_contrat_id = sc.id"+inner_join+"
                  WHERE l.id IN (?)
                  AND l.nom LIKE (?)"+and_clause+" order by l.nom"
    end
    
    if projet and projet!= "Equipe"
      req = ["SELECT l.id, l.nom"+base_req, @ids_lignes_viewables,"%#{nom}%","%#{projet}%"]
      req_count = ["SELECT COUNT(*)"+base_req, @ids_lignes_viewables,"%#{nom}%","%#{projet}%"]
    else
      req = ["SELECT l.id, l.nom"+base_req, @ids_lignes_viewables,"%#{nom}%"]
      req_count = ["SELECT COUNT(*)"+base_req, @ids_lignes_viewables,"%#{nom}%"]
    end

    @lignes = Ligne.paginate_by_sql req, :page => params[:page]||1, :per_page => 25
    @count = Ligne.count_by_sql req_count
 end

 def my_private_stats
    filters = Filtr.new
    filters.multiple @ids_lignes_viewables, 'lignes.id'

    @last_depense_fonctionnements = DepenseFonctionnement.find(:all, :include => [:ligne],
          :conditions => filters.conditions, :order => "depense_fonctionnements.updated_at DESC", :limit => 10)

    @last_depense_equipements = DepenseEquipement.find(:all, :include => [:ligne],
          :conditions => filters.conditions, :order => "depense_equipements.updated_at DESC", :limit => 10)

    @last_depense_missions = DepenseMission.find(:all, :include => [:ligne],
          :conditions => filters.conditions, :order => "depense_missions.updated_at DESC", :limit => 10)

    @last_depense_salaires = DepenseSalaire.find(:all, :include => [:ligne],
          :conditions => filters.conditions, :order => "depense_salaires.updated_at DESC", :limit => 10)

    @last_depense_non_ventilees = DepenseNonVentilee.find(:all, :include => [:ligne],
          :conditions => filters.conditions,  :order => "depense_non_ventilees.updated_at DESC", :limit => 10)

    @last_versements = Versement.find(:all, :include => [:ligne],
          :conditions => filters.conditions, :order => "versements.updated_at DESC", :limit => 10)

    @last_lignes = Ligne.find(:all, :conditions => filters.conditions, :order => "updated_at DESC", :limit => 10)

    @lasts = Array.new

    for item in @last_lignes
        @lasts << {   :ligne => item,
                      :type => "Ligne",
                      :created_at => item.created_at,
                      :updated_at => item.updated_at,
                      :created_by => item.created_by,
                      :updated_by => item.updated_by }
    end

    for item in @last_depense_fonctionnements
        @lasts << {   :ligne => item.ligne,
                      :type => "Fonct",
                      :soldee => item.commande_solde,
                      :id => item.id,
                      :date => item.date_commande,
                      :intitule => item.intitule,
                      :montant => item.montant,
                      :created_at => item.created_at,
                      :updated_at => item.updated_at,
                      :created_by => item.created_by,
                      :updated_by => item.updated_by }
    end

    for item in @last_depense_equipements
        @lasts << {   :ligne => item.ligne,
                      :type => "Equipement",
                      :soldee => item.commande_solde,
                      :id => item.id,
                      :date => item.date_commande,
                      :intitule => item.intitule,
                      :montant => item.montant,
                      :created_at => item.created_at,
                      :updated_at => item.updated_at,
                      :created_by => item.created_by,
                      :updated_by => item.updated_by }
    end


    for item in @last_depense_non_ventilees
        @lasts << {   :ligne => item.ligne,
                      :type => "NonVentilee",
                      :soldee => item.commande_solde,
                      :id => item.id,
                      :date => item.date_commande,
                      :intitule => item.intitule,
                      :montant => item.montant,
                      :created_at => item.created_at,
                      :updated_at => item.updated_at,
                      :created_by => item.created_by,
                      :updated_by => item.updated_by }
      end

    for item in @last_depense_missions
           @lasts << { :ligne => item.ligne,
                       :type => "Mission",
                       :soldee => item.commande_solde,
                       :id => item.id,
                       :date_depart => item.date_depart,
                       :date_retour => item.date_retour,
                       :agent => item.agent,
                       :montant => item.montant,
                       :created_at => item.created_at,
                       :updated_at => item.updated_at,
                       :created_by => item.created_by,
                       :updated_by => item.updated_by }
    end

    for item in @last_depense_salaires
           @lasts << { :ligne => item.ligne,
                       :type => "Salaire",
                       :soldee => item.commande_solde,
                       :id => item.id,
                       :date_debut => item.date_debut,
                       :date_fin => item.date_fin,
                       :statut => item.statut,
                       :agent => item.nom_agent,
                       :montant => item.montant,
                       :created_at => item.created_at,
                       :updated_at => item.updated_at,
                       :created_by => item.created_by,
                       :updated_by => item.updated_by }
    end
    for item in @last_versements
         @lasts << { :ligne => item.ligne,
                     :type => "Versement",
                     :id => item.id,
                     :date_effet => item.date_effet,
                     :ventilation => item.ventilation,
                     :origine => item.origine,
                     :montant => item.montant,
                     :created_at => item.created_at,
                     :updated_at => item.updated_at,
                     :created_by => item.created_by,
                     :updated_by => item.updated_by }
    end

    @lasts = @lasts.sort_by { |a| a[:updated_at] }.reverse
  end

  def export_csv
    if params[:encode] == 'utf16'
      codingTranslation = Iconv.new('WINDOWS-1252','UTF-8')
    else
      codingTranslation = Iconv.new('UTF-8','UTF-8')
    end
    options = {:row_sep => "\r\n", :col_sep => ";"}
    type_montant = "Montants"
    case @type_montant.to_s
      when "htr" then type_montant   = "Montants HTR"
      when "ht" then type_montant = "Montants HT"
      when "ttc" then type_montant  = "Montants TTC"
    end
    CSV.generate(options) do |csv|
      ligne = ["", type_montant]
      csv << ligne
      #Bilan du commun
      if @ligne.contrat_dotation  
        csv << ["Montants accordes",@total_a_ouvrir]
        csv << ['']
        if @detail.blank? ||  @detail == "0" || @detail == "2"   
          if @current_date_start != @date_start.to_s
            periode = "Du "+ date_to_csv(@date_start) + " au "+ date_to_csv(@current_date_start.to_date - 1)  
            csv << [periode]
            csv << ["Credits",@total_versements_pre]       
            csv << ["Depenses",(@total_depenses_pre * -1)]
            csv << ["Total",@total_pre]
            csv << ['']
          end
          periode = "Du "+ date_to_csv(@current_date_start.to_date) + " au "+ date_to_csv(@current_date_end.to_date)  
          csv << [periode]
          if(@detail == '2')
            csv << ["Recettes attendues",@total_recettes_attendues_commun]     
          elsif !( @detail =='0' and @periode.blank?)
            csv << ["Recettes attendues",@periode.depenses_fonctionnement]
          end
          csv << ["Credits",@total_versements]       
          csv << ["Depenses",(@total_depenses * -1)]
          csv << ["Total",@total]
          csv << ['']
          
          if @current_date_end != @date_end.to_s
            periode = "Du "+ date_to_csv(@current_date_end.to_date + 1) + " au "+ date_to_csv(@date_end)  
            csv << [periode]
            csv << ["Credits",@total_versements_post]       
            csv << ["Depenses",(@total_depenses_post * -1)]
            csv << ["Total",@total_post]
            csv << ['']
          end
          
        elsif @detail =='1'
          for year in @start_year..@end_year do
              csv << ["Credits "+year.to_s,@total_versements_tab[year]]
              csv << ["Depenses "+year.to_s,(@total_depenses_tab[year]* -1)]
              csv << ["Total "+year.to_s,@total_tab[year]]
              csv << ['']
          end   
        elsif @detail =='3' and @ligne.has_periods?  
           @ligne.periodes.each_with_index do |period, i|
             csv << ["Recettes attendues periode "+(i+1).to_s,period.depenses_fonctionnement]  
             csv << ["Credits periode "+(i+1).to_s,@total_versements_tab[i]]
             csv << ["Depenses periode "+(i+1).to_s,(@total_depenses_tab[i]  * -1)]
             csv << ["Total periode "+(i+1).to_s,@total_tab[i]]
             csv << ['']
           end     
         end
         csv << ["Reste a ouvrir",@reste_a_ouvrir]
         csv << ["Reste a engager",@reste_a_depenser]
      else
        csv << ["",'Fonctionnement','Equipement','Mission','Sous Total FEM','Salaire','Non Ventile','Total']
        csv << ["Montants accordes",@total_a_ouvrir_fonctionnement,@total_a_ouvrir_equipement,@total_a_ouvrir_mission,(@total_a_ouvrir_fonctionnement + @total_a_ouvrir_equipement + @total_a_ouvrir_mission),@total_a_ouvrir_salaire,@total_a_ouvrir_non_ventile,@total_a_ouvrir]
        csv << ['']
        if @detail.blank? ||  @detail == "0" || @detail == "2"   
          if @current_date_start != @date_start.to_s
            periode = "Du "+ date_to_csv(@date_start) + " au "+ date_to_csv(@current_date_start.to_date - 1)  
            csv << [periode]
            csv << ["Credits",@somme_versements_fonctionnement_pre, @somme_versements_equipement_pre,@somme_versements_mission_pre,@sous_total_versement_fem_pre, @somme_versements_salaire_pre,@somme_versements_non_ventile_pre,@total_versements_pre]       
            csv << ["Depenses",(@somme_depense_fonctionnement_pre * -1),(@somme_depense_equipement_pre * -1),(@somme_depense_mission_pre * -1),(@sous_total_depense_fem_pre * -1),(@somme_depense_salaire_pre * -1),(@somme_depense_non_ventilee_pre * -1) ,(@total_depenses_pre * -1)]
            csv << ["Total",@total_fonctionnement_pre,@total_equipement_pre ,@total_mission_pre,@sous_total_fem_pre,@total_salaire_pre,@total_non_ventilee_pre,@total_pre]
            csv << ['']
          end
          periode = "Du "+ date_to_csv(@current_date_start.to_date) + " au "+ date_to_csv(@current_date_end.to_date)  
          csv << [periode]
          if(@detail == '2')     
            csv << ["Recettes attendues",@total_recettes_attendues_fonctionnement,@total_recettes_attendues_equipement,@total_recettes_attendues_mission,(@total_recettes_attendues_fonctionnement+@total_recettes_attendues_equipement+@total_recettes_attendues_mission),@total_recettes_attendues_salaire,@total_recettes_attendues_non_ventile,(@total_recettes_attendues_fonctionnement+@total_recettes_attendues_equipement+@total_recettes_attendues_mission+@total_recettes_attendues_salaire+@total_recettes_attendues_non_ventile)]     
          elsif !( @detail =='0' and @periode.blank?)
            csv << ["Recettes attendues",@periode.depenses_fonctionnement,@periode.depenses_equipement,@periode.depenses_missions,(@periode.depenses_fonctionnement+@periode.depenses_equipement+@periode.depenses_missions),@periode.depenses_salaires,@periode.depenses_non_ventile,(@periode.depenses_fonctionnement+@periode.depenses_equipement+@periode.depenses_missions+@periode.depenses_salaires+@periode.depenses_non_ventile)]
          end
          if ((@current_date_start != @date_start.to_s) || (@current_date_end != @date_end.to_s ))
            csv << ["Credits",@somme_versements_fonctionnement,@somme_versements_equipement,@somme_versements_mission,@sous_total_versement_fem, @somme_versements_salaire,@somme_versements_non_ventile,@total_versements]       
            csv << ["Depenses",(@somme_depense_fonctionnement * -1),(@somme_depense_equipement * -1),(@somme_depense_mission * -1),(@sous_total_depense_fem * -1),(@somme_depense_salaire * -1),(@somme_depense_non_ventilee * -1) ,(@total_depenses * -1)]
            csv << ["Total",@total_fonctionnement,@total_equipement,@total_mission,@sous_total_fem,@total_salaire,@total_non_ventilee,@total]
            csv << ['']
          end
          if @current_date_end != @date_end.to_s
            periode = "Du "+ date_to_csv(@current_date_end.to_date + 1) + " au "+ date_to_csv(@date_end)  
            csv << [periode]
            csv << ["Credits",@somme_versements_fonctionnement_post,@somme_versements_equipement_post,@somme_versements_mission_post,@sous_total_versement_fem_post, @somme_versements_salaire_post,@somme_versements_non_ventile_post,@total_versements_post]       
            csv << ["Depenses",(@somme_depense_fonctionnement_post * -1),(@somme_depense_equipement_post * -1),(@somme_depense_mission_post * -1),(@sous_total_depense_fem_post * -1),(@somme_depense_salaire_post * -1),(@somme_depense_non_ventilee_post * -1) ,(@total_depenses_post * -1)]
            csv << ["Total",@total_fonctionnement_post,@total_equipement_post,@total_mission_post,@sous_total_fem_post,@total_salaire_post,@total_non_ventilee_post,@total_post]
            csv << ['']
          end         
        elsif @detail =='1'
          for year in @start_year..@end_year do
              csv << ["Credits "+year.to_s,@somme_versements_fonctionnement_tab[year],@somme_versements_equipement_tab[year],@somme_versements_mission_tab[year],@sous_total_versement_fem_tab[year],@somme_versements_salaire_tab[year],@somme_versements_non_ventile_tab[year],@total_versements_tab[year]]
              csv << ["Depenses "+year.to_s,(@somme_depense_fonctionnement_tab[year] * -1),(@somme_depense_equipement_tab[year] * -1),(@somme_depense_mission_tab[year]  * -1),(@sous_total_depense_fem_tab[year] * -1),(@somme_depense_salaire_tab[year] * -1),(@somme_depense_non_ventilee_tab[year] * -1),(@total_depenses_tab[year] * -1)]
              csv << ["Total "+year.to_s,@total_fonctionnement_tab[year],@total_equipement_tab[year],@total_mission_tab[year],@sous_total_fem_tab[year],@total_salaire_tab[year],@total_non_ventilee_tab[year],@total_tab[year]]
              csv << ['']
          end   
        elsif @detail =='3' and @ligne.has_periods?  
           @ligne.periodes.each_with_index do |period, i|
             csv << ["Recettes attendues periode "+(i+1).to_s,period.depenses_fonctionnement,period.depenses_equipement,period.depenses_missions,(period.depenses_fonctionnement+period.depenses_equipement+period.depenses_missions),period.depenses_salaires,period.depenses_non_ventile,(period.depenses_fonctionnement+period.depenses_equipement+period.depenses_missions+period.depenses_salaires+period.depenses_non_ventile)]           
             csv << ["Credits periode "+(i+1).to_s,@somme_versements_fonctionnement_tab[i],@somme_versements_equipement_tab[i],@somme_versements_mission_tab[i],@sous_total_versement_fem_tab[i],@somme_versements_salaire_tab[i],@somme_versements_non_ventile_tab[i],@total_versements_tab[i]]
             csv << ["Depenses periode "+(i+1).to_s,(@somme_depense_fonctionnement_tab[i] * -1),(@somme_depense_equipement_tab[i] * -1),(@somme_depense_mission_tab[i]  * -1),(@sous_total_depense_fem_tab[i] * -1),(@somme_depense_salaire_tab[i] * -1),(@somme_depense_non_ventilee_tab[i] * -1),(@total_depenses_tab[i] * -1)]
             csv << ["Total periode "+(i+1).to_s,@total_fonctionnement_tab[i],@total_equipement_tab[i],@total_mission_tab[i],@sous_total_fem_tab[i],@total_salaire_tab[i],@total_non_ventilee_tab[i],@total_tab[i]]
             csv << ['']
           end     
         end
         csv << ["Credits Totaux",@total_versements_fonctionnement,@total_versements_equipement,@total_versements_mission,@total_versements_fem, @total_versements_salaire,@total_versements_non_ventile,@total_versements_ligne]       
         csv << ["Depenses Totales",(@total_depenses_fonctionnement_ligne * -1),(@total_depenses_equipement_ligne * -1),(@total_depenses_mission_ligne * -1),(@total_depense_fem * -1),(@total_depenses_salaire_ligne * -1),(@total_depenses_non_ventile_ligne * -1) ,(@total_depenses_ligne * -1)]
         csv << ["Bilan Total",@bilan_total_fonctionnement,@bilan_total_equipement,@bilan_total_mission,@bilan_total_fem,@bilan_total_salaire,@bilan_total_non_ventile,@bilan_total_ligne]            
         csv << ['']
         csv << ["Reste a ouvrir",@reste_a_ouvrir_fonctionnement,@reste_a_ouvrir_equipement,@reste_a_ouvrir_mission,(@reste_a_ouvrir_fonctionnement + @reste_a_ouvrir_equipement + @reste_a_ouvrir_mission),@reste_a_ouvrir_salaire,@reste_a_ouvrir_non_ventile,@reste_a_ouvrir]
         csv << ["Reste a engager",@reste_a_depenser_fonctionnement,@reste_a_depenser_equipement,@reste_a_depenser_mission,(@reste_a_depenser_fonctionnement + @reste_a_depenser_equipement + @reste_a_depenser_mission),@reste_a_depenser_salaire,@reste_a_depenser_non_ventile,@reste_a_depenser]       
      end      
    end
  end
end
