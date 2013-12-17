#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class LaboratoiresController < ApplicationController
  # GET /laboratoires
  # GET /laboratoires.xml
  def index
    @laboratoires = Laboratoire.find(:all, :order => "nom")
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @laboratoires.to_xml }
    end
  end

  # GET /laboratoires/1
  # GET /laboratoires/1.xml
  def show
    @laboratoire = Laboratoire.find(params[:id])
    @projets = @laboratoire.projets
    @departements = @laboratoire.departements
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @laboratoire.to_xml }
    end
  end

  # GET /laboratoires/new
  def new
    @laboratoire = Laboratoire.new
  end


  # TEST TEST TEST
  # def add_projet
  #  @laboratoire_subscription = LaboratoireSubscription.new(params[:laboratoire_subscription])
  #  @laboratoire_subscription.save!
  #end

  # GET /laboratoires/1;edit
  def edit
    @laboratoire = Laboratoire.find(params[:id])
    @departements = @laboratoire.departements
    @laboratoire_subscriptions = @laboratoire.laboratoire_subscriptions.find(:all, :include => [:projet], :order => "projets.nom")   
    @projets_restants = Projet.find(
                                    :all, 
                                    :include => [:laboratoire_subscriptions, :departement_subscriptions], 
                                    :conditions => ["laboratoire_subscriptions.id IS NULL AND departement_subscriptions.id IS NULL"], 
                                    :order => "nom"
                                    )
  end

  # POST /laboratoires
  # POST /laboratoires.xml
  def create
    @laboratoire = Laboratoire.new(params[:laboratoire])

    respond_to do |format|
      if @laboratoire.save
        flash[:notice] = 'Le laboratoire a bien été créé.'
        format.html { redirect_to laboratoire_url(@laboratoire) }
        format.xml  { head :created, :location => laboratoire_url(@laboratoire) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @laboratoire.errors.to_xml }
      end
    end
  end

  # PUT /laboratoires/1
  # PUT /laboratoires/1.xml
  def update
    @laboratoire = Laboratoire.find(params[:id])

    respond_to do |format|
      if @laboratoire.update_attributes(params[:laboratoire])
        for sous_contrat in @laboratoire.sous_contrats do
          if sous_contrat.ligne
            sous_contrat.ligne.update_nom        
          end
        end
        
        flash[:notice] = 'Le laboratoire a bien été mis à jour.'
        format.html { redirect_to laboratoire_url(@laboratoire) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @laboratoire.errors.to_xml }
      end
    end
  end

  def ask_delete
    @laboratoire = Laboratoire.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  # DELETE /laboratoires/1
  # DELETE /laboratoires/1.xml
  def destroy
    @laboratoire = Laboratoire.find(params[:id])    
    if @laboratoire.sous_contrats.size == 0 && @laboratoire.projets.size == 0
      flash[:notice] = "Le laboratoire "+@laboratoire.nom+" a été supprimé"
      @laboratoire.destroy
    else
      flash[:notice] = 'Ce laboratoire ne peut pas être supprimé car des contrats ou des projets lui sont liés'
    end
    respond_to do |format|
      format.html { redirect_to laboratoires_url }
    end
  end
end
