#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class NotificationFrancePartenairesController < ApplicationController
  # GET /notification_france_partenaires
  # GET /notification_france_partenaires.xml
  def index
    @notification_france_partenaires = NotificationFrancePartenaire.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /notification_france_partenaires/1
  # GET /notification_france_partenaires/1.xml
  def show
    @notification_france_partenaire = NotificationFrancePartenaire.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /notification_france_partenaires/new
  def new
    @notification_france_partenaire = NotificationFrancePartenaire.new
  end

  # GET /notification_france_partenaires/1;edit
  def edit
    @notification_france_partenaire = NotificationFrancePartenaire.find(params[:id])
  end

  # POST /notification_france_partenaires
  # POST /notification_france_partenaires.xml
  def create
    @notification_france_partenaire = NotificationFrancePartenaire.new(params[:notification_france_partenaire])
    respond_to do |format|
      if @notification_france_partenaire.save
        flash[:notice] = 'NotificationFrancePartenaire was successfully created.'
        format.html { redirect_to notification_france_partenaire_url(@notification_france_partenaire) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /notification_france_partenaires/1
  # PUT /notification_france_partenaires/1.xml
  def update
    @notification_france_partenaire = NotificationFrancePartenaire.find(params[:id])

    respond_to do |format|
      if @notification_france_partenaire.update_attributes(params[:notification_france_partenaire])
        flash[:notice] = 'NotificationFrancePartenaire was successfully updated.'
        format.html { redirect_to notification_france_partenaire_url(@notification_france_partenaire) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /notification_france_partenaires/1
  # DELETE /notification_france_partenaires/1.xml
  def destroy
    @notification_france_partenaire = NotificationFrancePartenaire.find(params[:id])
    @notification_france_partenaire.destroy
    respond_to do |format|
      format.html { redirect_to notification_france_partenaires_url }
    end
  end
end
