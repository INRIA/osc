#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class NotificationEuropePartenairesController < ApplicationController
  # GET /notification_europe_partenaires
  # GET /notification_europe_partenaires.xml
  def index
    @notification_europe_partenaires = NotificationEuropePartenaire.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /notification_europe_partenaires/1
  # GET /notification_europe_partenaires/1.xml
  def show
    @notification_europe_partenaire = NotificationEuropePartenaire.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /notification_europe_partenaires/new
  def new
    @notification_europe_partenaire = NotificationEuropePartenaire.new
  end

  # GET /notification_europe_partenaires/1;edit
  def edit
    @notification_europe_partenaire = NotificationEuropePartenaire.find(params[:id])
  end

  # POST /notification_europe_partenaires
  # POST /notification_europe_partenaires.xml
  def create
    @notification_europe_partenaire = NotificationEuropePartenaire.new(params[:notification_europe_partenaire])

    respond_to do |format|
      if @notification_europe_partenaire.save
        flash[:notice] = 'NotificationEuropePartenaire was successfully created.'
        format.html { redirect_to notification_europe_partenaire_url(@notification_europe_partenaire) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /notification_europe_partenaires/1
  # PUT /notification_europe_partenaires/1.xml
  def update
    @notification_europe_partenaire = NotificationEuropePartenaire.find(params[:id])

    respond_to do |format|
      if @notification_europe_partenaire.update_attributes(params[:notification_europe_partenaire])
        flash[:notice] = 'NotificationEuropePartenaire was successfully updated.'
        format.html { redirect_to notification_europe_partenaire_url(@notification_europe_partenaire) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /notification_europe_partenaires/1
  # DELETE /notification_europe_partenaires/1.xml
  def destroy
    @notification_europe_partenaire = NotificationEuropePartenaire.find(params[:id])
    @notification_europe_partenaire.destroy

    respond_to do |format|
      format.html { redirect_to notification_europe_partenaires_url }
    end
  end
end
