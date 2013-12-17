#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class LaboratoireSubscriptionsController < ApplicationController
  # GET /laboratoire_subscriptions
  # GET /laboratoire_subscriptions.xml
  def index
    projet = Projet.find(params[:projet_id]) 
    @laboratoire_subscriptions = projet.laboratoire_subscriptions.find(:all)
    @type = 'projet'
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @laboratoire_subscriptions.to_xml }
    end
  end

  # GET /laboratoire_subscriptions/1
  # GET /laboratoire_subscriptions/1.xml
  def show
    @laboratoire_subscription = LaboratoireSubscription.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @laboratoire_subscription.to_xml }
    end
  end

  # GET /laboratoire_subscriptions/new
  def new
    @laboratoire_subscription = LaboratoireSubscription.new
    @laboratoire_subscription.projet = Projet.find(params[:projet_id]) 
  end

  # GET /laboratoire_subscriptions/1;edit
  def edit
    @laboratoire_subscription = LaboratoireSubscription.find(params[:id])
  end

  # POST /laboratoire_subscriptions
  # POST /laboratoire_subscriptions.xml
  def create
    @laboratoire_subscription = LaboratoireSubscription.new(params[:laboratoire_subscription])
    if /projets/.match(request.env["HTTP_REFERER"])
      @laboratoire_subscription.projet = Projet.find(params[:projet_id]) 
    end
    if /laboratoires/.match(request.env["HTTP_REFERER"])
      @laboratoire_subscription.laboratoire = Laboratoire.find(params[:laboratoire_id]) 
    end

    respond_to do |format|
      if @laboratoire_subscription.save
        format.html {
          if request.xhr?
            # Mise à jour de la page d'édition des projets
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
                page.visual_effect :highlight, 'laboratoire_subscription_'+@laboratoire_subscription.id.to_s
                page.visual_effect :highlight, 'add_departement_subscription'
              end
            end

            # Mise à jour de la page d'édition des laboratoires
            if /laboratoires/.match(request.env["HTTP_REFERER"])
              # variables necessaires pour laboratoires/list_laboratoire_subscriptions
              @laboratoire = Laboratoire.find(params[:laboratoire_id]) 
              @laboratoire_subscriptions = @laboratoire.laboratoire_subscriptions.find(:all, :include => [:projet], :order => "projets.nom")
              # variables nécessaires pour laboratoires/add_laboratoire_subscription
              @projets_restants = Projet.find(
              :all, 
              :include => [:laboratoire_subscriptions, :departement_subscriptions], 
              :conditions => ["laboratoire_subscriptions.id IS NULL AND departement_subscriptions.id IS NULL"],
              :order => "nom"
              )
              render :update do |page|
                page.replace_html  'laboratoireEditProjets', :partial => 'laboratoires/list_laboratoire_subscriptions'
                page.replace_html  'add_laboratoire_subscription', :partial => 'laboratoires/add_laboratoire_subscription'
                page.visual_effect :highlight, 'laboratoire_subscription_'+@laboratoire_subscription.id.to_s
              end
            end
          else
            redirect_to edit_projet_path(@laboratoire_subscription.projet)
          end
        }
        format.xml  { head :created, :location => laboratoire_subscription_url(@laboratoire_subscription.projet, @laboratoire_subscription) }
      else
        format.html {
          if request.xhr?
            render :update do |page|
              page.replace_html  'notice', "<p>Ajout impossible projet déjà associé à un département</p>"
              page.call('notice')
            end
          end
        }
        format.xml  { render :xml => @laboratoire_subscription.errors.to_xml }
      end
    end
  end

  # PUT /laboratoire_subscriptions/1
  # PUT /laboratoire_subscriptions/1.xml
  def update
    @laboratoire_subscription = LaboratoireSubscription.find(params[:id])
    respond_to do |format|
      if @laboratoire_subscription.update_attributes(params[:laboratoire_subscription])
        flash[:notice] = 'LaboratoireSubscription was successfully updated.'
        format.html { redirect_to laboratoire_subscription_url(@laboratoire_subscription.projet, @laboratoire_subscription) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @laboratoire_subscription.errors.to_xml }
      end
    end
  end

  # DELETE /laboratoire_subscriptions/1
  # DELETE /laboratoire_subscriptions/1.xml
  def destroy
    @laboratoire_subscription = LaboratoireSubscription.find(params[:id])
    @laboratoire = @laboratoire_subscription.laboratoire
    @projet = @laboratoire_subscription.projet
    @laboratoire_subscription.destroy
    respond_to do |format|
      format.html {
        if request.xhr?
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

          # Mise à jour de la page d'édition des laboratoires
          if /laboratoires/.match(request.env["HTTP_REFERER"])
            # variables necessaires pour laboratoires/list_laboratoire_subscriptions
            @laboratoire_subscriptions = @laboratoire.laboratoire_subscriptions.find(:all, :include => [:projet], :order => "projets.nom")
            # variables nécessaires pour laboratoires/add_laboratoire_subscription
            @projets_restants = Projet.find(
            :all, 
            :include => [:laboratoire_subscriptions, :departement_subscriptions], 
            :conditions => ["laboratoire_subscriptions.id IS NULL AND departement_subscriptions.id IS NULL"],
            :order => "nom"
            )
            render :update do |page|
              page.replace_html  'laboratoireEditProjets', :partial => 'laboratoires/list_laboratoire_subscriptions'
              page.replace_html  'add_laboratoire_subscription', :partial => 'laboratoires/add_laboratoire_subscription'
              page.visual_effect :highlight, 'laboratoireEditProjets'
            end
          end
        else        
         redirect_to :back 
        end
        } 
      format.xml  { head :ok }
    end
  end
end
