#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class TutelleLogosController < ApplicationController
  # GET /tutelle_logos
  # GET /tutelle_logos.xml
  def index
    tutelle = Tutelle.find(params[:tutelle_id]) 
    @tutelle_logos = tutelle.tutelle_logos.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @tutelle_logos.to_xml }
    end
  end

  # GET /tutelle_logos/1
  # GET /tutelle_logos/1.xml
  def show
    @tutelle_logo = TutelleLogo.find(params[:id])
    @tutelle_logo.tutelle = Tutelle.find(params[:tutelle_id]) 

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @tutelle_logo.to_xml }
    end
  end

  # GET /tutelle_logos/new
  def new
    @tutelle_logo = TutelleLogo.new
    @tutelle_logo.tutelle = Tutelle.find(params[:tutelle_id]) 
  end

  # GET /tutelle_logos/1;edit
  def edit
    @tutelle_logo = TutelleLogo.find(params[:id])
  end

  # POST /tutelle_logos
  # POST /tutelle_logos.xml
  def create
    @tutelle_logo = TutelleLogo.new(params[:tutelle_logo])
    @tutelle_logo.tutelle = Tutelle.find(params[:tutelle_id]) 
    respond_to do |format|
      if @tutelle_logo.save
        flash[:notice] = 'Le logo à été ajouté avec succès.'
        format.html { redirect_to edit_tutelle_path(@tutelle_logo.tutelle) }
        format.xml  { head :created, :location => tutelle_logo_url(@tutelle_logo) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tutelle_logo.errors.to_xml }
      end
    end
  end

  # PUT /tutelle_logos/1
  # PUT /tutelle_logos/1.xml
  def update
    @tutelle_logo = TutelleLogo.find(params[:id])
    @tutelle_logo.tutelle = Tutelle.find(params[:tutelle_id])
    respond_to do |format|
      if @tutelle_logo.update_attributes(params[:tutelle_logo])
        flash[:notice] = "Le logo à été mise à jour avec succès."
        format.html { redirect_to edit_tutelle_path(@tutelle_logo.tutelle) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tutelle_logo.errors.to_xml }
      end
    end
  end

  # DELETE /tutelle_logos/1
  # DELETE /tutelle_logos/1.xml
  def destroy
    @tutelle_logo = TutelleLogo.find(params[:id])
    @tutelle_logo.destroy

    respond_to do |format|
      format.html {   redirect_to :back  }
      format.xml  { head :ok }
    end
  end
end
