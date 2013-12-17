#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class BudgetaireReferencesController < ApplicationController
  # GET /budgetaire_references
  # GET /budgetaire_references.xml
  def index
    @budgetaire_references = BudgetaireReference.find(:all, :order => :code)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @budgetaire_references }
    end
  end

  # GET /budgetaire_references/1
  # GET /budgetaire_references/1.xml
  def show
    @budgetaire_reference = BudgetaireReference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @budgetaire_reference }
    end
  end

  # GET /budgetaire_references/new
  # GET /budgetaire_references/new.xml
  def new
    @budgetaire_reference = BudgetaireReference.new
    @budgetaire_references = BudgetaireReference.find(:all, :order => :code)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @budgetaire_reference }
    end
  end

  # GET /budgetaire_references/1/edit
  def edit
    @budgetaire_reference = BudgetaireReference.find(params[:id])
    @budgetaire_references = BudgetaireReference.find(:all, :order => :code)
  end

  # POST /budgetaire_references
  # POST /budgetaire_references.xml
  def create
    @budgetaire_reference = BudgetaireReference.new(params[:budgetaire_reference])
    @budgetaire_references = BudgetaireReference.find(:all, :order => :code)

    respond_to do |format|
      if @budgetaire_reference.save
        flash[:notice] = 'La référence Budgétaire a bien été créée.'
        format.html { redirect_to budgetaire_references_path }
        format.xml  { render :xml => @budgetaire_reference, :status => :created, :location => @budgetaire_reference }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @budgetaire_reference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /budgetaire_references/1
  # PUT /budgetaire_references/1.xml
  def update
    @budgetaire_reference = BudgetaireReference.find(params[:id])
    @budgetaire_references = BudgetaireReference.find(:all, :order => :code)

    respond_to do |format|
      if @budgetaire_reference.update_attributes(params[:budgetaire_reference])
        flash[:notice] = 'La référence Budgétaire a bien été mise à jour.'
        format.html { redirect_to budgetaire_references_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @budgetaire_reference.errors, :status => :unprocessable_entity }
      end
    end
  end

  def ask_delete
    @budgetaire_reference = BudgetaireReference.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end

  # DELETE /budgetaire_references/1
  # DELETE /budgetaire_references/1.xml
  def destroy
    @budgetaire_reference = BudgetaireReference.find(params[:id])
    @budgetaire_reference.destroy
    respond_to do |format|
      format.html { redirect_to(budgetaire_references_url) }
      format.js {
        render :update do |page|
          page.call("RedBox.close")
          page.visual_effect :fade, 'rf_'+@budgetaire_reference.id.to_s, :duration => 0.75
          page.delay(0.75) do
            page.replace_html 'rf_'+@budgetaire_reference.id.to_s, ""
          end
        end
      }
      format.xml  { head :ok }
    end
  end
end
