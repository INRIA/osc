#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseNonVentileeFacturesController < ApplicationController
  # GET /depense_non_ventilee_factures
  # GET /depense_non_ventilee_factures.xml
  def index
    @depense_non_ventilee_factures = DepenseNonVentileeFacture.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @depense_non_ventilee_factures }
    end
  end

  # GET /depense_non_ventilee_factures/1
  # GET /depense_non_ventilee_factures/1.xml
  def show
    @depense_non_ventilee_facture = DepenseNonVentileeFacture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @depense_non_ventilee_facture }
    end
  end

  # GET /depense_non_ventilee_factures/new
  # GET /depense_non_ventilee_factures/new.xml
  def new
    @depense_non_ventilee_facture = DepenseNonVentileeFacture.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @depense_non_ventilee_facture }
    end
  end

  # GET /depense_non_ventilee_factures/1/edit
  def edit
    @depense_non_ventilee_facture = DepenseNonVentileeFacture.find(params[:id])
  end

  # POST /depense_non_ventilee_factures
  # POST /depense_non_ventilee_factures.xml
  def create
    params[:depense_non_ventilee_facture] = clean_date_params(params[:depense_non_ventilee_facture])
    @depense_non_ventilee_facture = DepenseNonVentileeFacture.new(params[:depense_non_ventilee_facture])

    respond_to do |format|
      if @depense_non_ventilee_facture.save
        @depense_non_ventilee_facture.depense_non_ventilee.verif=false
        @depense_non_ventilee_facture.depense_non_ventilee.save
        flash[:notice] = 'DepenseFonctionnementFacture was successfully created.'
        format.html { redirect_to(@depense_non_ventilee_facture) }
        format.xml  { render :xml => @depense_non_ventilee_facture, :status => :created, :location => @depense_non_ventilee_facture }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @depense_non_ventilee_facture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /depense_non_ventilee_factures/1
  # PUT /depense_non_ventilee_factures/1.xml
  def update
    params[:depense_non_ventilee_facture] = clean_date_params(params[:depense_non_ventilee_facture])
    @depense_non_ventilee_facture = DepenseNonVentileeFacture.find(params[:id])

    respond_to do |format|
      if @depense_non_ventilee_facture.update_attributes(params[:depense_non_ventilee_facture])
        @depense_non_ventilee_facture.depense_non_ventilee.verif=false
        @depense_non_ventilee_facture.depense_non_ventilee.save
        flash[:notice] = 'DepenseFonctionnementFacture was successfully updated.'
        format.html { redirect_to(@depense_non_ventilee_facture) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @depense_non_ventilee_facture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /depense_non_ventilee_factures/1
  # DELETE /depense_non_ventilee_factures/1.xml
  def destroy
    @depense_non_ventilee_facture = DepenseNonVentileeFacture.find(params[:id])
    @depense_non_ventilee_facture.destroy

    respond_to do |format|
      format.html { redirect_to(depense_non_ventilee_factures_url) }
      format.xml  { head :ok }
    end
  end
end
