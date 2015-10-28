#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class ContratsController < ApplicationController 
  before_filter :compute_rights_in_session,:only => [:index]
  before_filter :set_contrats_consultables, :only => [:index, :search, :my_last_search]
  before_filter :set_contrats_editables, :only => [:index, :search, :my_last_search]
  before_filter :set_contrats_budget_editables, :only => [:index, :search, :my_last_search]
  before_filter :is_my_research_in_session?, :except => [:index, :search]
  before_filter :set_my_research_in_session, :only => [:index, :search]

  # Action de recherche sur les contrats
  # GET /contrats/search
  def search
    # Initialisation des critères de recherche d'acronyme, équipe et laboratoire
    @acronyme = (params[:acronyme].blank? ? "Acronyme" : params[:acronyme])
    @noContrat = (params[:noContrat].blank? ? "NumContrat" : params[:noContrat])
    @projet = (params[:projet].blank? ? "Equipe" : params[:projet])
    @laboratoire = (params[:laboratoire].blank? ? "Laboratoire" : params[:laboratoire])
    cookies[:projet_contrat] = @projet
    cookies[:noContrat_contrat] = @noContrat
    cookies[:laboratoire_contrat] = @laboratoire
    cookies[:acronyme] = @acronyme
    # critères de recherche en session
      my_criteria = Hash.new
      my_criteria[:acronym] = @acronyme
      my_criteria[:noContrat] = @noContrat
      my_criteria[:team] = @projet
      my_criteria[:labo] = @laboratoire
      my_criteria[:selection] = @selection = 'soumission'  unless params[:soumission] != 'soumission'
      my_criteria[:selection] = @selection = 'signature' unless params[:signature] != 'signature'
      my_criteria[:selection] = @selection = 'refu' unless params[:refu] != 'refu'
      my_criteria[:selection] = @selection = 'notification' unless params[:notification] != 'notification'
      my_criteria[:selection] = @selection = 'cloture' unless params[:cloture] != 'cloture'
      my_criteria[:selection] = @selection = 'creation' unless params[:creation] != 'creation'
      my_criteria[:selection] = @selection = 'default' unless params[:def] != 'default'
      my_criteria[:selection] = @selection = 'tous' unless params[:tous] != 'tous'
      set_my_research_in_session(my_criteria)
    
    my_private_search(@acronyme,@noContrat,@projet,@laboratoire,@selection,params)

    # Mise à jour ajax des résultats
    respond_to do |format|
      format.js {
        render :update do |page|
          if @count < 2
            page.replace_html 'ajax_result', @count.to_s+" contrat trouvé"
          else
            page.replace_html 'ajax_result', @count.to_s+" contrats trouvés"
          end
          page.replace_html  'list', :partial => 'list'
          
        end

 
      }
    end
  end
  
  def my_last_search
    my_search_criteria = my_research_in_session

    @acronyme = my_search_criteria[:acronym]
    @noContrat = my_search_criteria[:noContrat]
    @projet = my_search_criteria[:team]
    @laboratoire = my_search_criteria[:labo]
    @selection = (my_search_criteria[:selection].blank? ? "default" : my_search_criteria[:selection])

    my_private_search(@acronyme,@noContrat,@projet,@laboratoire,@selection,params)
    my_private_stats
    
    render :action => "index"
  end
  
  # Tableau de bord du suivi des contrats : unique page ou les droits sont calcules
  # GET /contrats
  def index
    
    if cookies[:acronyme]
      @acronyme = cookies[:acronyme]
    else
      @acronyme = "Acronyme"
    end
    if cookies[:noContrat_contrat]
      @noContrat = cookies[:noContrat_contrat]
    else
      @noContrat = 'NumContrat'  
    end
    
    if cookies[:projet_contrat] 
      @projet = cookies[:projet_contrat] 
    else
      @projet = 'Equipe'
    end
    if cookies[:laboratoire_contrat]
      @laboratoire = cookies[:laboratoire_contrat]
    else
      @laboratoire = "Laboratoire"
    end
    
    if params[:position_tous]=="tous"
      @selection = "tous"
    elsif params[:position_creation]=="creation"
      @selection = "creation"
    elsif params[:position_soumission]=="soumission"
      @selection = "soumission"
    elsif params[:position_signature]=="signature"
      @selection = "signature"
    elsif params[:position_refu]=="refu"
      @selection = "refu"
    elsif params[:position_notification]=="notification"
      @selection = "notification"
    elsif params[:position_cloture]=="cloture"
      @selection = "cloture"
    else
      @selection = "default"
    end  
    
    my_private_search(@acronyme,@noContrat,@projet,@laboratoire,@selection,params)
    my_private_stats

  end

  

  # GET /contrats/1
  # GET /contrats/1.pdf
  def show		
    @contrat = Contrat.find(params[:id])    

    #
    # Obtention des alertes à afficher sur le tableau de bord
    #
    
    # Tableau des ids des listes de tâches
    ids_todolist = @contrat.todolists.collect(&:id)
    
    # Tâches à réalisées dans le mois à venir ou dont la date d'execution est dépassée
    @alertes = Todoitem.find( :all,
                            :include => [:todolist],
                            #:conditions => [ "todolist_id IN (?) AND todoitems.has_alerte = '1' AND done = '0' AND date <= '"+(Time.now + 1.month).to_date.to_s+"'", ids_todolist],                                                           
                            :conditions => [ "todolist_id IN (?) AND todoitems.has_alerte = '1' AND done = '0' ", ids_todolist],
                            :order => 'todoitems.date ASC')
    
    
    
    #
    # Obtention des informations pour la section activité récente de la section suivi des contrats
    #
    
    @lasts = []
    @lasts << { :type => "Contrat", :contrat => @contrat,
                :created_at => @contrat.created_at, :updated_at => @contrat.created_at,
                :created_by => @contrat.created_by, :updated_by => @contrat.created_by }
    @lasts << { :type => "Soumission",
                :created_at => @contrat.soumission.created_at, :updated_at => @contrat.soumission.updated_at,
                :created_by => @contrat.soumission.created_by, :updated_by => @contrat.soumission.updated_by } if !@contrat.soumission.nil?     
    @lasts << { :type => "Notification",
                :created_at => @contrat.notification.created_at, :updated_at => @contrat.notification.updated_at,
                :created_by => @contrat.notification.created_by, :updated_by => @contrat.notification.updated_by } if !@contrat.notification.nil?    
    @lasts << { :type => "Signature",
                :created_at => @contrat.signature.created_at, :updated_at => @contrat.signature.updated_at,
                :created_by => @contrat.signature.created_by, :updated_by => @contrat.signature.updated_by } if !@contrat.signature.nil?
    @lasts << { :type => "Cloture",
                :created_at => @contrat.cloture.created_at, :updated_at => @contrat.cloture.updated_at,
                :created_by => @contrat.cloture.created_by, :updated_by => @contrat.cloture.updated_by } if !@contrat.cloture.nil?    
    @lasts << { :type => "Refus",
                :created_at => @contrat.refu.created_at, :updated_at => @contrat.refu.updated_at,
                :created_by => @contrat.refu.created_by, :updated_by => @contrat.refu.updated_by } if !@contrat.refu.nil?    
    @lasts << { :type => "Echeancier",
                :created_at => @contrat.echeancier.created_at, :updated_at => @contrat.echeancier.updated_at,
                :created_by => @contrat.echeancier.created_by, :updated_by => @contrat.echeancier.updated_by } if !@contrat.echeancier.nil?

    for todo in @contrat.todolists
      for item in todo.todoitems
        @lasts << { :type => "ToDo", :done => item.done,
                    :intitule => item.intitule, :todo_list => item.todolist.nom,
                    :created_at => item.created_at, :updated_at => item.updated_at,
                    :created_by => item.created_by, :updated_by => item.updated_by }
      end
    end
    
    if @contrat.sous_contrats.size > 1
      for sc in @contrat.sous_contrats
        if !sc.echeancier.nil?
          @lasts << { :type => "Echeancier", :id => sc.echeancier.id,
                      :created_at => sc.echeancier.created_at, :updated_at => sc.echeancier.updated_at,
                      :created_by => sc.echeancier.created_by, :updated_by => sc.echeancier.updated_by }
        end
      end
    end
    
    for item in @contrat.contrat_files
      @lasts << { :type => "Fichier", :file => item,
                  :created_at => item.created_at, :updated_at => item.created_at,
                  :created_by => item.created_by, :updated_by => item.updated_by }
    end
    
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
        if !@contrat.is_consultable? current_user
            flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder au contrat "+@contrat.acronyme+"."  
            redirect_to contrats_path()
        end
      }
      format.pdf do
         pdf = PrawnPdfDrawer.new(@contrat, request)
         send_data pdf.render, :filename => @contrat.acronyme+'.pdf', :type => 'application/pdf', :disposition => 'inline'
      end
    end
  end

  # GET /contrats/new
  def new
    # Action accessible uniquement aux administrateurs et administrateurs de contrat
    if !current_user.is_contrat_admin? and !current_user.is_admin? 
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
      redirect_to :controller => 'contrats', :action => 'index'
    end
    @contrat = Contrat.new
    @non_modifiables = @contrat.get_non_modifiables
  end



  # Partial show_not_authorized_users
  # Vue dans l'édition d'un contrat section Utilisateurs/droits
  # Liste des utilisateurs n'ayant pas de droits définis sur le contrat courant
  def show_not_authorized_users
    @contrat = Contrat.find(params[:id])
      
    users_with_role =  User.find_with_role(@contrat.id)
    # Utilisateurs ayant un droit de consultation sur le contrat courant
    consultation_users = users_with_role[:consultation]
    # Utilisateurs ayant un droit de modification sur le contrat courant
    modification_users = users_with_role[:modification]
    # Utilisateurs ayant un droit de modification uniquement sur le budget du contrat courant
    modification_budget_users = users_with_role[:modification_budget]
    
    
  	# Ensemble des ids d'utilisateurs ayant des droits de consultation ou modification sur le contrat courant
  	reject_ids = consultation_users.collect{|u| u.id}+modification_users.collect{|u| u.id}+modification_budget_users.collect{|u| u.id}
  	
  	# Obtention des utilisateurs n'ayant pas de droits sur contrat courant et correspondant au critère de recherche par nom
  	filter = Filtr.new 
    filter.not_multiple reject_ids, 'id' if !reject_ids.empty?
  	filter.contient params[:query], "nom"
  	@users_not_authorized = User.paginate(:conditions => filter.conditions,
  	                                  :order => "nom, prenom",
                                      :page => params[:page]||1,
                                      :per_page => 10)

    render :partial => 'show_not_authorized_users.html.erb'
  end
  
  # Partial show_not_authorized_groups
  # Vue dans l'édition d'un contrat section Groupes/droits
  # Liste des groupes n'ayant pas de droits définis sur le contrat courant
  def show_not_authorized_groups
    @contrat = Contrat.find(params[:id])
    
    groups_with_role =  Group.find_with_role(@contrat.id)
    # Groupes ayant un droit de consultation sur le contrat courant   
    consultation_groups = groups_with_role[:consultation]
    # Groupes ayant un droit de modification sur le contrat courant
    modification_groups = groups_with_role[:modification]
     # Groupes ayant un droit de modification uniquement sur le budget du contrat courant
    modification_budget_groups = groups_with_role[:modification_budget]
      
    filter = Filtr.new 
		filter.contient params[:query_group], "nom"
		groups_all = Group.find(:all, :conditions => filter.conditions, :order => "nom")
    groups_not_authorized_tmp =[]
    for group in groups_all
      if(!modification_groups.member? group) and (!consultation_groups.member? group) and (!modification_budget_groups.member? group)
        groups_not_authorized_tmp << group
      end
    end
    
    @groups_not_authorized = groups_not_authorized_tmp.paginate(:page => params[:page]||1, :per_page => 10)
    
    
    render :partial => 'show_not_authorized_groups.html.erb'
  end
  
  
  # GET /contrats/1/edit
  def edit
    # Action accessible uniquement aux administrateurs de contrat
   if !current_user.is_contrat_admin? and !current_user.is_admin? 
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
      redirect_to :controller => 'contrats', :action => 'show'
    end
  
    
    @contrat = Contrat.find(params[:id])
    @non_modifiables = @contrat.get_non_modifiables
    # Preparation des variables pour la vue d'édition
    prepare_edit_and_update
  end

  # POST /contrats/1/duplicate
  def duplicate 
    # Action accessible uniquement aux administrateurs de contrat
    if !current_user.is_contrat_admin? and !current_user.is_admin? and !@contrat.is_consultable? current_user
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
      redirect_to :controller => 'contrats', :action => 'show'
    end
    @contrat = Contrat.find(params[:id])
    @new_contrat = @contrat.clone
    @new_contrat.acronyme = '*'
    @non_modifiables = []
    success = true
    success &&= @new_contrat.save
   # puts "test" + @contrat.id.to_s + " retet : "+@new_contrat.id.to_s
    respond_to do |format|
      if success
        @new_contrat.accepts_role 'modification', current_user
        flash[:notice] = 'Le contrat a bien été crée.'
        format.html { redirect_to edit_contrat_url(@new_contrat)+"#generalites" }
      else
        flash[:error] = "Erreur avec la création du nouveau contrat."
        format.html { redirect_to :controller => 'contrats', :action => 'show' }
      end
    end  
  end

  # POST /contrats
  def create
    # Action accessible uniquement aux administrateurs de contrat
    if !current_user.is_contrat_admin? and !current_user.is_admin? 
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
      redirect_to :controller => 'contrats', :action => 'show'
    end
    @contrat = Contrat.new(params[:contrat])
    @non_modifiables = @contrat.get_non_modifiables
    respond_to do |format|
      if @contrat.save
        # Sauvegarde réussie, on donne le droit de modification à l'administrateur 
        # de contrat ayant effectué la création uniquement si il n'est pas administrateur
        # (les administrateurs ont accès à tous les contrats)
        if !current_user.has_role? "Administrateur"
          @contrat.accepts_role 'modification', current_user
        end
        flash[:notice] = 'Le contrat a bien été créé.'
        format.html { redirect_to edit_contrat_url(@contrat) }
      else
        format.html { render :action => "new" }
      end
    end
  end



  # PUT /contrats/1
  def update
    # Action accessible uniquement aux administrateurs de contrat
    if !current_user.is_contrat_admin? and !current_user.is_admin? 
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
      redirect_to :controller => 'contrats', :action => 'show'
    end
    @contrat = Contrat.find(params[:id])
    @non_modifiables = @contrat.get_non_modifiables
    if @contrat.update_attributes(params[:contrat])
      for sous_contrat in @contrat.sous_contrats do
        if sous_contrat.ligne
          sous_contrat.ligne.update_nom        
        end
      end

      flash[:notice] = 'Le contrat a bien été mis à jour.'
      redirect_to edit_contrat_url(@contrat)+"#generalites"
    else
      # Preparation des variables pour la vue d'édition
      prepare_edit_and_update
      # On renvoit vers le formulaire d'édition
      # ! Probleme avec le Glider: Tabulation mal positionnée
      render :action => "edit"
    end
  end


  # Ajout d'un droit de consultation ou modification à un utilisateur
  def add_user
    @contrat = Contrat.find(params[:id])
    @user = User.find(params['contrat'][:user_id])
    type_droit = params['contrat'][:type_droit]
    @contrat.accepts_role type_droit, @user
    
    # Envoi d'un email à l'utilisateur ayant un nouveau droit dans l'application
    Notifier.send_mail_for_add_roles(type_droit, @contrat, @user, current_user ).deliver
    
    redirect_to :controller => 'contrats', :action => 'edit', :id => @contrat.id, :anchor => 'utilisateurs'    
  end
  
  
  
  # Suppression d'un droit de consultation ou modification à un utilisateur
  def delete_user
    @contrat = Contrat.find(params[:id])
    @user = User.find(params[:user_id])
    type_droit = params[:type_droit]

    if @user == @current_user
      flash[:error] = "Vous ne pouvez pas supprimer vos droits. Merci de contacter l'administrateur de l'application."  
    else
      @user.has_no_role( type_droit, @contrat )
    end
    redirect_to :controller => 'contrats', :action => 'edit', :id => @contrat.id, :anchor => 'utilisateurs'    
  end

  # Ajout d'un droit de consultation ou modification à un groupe
  def add_group
    @contrat = Contrat.find(params[:id])
    @group = Group.find(params['contrat'][:group_id])
    type_droit = params['contrat'][:type_droit]
    
    new_role = Role.find( :first, 
                            :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id = ?', 
                                        type_droit, "Contrat", @contrat.id ] )
    
    if(!new_role)
      new_role= Role.new(params[:role])
      new_role.name = type_droit
      new_role.authorizable_type = "Contrat"
      new_role.authorizable_id = @contrat.id
      if !new_role.save
        flash[:notice] = 'Erreur ! Ajout des droits impossible'
      end
    end

      
    new_group_right = GroupRight.new(params[:group_right])
    new_group_right.role_id=new_role.id
    new_group_right.group_id=@group.id
    if !new_group_right.save
      flash[:notice] = 'Erreur ! Ajout des droits au groupe impossible'
    end

    redirect_to :controller => 'contrats', :action => 'edit', :id => @contrat.id, :anchor => 'groupes'    
  end
  
  
  
  # Suppression d'un droit de consultation ou modification à un utilisateur
  def delete_group
    @contrat = Contrat.find(params[:id])
    @group = Group.find(params[:group_id])
    type_droit = params[:type_droit]

    @role = Role.find( :first, 
                       :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id = ?', 
                                        type_droit, "Contrat", @contrat.id ] )
                                              
    @group_right = GroupRight.find( :first, 
                                   :conditions => [ 'role_id = ? and group_id = ?', 
                                        @role.id, @group.id ] )
    
    @group_right.destroy 

    redirect_to :controller => 'contrats', :action => 'edit', :id => @contrat.id, :anchor => 'groupes'    
  end

  # Boite de dialogue avant la suppression d'un contrat
  def ask_delete
    @contrat = Contrat.find(params[:id])
  end



  # DELETE /contrats/1
  def destroy
    # Action accessible uniquement aux administrateurs de contrat
    if !current_user.is_contrat_admin? and !current_user.is_admin? 
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
      redirect_to :controller => 'contrats', :action => 'show'
    end
    
    # Suppression des droits associés au contrats
    @contrat = Contrat.find(params[:id])
    @roles = Role.find(:all, :conditions => [" authorizable_id = ? AND authorizable_type = 'Contrat' ", @contrat.id ])
    for role in @roles
      role.destroy
    end
    
    # Suppression du contrats
    @contrat.destroy
    
    # Redirection vers le tableau de bord de la section suivi des contrats

    respond_to do |format|
      format.html { redirect_to contrats_url }
    end
  end
  
  def reporting
    @contrat = Contrat.find(params[:id])
    ligne_ids = @contrat.sous_contrats.collect {|sc| sc.ligne.id if !sc.ligne.nil?}
    
    @periodes  = []
    
    data = Hash.new
    data["type"] = "global"
    
    # Récupération des données contractuelles issues de la notification
    data["contractuel"] = Hash.new
    data["contractuel"]["mission"]        = @contrat.notification.ma_mission
    data["contractuel"]["fonctionnement"] = @contrat.notification.ma_fonctionnement
    data["contractuel"]["equipement"]     = @contrat.notification.ma_equipement
    data["contractuel"]["prestation"]     = 0
    data["contractuel"]["contractuel"]    = @contrat.notification.ma_salaire
    data["contractuel"]["permanent"]      = 0
    data["contractuel"]["total"] = data["contractuel"]["mission"] + data["contractuel"]["fonctionnement"] + data["contractuel"]["equipement"] + data["contractuel"]["prestation"] + data["contractuel"]["contractuel"] + data["contractuel"]["permanent"]
    
    # Récupération des dépenses éligibles réalisées
    data["realise"] = Hash.new
    data["realise"]["mission"]        = DepenseMission.reporting_total_depense(ligne_ids, :type => 'realisees')
    data["realise"]["fonctionnement"] = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'realisees', :prestation_service => false)
    data["realise"]["equipement"]     = DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'realisees')
    data["realise"]["prestation"]     = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'realisees', :prestation_service => true)
    data["realise"]["contractuel"]    = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'realisees', :type_personnel => 'Contractuel')
    data["realise"]["permanent"]      = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'realisees', :type_personnel => 'Titulaire')
    data["realise"]["total_eligible"] = data["realise"]["mission"] + data["realise"]["fonctionnement"] + data["realise"]["prestation"] + data["realise"]["contractuel"] + data["realise"]["permanent"]
    
    # Récupération des dépenses non éligibles réalisées
    mission        = DepenseMission.reporting_total_depense(ligne_ids, :type => 'realisees', :eligible => 0)
    fonctionnement = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'realisees', :prestation_service => false, :eligible => 0)
    equipement     = DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'realisees', :eligible => 0)
    prestation     = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'realisees', :prestation_service => true, :eligible => 0)
    contractuel    = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'realisees', :type_personnel => 'Contractuel', :eligible => 0)
    permanent      = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'realisees', :type_personnel => 'Titulaire', :eligible => 0)
    data["realise"]["total_non_eligible"] = mission + fonctionnement + equipement + prestation + contractuel + permanent
    data["realise"]["total"]              = data["realise"]["total_eligible"] + data["realise"]["total_non_eligible"]
    
    # Récupération des dépenses éligibles prévisionnelles
    data["previsionnel"] = Hash.new
    data["previsionnel"]["mission"]        = DepenseMission.reporting_total_depense(ligne_ids, :type => 'previsionnelles')
    data["previsionnel"]["fonctionnement"] = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :prestation_service => false)
    data["previsionnel"]["equipement"]     = DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'previsionnelles')
    data["previsionnel"]["prestation"]     = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :prestation_service => true)
    data["previsionnel"]["contractuel"]    = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_personnel => 'Contractuel')    
    data["previsionnel"]["permanent"]      = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_personnel => 'Titulaire')
    data["previsionnel"]["total_eligible"] = data["previsionnel"]["mission"] + data["previsionnel"]["fonctionnement"] + 
                                             data["previsionnel"]["equipement"] + data["previsionnel"]["prestation"] + 
                                             data["previsionnel"]["contractuel"] + data["previsionnel"]["permanent"]
    
    # Récupération des dépenses non éligibles prévisionnelles
    mission        = DepenseMission.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :eligible => 0)
    fonctionnement = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :prestation_service => false, :eligible => 0)
    equipement     = DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :eligible => 0)
    prestation     = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :prestation_service => true, :eligible => 0)
    contractuel    = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_personnel => 'Contractuel', :eligible => 0)    
    permanent      = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_personnel => 'Titulaire', :eligible => 0)
    data["previsionnel"]["total_non_eligible"] = mission + fonctionnement + equipement + prestation + contractuel + permanent
    data["previsionnel"]["total"]              = data["previsionnel"]["total_eligible"] + data["previsionnel"]["total_non_eligible"]
    
    # Récupération des dépenses éligibles engage non réalisé
    data["engage"] = Hash.new
    data["engage"]["mission"]        = DepenseMission.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees')
    data["engage"]["fonctionnement"] = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :prestation_service => false)
    data["engage"]["equipement"]     = DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees')
    data["engage"]["prestation"]     = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :prestation_service => true)
    data["engage"]["contractuel"]    = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_personnel => 'Contractuel')    
    data["engage"]["permanent"]      = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_personnel => 'Titulaire')
    data["engage"]["total_eligible"] = data["engage"]["mission"] + data["engage"]["fonctionnement"] +
                                       data["engage"]["equipement"] + data["engage"]["prestation"] +
                                       data["engage"]["contractuel"] + data["engage"]["permanent"]
    
    # Récupération des dépenses non éligibles engage non réalisé
    mission        = DepenseMission.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :eligible => 0)
    fonctionnement = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :prestation_service => false, :eligible => 0)
    equipement     = DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :eligible => 0)
    prestation     = DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :prestation_service => true, :eligible => 0)
    contractuel    = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_personnel => 'Contractuel', :eligible => 0)    
    permanent      = DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_personnel => 'Titulaire', :eligible => 0)
    data["engage"]["total_non_eligible"] = mission + fonctionnement + equipement + prestation + contractuel + permanent
    
    data["all"] = Hash.new
    data["all"]["total_eligible"]     = data["realise"]["total_eligible"]     + data["previsionnel"]["total_eligible"]     + data["engage"]["total_eligible"]
    data["all"]["total_non_eligible"] = data["realise"]["total_non_eligible"] + data["previsionnel"]["total_non_eligible"] + data["engage"]["total_non_eligible"]
    data["all"]["total"]              = data["all"]["total_eligible"] + data["all"]["total_non_eligible"]
    
    # Calcul des pourcentages réalisé
    data["realise"]["mission_%"]        = calculate_percentage(data["realise"]["mission"],        data["contractuel"]["mission"])
    data["realise"]["fonctionnement_%"] = calculate_percentage(data["realise"]["fonctionnement"], data["contractuel"]["fonctionnement"])
    data["realise"]["equipement_%"]     = calculate_percentage(data["realise"]["equipement"],     data["contractuel"]["equipement"])
    data["realise"]["prestation_%"]     = calculate_percentage(data["realise"]["prestation"],     data["contractuel"]["prestation"])
    data["realise"]["contractuel_%"]    = calculate_percentage(data["realise"]["contractuel"],    data["contractuel"]["contractuel"])
    data["realise"]["permanent_%"]      = calculate_percentage(data["realise"]["permanent"],      data["contractuel"]["permanent"])
    
    # Calcul des pourcentages prévisionnels
    data["previsionnel"]["mission_%"]        = calculate_percentage(data["previsionnel"]["mission"],        data["contractuel"]["mission"])
    data["previsionnel"]["fonctionnement_%"] = calculate_percentage(data["previsionnel"]["fonctionnement"], data["contractuel"]["fonctionnement"])
    data["previsionnel"]["equipement_%"]     = calculate_percentage(data["previsionnel"]["equipement"],     data["contractuel"]["equipement"])
    data["previsionnel"]["prestation_%"]     = calculate_percentage(data["previsionnel"]["prestation"],     data["contractuel"]["prestation"])
    data["previsionnel"]["contractuel_%"]    = calculate_percentage(data["previsionnel"]["contractuel"],    data["contractuel"]["contractuel"])
    data["previsionnel"]["permanent_%"]      = calculate_percentage(data["previsionnel"]["permanent"],      data["contractuel"]["permanent"])

    # Calcul des pourcentages engage non réalisé
    data["engage"]["mission_%"]        = calculate_percentage(data["engage"]["mission"],        data["contractuel"]["mission"])
    data["engage"]["fonctionnement_%"] = calculate_percentage(data["engage"]["fonctionnement"], data["contractuel"]["fonctionnement"])
    data["engage"]["equipement_%"]     = calculate_percentage(data["engage"]["equipement"],     data["contractuel"]["equipement"])
    data["engage"]["prestation_%"]     = calculate_percentage(data["engage"]["prestation"],     data["contractuel"]["prestation"])
    data["engage"]["contractuel_%"]    = calculate_percentage(data["engage"]["contractuel"],    data["contractuel"]["contractuel"])
    data["engage"]["permanent_%"]      = calculate_percentage(data["engage"]["permanent"],      data["contractuel"]["permanent"])
    
    if @contrat.notification.contrat_type.id == ID_CONTRAT_TYPE_EUROPEEN
      # Dépenses éligibles réalisées en R&D, montant des coûts directs
      data["realise_direct_r&d"]           = DepenseMission.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'R&D') +
                                             DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'R&D') +
                                             DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'R&D') +
                                             DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'R&D')
                                             
      # Dépenses éligibles prévisionnelles en R&D, montant des coûts directs
      data["previsionnel_direct_r&d"]      = DepenseMission.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'R&D') +
                                             DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'R&D') +
                                             DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'R&D') +
                                             DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'R&D')
                                             
      # Dépenses éligibles engagées non réalisées en R&D, montant des coûts directs
      data["engage_direct_r&d"]           = DepenseMission.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'R&D') +
                                            DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'R&D') +
                                            DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'R&D') +
                                            DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'R&D')
      data["total_direct_r&d"] = data["realise_direct_r&d"] + data["previsionnel_direct_r&d"] + data["engage_direct_r&d"]

      # Dépenses éligibles réalisées en Démonstration, montant des coûts directs
      data["realise_direct_demonstration"] = DepenseMission.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Démonstration') + 
                                             DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Démonstration') +
                                             DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Démonstration') +
                                             DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Démonstration')
                                             
      # Dépenses éligibles prévisionnelles en Démonstration, montant des coûts directs
      data["previsionnel_direct_demonstration"] = DepenseMission.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Démonstration') +
                                                  DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Démonstration') +
                                                  DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Démonstration') +
                                                  DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Démonstration')
                                                  
      # Dépenses éligibles engagées non réalisées en Démonstration, montant des coûts directs
      data["engage_direct_demonstration"] = DepenseMission.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Démonstration') +
                                            DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Démonstration') +
                                            DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Démonstration') +
                                            DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Démonstration')
      data["total_direct_demonstration"] = data["realise_direct_demonstration"] + data["previsionnel_direct_demonstration"] + data["engage_direct_demonstration"]

      # Dépenses éligibles réalisées en Training, montant des coûts directs
      data["realise_direct_training"]      = DepenseMission.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Training') + 
                                             DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Training') +
                                             DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Training') +
                                             DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Training')
                                             
      # Dépenses éligibles prévisionnelles en Training, montant des coûts directs
      data["previsionnel_direct_training"] = DepenseMission.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Training') + 
                                             DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Training') +
                                             DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Training') +
                                             DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Training')
                                             
      # Dépenses éligibles engagées non réalisées en Training, montant des coûts directs
      data["engage_direct_training"]       = DepenseMission.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Training') + 
                                             DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Training') +
                                             DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Training') +
                                             DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Training')
      data["total_direct_training"] = data["realise_direct_training"] + data["previsionnel_direct_training"] + data["engage_direct_training"]

      # Dépenses éligibles réalisées en Management, montant des coûts directs
      data["realise_direct_management"]    = DepenseMission.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Management') +
                                             DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Management') +
                                             DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Management') +
                                             DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Management')
                                             
      # Dépenses éligibles prévisionnelles en Management, montant des coûts directs
      data["previsionnel_direct_management"] = DepenseMission.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Management') +
                                               DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Management') +
                                               DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Management') +
                                               DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Management')
                                               
      # Dépenses éligibles engagées non réalisées en Management, montant des coûts directs
      data["engage_direct_management"]    = DepenseMission.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Management') +
                                            DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Management') +
                                            DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Management') +
                                            DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Management')
      data["total_direct_management"] = data["realise_direct_management"] + data["previsionnel_direct_management"] + data["engage_direct_management"]

      # Dépenses éligibles réalisées en Autre, montant des coûts directs
      data["realise_direct_autre"]         = DepenseMission.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Autre') +
                                             DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Autre') +
                                             DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Autre') +
                                             DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'realisees', :type_activite => 'Autre')
                                             
      # Dépenses éligibles prévisionnelles en Autre, montant des coûts directs
      data["previsionnel_direct_autre"]    = DepenseMission.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Autre') +
                                             DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Autre') +
                                             DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Autre') +
                                             DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'previsionnelles', :type_activite => 'Autre')
                                             
      # Dépenses éligibles engagées non réalisées en Autre, montant des coûts directs
      data["engage_direct_autre"]          = DepenseMission.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Autre') +
                                             DepenseFonctionnement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Autre') +
                                             DepenseEquipement.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Autre') +
                                             DepenseSalaire.reporting_total_depense(ligne_ids, :type => 'engagees_non_realisees', :type_activite => 'Autre')
      data["total_direct_autre"] = data["realise_direct_autre"] + data["previsionnel_direct_autre"] + data["engage_direct_autre"]
    end
    
    @periodes << data
    
    i = 1
    if !@contrat.echeancier.nil?
      for period in @contrat.echeancier.echeancier_periodes
        data = Hash.new
      
        data["index"]      = i
        data["type"]       = "local"
        data["date_debut"] = period.date_debut
        data["date_fin"]   = period.date_fin
      
        # Récupération des données contractuelles issues de la notification
        data["contractuel"] = Hash.new
        data["contractuel"]["mission"]        = period.depenses_missions
        data["contractuel"]["fonctionnement"] = period.depenses_fonctionnement
        data["contractuel"]["equipement"]     = period.depenses_equipement
        data["contractuel"]["prestation"]     = 0
        data["contractuel"]["contractuel"]    = period.depenses_salaires
        data["contractuel"]["permanent"]      = 0
      
        # Récupération des dépenses éligibles réalisées
        data["realise"] = Hash.new
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees'}
        data["realise"]["mission"] = DepenseMission.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees', :prestation_service => false}
        data["realise"]["fonctionnement"] = DepenseFonctionnement.reporting_total_depense(ligne_ids, options)
        
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees'}
        data["realise"]["equipement"] = DepenseEquipement.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees', :prestation_service => true}
        data["realise"]["prestation"] = DepenseFonctionnement.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees', :type_personnel => 'Contractuel'}
        data["realise"]["contractuel"] = DepenseSalaire.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees', :type_personnel => 'Titulaire'}
        data["realise"]["permanent"] = DepenseSalaire.reporting_total_depense(ligne_ids, options)
        
        
        # Récupération des dépenses non éligibles réalisées
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees', :eligible => 0}
        mission        = DepenseMission.reporting_total_depense(ligne_ids, options )
        
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees', :prestation_service => false, :eligible => 0}
        fonctionnement = DepenseFonctionnement.reporting_total_depense(ligne_ids, options )
        
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees', :eligible => 0}
        equipement = DepenseEquipement.reporting_total_depense(ligne_ids, options )
        
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees', :prestation_service => true, :eligible => 0}
        prestation = DepenseFonctionnement.reporting_total_depense(ligne_ids, options )
        
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees', :type_personnel => 'Contractuel', :eligible => 0}
        contractuel = DepenseSalaire.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'realisees', :type_personnel => 'Titulaire', :eligible => 0}
        permanent = DepenseSalaire.reporting_total_depense(ligne_ids, options)

        data["realise"]["total_non_eligible"] = mission + fonctionnement + equipement + prestation + contractuel + permanent
        
        # Récupération des dépenses éligibles engagée non réalisées
        data["engage"] = Hash.new

        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'engagees_non_realisees'}
        data["engage"]["mission"]        = DepenseMission.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'engagees_non_realisees', :prestation_service => false}
        data["engage"]["fonctionnement"] = DepenseFonctionnement.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'engagees_non_realisees'}
        data["engage"]["equipement"]     = DepenseEquipement.reporting_total_depense(ligne_ids, options)

        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'engagees_non_realisees', :prestation_service => true}
        data["engage"]["prestation"]     = DepenseFonctionnement.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'engagees_non_realisees', :type_personnel => 'Contractuel'}
        data["engage"]["contractuel"]    = DepenseSalaire.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'engagees_non_realisees', :type_personnel => 'Titulaire'}
        data["engage"]["permanent"]      = DepenseSalaire.reporting_total_depense(ligne_ids, options)
      
        # Récupération des dépenses éligibles prévisionnelles
        data["previsionnel"] = Hash.new
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'previsionnelles'}
        data["previsionnel"]["mission"]        = DepenseMission.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'previsionnelles', :prestation_service => false}
        data["previsionnel"]["fonctionnement"] = DepenseFonctionnement.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'previsionnelles'}
        data["previsionnel"]["equipement"]     = DepenseEquipement.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'previsionnelles', :prestation_service => true}
        data["previsionnel"]["prestation"]     = DepenseFonctionnement.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'previsionnelles', :type_personnel => 'Contractuel'}
        data["previsionnel"]["contractuel"]    = DepenseSalaire.reporting_total_depense(ligne_ids, options)
      
        options = {:date_min => period.date_debut, :date_max => period.date_fin, :type => 'previsionnelles', :type_personnel => 'Titulaire'}
        data["previsionnel"]["permanent"]      = DepenseSalaire.reporting_total_depense(ligne_ids, options)
      
        # Calcul des pourcentages réalisé
        data["realise"]["mission_%"]        = calculate_percentage(data["realise"]["mission"],        data["contractuel"]["mission"])
        data["realise"]["fonctionnement_%"] = calculate_percentage(data["realise"]["fonctionnement"], data["contractuel"]["fonctionnement"])
        data["realise"]["equipement_%"]     = calculate_percentage(data["realise"]["equipement"],     data["contractuel"]["equipement"])
        data["realise"]["prestation_%"]     = calculate_percentage(data["realise"]["prestation"],     data["contractuel"]["prestation"])
        data["realise"]["contractuel_%"]    = calculate_percentage(data["realise"]["contractuel"],    data["contractuel"]["contractuel"])
        data["realise"]["permanent_%"]      = calculate_percentage(data["realise"]["permanent"],      data["contractuel"]["permanent"])
      
        # Calcul des pourcentages engage non réalisé
        data["engage"]["mission_%"]        = calculate_percentage(data["engage"]["mission"],        data["contractuel"]["mission"])
        data["engage"]["fonctionnement_%"] = calculate_percentage(data["engage"]["fonctionnement"], data["contractuel"]["fonctionnement"])
        data["engage"]["equipement_%"]     = calculate_percentage(data["engage"]["equipement"],     data["contractuel"]["equipement"])
        data["engage"]["prestation_%"]     = calculate_percentage(data["engage"]["prestation"],     data["contractuel"]["prestation"])
        data["engage"]["contractuel_%"]    = calculate_percentage(data["engage"]["contractuel"],    data["contractuel"]["contractuel"])
        data["engage"]["permanent_%"]      = calculate_percentage(data["engage"]["permanent"],      data["contractuel"]["permanent"])

        # Calcul des pourcentages prévisionnels
        data["previsionnel"]["mission_%"]        = calculate_percentage(data["previsionnel"]["mission"],        data["contractuel"]["mission"])
        data["previsionnel"]["fonctionnement_%"] = calculate_percentage(data["previsionnel"]["fonctionnement"], data["contractuel"]["fonctionnement"])
        data["previsionnel"]["equipement_%"]     = calculate_percentage(data["previsionnel"]["equipement"],     data["contractuel"]["equipement"])
        data["previsionnel"]["prestation_%"]     = calculate_percentage(data["previsionnel"]["prestation"],     data["contractuel"]["prestation"])
        data["previsionnel"]["contractuel_%"]    = calculate_percentage(data["previsionnel"]["contractuel"],    data["contractuel"]["contractuel"])
        data["previsionnel"]["permanent_%"]      = calculate_percentage(data["previsionnel"]["permanent"],      data["contractuel"]["permanent"])
      
        @periodes << data
        
        i += 1
      end
    end
  end
  
  private
  
  def calculate_percentage(x,y)
    if y != 0
      (x * 100 / y).round().to_i.to_s + " %"
    else
      "-"
    end
  end
  
  # Preparation des variables neccesssaires aux actions d'édition et de mise à jour en cas d'echec
  def prepare_edit_and_update
    
    users_with_role =  User.find_with_role(@contrat.id)
    # Utilisateurs ayant un droit de consultation sur le contrat courant
    @consultation_users = users_with_role[:consultation]
    # Utilisateurs ayant un droit de modification sur le contrat courant
    @modification_users = users_with_role[:modification]
    # Utilisateurs ayant un droit de modification uniquement sur le budget du contrat courant
    @modification_budget_users = users_with_role[:modification_budget]
    @admin_contrat_users =  users_with_role[:admin_contrat]
    
  	# Ensemble des ids d'utilisateurs ayant des droits de consultation ou modification sur le contrat courant
    reject_users_ids = @consultation_users.collect{|u| u.id}+@modification_users.collect{|u| u.id}+@modification_budget_users.collect{|u| u.id}
    
  	# Obtention des utilisateurs n'ayant pas de droits sur contrat courant et correspondant au critère de recherche par nom
  	@filter_user = Filtr.new 
    @filter_user.not_multiple reject_users_ids, 'id' if reject_users_ids.empty?
  	@filter_user.contient params[:query], "nom"
  	@users_not_authorized = User.paginate(:conditions => @filter_user.conditions,
                                        :order => "nom, prenom",
                                        :page => params[:page]||1,
                                        :per_page => 10)
  	#@users_not_authorized = User.paginate(:all, :conditions => @filter_user.conditions,
  	#                                    :order => "nom, prenom",
    #                                    :page => params[:page]||1,
    #                                    :per_page => 10)

    
    groups_with_role =  Group.find_with_role(@contrat.id)
    # Groupes ayant un droit de consultation sur le contrat courant   
    @consultation_groups = groups_with_role[:consultation]
    # Groupes ayant un droit de modification sur le contrat courant
    @modification_groups = groups_with_role[:modification]
     # Groupes ayant un droit de modification uniquement sur le budget du contrat courant
    @modification_budget_groups = groups_with_role[:modification_budget]
    @admin_contrat_groups =  groups_with_role[:admin_contrat]
    
    filter = Filtr.new
		filter.contient params[:query_group], "nom"
    groups_all = Group.find(:all, :order => "nom")
    @groups_not_authorized_tmp =[]
    for group in groups_all
      if(!@modification_groups.member? group) and (!@consultation_groups.member? group) and (!@modification_budget_groups.member? group)
        @groups_not_authorized_tmp << group
      end
    end
    
    @groups_not_authorized = @groups_not_authorized_tmp.paginate( :page => params[:page]||1,
                                                                   :per_page => 10)
    
    
    # Sous contrats de type Projet
    @sous_contrats_projet = @contrat.sous_contrats.find(:all, :conditions => "entite_type = 'Projet'")
    # Sous contrats de type Département
    @sous_contrats_departement = @contrat.sous_contrats.find(:all, :conditions => "entite_type = 'Departement'")
    # Sous contrats de type Laboratoire
    @sous_contrats_laboratoire = @contrat.sous_contrats.find(:all, :conditions => "entite_type = 'Laboratoire'")

    # Projets, departements, laboratoires pour les selects du formulaire d'associations d'entités au contrat
    @projets = Projet.find(:all) - Projet.find(:all, :include => ['sous_contrats'] ,:conditions => ["sous_contrats.entite_type = 'Projet' AND contrat_id = ?", @contrat.id])
    @departements = Departement.find(:all) - Departement.find(:all, :include => [:sous_contrats] ,:conditions => ["sous_contrats.entite_type = 'Departement' AND contrat_id = ?", @contrat.id])
    @laboratoires = Laboratoire.find(:all) - Laboratoire.find(:all, :include => [:sous_contrats] ,:conditions => ["sous_contrats.entite_type = 'Laboratoire' AND contrat_id = ?", @contrat.id])
    @langues = Langue.find(:all)
    @descriptifs = Descriptif.find(:all, :conditions => ["descriptifs.contrat_id = ?", @contrat.id])
  end
  
  def my_private_search(acronym,noContrat,team,labo,selection,params=nil)

    if acronym == "Acronyme" and noContrat == "NumContrat" and team == "Equipe" and labo == "Laboratoire" and selection == "default"
      tous = true
    else
      tous = false
    end

    @ids_viewables = @ids_consultables
    @ids_viewables = ['-1'] if @ids_viewables.size == 0

    if !tous
      ids_contrats = Contrat.my_find_all(@ids_viewables, acronym, noContrat, team, labo)
      unless ids_contrats.size > 0
        ids_contrats << 0
      end
    else
      ids_contrats= @ids_viewables
    end

    # Construction des filtres de recherche pour la recherche avancées
    filters = Filtr.new
    filters.multiple ids_contrats, 'contrats.id'
    if !tous
      filters.equal 'soumission', 'contrats.etat' if selection == 'soumission'
      filters.equal 'signature', 'contrats.etat' if selection == 'signature'
      filters.equal 'refus', 'contrats.etat' if selection == 'refu'
      filters.equal 'notification', 'contrats.etat' if selection == 'notification'
      filters.equal 'cloture', 'contrats.etat' if selection == 'cloture'
      filters.equal 'init', 'contrats.etat' if selection == 'creation'
      filters.ne_contient_pas 'cloture',  'contrats.etat' if selection == 'default'
      filters.ne_contient_pas 'refus',  'contrats.etat' if selection == 'default'
    else
      filters.ne_contient_pas 'cloture',  'contrats.etat'
      filters.ne_contient_pas 'refus',  'contrats.etat'
    end
    # Obtention des contrats correspondant à l'ensemble des critères de recherche + pagination avec le gem mislav-will_paginate
    @contrats = Contrat.paginate(:include => [:projets, :departements, :laboratoires ],
                                :conditions => filters.conditions, :order => "acronyme",
                                :page => params[:page]||1,
                                :per_page => 25)
    
    # Obtention du nombre de contrats correspondant à l'ensemble des critères de recherche
    @count = Contrat.count(:all, :include => [:projets, :departements, :laboratoires ], :conditions => filters.conditions)
  end

  def my_private_stats
    first_filters = Filtr.new
    first_filters.multiple @ids_viewables, 'id'
    second_filters = Filtr.new
    second_filters.multiple @ids_viewables, 'contrat_id'
    #
    # Obtention des informations relatives aux statistiques affichés au début du tableau de bord
    #

    # Nombre total de contrats (accessibles à l'utilisateur courant)
    @nb_contrats = Contrat.count(:all, :conditions => [ "contrats.id in (?)", @ids_viewables])

    # Nombre total de contrats soumis (accessibles à l'utilisateur courant)
    @nb_contrats_soumis = Contrat.count(:all, :conditions => [ "etat != 'init' AND contrats.id in (?)", @ids_viewables])

    # Nombre total de contrats signés (accessibles à l'utilisateur courant)
    @nb_contrats_signes = Contrat.count(:all, :conditions => [ "etat != 'init' AND etat != 'soumission' AND etat !='refus' AND id in (?)", @ids_viewables])

    # Nombre total de contrats refusés (accessibles à l'utilisateur courant)
    @nb_contrats_refuses = Contrat.count(:all, :conditions => [ "etat = 'refus' AND id in (?)", @ids_viewables])

    # Nombre total de contrats notifiés (accessibles à l'utilisateur courant)
    @nb_contrats_notifies = Contrat.count(:all, :conditions => [ "(etat = 'notification' OR etat = 'cloture') AND contrats.id in (?)", @ids_viewables])

    # Nombre total de contrats clos(accessibles à l'utilisateur courant)
    @nb_contrats_clos = Contrat.count(:all, :conditions => [ "etat = 'cloture' AND id in (?)", @ids_viewables])


    #
    # Obtention des alertes à afficher sur le tableau de bord
    #

    # Tableau des ids des listes de tâches des contrats accessibles par l'utilisateur courant
    ids_todolist = Todolist.find_all_by_contrat_id(@ids_viewables).collect(&:id)

    # Tâches à réalisées dans le mois à venir ou dont la date d'execution est dépassée
    @alertes = Todoitem.find( :all,
                            :include => [:todolist],
                            :conditions => [ "todolist_id IN (?) AND todoitems.has_alerte = '1' AND done = '0' AND date <= '"+(Time.now + 1.month).to_date.to_s+"'", ids_todolist],
                            :order => 'todoitems.date ASC')

    #
    # Obtention des informations pour la section activité récente de la section suivi des contrats
    #

    # 10 derniers contrats créés
    last_contrats  = Contrat.find(:all,
                      :select => "id, nom, acronyme, updated_at, updated_by, created_at, created_by",
                      :conditions => first_filters.conditions, :order => "created_at DESC", :limit => 10)

    # 20 dernières tâches modifiées ou enrregistrées
    last_todoitems = Todoitem.find(:all, :include =>[:todolist], :conditions => ["todolist_id IN (?)", ids_todolist],
                                    :order => "todoitems.updated_at DESC", :limit => 20)

    # 10 dernières soumissions créées ou modifiées
    last_soumissions = Soumission.find( :all,
                                      :select => "contrat_id, id, updated_at, updated_by, created_at, created_by",
                                      :conditions => second_filters.conditions, :order => "soumissions.updated_at DESC", :limit => 10)

    # 10 derniers refus créés ou modifiés
    last_refus = Refu.find(:all,
                            :select => "contrat_id, id, updated_at, updated_by, created_at, created_by",
                            :conditions => second_filters.conditions, :order => "updated_at DESC", :limit => 10)

    # 10 dernières signatures créées ou modifiées
    last_signatures = Signature.find(:all,
                                      :select => "contrat_id, id, updated_at, updated_by, created_at, created_by",
                                      :conditions => second_filters.conditions, :order => "updated_at DESC", :limit => 10)

    # 10 dernières notifications créées ou modifiées
    last_notifications = Notification.find(:all,
                                            :select => "contrat_id, id, updated_at, updated_by, created_at, created_by",
                                            :conditions => second_filters.conditions, :order => "updated_at DESC", :limit => 10)
    # 10 dernières clotures créées ou modifiées
    last_clotures = Cloture.find(:all,
                                  :select => "id, contrat_id, created_at, created_by, updated_at, updated_by",
                                  :conditions => second_filters.conditions, :order => "updated_at DESC", :limit => 10)

    # 10 derniers echéanciers créés ou modifiées
    last_echeancier = Echeancier.find(:all,:order => "updated_at DESC",
                                            :conditions => ["echeanciable_type = 'Contrat'"], :limit => 10)

    # 10 derniers fichiers créés ou modifiées
    last_contrat_files = ContratFile.find(:all, :conditions => second_filters.conditions, :order => "created_at DESC", :limit => 10)



    # On rassemble l'ensemble des dernière actions dans la variable last ayant une structure unifiée permettant ensuite un tris par date
    lasts = []

     for item in last_contrats
       lasts << { :type => "Contrat", :contrat_id => item.id,
                   :at => item.created_at, :by => item.created_by, :action => "Création"}
     end

     for item in last_todoitems
       if item.created_at == item.updated_at
         lasts << { :type => "ToDo", :contrat_id => item.todolist.contrat.id,
                     :done => item.done, :intitule => item.intitule, :todo_list => item.todolist.nom,
                     :at => item.created_at, :by => item.created_by, :action => "Création" }
       else
         lasts << { :type => "ToDo", :contrat_id => item.todolist.contrat.id,
                     :done => item.done, :intitule => item.intitule, :todo_list => item.todolist.nom,
                     :at => item.updated_at, :by => item.updated_by, :action => "Modification" }
      end
     end

     for item in last_soumissions
       if item.created_at == item.updated_at
         lasts << { :type => "Soumission", :contrat_id => item.contrat_id, :soumission_id => item.id,
                   :at => item.created_at, :by => item.created_by, :action => "Création" }
       else
        lasts << { :type => "Soumission", :contrat_id => item.contrat_id, :soumission_id => item.id,
                    :at => item.updated_at, :by => item.updated_by, :action => "Modification" }
       end
     end

     for item in last_notifications
       if item.created_at == item.updated_at
        lasts << { :type => "Notification", :contrat_id => item.contrat_id, :notification_id => item.id,
           :at => item.created_at, :by => item.created_by, :action => "Création" }
      else
        lasts << { :type => "Notification", :contrat_id => item.contrat_id, :notification_id => item.id,
          :at => item.updated_at, :by => item.updated_by, :action => "Modification" }
      end
     end

     for item in last_signatures
       if item.created_at == item.updated_at
         lasts << { :type => "Signature", :contrat_id => item.contrat_id, :signature_id => item.id,
           :at => item.created_at, :by => item.created_by, :action => "Création" }
       else
         lasts << { :type => "Signature", :contrat_id => item.contrat_id, :signature_id => item.id,
           :at => item.updated_at, :by => item.updated_by, :action => "Modification" }
       end
     end


     for item in last_clotures
       if item.created_at == item.updated_at
         lasts << { :type => "Cloture", :contrat_id => item.contrat.id, :cloture_id => item.id,
           :at => item.created_at, :by => item.created_by, :action => "Création" }
       else
         lasts << { :type => "Cloture", :contrat_id => item.contrat.id, :cloture_id => item.id,
           :at => item.updated_at, :by => item.updated_by, :action => "Modification" }
       end
     end

     for item in last_refus
       if item.created_at == item.updated_at
         lasts << { :type => "Refus", :contrat_id => item.contrat.id, :refu_id => item.id,
           :at => item.created_at, :by => item.created_by, :action => "Création" }
       else
         lasts << { :type => "Refus", :contrat_id => item.contrat.id, :refu_id => item.id,
           :at => item.updated_at, :by => item.updated_by, :action => "Modification" }
       end
     end

     for item in last_echeancier
       if item.echeanciable_type == "Contrat"
         if @ids_viewables.include? item.echeanciable_id
           if item.created_at == item.updated_at
             lasts << { :type => "Echeancier", :contrat_id => item.echeanciable.id, :echeancier_id => item.id,
               :at => item.created_at, :by => item.created_by, :action => "Création" }
           else
             lasts << { :type => "Echeancier", :contrat_id => item.echeanciable.id, :echeancier_id => item.id,
               :at => item.updated_at, :by => item.updated_by, :action => "Modification" }
           end
         end
       else
         if @ids_viewables.include? item.echeanciable.contrat.id
           if item.created_at == item.updated_at
             lasts << { :type => "Echeancier", :contrat_id => item.echeanciable.contrat.id, :echeancier_id => item.id, :id => item.id,
                             :at => item.created_at, :by => item.created_by, :action => "Création" }
           else
             lasts << { :type => "Echeancier", :contrat_id => item.echeanciable.contrat.id, :echeancier_id => item.id, :id => item.id,
               :at => item.updated_at, :by => item.updated_by, :action => "Modification" }
           end
          end
       end
     end

     for item in last_contrat_files
         lasts << { :type => "Fichier", :contrat_id => item.contrat_id, :file => item,
                     :at => item.created_at, :by => item.created_by, :action => "Création" }
     end

     # On passe à la vue les 80 dernières actions réalisées classées par date
     @lasts = lasts.sort_by { |a| a[:at] }.reverse[0..80]
  end

end
