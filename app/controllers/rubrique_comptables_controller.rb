#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class RubriqueComptablesController < ApplicationController
  # GET /rubrique_comptables
  # GET /rubrique_comptables.xml
  def index
    @rubrique_comptables = RubriqueComptable.find(:all, :order => :numero_rubrique)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rubrique_comptables }
    end
  end

  # GET /rubrique_comptables/1
  # GET /rubrique_comptables/1.xml
  def show
    @rubrique_comptable = RubriqueComptable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rubrique_comptable }
    end
  end

  # GET /rubrique_comptables/new
  # GET /rubrique_comptables/new.xml
  def new
    @rubrique_comptable = RubriqueComptable.new
    @rubrique_comptables = RubriqueComptable.find(:all, :order => :numero_rubrique)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rubrique_comptable }
    end
  end

  # GET /rubrique_comptables/1/edit
  def edit
    @rubrique_comptable = RubriqueComptable.find(params[:id])    
    @rubrique_comptables = RubriqueComptable.find(:all, :order => :numero_rubrique)
  end

  # POST /rubrique_comptables
  # POST /rubrique_comptables.xml
  def create
    @rubrique_comptable = RubriqueComptable.new(params[:rubrique_comptable])
    @rubrique_comptables = RubriqueComptable.find(:all, :order => :numero_rubrique)

    respond_to do |format|
      if @rubrique_comptable.save
        flash[:notice] = "La Rubrique Comptable a bien été créée."
        format.html { redirect_to rubrique_comptables_path }
        format.xml  { render :xml => @rubrique_comptable, :status => :created, :location => @rubrique_comptable }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rubrique_comptable.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rubrique_comptables/1
  # PUT /rubrique_comptables/1.xml
  def update
    @rubrique_comptable = RubriqueComptable.find(params[:id])
    @rubrique_comptables = RubriqueComptable.find(:all, :order => :numero_rubrique)

    respond_to do |format|
      if @rubrique_comptable.update_attributes(params[:rubrique_comptable])
        flash[:notice] = "La Rubrique Comptable a bien été mise à jour."
        format.html { redirect_to rubrique_comptables_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rubrique_comptable.errors, :status => :unprocessable_entity }
      end
    end
  end

  def ask_delete
    @rubrique_comptable = RubriqueComptable.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end
  
  # DELETE /rubrique_comptables/1
  # DELETE /rubrique_comptables/1.xml
  def destroy
    @rubrique_comptable = RubriqueComptable.find(params[:id])
    @rubrique_comptable.destroy
    
    respond_to do |format|
      format.html { redirect_to(rubrique_comptables_url) }
      format.js {
        render :update do |page|
          page.call("RedBox.close")
          page.visual_effect :fade, 'rc_'+@rubrique_comptable.id.to_s, :duration => 0.75
          page.delay(0.75) do
            page.replace_html 'rc_'+@rubrique_comptable.id.to_s, ""
          end
        end
      }
      format.xml  { head :ok }
    end
  end
end
