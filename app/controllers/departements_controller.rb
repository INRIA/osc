#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
# Controleur des departements
#
# Controleur des type REST

class DepartementsController < ApplicationController
  # GET /departements
  # GET /departements.xml
  def index
    @departements = Departement.find(:all)
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @departements.to_xml }
    end
  end

  # GET /departements/1
  # GET /departements/1.xml
  def show
    @departement = Departement.find(params[:id])
    @projets = @departement.projets
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @departement.to_xml }
    end
  end

  # GET /departements/new
  def new
    @departement = Departement.new
    @laboratoires = Laboratoire.find(:all, :order => 'nom')
  end

  # GET /departements/1;edit
  def edit
    @departement = Departement.find(params[:id])
    @departement_subscriptions = @departement.departement_subscriptions.find(:all, :include => [:projet], :order => "projets.nom")   
    @projets_restants = Projet.find(
                                    :all, 
                                    :include => [:laboratoire_subscriptions, :departement_subscriptions], 
                                    :conditions => ["laboratoire_subscriptions.id IS NULL AND departement_subscriptions.id IS NULL"],
                                    :order => "nom"
                                    )
  end

  # POST /departements
  # POST /departements.xml
  def create
    @departement = Departement.new(params[:departement])

    respond_to do |format|
      if @departement.save
        flash[:notice] = 'Le département a bien été créé.'
        format.html { redirect_to departement_url(@departement) }
        format.xml  { head :created, :location => departement_url(@departement) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @departement.errors.to_xml }
      end
    end
  end

  # PUT /departements/1
  # PUT /departements/1.xml
  def update
    @departement = Departement.find(params[:id])

    respond_to do |format|
      if @departement.update_attributes(params[:departement])
        for sous_contrat in @departement.sous_contrats do
          if sous_contrat.ligne
            sous_contrat.ligne.update_nom        
          end
        end
        flash[:notice] = 'Le département a bien été mis à jour.'
        format.html { redirect_to departement_url(@departement) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @departement.errors.to_xml }
      end
    end
  end

  def ask_delete
    @departement = Departement.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  # DELETE /departements/1
  # DELETE /departements/1.xml
  def destroy
    @departement = Departement.find(params[:id])
    if @departement.sous_contrats.size == 0 && @departement.projets.size == 0
      flash[:notice] = "Le département "+@departement.nom+" a été supprimé"
      @departement.destroy
    else
      flash[:notice] = 'Ce département ne peut pas être supprimé car des contrats ou des projets lui sont liés'
    end
    respond_to do |format|
      format.html { redirect_to departements_url }
    end
  end
end
