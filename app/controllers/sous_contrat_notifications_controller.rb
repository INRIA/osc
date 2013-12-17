#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SousContratNotificationsController < ApplicationController
  # GET /sous_contrat_notifications
  # GET /sous_contrat_notifications.xml
  def index
    @sous_contrat_notifications = SousContratNotification.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @sous_contrat_notifications.to_xml }
    end
  end

  # GET /sous_contrat_notifications/1
  # GET /sous_contrat_notifications/1.xml
  def show
    @sous_contrat_notification = SousContratNotification.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @sous_contrat_notification.to_xml }
    end
  end

  # GET /sous_contrat_notifications/new
  def new
    @sous_contrat_notification = SousContratNotification.new
  end

  # GET /sous_contrat_notifications/1;edit
  def edit
    @sous_contrat_notification = SousContratNotification.find(params[:id])
  end

  # POST /sous_contrat_notifications
  # POST /sous_contrat_notifications.xml
  def create
    @sous_contrat_notification = SousContratNotification.new(params[:sous_contrat_notification])

    respond_to do |format|
      if @sous_contrat_notification.save
        flash[:notice] = 'SousContratNotification was successfully created.'
        format.html { redirect_to sous_contrat_notification_url(@sous_contrat_notification) }
        format.xml  { head :created, :location => sous_contrat_notification_url(@sous_contrat_notification) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sous_contrat_notification.errors.to_xml }
      end
    end
  end

  # PUT /sous_contrat_notifications/1
  # PUT /sous_contrat_notifications/1.xml
  def update
    @sous_contrat_notification = SousContratNotification.find(params[:id])

    respond_to do |format|
      if @sous_contrat_notification.update_attributes(params[:sous_contrat_notification])
        flash[:notice] = 'SousContratNotification was successfully updated.'
        format.html { redirect_to sous_contrat_notification_url(@sous_contrat_notification) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sous_contrat_notification.errors.to_xml }
      end
    end
  end

  # DELETE /sous_contrat_notifications/1
  # DELETE /sous_contrat_notifications/1.xml
  def destroy
    @sous_contrat_notification = SousContratNotification.find(params[:id])
    @sous_contrat_notification.destroy

    respond_to do |format|
      format.html { redirect_to sous_contrat_notifications_url }
      format.xml  { head :ok }
    end
  end
end
