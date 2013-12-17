#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SoumissionPersonnelsController < ApplicationController
  # GET /soumission_personnels
  # GET /soumission_personnels.xml
  def index
    @soumission_personnels = SoumissionPersonnel.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /soumission_personnels/1
  # GET /soumission_personnels/1.xml
  def show
    @soumission_personnel = SoumissionPersonnel.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /soumission_personnels/new
  def new
    @soumission_personnel = SoumissionPersonnel.new
  end

  # GET /soumission_personnels/1;edit
  def edit
    @soumission_personnel = SoumissionPersonnel.find(params[:id])
  end

  # POST /soumission_personnels
  # POST /soumission_personnels.xml
  def create
    @soumission_personnel = SoumissionPersonnel.new(params[:soumission_personnel])

    respond_to do |format|
      if @soumission_personnel.save
        flash[:notice] = 'SoumissionPersonnel was successfully created.'
        format.html { redirect_to soumission_personnel_url(@soumission_personnel) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /soumission_personnels/1
  # PUT /soumission_personnels/1.xml
  def update
    @soumission_personnel = SoumissionPersonnel.find(params[:id])

    respond_to do |format|
      if @soumission_personnel.update_attributes(params[:soumission_personnel])
        flash[:notice] = 'SoumissionPersonnel was successfully updated.'
        format.html { redirect_to soumission_personnel_url(@soumission_personnel) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /soumission_personnels/1
  # DELETE /soumission_personnels/1.xml
  def destroy
    @soumission_personnel = SoumissionPersonnel.find(params[:id])
    @soumission_personnel.destroy

    respond_to do |format|
      format.html { redirect_to soumission_personnels_url }
    end
  end
end
