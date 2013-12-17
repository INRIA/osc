#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class OrganismeGestionnairesController < ApplicationController
  include UIEnhancements::SubList
  helper :SubList
  
  sub_list 'OrganismeGestionnaireTauxes', 'organisme_gestionnaire' do |new_organisme_gestionnaire_taux|
  end
    
  # GET /organisme_gestionnaires
  # GET /organisme_gestionnaires.xml
  def index
    @organisme_gestionnaires = OrganismeGestionnaire.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @organisme_gestionnaires }
    end
  end

  # GET /organisme_gestionnaires/1
  # GET /organisme_gestionnaires/1.xml
  def show
    @organisme_gestionnaire = OrganismeGestionnaire.find(params[:id])
    @organisme_gestionnaire_tauxes = @organisme_gestionnaire.organisme_gestionnaire_tauxes

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organisme_gestionnaire }
    end
  end

  # GET /organisme_gestionnaires/new
  # GET /organisme_gestionnaires/new.xml
  def new
    @organisme_gestionnaire = OrganismeGestionnaire.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organisme_gestionnaire }
    end
  end

  # GET /organisme_gestionnaires/1/edit
  def edit
    @organisme_gestionnaire = OrganismeGestionnaire.find(params[:id])
  end

  # POST /organisme_gestionnaires
  # POST /organisme_gestionnaires.xml
  def create
    @organisme_gestionnaire = OrganismeGestionnaire.new(params[:organisme_gestionnaire])

    success = true
    success &&= initialize_organisme_gestionnaire_tauxes
    success &&= @organisme_gestionnaire.save

    respond_to do |format|
      if success
        flash[:notice] = "L'Organisme Gestionnaire a bien été créé."
        format.html { redirect_to(@organisme_gestionnaire) }
        format.xml  { render :xml => @organisme_gestionnaire, :status => :created, :location => @organisme_gestionnaire }
      else
        prepare_organisme_gestionnaire_tauxes
        format.html { render :action => "new" }
        format.xml  { render :xml => @organisme_gestionnaire.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /organisme_gestionnaires/1
  # PUT /organisme_gestionnaires/1.xml
  def update
    @organisme_gestionnaire = OrganismeGestionnaire.find(params[:id])
    
    @organisme_gestionnaire.update_attributes(params[:organisme_gestionnaire])
    
    success = true
    success &&= initialize_organisme_gestionnaire_tauxes
    success &&= @organisme_gestionnaire.save
    
    respond_to do |format|
      if success
        flash[:notice] = "L'Organisme Gestionnaire a bien été mis à jour."
        format.html { redirect_to(@organisme_gestionnaire) }
        format.xml  { head :ok }
      else
        prepare_organisme_gestionnaire_tauxes
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organisme_gestionnaire.errors, :status => :unprocessable_entity }
      end
    end
  end

  def ask_delete
    @organisme_gestionnaire = OrganismeGestionnaire.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end
  
  # DELETE /organisme_gestionnaires/1
  # DELETE /organisme_gestionnaires/1.xml
  def destroy
    @organisme_gestionnaire = OrganismeGestionnaire.find(params[:id])
    @organisme_gestionnaire.destroy 
    respond_to do |format|
      format.html {         
        redirect_to(organisme_gestionnaires_url) 
      }
      format.js {
        render :update do |page|
          page.call("RedBox.close")
          page.visual_effect :fade, 'og_'+@organisme_gestionnaire.id.to_s, :duration => 0.75
          page.delay(0.75) do
            page.replace_html 'og_'+@organisme_gestionnaire.id.to_s, ""
          end
        end
      }
      format.xml  { head :ok }
    end
  end
end
