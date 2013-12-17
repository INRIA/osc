#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class RefusController < ApplicationController
  before_filter :is_my_research_in_session?
  
  # GET /refus/1
  # GET /refus/1.pdf
  def show
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @refu = @contrat.refu
    respond_to do |format|
      format.html # show.rhtml
      format.pdf do
         pdf = PrawnPdfDrawer.new(@refu, request)
         send_data pdf.render, :filename => 'refu_'+@contrat.acronyme+'.pdf', :type => 'application/pdf', :disposition => 'inline'
      end
    end
  end

  # GET /refus/new
  def new
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @refu = Refu.new
        
    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de refus pour le contrat "+@contrat.acronyme+".").html_safe()           
      redirect_to contrat_path(@contrat)
    else
      if !@contrat.refu.nil?
        flash[:error] = ("Il est impossible de créer un refus pour le contrat "+@contrat.acronyme+" car il existe déja.").html_safe()           
        redirect_to contrat_refu_path(@contrat, @contrat.refu)
      elsif @contrat.soumission.nil?
        flash[:error] = ("Il est impossible de créer un refus pour le contrat "+@contrat.acronyme+" car aucune soumission n'a été enregistrée. Merci de procéder à cette opération.").html_safe()           
        redirect_to new_contrat_soumission_path(@contrat)
      elsif !@contrat.signature.nil?
        flash[:error] = ("Il est impossible de créer un refus pour le contrat "+@contrat.acronyme+" car la signature du contrat a été enregistrée.").html_safe()           
        redirect_to contrat_signature_path(@contrat, @contrat.signature)
      end
    end
  end

  # GET /refus/1/edit
  def edit
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @refu = @contrat.refu
    
    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée.").html_safe()       
      redirect_to contrat_refu_path(@contrat)
    end
  end

  # POST /refus
  def create
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @refu = Refu.new(clean_date_params(params[:refu]))
    @refu.contrat = @contrat

    if @refu.save
      flash[:notice] = ('Le refus du contrat <strong>'+@contrat.acronyme+'</strong> a bien été créé.').html_safe()
      redirect_to contrat_refu_url(@contrat, @refu)
    else
      render :action => "new"
    end
  end

  # PUT /refus/1
  def update
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @refu = @contrat.refu

    if @refu.update_attributes(clean_date_params(params[:refu]))
      flash[:notice] = ('Le refus du contrat <strong>'+@contrat.acronyme+'</strong> a bien été mis à jour.').html_safe()
      redirect_to contrat_refu_url(@contrat, @refu)
    else
      render :action => "edit" 
    end
  end
  
  def ask_delete    
    @contrat = Contrat.find(params[:contrat_id])
    @refu = @contrat.refu
  end

  # DELETE /refus/1
  def destroy
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @refu = @contrat.refu

    if @contrat.is_editable? current_user 
      @refu.destroy
      flash[:notice] = ('Le refus du contrat <strong>'+@contrat.acronyme+'</strong> à bien été supprimée.').html_safe()
      redirect_to contrat_path(@contrat)
    else
      flash[:error] = ("Vos droits dans l'application ne vous permettent de supprimer le refus du contrat "+@contrat.acronyme+".").html_safe()      
      redirect_to contrat_refu_path(@contrat)
    end
    
  end
end
