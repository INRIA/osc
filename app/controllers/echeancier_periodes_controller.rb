#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class EcheancierPeriodesController < ApplicationController
  # GET /echeancier_periodes
  # GET /echeancier_periodes.xml
  def index
    @echeancier_periodes = EcheancierPeriode.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /echeancier_periodes/1
  # GET /echeancier_periodes/1.xml
  def show
    @echeancier_periode = EcheancierPeriode.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /echeancier_periodes/new
  def new
    @echeancier_periode = EcheancierPeriode.new
  end

  # GET /echeancier_periodes/1;edit
  def edit
    @echeancier_periode = EcheancierPeriode.find(params[:id])
  end

  # POST /echeancier_periodes
  # POST /echeancier_periodes.xml
  def create
    @echeancier_periode = EcheancierPeriode.new(params[:echeancier_periode])
    respond_to do |format|
      if @echeancier_periode.save
        flash[:notice] = 'EcheancierPeriode was successfully created.'
        format.html { redirect_to echeancier_periode_url(@echeancier_periode) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /echeancier_periodes/1
  # PUT /echeancier_periodes/1.xml
  def update
    @echeancier_periode = EcheancierPeriode.find(params[:id])
    respond_to do |format|
      if @echeancier_periode.update_attributes(params[:echeancier_periode])           
        flash[:notice] = 'EcheancierPeriode was successfully updated.'
        format.html { redirect_to echeancier_periode_url(@echeancier_periode) }
      else
        format.html { render :action => "edit" }
      end
    end
  end


  # DELETE /echeancier_periodes/1
  # DELETE /echeancier_periodes/1.xml
  def destroy
    @echeancier_periode = EcheancierPeriode.find(params[:id])    
    @echeancier_periode.destroy


    respond_to do |format|
      format.js {
      }
    end
  end
end
