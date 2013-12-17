#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepartementSubscriptionsController < ApplicationController
  # GET /departement_subscriptions
  # GET /departement_subscriptions.xml
  def index
    @departement_subscriptions = DepartementSubscription.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @departement_subscriptions.to_xml }
    end
  end

  # GET /departement_subscriptions/1
  # GET /departement_subscriptions/1.xml
  def show
    @departement_subscription = DepartementSubscription.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @departement_subscription.to_xml }
    end
  end

  # GET /departement_subscriptions/new
  def new
    @departement_subscription = DepartementSubscription.new
  end

  # GET /departement_subscriptions/1;edit
  def edit
    @departement_subscription = DepartementSubscription.find(params[:id])
  end

  # POST /departement_subscriptions
  # POST /departement_subscriptions.xml
  def create
    @departement_subscription = DepartementSubscription.new(params[:departement_subscription])
    if /projets/.match(request.env["HTTP_REFERER"])
      @departement_subscription.projet = Projet.find(params[:projet_id]) 
    end
    if /departements/.match(request.env["HTTP_REFERER"])
      @departement_subscription.departement = Departement.find(params[:departement_id]) 
    end
    
    respond_to do |format|
      if @departement_subscription.save
        format.html {
          if request.xhr?
            # Mise à jour de la page d'édition des départements
            if /departements/.match(request.env["HTTP_REFERER"])
              # variables necessaires pour departements/_list_departement_subscription
              @departement = Departement.find(params[:departement_id])
              @departement_subscriptions = @departement.departement_subscriptions.find(:all, :include => [:projet], :order => "projets.nom")
              # variables necessaires pour departements/_add_departement_subscription
              @projets_restants = Projet.find(
                                              :all, 
                                              :include => [:laboratoire_subscriptions, :departement_subscriptions], 
                                              :conditions => ["laboratoire_subscriptions.id IS NULL AND departement_subscriptions.id IS NULL"],
                                              :order => "nom"
                                              )
              render :update do |page|
                page.replace_html  'departementEditProjets', :partial => 'departements/list_departement_subscriptions'
                page.replace_html  'add_departement_subscription', :partial => 'departements/add_departement_subscription'
                page.visual_effect :highlight, 'departement_subscription_'+@departement_subscription.id.to_s
              end
            end
                      
            # Mise à jour de la page d'édition des départements
            if /projets/.match(request.env["HTTP_REFERER"])
              # variables necessaires pour projets/list_tutelle_subscription
              @projet = Projet.find(params[:projet_id]) 
              # variables necessaires pour projets/list_laboratoire_subscriptions
              @laboratoire_subscriptions = @projet.laboratoire_subscriptions.find(:all, :include => [:laboratoire], :order => "laboratoires.nom")
              # variables necessaires pour projets/add_laboratoire_subscription
              @laboratoires = Laboratoire.find(:all, :order => "nom")
              # variables necessaires pour projets/list_departement_subscriptions
              @departement_subscriptions = @projet.departement_subscriptions
              # variables necessaires pour projets/add_departement_subscription
              @departements = Departement.find(:all, :order => "nom")
              render :update do |page|
                page.replace_html  'projetEditLaboratoires', :partial => 'projets/list_laboratoire_subscriptions'
                page.replace_html  'add_laboratoire_subscription', :partial => 'projets/add_laboratoire_subscription'
                page.replace_html  'projetEditDepartements', :partial => 'projets/list_departement_subscriptions'
                page.replace_html  'add_departement_subscription', :partial => 'projets/add_departement_subscription'
                page.visual_effect :highlight, 'departement_subscription_'+@departement_subscription.id.to_s
                page.visual_effect :highlight, 'add_departement_subscription'
              end
            end
          end
          }
        format.xml  { head :created, :location => departement_subscription_url(@departement_subscription) }
      else
        format.html { 
          if request.xhr?
            render :update do |page|
              page.replace_html  'notice', "<p>Ajout impossible projet déjà associé à un laboratoire</p>"
              page.call('notice')
            end
          end
        }
        format.xml  { render :xml => @departement_subscription.errors.to_xml }
      end
    end
  end

  # PUT /departement_subscriptions/1
  # PUT /departement_subscriptions/1.xml
  def update
    @departement_subscription = DepartementSubscription.find(params[:id])
    respond_to do |format|
      if @departement_subscription.update_attributes(params[:departement_subscription])
        flash[:notice] = 'DepartementSubscription was successfully updated.'
        format.html { redirect_to departement_subscription_url(@departement_subscription) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @departement_subscription.errors.to_xml }
      end
    end
  end

  # DELETE /departement_subscriptions/1
  # DELETE /departement_subscriptions/1.xml
  def destroy
    @departement_subscription = DepartementSubscription.find(params[:id])
    @departement = @departement_subscription.departement
    @projet = @departement_subscription.projet
    @departement_subscription.destroy

    respond_to do |format|
      format.html {
        if request.xhr?
          # Mise à jour de la page d'édition des départements
          if /departements/.match(request.env["HTTP_REFERER"])
            # variables necessaires pour departements/_list_departement_subscription
            @departement_subscriptions = @departement.departement_subscriptions.find(:all, :include => [:projet], :order => "projets.nom")
            # variables necessaires pour departements/_add_departement_subscription
            @projets_restants = Projet.find(
                                            :all, 
                                            :include => [:laboratoire_subscriptions, :departement_subscriptions], 
                                            :conditions => ["laboratoire_subscriptions.id IS NULL AND departement_subscriptions.id IS NULL"],
                                            :order => "nom"
                                            )
            render :update do |page|
              page.replace_html  'departementEditProjets', :partial => 'departements/list_departement_subscriptions'
              page.replace_html  'add_departement_subscription', :partial => 'departements/add_departement_subscription'
              page.visual_effect :highlight, 'departementEditProjets'
            end
          end
          
          # Mise à jour de la page d'édition des projets
          if /projets/.match(request.env["HTTP_REFERER"])
            # variables necessaires pour projets/list_laboratoire_subscriptions
            @laboratoire_subscriptions = @projet.laboratoire_subscriptions.find(:all, :include => [:laboratoire], :order => "laboratoires.nom")
            # variables necessaires pour projets/add_laboratoire_subscription
            @laboratoires = Laboratoire.find(:all, :order => "nom")
            # variables necessaires pour projets/list_departement_subscriptions
            @departement_subscriptions = @projet.departement_subscriptions
            # variables necessaires pour projets/add_departement_subscription
            @departements = Departement.find(:all, :order => "nom")
            render :update do |page|
              page.replace_html  'projetEditLaboratoires', :partial => 'projets/list_laboratoire_subscriptions'
              page.replace_html  'add_laboratoire_subscription', :partial => 'projets/add_laboratoire_subscription'
              page.replace_html  'projetEditDepartements', :partial => 'projets/list_departement_subscriptions'
              page.replace_html  'add_departement_subscription', :partial => 'projets/add_departement_subscription'
              page.visual_effect :highlight, 'add_laboratoire_subscription'
              page.visual_effect :highlight, 'add_departement_subscription'
            end
          end
        end
      }
      format.xml  { head :ok }
    end
  end
end
