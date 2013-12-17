#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class MembershipsController < ApplicationController
  # GET /memberships
  # GET /memberships.xml
  def index
    @memberships = Membership.find(:all)
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @memberships.to_xml }
    end
  end

  # GET /memberships/1
  # GET /memberships/1.xml
  def show
    @membership = Membership.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @membership.to_xml }
    end
  end

  # GET /memberships/new
  def new
    @membership = Membership.new
    @membership.user = User.find(params[:user_id])
  end

  # GET /memberships/1;edit
  def edit
    @membership = Membership.find(params[:id])
  end

  # POST /memberships
  # POST /memberships.xml
  def create    
    @membership = Membership.new(params[:membership])
    if /users/.match(request.env["HTTP_REFERER"])
      @membership.user = User.find(params[:user_id])
    end
    if /groups/.match(request.env["HTTP_REFERER"])    
      @membership.group = Group.find(params[:group_id]) 
    end

    respond_to do |format|
      if @membership.save
        # Envoi d'un email aux administrateurs fonctionnels pour les prévenir
        Notifier.send_mail_for_add_user_in_group(@membership.user,@membership.group ).deliver
        
        format.html { 
          if request.xhr?
            # Mise à jour de la page d'édition des utilisateurs
            if /users/.match(request.env["HTTP_REFERER"])
              # variables necessaires pour users/list_memberships
              @user = User.find(params[:user_id]) 
              @memberships = @user.memberships.find(:all, :include => [:group], :order => "groups.nom")
              # variables nécessaires pour users/add_membership
              @groups = @user.groups.find(:all, :order => "nom")
              @groups_restant = Group.find(:all, :order => "nom") - @groups
              render :update do |page|
                page.replace_html  'userEditGroups', :partial => 'users/list_memberships'
                page.replace_html  'add_membership', :partial => 'users/add_membership'
                page.visual_effect :highlight, 'membership_'+@membership.id.to_s
              end
            end
            # Mise à jour de la page d'édition des groupes
            if /groups/.match(request.env["HTTP_REFERER"])
              # variables necessaires pour groups/list_memberships
              @group = Group.find(params[:group_id]) 
              @memberships = @group.memberships.find(:all, :include => [:user], :order => "users.nom")
              # variables nécessaires pour groups/add_membership
              @users = @group.users.find(:all, :order => "nom")
              @users_restant = User.find(:all, :order => "nom") - @users
              render :update do |page|
                page.replace_html  'groupEditUsers', :partial => 'groups/list_memberships'
                page.replace_html  'add_membership', :partial => 'groups/add_membership'
                page.visual_effect :highlight, 'membership_'+@membership.id.to_s
              end
            end
          else
           redirect_to :action => "show", :id => params[:id]
          end
        }

        #  redirect_to edit_user_path(@membership.user) }
        format.xml  { head :created, :location => membership_url(@membership) }
        
        
      else
        flash[:notice] = 'Erreur ! Ajout impossible'
        format.html {
          if request.xhr?
            render :update do |page|
              page.replace_html  'error', flash[:notice] 
              page.visual_effect :highlight, 'error'
            end
          else
           render :action => "new"
           end }
        format.xml  { render :xml => @membership.errors.to_xml }
      end
    end
  end

  # PUT /memberships/1
  # PUT /memberships/1.xml
  def update
    @membership = Membership.find(params[:id])

    respond_to do |format|
      if @membership.update_attributes(params[:membership])
        flash[:notice] = 'Membership was successfully updated.'
        format.html { redirect_to membership_url(@membership) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership.errors.to_xml }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.xml
  def destroy
    @membership = Membership.find(params[:id])
    @user = @membership.user
    @group = @membership.group
    @membership.destroy
    # Envoi d'un email aux administrateurs fonctionnels pour les prévenir
    Notifier.send_mail_for_del_user_in_group(@user,@group).deliver


    respond_to do |format|
      format.html { 
        if request.xhr?
          # Mise à jour de la page d'édition des utilisateurs
          if /users/.match(request.env["HTTP_REFERER"])
            # variables necessaires pour users/list_memberships
            @memberships = @user.memberships.find(:all, :include => [:group], :order => "groups.nom")
            # variables nécessaires pour users/add_membership
            @groups = @user.groups.find(:all, :order => "nom")
            @groups_restant = Group.find(:all, :order => "nom") - @groups
            render :update do |page|
              page.replace_html  'userEditGroups', :partial => 'users/list_memberships'
              page.replace_html  'add_membership', :partial => 'users/add_membership'
              page.visual_effect :highlight, 'userEditGroups'
            end
          end
          # Mise à jour de la page d'édition des groupes
          if /groups/.match(request.env["HTTP_REFERER"])
            # variables necessaires pour groups/list_memberships
            @memberships = @group.memberships.find(:all, :include => [:user], :order => "users.nom")
            # variables nécessaires pour groups/add_membership
            @users = @group.users.find(:all, :order => "nom")
            @users_restant = User.find(:all, :order => "nom") - @users
            render :update do |page|
              page.replace_html  'groupEditUsers', :partial => 'groups/list_memberships'
              page.replace_html  'add_membership', :partial => 'groups/add_membership'
              page.visual_effect :highlight, 'groupEditUsers'
            end
          end
        else
        redirect_to :back
        end
        }
      format.xml  { head :ok }      
    end
  end
end
