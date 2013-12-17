#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class CloturesController < ApplicationController
  
  # GET /clotures
  # GET /clotures.xml
  def index
    @clotures = Cloture.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /clotures/1
  # GET /clotures/1.xml
  def show
    @contrats = Contrat.find(:all, :order => "acronyme")
    @cloture = Cloture.find(params[:id])
    @contrat = Contrat.find(params[:contrat_id])
    respond_to do |format|
      format.html # show.rhtml
      format.pdf do
         pdf = PrawnPdfDrawer.new(@cloture, request)
         send_data pdf.render, :filename => 'cloture_'+@contrat.acronyme+'.pdf', :type => 'application/pdf', :disposition => 'inline'
      end
    end
  end

  # GET /clotures/new
  def new
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    
    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de clôture pour le contrat "+@contrat.acronyme+".").html_safe()       
      redirect_to contrat_path(@contrat)
    else
      if !@contrat.cloture.nil?
        flash[:error] = ("Il est impossible de créer la clôture pour le contrat "+@contrat.acronyme+" car la clôture du contrat à déjà été enregistrée.").html_safe()       
        redirect_to contrat_refu_path(@contrat, @contrat.refu)
      elsif @contrat.notification.nil?
        flash[:error] = ("Il est impossible de créer la clôture pour le contrat "+@contrat.acronyme+" car aucune notification n'a été enregistrée. Merci de procéder à cette opération.").html_safe()       
        redirect_to new_contrat_soumission_path(@contrat)
      elsif @contrat.soumission.nil?
        flash[:error] = ("Il est impossible de créer la clôture pour le contrat "+@contrat.acronyme+" car aucune soumission n'a été enregistrée. Merci de procéder à cette opération.").html_safe()       
        redirect_to new_contrat_soumission_path(@contrat)
      elsif !@contrat.refu.nil?
        flash[:error] = ("Il est impossible de créer une clôture pour le contrat "+@contrat.acronyme+" car un refus à été enregistré.").html_safe()       
        redirect_to contrat_refu_path(@contrat, @contrat.refu)
      end
    end
    
    @cloture = Cloture.new
  end

  # GET /clotures/1;edit
  def edit
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    
    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée.").html_safe()       
      redirect_to contrat_cloture_path(@contrat)
    end
    
    @cloture = @contrat.cloture
  end

  # POST /clotures
  # POST /clotures.xml
  def create
    @contrats = Contrat.find(:all, :order => "acronyme")
    @cloture = Cloture.new(clean_date_params(params[:cloture]))
    @contrat = Contrat.find(params[:contrat_id])
    @cloture.contrat = @contrat
    
    respond_to do |format|
      if @cloture.save
        flash[:notice] = ('La clôture du contrat <strong>'+@contrat.acronyme+'</strong> a bien été créée.').html_safe()
        format.html { redirect_to contrat_cloture_url(@contrat, @cloture) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /clotures/1
  # PUT /clotures/1.xml
  def update
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @cloture = @contrat.cloture

    respond_to do |format|
      if @cloture.update_attributes(clean_date_params(params[:cloture]))
        flash[:notice] = ('La clôture du contrat <strong>'+@contrat.acronyme+'</strong> à bien été mise à jour.').html_safe()
        format.html { redirect_to contrat_cloture_url(@contrat, @cloture) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def ask_delete
    @contrat = Contrat.find(params[:contrat_id])
    @cloture = @contrat.cloture
    respond_to do |format|
      format.html
    end
  end

  # DELETE /clotures/1
  # DELETE /clotures/1.xml
  def destroy
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @cloture = @contrat.cloture    

    if @contrat.is_editable? current_user 
      @cloture.destroy
      flash[:notice] = ('La clôture du contrat <strong>'+@contrat.acronyme+'</strong> à bien été supprimée.').html_safe()
      respond_to do |format|
        format.html { redirect_to contrat_path(@contrat) }
        format.js {render :js =>%(window.location.href='#{contrat_path(@contrat)}')}
      end
    else
        flash[:error] = ("Vos droits dans l'application ne vous permettent de supprimer la clôture du contrat "+@contrat.acronyme+".").html_safe()       
        redirect_to contrat_cloture_path(@contrat)
    end
  end
end
