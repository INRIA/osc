#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class NotificationPersonnelsController < ApplicationController
  # GET /notification_personnels
  # GET /notification_personnels.xml
  def index
    @notification_personnels = NotificationPersonnel.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /notification_personnels/1
  # GET /notification_personnels/1.xml
  def show
    @notification_personnel = NotificationPersonnel.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /notification_personnels/new
  def new
    @notification_personnel = NotificationPersonnel.new
  end

  # GET /notification_personnels/1;edit
  def edit
    @notification_personnel = NotificationPersonnel.find(params[:id])
  end

  # POST /notification_personnels
  # POST /notification_personnels.xml
  def create
    @notification_personnel = NotificationPersonnel.new(params[:notification_personnel])

    respond_to do |format|
      if @notification_personnel.save
        flash[:notice] = 'NotificationPersonnel was successfully created.'
        format.html { redirect_to notification_personnel_url(@notification_personnel) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /notification_personnels/1
  # PUT /notification_personnels/1.xml
  def update
    @notification_personnel = NotificationPersonnel.find(params[:id])

    respond_to do |format|
      if @notification_personnel.update_attributes(params[:notification_personnel])
        flash[:notice] = 'NotificationPersonnel was successfully updated.'
        format.html { redirect_to notification_personnel_url(@notification_personnel) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /notification_personnels/1
  # DELETE /notification_personnels/1.xml
  def destroy
    @notification_personnel = NotificationPersonnel.find(params[:id])
    @notification_personnel.destroy

    respond_to do |format|
      format.html { redirect_to notification_personnels_url }
    end
  end
end
