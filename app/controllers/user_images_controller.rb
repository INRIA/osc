#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class UserImagesController < ApplicationController
  # GET /user_images
  # GET /user_images.xml
  def index
    user = User.find(params[:user_id]) 
    @user_images = user.user_images.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @user_images.to_xml }
    end
  end

  # GET /user_images/1
  # GET /user_images/1.xml
  def show
    @user_image = UserImage.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user_images.to_xml }
    end
  end

  # GET /user_images/new
  def new
    @user_image = UserImage.new
    @user_image.user = User.find(params[:user_id]) 
  end

  # GET /user_images/1;edit
  def edit
    @user_image = UserImage.find(params[:id])  
  end

  # POST /user_images
  # POST /user_images.xml
  def create
    @user_image = UserImage.new(params[:user_image])
    @user_image.user = User.find(params[:user_id])
    respond_to do |format|
      if @user_image.save
        flash[:notice] = "L'image à été sauvegardée avec succès."
        format.html { redirect_to edit_user_path(@user_image.user)+"#photo"}
        format.xml  { head :created, :location => user_image_url(@user_image) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_image.errors.to_xml }
      end
    end
  end

  # PUT /user_images/1
  # PUT /user_images/1.xml
  def update
    @user_image = UserImage.find(params[:id])
    @user_image.user = User.find(params[:user_id])
    respond_to do |format|
      if @user_image.update_attributes(params[:user_image])
        flash[:notice] = "L'image à été mise à jour avec succès."
        format.html { redirect_to edit_user_path(@user_image.user)+"#photo" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_image.errors.to_xml }
      end
    end
  end

  # DELETE /user_images/1
  # DELETE /user_images/1.xml
  def destroy
    @user_image = UserImage.find(params[:id])
    @user_image.destroy
    respond_to do |format|
      format.html { redirect_to edit_user_path(@user_image.user)+"#photo" }
      format.xml  { head :ok }
    end
  end
end
