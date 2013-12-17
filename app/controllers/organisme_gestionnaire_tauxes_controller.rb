#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class OrganismeGestionnaireTauxesController < ApplicationController
  # GET /organisme_gestionnaire_tauxes
  # GET /organisme_gestionnaire_tauxes.xml
  def index
    @organisme_gestionnaire_tauxes = OrganismeGestionnaireTaux.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @organisme_gestionnaire_tauxes }
    end
  end

  # GET /organisme_gestionnaire_tauxes/1
  # GET /organisme_gestionnaire_tauxes/1.xml
  def show
    @organisme_gestionnaire_taux = OrganismeGestionnaireTaux.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organisme_gestionnaire_taux }
    end
  end

  # GET /organisme_gestionnaire_tauxes/new
  # GET /organisme_gestionnaire_tauxes/new.xml
  def new
    @organisme_gestionnaire_taux = OrganismeGestionnaireTaux.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organisme_gestionnaire_taux }
    end
  end

  # GET /organisme_gestionnaire_tauxes/1/edit
  def edit
    @organisme_gestionnaire_taux = OrganismeGestionnaireTaux.find(params[:id])
  end

  # POST /organisme_gestionnaire_tauxes
  # POST /organisme_gestionnaire_tauxes.xml
  def create
    @organisme_gestionnaire_taux = OrganismeGestionnaireTaux.new(params[:organisme_gestionnaire_taux])

    respond_to do |format|
      if @organisme_gestionnaire_taux.save
        flash[:notice] = 'OrganismeGestionnaireTaux was successfully created.'
        format.html { redirect_to(@organisme_gestionnaire_taux) }
        format.xml  { render :xml => @organisme_gestionnaire_taux, :status => :created, :location => @organisme_gestionnaire_taux }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @organisme_gestionnaire_taux.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /organisme_gestionnaire_tauxes/1
  # PUT /organisme_gestionnaire_tauxes/1.xml
  def update
    @organisme_gestionnaire_taux = OrganismeGestionnaireTaux.find(params[:id])

    respond_to do |format|
      if @organisme_gestionnaire_taux.update_attributes(params[:organisme_gestionnaire_taux])
        flash[:notice] = 'OrganismeGestionnaireTaux was successfully updated.'
        format.html { redirect_to(@organisme_gestionnaire_taux) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organisme_gestionnaire_taux.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /organisme_gestionnaire_tauxes/1
  # DELETE /organisme_gestionnaire_tauxes/1.xml
  def destroy
    @organisme_gestionnaire_taux = OrganismeGestionnaireTaux.find(params[:id])
    @organisme_gestionnaire_taux.destroy

    respond_to do |format|
      format.html { redirect_to(organisme_gestionnaire_tauxes_url) }
      format.xml  { head :ok }
    end
  end
end
