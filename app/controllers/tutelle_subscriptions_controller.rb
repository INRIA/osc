#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class TutelleSubscriptionsController < ApplicationController
  # GET /tutelle_subscriptions
  # GET /tutelle_subscriptions.xml
  def index
    projet = Projet.find(params[][:projet_id]) 
    @tutelle_subscriptions = projet.tutelle_subscriptions.find(:all)
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @tutelle_subscriptions.to_xml }
    end
  end

  # GET /tutelle_subscriptions/1
  # GET /tutelle_subscriptions/1.xml
  def show
    @tutelle_subscription = TutelleSubscription.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @tutelle_subscription.to_xml }
    end
  end

  # GET /tutelle_subscriptions/new
  def new
    @tutelle_subscription = TutelleSubscription.new
    @tutelle_subscription.projet = Projet.find(params[:projet_id]) 
  end

  # GET /tutelle_subscriptions/1;edit
  def edit
    @tutelle_subscription = TutelleSubscription.find(params[:id])
  end

  # POST /tutelle_subscriptions
  # POST /tutelle_subscriptions.xml
  def create
    @tutelle_subscription = TutelleSubscription.new(params[:tutelle_subscription])
    if /projets/.match(request.env["HTTP_REFERER"])
      @tutelle_subscription.projet = Projet.find(params[:projet_id]) 
    end
    if /tutelles/.match(request.env["HTTP_REFERER"])
      @tutelle_subscription.tutelle = Tutelle.find(params[:tutelle_id]) 
    end

   
    respond_to do |format|
      if @tutelle_subscription.save
        format.html {
          if request.xhr?
            # Mise à jour de la page d'édition des projets
            if /projets/.match(request.env["HTTP_REFERER"])
              # variables necessaires pour projets/list_tutelle_subscription
              @projet = Projet.find(params[:projet_id]) 
              @tutelle_subscriptions = @projet.tutelle_subscriptions.find(:all, :include => [:tutelle], :order => "tutelles.nom")
              # variables nécessaires pour projets/add_tutelle_subscription
              @tutelles = @projet.tutelles.find(:all, :order => "nom")
              @tutelles_restantes = Tutelle.find(:all, :order => "nom") - @tutelles
              render :update do |page|
                page.replace_html  'projetEditTutelles', :partial => 'projets/list_tutelle_subscriptions'
                page.replace_html  'add_tutelle_subscription', :partial => 'projets/add_tutelle_subscription'
                page.visual_effect :highlight, 'tutelle_subscription_'+@tutelle_subscription.id.to_s
              end
            end
            
            # Mise à jour de la page d'édition des tutelles
            if /tutelles/.match(request.env["HTTP_REFERER"])
              # variables necessaires pour tutelles/list_tutelle_subscriptions
              @tutelle = Tutelle.find(params[:tutelle_id]) 
              @tutelle_subscriptions = @tutelle.tutelle_subscriptions.find(:all, :include => [:projet], :order => "projets.nom")
              # variables nécessaires pour tutelles/add_tutelle_subscription
              @projets = @tutelle.projets.find(:all, :order => "nom")
              @projets_restants = Projet.find(:all, :order => "nom") - @projets
              render :update do |page|
                page.replace_html  'tutelleEditProjets', :partial => 'tutelles/list_tutelle_subscriptions'
                page.replace_html  'add_tutelle_subscription', :partial => 'tutelles/add_tutelle_subscription'
                page.visual_effect :highlight, 'tutelle_subscription_'+@tutelle_subscription.id.to_s
              end
            end
            
            
          else
           redirect_to edit_projet_path(@tutelle_subscription.projet) 
          end
          }
        format.xml  { head :created, :location => tutelle_subscription_url(@tutelle_subscription) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tutelle_subscription.errors.to_xml }
      end
    end
  end

  # PUT /tutelle_subscriptions/1
  # PUT /tutelle_subscriptions/1.xml
  def update
    @tutelle_subscription = TutelleSubscription.find(params[:id])

    respond_to do |format|
      if @tutelle_subscription.update_attributes(params[:tutelle_subscription])
        flash[:notice] = 'TutelleSubscription was successfully updated.'
        format.html { redirect_to tutelle_subscription_url(@tutelle_subscription) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tutelle_subscription.errors.to_xml }
      end
    end
  end

  # DELETE /tutelle_subscriptions/1
  # DELETE /tutelle_subscriptions/1.xml
  def destroy
    @tutelle_subscription = TutelleSubscription.find(params[:id])
    @tutelle = @tutelle_subscription.tutelle
    @projet = @tutelle_subscription.projet
    @tutelle_subscription.destroy

    respond_to do |format|
      format.html { 
        if request.xhr?
          # Mise à jour de la page d'édition des projets
          if /projets/.match(request.env["HTTP_REFERER"])
            # variables necessaires pour projets/list_tutelle_subscription
            @tutelle_subscriptions = @projet.tutelle_subscriptions.find(:all, :include => [:tutelle], :order => "tutelles.nom")
            # variables nécessaires pour projets/add_tutelle_subscription
            @tutelles = @projet.tutelles.find(:all, :order => "nom")
            @tutelles_restantes = Tutelle.find(:all, :order => "nom") - @tutelles
            render :update do |page|
              page.replace_html  'projetEditTutelles', :partial => 'projets/list_tutelle_subscriptions'
              page.replace_html  'add_tutelle_subscription', :partial => 'projets/add_tutelle_subscription'
              page.visual_effect :highlight, 'projetEditTutelles'
            end
          end
          
          # Mise à jour de la page d'édition des tutelles
          if /tutelles/.match(request.env["HTTP_REFERER"])
            # variables necessaires pour tutelles/list_tutelle_subscriptions
            @tutelle_subscriptions = @tutelle.tutelle_subscriptions.find(:all, :include => [:projet], :order => "projets.nom")
            # variables nécessaires pour tutelles/add_tutelle_subscription
            @projets = @tutelle.projets.find(:all, :order => "nom")
            @projets_restants = Projet.find(:all, :order => "nom") - @projets
            render :update do |page|
              page.replace_html  'tutelleEditProjets', :partial => 'tutelles/list_tutelle_subscriptions'
              page.replace_html  'add_tutelle_subscription', :partial => 'tutelles/add_tutelle_subscription'
              page.visual_effect :highlight, 'tutelleEditProjets'
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
