#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SoumissionFrancePartenairesController < ApplicationController
  # GET /soumission_france_partenaires
  # GET /soumission_france_partenaires.xml
  def index
    @soumission_france_partenaires = SoumissionFrancePartenaire.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /soumission_france_partenaires/1
  # GET /soumission_france_partenaires/1.xml
  def show
    @soumission_france_partenaire = SoumissionFrancePartenaire.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /soumission_france_partenaires/new
  def new
    @soumission_france_partenaire = SoumissionFrancePartenaire.new
  end

  # GET /soumission_france_partenaires/1;edit
  def edit
    @soumission_france_partenaire = SoumissionFrancePartenaire.find(params[:id])
  end

  # POST /soumission_france_partenaires
  # POST /soumission_france_partenaires.xml
  def create
    @soumission_france_partenaire = SoumissionFrancePartenaire.new(params[:soumission_france_partenaire])

    respond_to do |format|
      if @soumission_france_partenaire.save
        flash[:notice] = 'SoumissionFrancePartenaire was successfully created.'
        format.html { redirect_to soumission_france_partenaire_url(@soumission_france_partenaire) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /soumission_france_partenaires/1
  # PUT /soumission_france_partenaires/1.xml
  def update
    @soumission_france_partenaire = SoumissionFrancePartenaire.find(params[:id])

    respond_to do |format|
      if @soumission_france_partenaire.update_attributes(params[:soumission_france_partenaire])
        flash[:notice] = 'SoumissionFrancePartenaire was successfully updated.'
        format.html { redirect_to soumission_france_partenaire_url(@soumission_france_partenaire) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /soumission_france_partenaires/1
  # DELETE /soumission_france_partenaires/1.xml
  def destroy
    @soumission_france_partenaire = SoumissionFrancePartenaire.find(params[:id])
    @soumission_france_partenaire.destroy

    respond_to do |format|
      format.html { redirect_to soumission_france_partenaires_url }
    end
  end
end
