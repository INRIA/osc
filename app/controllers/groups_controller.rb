#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class GroupsController < ApplicationController
 
  # Action de recherche des groupes
  # GET /groups/search_by_name
  def search_by_name
    
    @admin = false
    if current_user.is_admin?
      @admin = true
    end
    @admin_fonc = false
    if current_user.is_fonc_admin?
      @admin_fonc = true
    end
    
    count = Group.find(:all, :conditions => ["nom LIKE ?", "%#{params[:query]}%"]).size    
    @groups = Group.paginate(:order => 'nom',
                          :per_page => 10,
                          :page => params[:page]||1,
                          :conditions => ["nom LIKE ?", "%#{params[:query]}%"])
        
    respond_to do |format|
      format.js { 
        render :update do |page|
          page.replace_html  'list', :partial => 'list'
          if params[:query] != ''
            page.replace_html 'ajax_result', ""+count.to_s+" groupe(s) trouvé(s)"
          else
            page.replace_html 'ajax_result',""+count.to_s+" groupes référencés"
          end
        end
      }
    end
  end
  
  # GET /groups
  # GET /groups.xml
  def index
    @admin = false
    if current_user.is_admin?
      @admin = true
    end
     @admin_fonc = false
    if current_user.is_fonc_admin?
      @admin_fonc = true
    end
    
    @count = Group.find(:all, :conditions => ["nom LIKE ?", "%#{params[:query]}%"]).size    
     
    @groups = Group.paginate(:order => 'nom',
                          :per_page => 20,
                          :page => params[:page]||1,
                          :conditions => ["nom LIKE ?", "%#{params[:query]}%"])
                        
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @groups.to_xml }
    end
  end
  

  # GET /groups/1
  # GET /groups/1.xml
  def show    
    @group = Group.find(params[:id])
    @users = @group.users.find(:all, :order => "nom")
    
    
    @contrats_editables = []
    @contrats_consultables = []
    @contrats_budget_editables = []
    @contrats_not_authorized = []
    
    @projets_editables = []
    @projets_consultables = []
    @projets_budget_editables = []

    # recuperation des roles du groupe
    # RQ : dans la BDD un role est differencie d'un droit par le fait qu'aucun id
    # de contrat n'est lie au role (donc authorizable_id=nil=false)
    @roles = []
    @group.roles.each {|role|
      if !role.authorizable_id
        if !@roles.collect{|r|r.name}.include?(role.name)
          @roles << role
        end
      end
    }

    #recuperation des contrats pour lesquels le groupe a des droits
    roles_name = ['consultation','modification','modification_budget']
    contrats = Contrat.find(:all,
      :include => [{:roles =>:groups}],
      :conditions => ["roles.name in (?) and groups.id = ? and roles.authorizable_type = 'Contrat'",roles_name,@group.id],
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
    
    #recuperation des projets pour lesquels le groupe a des droits
    projets = Projet.find(:all,
      :include => [{:roles =>:groups}],
      :conditions => ["roles.name in (?) and groups.id = ? and roles.authorizable_type = 'Projet'",roles_name,@group.id],
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
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @group.to_xml }
    end  
    
  end
  

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1;edit
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
    
    @group = Group.find(params[:id])
    @users = @group.users.find(:all, :order => "nom")
    @users_restant = User.find(:all, :order => "nom") - @users
    @memberships = @group.memberships.find(:all, :include => [:user], :order => "users.nom")

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
   
    #recuperation des contrats pour lesquels le groupe a des droits   
    roles_name = ['consultation','modification','modification_budget']
    contrats_with_droits = Contrat.find(:all,
      :include => [{:roles =>:groups}, :projets],
      :conditions => ["roles.name in (?) and groups.id = ? and roles.authorizable_type = 'Contrat'",roles_name,@group.id],
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

    #recuperation des projets pour lesquels le groupe a des droits
    projets = Projet.find(:all,
      :include => [{:roles =>:groups}],
      :conditions => ["roles.name in (?) and groups.id = ? and roles.authorizable_type = 'Projet'",roles_name,@group.id],
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

    # récupère les contrats pour lesquels le groupe n'a pas de droit
    # (en fonction des droits de l'utilisateur connecté)
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
      
      
      @group = Group.find(params[:group_id])
      type_droit = params[:type_droit]
      
      if(params[:type_ajout]=="projet")                  
         roles = Role.find(:all,:conditions=> ["authorizable_type = ? and authorizable_id = ?","Projet",params[:projet][:id]] )
             
         for role in roles
           group_right = GroupRight.find( :first, 
                                          :conditions => [ 'role_id = ? and group_id = ?', 
                                                           role.id, @group.id ] )
           if(group_right)
             group_right.destroy
           end
         end   
         
         new_role = Role.find( :first, 
                          :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id = ?', 
                                      type_droit, "Projet", params[:projet][:id] ] )
         if(!new_role)
           new_role= Role.new(params[:role])
           new_role.name = type_droit
           new_role.authorizable_type = "Projet"
           new_role.authorizable_id = params[:projet][:id]
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
      
      elsif (params[:type_ajout]=="contrat")
        id_objet = params[:contrat][:id]
        contrat = Contrat.find(id_objet)     
        
        roles = Role.find(:all,:conditions=> ["authorizable_type = ? and authorizable_id = ?","Contrat",params[:contrat][:id]] )
             
         for role in roles
           group_right = GroupRight.find( :first, 
                                          :conditions => [ 'role_id = ? and group_id = ?', 
                                                           role.id, @group.id ] )
           if(group_right)
             group_right.destroy
           end
         end   
        
        new_role = Role.find( :first, 
                              :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id = ?', 
                                          type_droit, "Contrat", id_objet ] )
        if(!new_role)
          new_role= Role.new(params[:role])
          new_role.name = type_droit
          new_role.authorizable_type = "Contrat"
          new_role.authorizable_id = id_objet
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
      elsif (params[:type_ajout]=="suppression")  
        sous_contrats = SousContrat.find(:all, :conditions => ["entite_id = ? and entite_type = ?",params[:suppression_projet][:id],"Projet" ])
        
        roles = Role.find(:all, 
                          :conditions => [ 'authorizable_type = ? and authorizable_id = ?', 
                                           "Projet", params[:suppression_projet][:id] ])
         for role in roles          
           group_right = GroupRight.find( :first, 
                                          :conditions => [ 'role_id = ? and group_id = ?', 
                                                            role.id, @group.id ] )
           if(group_right)
             group_right.destroy
           end
         end
                
        for sous_contrat in sous_contrats
          contrat = Contrat.find(sous_contrat.contrat_id)
          if contrat.is_editable? current_user
            roles = Role.find(:all,:conditions=> ["authorizable_type = ? and authorizable_id = ?","Contrat",contrat.id] )
            for role in roles
              group_right = GroupRight.find( :first, 
                                              :conditions => [ 'role_id = ? and group_id = ?', 
                                                               role.id, @group.id ] )
              if(group_right)
                group_right.destroy
              end
            end
          end
        end       
      end
    end
    redirect_to :controller => 'groups', :action => 'edit', :id => @group.id, :anchor => 'droits'
  end
  
  def delete_droit
    @group = Group.find(params[:group_id])
    

    authorizable_type = params[:authorizable_type]
    type_droit = params[:type_droit]
    
    if authorizable_type == 'Contrat'
      @contrat = Contrat.find(params[:contrat_id])
      @role = Role.find( :first, 
                       :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id = ?', 
                                        type_droit, "Contrat", @contrat.id ] )
    elsif authorizable_type == 'Projet'
      @projet = Projet.find(params[:projet_id])
      @role = Role.find( :first, 
                       :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id = ?', 
                                        type_droit, "Projet", @projet.id ] )
    end
    @group_right = GroupRight.find( :first, 
                                   :conditions => [ 'role_id = ? and group_id = ?', 
                                        @role.id, @group.id ] )
    
    @group_right.destroy 
    
    prepare_edit_and_delete_droit
    
    respond_to do |format|
      format.html { redirect_to :controller => 'groups', :action => 'edit', :id => @group.id, :anchor => 'droits' }
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
      @group = Group.find(params[:group_id])
      @role = Role.find(:first,
                        :conditions => [ 'name = ?', params[:role]])
      new_group_right = GroupRight.new(params[:group_right])
      new_group_right.role_id=@role.id
      new_group_right.group_id=@group.id
      if !new_group_right.save
          flash[:notice] = 'Erreur ! Ajout des droits au groupe impossible'
        end
      
    end
    redirect_to :controller => 'groups', :action => 'edit', :id => @group.id, :anchor => 'roles'     
  end
   
  def delete_role
    if !current_user.is_admin? and !current_user.is_fonc_admin?
      flash[:error] = "Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée."
      redirect_to :controller => 'contrats', :action => 'index'
    end
    @group = Group.find(params[:group_id])
    
    @group_right = GroupRight.find( :first, 
                                   :conditions => [ 'role_id = ? and group_id = ?', 
                                        params[:role_id], params[:group_id] ] )
   
    @group_right.destroy 
    respond_to do |format|
       format.html { redirect_to :controller => 'groups', :action => 'edit', :id => @group.id, :anchor => 'roles' }
       format.js {
         render :update do |page|
           page.replace_html  'roles', :partial => 'roles'
         end
       }
     end
    
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Le groupe à bien été créé.'
        format.html { redirect_to group_url(@group) }
        format.xml  { head :created, :location => group_url(@group) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors.to_xml }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Le groupe à bien été mis à jour.'
        format.html { redirect_to edit_group_url(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors.to_xml }
      end
    end
  end

  def ask_delete
    @group = Group.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end
  
  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])  
    @group.destroy
    flash[:notice] = ("Le groupe <strong>"+@group.nom+"</strong> à bien été supprimé.").html_safe()

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.xml  { head :ok }
    end
  end
end
