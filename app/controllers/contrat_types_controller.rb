#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class ContratTypesController < ApplicationController
  
  
  # GET /contrat_types
  # GET /contrat_types.xml
  def index
    @contrat_types = ContratType.find(:all, :order => "nom")
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @contrat_types.to_xml }
    end
  end

  # GET /contrat_types/1
  # GET /contrat_types/1.xml
  def show
    @contrat_type = ContratType.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @contrat_type.to_xml }
    end
  end

  # GET /contrat_types/new
  def new
    @contrat_types = ContratType.find(:all)
    @contrat_type = ContratType.new
  end

  # GET /contrat_types/1;edit
  def edit
    @contrat_types = ContratType.find(:all, :order => "nom")
    @contrat_type = ContratType.find(params[:id])
  end

  # POST /contrat_types
  # POST /contrat_types.xml
  def create
    @contrat_types = ContratType.find(:all, :order => "nom")
    @contrat_type = ContratType.new(params[:contrat_type])

    respond_to do |format|
      if @contrat_type.save
        flash[:notice] = 'Le type de contrat à été créé.'
        format.html { redirect_to contrat_types_url }
        format.xml  { head :created, :location => contrat_type_url(@contrat_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contrat_type.errors.to_xml }
      end
    end
  end

  # PUT /contrat_types/1
  # PUT /contrat_types/1.xml
  def update
    @contrat_types = ContratType.find(:all, :order => "nom")
    @contrat_type = ContratType.find(params[:id])

    respond_to do |format|
      if @contrat_type.update_attributes(params[:contrat_type])
        flash[:notice] = 'Le type de contrat à bien été mis à jour.'
        format.html { redirect_to contrat_types_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contrat_type.errors.to_xml }
      end
    end
  end

  def ask_delete
    @contrat_type = ContratType.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end
  
  # DELETE /contrat_types/1
  # DELETE /contrat_types/1.xml
  def destroy
    @contrat_type = ContratType.find(params[:id])
    @contrat_type.destroy  
    
    respond_to do |format|
      format.html { redirect_to contrat_types_url }
      format.js {
        render :update do |page|
          page.call("RedBox.close")
          page.visual_effect :fade, 'ct_'+@contrat_type.id.to_s, :duration => 0.75
          page.delay(0.75) do
            page.replace_html 'ct_'+@contrat_type.id.to_s, ""
          end
        end
      }
      format.xml  { head :ok }
    end
  end
end
