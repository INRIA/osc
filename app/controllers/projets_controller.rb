#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class ProjetsController < ApplicationController
  
  def search_by_name
    
    @admin = false
    if current_user.is_admin?
      @admin = true
    end
    @admin_fonc = false
    if current_user.is_fonc_admin?
      @admin_fonc = true
    end
    
    count = Projet.find(:all, :conditions => ["nom LIKE ?", "%#{params[:query]}%"]).size    
    @projets = Projet.paginate(:order => 'nom',
                          :per_page => 10,
                          :page => params[:page]||1,
                          :conditions => ["nom LIKE ?", "%#{params[:query]}%"])
        
    respond_to do |format|
      format.js { 
                  render :update do |page|
                    page.replace_html  'list', :partial => 'list'
                    if params[:query] != ''
                      page.replace_html 'ajax_result', ""+count.to_s+" projet(s) trouvé(s)"
                    else
                      page.replace_html 'ajax_result',""+count.to_s+" projets référencés"
                    end
                  end
                }
    end
  end
  
  
  
  # GET /projets
  # GET /projets.xml
  def index
    #@projets = Projet.find(:all, :order =>'nom')
    
        
    @count = Projet.find(:all, :conditions => ["nom LIKE ?", "%#{params[:query]}%"]).size    

    @projets = Projet.paginate(:order => 'nom',
                          :per_page => 10,
                          :page => params[:page]||1,
                          :conditions => ["nom LIKE ?", "%#{params[:query]}%"])
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @projets.to_xml }
    end
  end

  # GET /projets/1
  # GET /projets/1.xml
  def show
    @projet = Projet.find(params[:id])
    @laboratoires = @projet.laboratoires
    @tutelles = @projet.tutelles
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @projet.to_xml }
    end
  end

  # GET /projets/new
  def new
    @projet = Projet.new
    @non_modifiable = []
  end

  # GET /projets/1;edit
  def edit
    @projet = Projet.find(params[:id])
    
    @non_modifiable = []
    if (@projet.verrou == 'SI INRIA') and @projet.verrou_listchamps
      verrou_listchamps_tableau = @projet.verrou_listchamps.split(';')
      for champ in verrou_listchamps_tableau do
        @non_modifiable << champ
      end
    end
    
    @laboratoire_subscriptions = @projet.laboratoire_subscriptions.find(:all, :include => [:laboratoire], :order => "laboratoires.nom")
    @laboratoires = Laboratoire.find(:all, :order => "nom")
    
    @departements = Departement.find(:all, :order => "nom")
    @departement_subscriptions = @projet.departement_subscriptions
    
    @tutelle_subscriptions = @projet.tutelle_subscriptions.find(:all, :include => [:tutelle], :order => "tutelles.nom")
    @tutelles = @projet.tutelles.find(:all, :order => "nom")
    @tutelles_restantes = Tutelle.find(:all, :order => "nom") - @tutelles
  end

  # POST /projets
  # POST /projets.xml
  def create
    @projet = Projet.new(clean_date_params(params[:projet]))
    
    respond_to do |format|
      if @projet.save
        flash[:notice] = "L'équipe a bien été créée."
        format.html { redirect_to projet_url(@projet) }
        format.xml  { head :created, :location => projet_url(@projet) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @projet.errors.to_xml }
      end
    end
  end

  # PUT /projets/1
  # PUT /projets/1.xml
  def update
    @projet = Projet.find(params[:id])
    # en cas d'erreur ...
    @laboratoire_subscriptions = @projet.laboratoire_subscriptions.find(:all, :include => [:laboratoire], :order => "laboratoires.nom")
    @laboratoires = Laboratoire.find(:all, :order => "nom")
    @tutelle_subscriptions = @projet.tutelle_subscriptions.find(:all, :include => [:tutelle], :order => "tutelles.nom")
    @tutelles = @projet.tutelles.find(:all, :order => "nom")
    @tutelles_restantes = Tutelle.find(:all, :order => "nom") - @tutelles
    @non_modifiable = []
    respond_to do |format|
      if @projet.update_attributes(clean_date_params(params[:projet]))
        for sous_contrat in @projet.sous_contrats do
          if sous_contrat.ligne
            sous_contrat.ligne.update_nom        
          end
        end
        
        flash[:notice] = "L'équipe a bien été modifiée."
        format.html { redirect_to projet_url(@projet) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @projet.errors.to_xml }
      end
    end
  end

  def ask_delete
    @projet = Projet.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end

  # DELETE /projets/1
  # DELETE /projets/1.xml
  def destroy
    @projet = Projet.find(params[:id])
    if @projet.sous_contrats.size == 0
      flash[:notice] = 'L\'équipe '+@projet.nom+' a été supprimée.'
      roles = Role.find( :all, 
                       :conditions => [ 'authorizable_type = ? and authorizable_id = ?', 
                                         "Projet", @projet.id ] )
      #suppression des droits associes
      for role in roles
        group_rights = GroupRight.find( :all,:conditions => [ 'role_id = ?',role.id] )
        for group_right in group_rights
          group_right.destroy
        end
        users_with_role = User.find(:all, :include => :roles,:conditions => ["roles.id = ?",role.id])

        for user_with_role in users_with_role
          user_with_role.roles.delete( role )
        end
        role.destroy
      end

      @projet.destroy
    else
      flash[:notice] = 'Cette équipe ne peut pas être supprimée car des contrats lui sont liés'
    end
    respond_to do |format|
      format.html { redirect_to projets_url }
      format.xml  { head :ok }
    end
  end
end
