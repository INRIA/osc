#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseFonctionnementFacturesController < ApplicationController
  # GET /depense_fonctionnement_factures
  # GET /depense_fonctionnement_factures.xml
  def index
    @depense_fonctionnement_factures = DepenseFonctionnementFacture.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @depense_fonctionnement_factures }
    end
  end

  # GET /depense_fonctionnement_factures/1
  # GET /depense_fonctionnement_factures/1.xml
  def show
    @depense_fonctionnement_facture = DepenseFonctionnementFacture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @depense_fonctionnement_facture }
    end
  end

  # GET /depense_fonctionnement_factures/new
  # GET /depense_fonctionnement_factures/new.xml
  def new
    @depense_fonctionnement_facture = DepenseFonctionnementFacture.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @depense_fonctionnement_facture }
    end
  end

  # GET /depense_fonctionnement_factures/1/edit
  def edit
    @depense_fonctionnement_facture = DepenseFonctionnementFacture.find(params[:id])
  end

  # POST /depense_fonctionnement_factures
  # POST /depense_fonctionnement_factures.xml
  def create
    params[:depense_fonctionnement_facture] = clean_date_params(params[:depense_fonctionnement_facture])
    @depense_fonctionnement_facture = DepenseFonctionnementFacture.new(params[:depense_fonctionnement_facture])

    respond_to do |format|
      if @depense_fonctionnement_facture.save
        @depense_fonctionnement_facture.depense_fonctionnement.verif=false
        @depense_fonctionnement_facture.depense_fonctionnement.save
        flash[:notice] = 'DepenseFonctionnementFacture was successfully created.'
        format.html { redirect_to(@depense_fonctionnement_facture) }
        format.xml  { render :xml => @depense_fonctionnement_facture, :status => :created, :location => @depense_fonctionnement_facture }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @depense_fonctionnement_facture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /depense_fonctionnement_factures/1
  # PUT /depense_fonctionnement_factures/1.xml
  def update
    params[:depense_fonctionnement_facture] = clean_date_params(params[:depense_fonctionnement_facture])
    @depense_fonctionnement_facture = DepenseFonctionnementFacture.find(params[:id])

    respond_to do |format|
      if @depense_fonctionnement_facture.update_attributes(params[:depense_fonctionnement_facture])
        @depense_fonctionnement_facture.depense_fonctionnement.verif=false
        @depense_fonctionnement_facture.depense_fonctionnement.save
        flash[:notice] = 'DepenseFonctionnementFacture was successfully updated.'
        format.html { redirect_to(@depense_fonctionnement_facture) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @depense_fonctionnement_facture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /depense_fonctionnement_factures/1
  # DELETE /depense_fonctionnement_factures/1.xml
  def destroy
    @depense_fonctionnement_facture = DepenseFonctionnementFacture.find(params[:id])
    @depense_fonctionnement_facture.destroy

    respond_to do |format|
      format.html { redirect_to(depense_fonctionnement_factures_url) }
      format.xml  { head :ok }
    end
  end
end
