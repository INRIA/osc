#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseSalaireFacturesController < ApplicationController
  # GET /depense_salaire_factures
  # GET /depense_salaire_factures.xml
  def index
    @depense_salaire_factures = DepenseSalaireFacture.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @depense_salaire_factures }
    end
  end

  # GET /depense_salaire_factures/1
  # GET /depense_salaire_factures/1.xml
  def show
    @depense_salaire_facture = DepenseSalaireFacture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @depense_salaire_facture }
    end
  end

  # GET /depense_salaire_factures/new
  # GET /depense_salaire_factures/new.xml
  def new
    @depense_salaire_facture = DepenseSalaireFacture.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @depense_salaire_facture }
    end
  end

  # GET /depense_salaire_factures/1/edit
  def edit
    @depense_salaire_facture = DepenseSalaireFacture.find(params[:id])
  end

  # POST /depense_salaire_factures
  # POST /depense_salaire_factures.xml
  def create
    params[:depense_salaire_facture] = clean_date_params(params[:depense_salaire_facture])
    @depense_salaire_facture = DepenseSalaireFacture.new(params[:depense_salaire_facture])

    respond_to do |format|
      if @depense_salaire_facture.save
        @depense_salaire_facture.depense_salaire.verif=false
        @depense_salaire_facture.depense_salaire.save
        flash[:notice] = 'DepenseSalaireFacture was successfully created.'
        format.html { redirect_to(@depense_salaire_facture) }
        format.xml  { render :xml => @depense_salaire_facture, :status => :created, :location => @depense_salaire_facture }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @depense_salaire_facture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /depense_salaire_factures/1
  # PUT /depense_salaire_factures/1.xml
  def update
    params[:depense_salaire_facture] = clean_date_params(params[:depense_salaire_facture])
    @depense_salaire_facture = DepenseSalaireFacture.find(params[:id])

    respond_to do |format|
      if @depense_salaire_facture.update_attributes(params[:depense_salaire_facture])
        @depense_salaire_facture.depense_salaire.verif=false
        @depense_salaire_facture.depense_salaire.save
        flash[:notice] = 'DepenseSalaireFacture was successfully updated.'
        format.html { redirect_to(@depense_salaire_facture) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @depense_salaire_facture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /depense_salaire_factures/1
  # DELETE /depense_salaire_factures/1.xml
  def destroy
    @depense_salaire_facture = DepenseSalaireFacture.find(params[:id])
    @depense_salaire_facture.destroy

    respond_to do |format|
      format.html { redirect_to(depense_salaire_factures_url) }
      format.xml  { head :ok }
    end
  end
end
