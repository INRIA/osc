#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class AvenantsController < ApplicationController
  # GET /avenants
  # GET /avenants.xml
  def index
    @avenants = Avenant.find(:all)
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @avenants.to_xml }
    end
  end

  # GET /avenants/1
  # GET /avenants/1.xml
  def show
    @avenant = Avenant.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @avenant.to_xml }
    end
  end

  # GET /avenants/new
  def new
    @avenant = Avenant.new
  end

  # GET /avenants/1;edit
  def edit
    @avenant = Avenant.find(params[:id])
  end

  # POST /avenants
  # POST /avenants.xml
  def create
    @avenant = Avenant.new(params[:avenant])
    respond_to do |format|
      if @avenant.save
        flash[:notice] = 'Avenant was successfully created.'
        format.html { redirect_to avenant_url(@avenant) }
        format.xml  { head :created, :location => avenant_url(@avenant) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @avenant.errors.to_xml }
      end
    end
  end

  # PUT /avenants/1
  # PUT /avenants/1.xml
  def update
    @avenant = Avenant.find(params[:id])

    respond_to do |format|
      if @avenant.update_attributes(params[:avenant])
        flash[:notice] = 'Avenant was successfully updated.'
        format.html { redirect_to avenant_url(@avenant) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @avenant.errors.to_xml }
      end
    end
  end

  # DELETE /avenants/1
  # DELETE /avenants/1.xml
  def destroy
    @avenant = Avenant.find(params[:id])
    @avenant.destroy

    respond_to do |format|
      format.html { redirect_to avenants_url }
      format.xml  { head :ok }
    end
  end
end
