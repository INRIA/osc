#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class NotificationPartenairesController < ApplicationController
  # GET /notification_partenaires
  # GET /notification_partenaires.xml
  def index
    @notification_partenaires = NotificationPartenaire.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /notification_partenaires/1
  # GET /notification_partenaires/1.xml
  def show
    @notification_partenaire = NotificationPartenaire.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /notification_partenaires/new
  def new
    @notification_partenaire = NotificationPartenaire.new
  end

  # GET /notification_partenaires/1;edit
  def edit
    @notification_partenaire = NotificationPartenaire.find(params[:id])
  end

  # POST /notification_partenaires
  # POST /notification_partenaires.xml
  def create
    @notification_partenaire = NotificationPartenaire.new(params[:notification_partenaire])

    respond_to do |format|
      if @notification_partenaire.save
        flash[:notice] = 'NotificationPartenaire was successfully created.'
        format.html { redirect_to notification_partenaire_url(@notification_partenaire) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /notification_partenaires/1
  # PUT /notification_partenaires/1.xml
  def update
    @notification_partenaire = NotificationPartenaire.find(params[:id])

    respond_to do |format|
      if @notification_partenaire.update_attributes(params[:notification_partenaire])
        flash[:notice] = 'NotificationPartenaire was successfully updated.'
        format.html { redirect_to notification_partenaire_url(@notification_partenaire) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /notification_partenaires/1
  # DELETE /notification_partenaires/1.xml
  def destroy
    @notification_partenaire = NotificationPartenaire.find(params[:id])
    @notification_partenaire.destroy

    respond_to do |format|
      format.html { redirect_to notification_partenaires_url }
    end
  end
end
