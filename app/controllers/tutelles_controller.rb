#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class TutellesController < ApplicationController
  # GET /tutelles
  # GET /tutelles.xml
  def index
    @tutelles = Tutelle.find(:all, :order => "nom")

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @tutelles.to_xml }
    end
  end

  # GET /tutelles/1
  # GET /tutelles/1.xml
  def show
    @tutelle = Tutelle.find(params[:id])
    @projets = @tutelle.projets
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @tutelle.to_xml }
    end
  end

  # GET /tutelles/new
  def new
    @tutelle = Tutelle.new
  end

  # GET /tutelles/1;edit
  def edit
    @tutelle = Tutelle.find(params[:id])
    @tutelle_subscriptions = @tutelle.tutelle_subscriptions.find(:all, :include => [:projet], :order => "projets.nom")
    @projets = @tutelle.projets.find(:all, :order => "nom")
    @projets_restants = Projet.find(:all, :order => "nom") - @projets    
  end

  # POST /tutelles
  # POST /tutelles.xml
  def create
    @tutelle = Tutelle.new(params[:tutelle])

    respond_to do |format|
      if @tutelle.save
        flash[:notice] = 'La tutelle a bien été créée.'
        format.html { redirect_to tutelle_url(@tutelle) }
        format.xml  { head :created, :location => tutelle_url(@tutelle) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tutelle.errors.to_xml }
      end
    end
  end

  # PUT /tutelles/1
  # PUT /tutelles/1.xml
  def update
    @tutelle = Tutelle.find(params[:id])

    respond_to do |format|
      if @tutelle.update_attributes(params[:tutelle])
        flash[:notice] = 'La tutelle a bien été mise à jour.'
        format.html { redirect_to edit_tutelle_url(@tutelle) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tutelle.errors.to_xml }
      end
    end
  end

  def ask_delete
    @tutelle = Tutelle.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  # DELETE /tutelles/1
  # DELETE /tutelles/1.xml
  def destroy
    @tutelle = Tutelle.find(params[:id])
    @tutelle.destroy
    flash[:notice] = "La tutelle "+@tutelle.nom+"a été supprimée."
    respond_to do |format|
      format.html { redirect_to tutelles_url }
    end
  end
end
