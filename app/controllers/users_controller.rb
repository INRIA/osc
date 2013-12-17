#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class UsersController < ApplicationController

  def update_photos_with_ose
    require 'net/https'
    users = User.find(:all, :order => "nom, prenom")
    osePeople = OseApi.new(OSE_URL, OSE_PORT, OSE_API_GET_DOSSIER_PATH, OSE_API_KEY)
    for user in users
      reponse = osePeople.find_by_login user.login
      if reponse['status'] == 'ok' && reponse['has_answers']
        photo = reponse['answers'][0]['photo'][0]['content']
        if user.photose != photo && user.update_attribute('photose', photo)
          @text = @text.to_s + "Mise à jour de "+user.nom+" "+user.prenom+" : ajout d'une photo à partir de OSE<br />"
        end
      end
    end
    
    @admin = false
    if current_user.is_admin?
      @admin = true
    end
    @admin_fonc = false
    if current_user.is_fonc_admin?
      @admin_fonc = true
    end
    
    @count = User.find(:all, :conditions => ["nom LIKE ?", "%#{params[:query]}%"]).size    

    @users = User.paginate(:order => 'nom, prenom',
                          :per_page => 8,
                          :page => params[:page]||1,
                          :conditions => ["nom LIKE ?", "%#{params[:query]}%"])
    
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html  'notice', :partial => 'update_photos_with_ose'
          page.replace_html  'list', :partial => 'list'
        end
      }
    end
  end
  
  def update_photo_with_ose
    @user = User.find(params[:id])
    osePeople = OseApi.new(OSE_URL, OSE_PORT, OSE_API_GET_DOSSIER_PATH, OSE_API_KEY)
    reponse = osePeople.find_by_login @user.login
    if reponse['status'] == 'ok'
      if reponse['has_answers']
        photo = reponse['answers'][0]['photo'][0]['content']
        if @user.photose != photo && @user.update_attribute('photose', photo)
          flash[:notice] = "Mise à jour de l'utilisateur : ajout d'une photo à partir de OSE"
        end
      else
        flash[:notice] = "Personne non trouvée dans OSE."
      end
    else
      flash[:notice] = "Impossible de contacter le web service OSE."
    end
    respond_to do |format|
      format.html { redirect_to edit_user_url(@user)+"#photo" }
    end
  end

  # Recherche par nom dans des bases Ldap référencées
  def search
    @research = params[:research]
    if @research[:nom].size > 0
      # On recherche dans les bases ldap définies dans le fichier de conf
      # on stocke le résultat dans un tableau
      @result_search = Array.new(BASES_LDAP.size,Hash.new)
      i=0
      BASES_LDAP.each do |ldap|
        res ={"type"=>ldap["type"],"flag"=>false,"result"=>""}
        host = ldap["host"]
        base = ldap["base"]
        port = ldap["port"]
        filter = Net::LDAP::Filter.eq("sn",@research[:nom]+'*')        
        begin        
          
          if port == 389
            conn = Net::LDAP.new(:host=>host, :port=>port)
          else
            conn = Net::LDAP.new(:host=>host, :port=>port, :encryption => :simple_tls)
          end
          res["results"] = conn.search(:base => base, :filter => filter)
          res["flag"]=true
          
        rescue Errno::ETIMEDOUT
        rescue Net::LDAP::LdapError
        end
        @result_search[i]=res
        i=i+1
      end
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          if @research[:nom].size < 1
            page.replace_html  'results', "<p>Erreur : Merci de saisir au moins un caractère</p>"
          else
            page.replace_html  'results', :partial => 'search'
          end
          page.visual_effect :highlight, 'results'
        end
      }
    end
  end

  # Action de recherche des utilisateurs
  # GET /users/search_by_name
  def search_by_name
    
    @admin = false
    if current_user.is_admin?
      @admin = true
    end
    @admin_fonc = false
    if current_user.is_fonc_admin?
      @admin_fonc = true
    end
    
    count = User.find(:all, :conditions => ["nom LIKE ?", "%#{params[:query]}%"]).size    
    @users = User.paginate(:order => 'nom, prenom',
                          :per_page => 8,
                          :page => params[:page]||1,
                          :conditions => ["nom LIKE ?", "%#{params[:query]}%"])
        
    respond_to do |format|
      format.js { 
        render :update do |page|
          page.replace_html  'list', :partial => 'list'
          if params[:query] != ''
            page.replace_html 'ajax_result', ""+count.to_s+" utilisateur(s) trouvé(s)"
          else
            page.replace_html 'ajax_result',""+count.to_s+" utilisateurs référencés"
          end
        end
      }
    end
  end

  # GET /users
  def index
    if !current_user.is_contrat_admin? and !current_user.is_admin? and !current_user.is_fonc_admin?
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
      redirect_to :controller => 'contrats', :action => 'index'
    end
    
    @admin = false
    if current_user.is_admin?
      @admin = true
    end
    @admin_fonc = false
    if current_user.is_fonc_admin?
      @admin_fonc = true
    end
    
    @count = User.find(:all, :conditions => ["nom LIKE ?", "%#{params[:query]}%"]).size    

    @users = User.paginate(:order => 'nom, prenom',
                          :per_page => 8,
                          :page => params[:page]||1,
                          :conditions => ["nom LIKE ?", "%#{params[:query]}%"])
  end


  # GET /users/1
  def show
    @user = User.find(params[:id])
    @contrats_editables = []
    @contrats_consultables = []
    @contrats_budget_editables = []
    @contrats_not_authorized = []
    @groups = @user.groups.find(:all, :order => "nom")

    @projets_editables = []
    @projets_consultables = []
    @projets_budget_editables = []

    # recuperation des roles de l'utilisateur
    @roles = []
    @user.roles.each{|role|
      # dans la BDD un role est differencie d'un droit par le fait qu'aucun id
      # de contrat n'est lie au role (donc authorizable_id=nil=false)
      if !role.authorizable_id
        if !@roles.collect{|r|r.name}.include?(role.name)
          @roles << role
        end
      end

    }
    @groups.each {|group|
      group.roles.each {|role|
        if !role.authorizable_id
          if !@roles.collect{|r|r.name}.include?(role.name)
            @roles << role
          end
        end
      }
    }

    #recuperation des contrats pour lesquels l'utilisateur a des droits specifiques
    roles_name = ['consultation','modification','modification_budget']
    contrats = Contrat.find(:all,
      :include => [{:roles =>:users}],
      :conditions => ["roles.name in (?) and users.id = ? and roles.authorizable_type = 'Contrat'",roles_name,@user.id],
      :order => "acronyme")
    for contrat in contrats
      contrat.roles.each {|role|
        if role.name == "modification"
          @contrats_editables << contrat
        elsif role.name == "modification_budget"
          @contrats_budget_editables << contrat
        else
          @contrats_consultables << contrat
        end
      }
    end
    
    #recuperation des projets pour lesquels l'utilisateur a des droits
    projets = Projet.find(:all,
      :include => [{:roles =>:users}],
      :conditions => ["roles.name in (?) and users.id = ? and roles.authorizable_type = 'Projet'",roles_name,@user.id],
      :order => "projets.nom")
    for projet in projets
      projet.roles.each {|role|
        if role.name == "modification"
          @projets_editables << projet
        elsif role.name == "modification_budget"
          @projets_budget_editables << projet
        else
          @projets_consultables << projet
        end
      }
    end
    
  end    

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1;edit
  def edit
    prepare_edit_and_delete_droit
  end
  
  def prepare_edit_and_delete_droit
    if !current_user.is_contrat_admin? and !current_user.is_admin? and !current_user.is_fonc_admin?
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
      redirect_to :controller => 'contrats', :action => 'index'
    end

    @admin = false
    if current_user.is_admin?
      @admin = true
    end
    @admin_fonc = false
    if current_user.is_fonc_admin?
      @admin_fonc = true
    end

    
    @user = User.find(params[:id])
    @groups = @user.groups.find(:all, :order => "nom")
    @groups_restant = Group.find(:all, :order => "nom") - @groups
    @memberships = @user.memberships.find(:all, :include => [:group], :order => "groups.nom")
    

    @contrats_editables = []
    @contrats_consultables = []
    @contrats_not_authorized = []
    @contrats_budget_editables = []
    @projet_with_contrat_editable_to_add = []
    @projet_with_contrat_editable_to_delete = []
    @projets_editables = []
    @projets_consultables = []
    @projets_budget_editables = []
    projet_all = Projet.find(:all, :order => "nom")
    @projet_with_contrat_editable_to_delete = projet_all
    
    #recuperation des contrats pour lesquels l'utilisateur a des droits  
    roles_name = ['consultation','modification','modification_budget']
    contrats_with_droits = Contrat.find(:all,
      :include => [{:roles =>:users}, :projets],
      :conditions => ["roles.name in (?) and users.id = ? and roles.authorizable_type = 'Contrat'",roles_name,@user.id],
      :order => "acronyme")
    for contrat in contrats_with_droits
      contrat.roles.each {|role|
        if role.name == "modification"
          @contrats_editables << contrat
        elsif role.name == "modification_budget"
          @contrats_budget_editables << contrat
        else
          @contrats_consultables << contrat
        end
      }
    end

    #recuperation des projets pour lesquels l'utilisateur a des droits
    projets = Projet.find(:all,
      :include => [{:roles =>:users}],
      :conditions => ["roles.name in (?) and users.id = ? and roles.authorizable_type = 'Projet'",roles_name,@user.id],
      :order => "projets.nom")
    for projet in projets
      projet.roles.each {|role|
        if role.name == "modification"
          @projets_editables << projet
        elsif role.name == "modification_budget"
          @projets_budget_editables << projet
        else
          @projets_consultables << projet
        end
      }
    end
    
    # récupère les contrats pour lesquels le user n'a pas de droit
    # (qui sont fonction des droits de l'utilisateur connecté)
    if @admin || @admin_fonc
      @contrats_not_authorized = Contrat.find(:all, :include => :projets, :order => "acronyme") #- contrats_with_droits
      @projet_with_contrat_editable_to_add = projet_all

    else
      authorized_contrat = Contrat.find(:all,
      :include => [{:roles=> :users}, :projets],
      :conditions => ["roles.name in (?) and users.id = ?",roles_name,current_user.id],
      :order => "acronyme")
      authorized_contrat += Contrat.find(:all,
      :include => [{:roles => {:groups => :users}}, :projets],
      :conditions => ["roles.name in (?) and users.id = ?",roles_name,current_user.id],
      :order => "acronyme")
      @contrats_not_authorized = authorized_contrat #- contrats_with_droits
      
      authorized_projet = Projet.find(:all,
      :include => [{:roles=> :users}],
      :conditions => ["roles.name in (?) and users.id = ?",roles_name,current_user.id],
      :order => "nom")
      authorized_projet += Projet.find(:all,
      :include => [{:roles => {:groups => :users}}],
      :conditions => ["roles.name in (?) and users.id = ?",roles_name,current_user.id],
      :order => "nom")
      @projet_with_contrat_editable_to_add = authorized_projet

    end

  end
  
  def add_droit
     if request.post?
       @user = User.find(params[:user_id])
       type_droit = params[:type_droit]
        
       if(params[:type_ajout]=="projet")
         
         roles = Role.find(:all,:conditions=> ["authorizable_type = ? and authorizable_id = ?","Projet",params[:projet][:id]] )
         projet = Projet.find(params[:projet][:id])    
         
         for role in roles
           @user.has_no_role(role.name, projet )                                             
         end   
         
         new_role = Role.find( :first, 
                          :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id = ?', 
                                      type_droit, "Projet", params[:projet][:id] ] )
        
         projet.accepts_role type_droit, @user
       
       elsif (params[:type_ajout]=="contrat")
         id_objet = params[:contrat][:id]
         contrat = Contrat.find(id_objet)
         roles = Role.find(:all,:conditions=> ["authorizable_type = ? and authorizable_id = ?","Contrat",params[:contrat][:id]] )
         for role in roles
           @user.has_no_role(role.name, contrat )                                             
         end
         contrat.accepts_role type_droit, @user
         # Envoi d'un email à l'utilisateur ayant un nouveau droit dans l'application
         Notifier.send_mail_for_add_roles(type_droit, Contrat.find_by_id(params[:contrat][:id]), @user, current_user ).deliver
       
       elsif (params[:type_ajout]=="suppression")        
         roles = Role.find(:all,:conditions=> ["authorizable_type = ? and authorizable_id = ?","Projet",params[:suppression_projet][:id]] )
         projet = Projet.find(params[:suppression_projet][:id])    
         
         for role in roles
           @user.has_no_role(role.name, projet )                                             
         end   
         
         sous_contrats = SousContrat.find(:all, :conditions=> ["entite_id = ? and entite_type = ?",params[:suppression_projet][:id],"Projet" ])
         for sous_contrat in sous_contrats
           contrat = Contrat.find(sous_contrat.contrat_id)
           if contrat.is_editable? current_user
             roles = Role.find(:all,:conditions=> ["authorizable_type = ? and authorizable_id = ?","Contrat",contrat.id] )
             for role in roles
               @user.has_no_role(role.name, contrat )
             end
           end
         end
       end
     end
     redirect_to :controller => 'users', :action => 'edit', :id => @user.id, :anchor => 'droits'
   end
  
   def delete_droit
     @user = User.find(params[:id])

     authorizable_type = params[:authorizable_type]
     if authorizable_type == 'Contrat'
       @contrat = Contrat.find(params[:contrat_id])
       ref='dc_'+@contrat.id.to_s
       @user.has_no_role(params[:type_droit], @contrat)
     elsif authorizable_type == 'Projet'
       @projet = Projet.find(params[:projet_id])
       ref='dp_'+@projet.id.to_s
       @user.has_no_role(params[:type_droit], @projet)
     end
     prepare_edit_and_delete_droit
     
     respond_to do |format|
       format.html { redirect_to :controller => 'users', :action => 'edit', :id => @user.id, :anchor => 'droits' }
       format.js {
         render :update do |page|
           page.replace_html  'droits', :partial => 'droits'
         end
       }
     end
     
   end
   
   def add_role
     if !current_user.is_admin? and !current_user.is_fonc_admin?
       flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
       redirect_to :controller => 'contrats', :action => 'index'
     end
     if request.post?
       @user = User.find(params[:user_id])
       @user.has_role(params[:role])
     end
     redirect_to :controller => 'users', :action => 'edit', :id => @user.id, :anchor => 'roles'     
   end
   
   def delete_role
     if !current_user.is_admin? and !current_user.is_fonc_admin?
       flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
       redirect_to :controller => 'contrats', :action => 'index'
     end
     @role = Role.find(params[:role_id])
     @user = User.find(params[:user_id])
     @user.has_no_role(@role.name, @contrat )
     respond_to do |format|
       format.html { redirect_to :controller => 'users', :action => 'edit', :id => @user.id, :anchor => 'roles' }
       format.js {
         render :update do |page|
           page.replace_html  'roles', :partial => 'roles'
         end
       }
     end
     
   end
  
  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        flash[:notice] = "L'utilisateur à bien été créé."
        if !@user.ldap?
          Notifier.send_mail_for_add_local_user(@user, params[:user][:password]).deliver
        end
        format.html { redirect_to edit_user_url(@user) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
    @groups = @user.groups.find(:all, :order => "nom")
    @groups_restant = Group.find(:all, :order => "nom") - @groups
    @memberships = @user.memberships.find(:all, :include => [:group], :order => "groups.nom")
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html {
          if params[:myaction] == "photo"
            flash[:notice] = "La photo à bien été mis à jour"
            redirect_to :action => 'edit', :anchor => "photo"
          elsif !params[:user][:login].nil?
            if !@user.ldap?
              Notifier.send_mail_for_add_local_user(@user, params[:user][:password]).deliver
            end
            flash[:notice] = "Les paramètres d'authentification ont été mis à jour"
            redirect_to :action => 'edit', :anchor => "authentification"
          else 
            flash[:notice] = "L'identité de l'utilisateur à bien été mis à jour"
            redirect_to :action => 'edit', :anchor => "identite"
          end
        }
      else
        format.html { render :action => "edit"}
      end
    end
  end

  def ask_delete
    @user = User.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end
  
  # DELETE /users/1
  def destroy
      @user = User.find(params[:id])
      @user.destroy
      flash[:notice] = ("L'utilisateur <strong>"+@user.prenom+" "+@user.nom+"</strong> à bien été supprimé.").html_safe()

      respond_to do |format|
        format.html { redirect_to users_url }
      end
  end
end
