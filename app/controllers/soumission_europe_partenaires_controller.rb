#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SoumissionEuropePartenairesController < ApplicationController
  # GET /soumission_europe_partenaires
  # GET /soumission_europe_partenaires.xml
  def index
    @soumission_europe_partenaires = SoumissionEuropePartenaire.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /soumission_europe_partenaires/1
  # GET /soumission_europe_partenaires/1.xml
  def show
    @soumission_europe_partenaire = SoumissionEuropePartenaire.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /soumission_europe_partenaires/new
  def new
    @soumission_europe_partenaire = SoumissionEuropePartenaire.new
  end

  # GET /soumission_europe_partenaires/1;edit
  def edit
    @soumission_europe_partenaire = SoumissionEuropePartenaire.find(params[:id])
  end

  # POST /soumission_europe_partenaires
  # POST /soumission_europe_partenaires.xml
  def create
    @soumission_europe_partenaire = SoumissionEuropePartenaire.new(params[:soumission_europe_partenaire])

    respond_to do |format|
      if @soumission_europe_partenaire.save
        flash[:notice] = 'SoumissionEuropePartenaire was successfully created.'
        format.html { redirect_to soumission_europe_partenaire_url(@soumission_europe_partenaire) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /soumission_europe_partenaires/1
  # PUT /soumission_europe_partenaires/1.xml
  def update
    @soumission_europe_partenaire = SoumissionEuropePartenaire.find(params[:id])

    respond_to do |format|
      if @soumission_europe_partenaire.update_attributes(params[:soumission_europe_partenaire])
        flash[:notice] = 'SoumissionEuropePartenaire was successfully updated.'
        format.html { redirect_to soumission_europe_partenaire_url(@soumission_europe_partenaire) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /soumission_europe_partenaires/1
  # DELETE /soumission_europe_partenaires/1.xml
  def destroy
    @soumission_europe_partenaire = SoumissionEuropePartenaire.find(params[:id])
    @soumission_europe_partenaire.destroy

    respond_to do |format|
      format.html { redirect_to soumission_europe_partenaires_url }
    end
  end
end
