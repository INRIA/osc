#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseMissionFacturesController < ApplicationController

  def index
    @depense_mission_factures = DepenseMissionFacture.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @depense_mission_factures }
    end
  end

  # GET /depense_fonctionnement_factures/1
  # GET /depense_fonctionnement_factures/1.xml
  def show
    @depense_mission_factures = DepenseMissionFacture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @depense_mission_factures }
    end
  end

  def new
    @depense_mission_factures = DepenseMissionFacture.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @depense_mission_factures }
    end
  end

  def edit
    @depense_mission_facture = DepenseMissionFacture.find(params[:id])
  end

  def create
    params[:depense_mission_factures] = clean_date_params(params[:depense_mission_factures])
    @depense_mission_facture = DepenseMissionFacture.new(params[:depense_mission_factures])

    respond_to do |format|
      if @depense_mission_facture.save
        @depense_mission_facture.depense_mission.verif=false
        @depense_mission_facture.depense_mission.save
        flash[:notice] = 'Mission facture was successfully created.'
        format.html { redirect_to(@depense_mission_facture) }
        format.xml  { render :xml => @depense_mission_facture, :status => :created, :location => @depense_fonctionnement_facture }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @depense_mission_facture.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    params[:depense_mission_factures] = clean_date_params(params[:depense_mission_factures])
    @depense_mission_facture = DepenseMissionFacture.find(params[:id])

    respond_to do |format|
      if @depense_mission_facture.update_attributes(params[:depense_mission_facture])
        @depense_mission_facture.depense_mission.verif=false
        @depense_mission_facture.depense_mission.save
        flash[:notice] = 'facture mission was successfully updated.'
        format.html { redirect_to(@depense_mission_facture) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @depense_mission_facture.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @depense_mission_facture = DepenseMissionFacture.find(params[:id])
    @depense_mission_facture.destroy

    respond_to do |format|
      format.html { redirect_to(depense_mission_factures_url) }
      format.xml  { head :ok }
    end
  end
end
