#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseEquipementFacturesController < ApplicationController
  # GET /depense_equipement_factures
  def index
    @depense_equipement_factures = DepenseEquipementFacture.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /depense_equipementfactures/1
  def show
    @depense_equipement_facture = DepenseEquipementFacture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /depense_equipement_factures/new
  def new
    @depense_equipement_facture = DepenseEquipementFacture.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /depense_equipement_factures/1/edit
  def edit
    @depense_equipement_facture = DepenseEquipementFacture.find(params[:id])
  end

  # POST /depense_equipement_factures
  def create
    params[:depense_equipement_facture] = clean_date_params(params[:depense_equipement_facture])
    @depense_equipement_facture = DepenseEquipementFacture.new(params[:depense_equipement_facture])

    respond_to do |format|
      if @depense_equipement_facture.save
        @depense_equipement_facture.depense_equipement.verif=false
        @depense_equipement_facture.depense_equipement.save
        flash[:notice] = 'DepenseEquipementFacture was successfully created.'
        format.html { redirect_to(@depense_equipement_facture) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /depense_equipement_factures/1
  def update
    params[:depense_equipement_facture] = clean_date_params(params[:depense_equipement_facture])
    @depense_equipement_facture = DepenseEquipementFacture.find(params[:id])

    respond_to do |format|
      if @depense_equipement_facture.update_attributes(params[:depense_equipement_facture])
        @depense_equipement_facture.depense_equipement.verif=false
        @depense_equipement_facture.depense_equipement.save
        flash[:notice] = 'DepenseEquipementFacture was successfully updated.'
        format.html { redirect_to(@depense_equipement_facture) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /depense_equipement_factures/1
  def destroy
    @depense_equipement_facture = DepenseEquipementFacture.find(params[:id])
    @depense_equipement_facture.destroy

    respond_to do |format|
      format.html { redirect_to(depense_equipement_factures_url) }
      format.xml  { head :ok }
    end
  end
end
