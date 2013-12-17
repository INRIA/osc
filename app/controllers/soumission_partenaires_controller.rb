#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SoumissionPartenairesController < ApplicationController
  # GET /soumission_partenaires
  # GET /soumission_partenaires.xml
  def index
    @soumission_partenaires = SoumissionPartenaire.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /soumission_partenaires/1
  # GET /soumission_partenaires/1.xml
  def show
    @soumission_partenaire = SoumissionPartenaire.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /soumission_partenaires/new
  def new
    @soumission_partenaire = SoumissionPartenaire.new
  end

  # GET /soumission_partenaires/1;edit
  def edit
    @soumission_partenaire = SoumissionPartenaire.find(params[:id])
  end

  # POST /soumission_partenaires
  # POST /soumission_partenaires.xml
  def create
    @soumission_partenaire = SoumissionPartenaire.new(params[:soumission_partenaire])

    respond_to do |format|
      if @soumission_partenaire.save
        flash[:notice] = 'SoumissionPartenaire was successfully created.'
        format.html { redirect_to soumission_partenaire_url(@soumission_partenaire) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /soumission_partenaires/1
  # PUT /soumission_partenaires/1.xml
  def update
    @soumission_partenaire = SoumissionPartenaire.find(params[:id])

    respond_to do |format|
      if @soumission_partenaire.update_attributes(params[:soumission_partenaire])
        flash[:notice] = 'SoumissionPartenaire was successfully updated.'
        format.html { redirect_to soumission_partenaire_url(@soumission_partenaire) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /soumission_partenaires/1
  # DELETE /soumission_partenaires/1.xml
  def destroy
    @soumission_partenaire = SoumissionPartenaire.find(params[:id])
    @soumission_partenaire.destroy

    respond_to do |format|
      format.html { redirect_to soumission_partenaires_url }
    end
  end
end
