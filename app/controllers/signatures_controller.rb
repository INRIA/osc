#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SignaturesController < ApplicationController
  before_filter :is_my_research_in_session?
  
  # GET /signatures/1
  # GET /signatures/1.xml
  def show
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @signature = @contrat.signature

    respond_to do |format|
      format.html # show.rhtml
      format.pdf do
         pdf = PrawnPdfDrawer.new(@signature, request)
         send_data pdf.render, :filename => 'signature_'+@contrat.acronyme+'.pdf', :type => 'application/pdf', :disposition => 'inline'
      end
    end
  end

  # GET /signatures/new
  def new
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    
    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de signature pour le contrat "+@contrat.acronyme+".").html_safe()       
      redirect_to contrat_path(@contrat)
    else
      if !@contrat.refu.nil?
        flash[:error] = ("Il est impossible de créer la signature pour le contrat "+@contrat.acronyme+" car le refus du contrat à été enregistré.").html_safe()       
        redirect_to contrat_refu_path(@contrat, @contrat.refu)
      elsif @contrat.soumission.nil?
        flash[:error] = ("Il est impossible de créer la signature pour le contrat "+@contrat.acronyme+" car aucune soumission n'a été enregistrée. Merci de procéder à cette opération.").html_safe()       
        redirect_to new_contrat_soumission_path(@contrat)
      elsif !@contrat.signature.nil?
        flash[:error] = ("Il est impossible de créer une signature pour le contrat "+@contrat.acronyme+" car elle existe déja.").html_safe()       
        redirect_to contrat_signature_path(@contrat, @contrat.signature)
      end
    end
    
    @signature = Signature.new
    @non_modifiables = @signature.get_non_modifiables
  end

  # GET /signatures/1;edit
  def edit
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @signature = @contrat.signature
    @non_modifiables = @signature.get_non_modifiables
    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'accéder à la page demandée.").html_safe()       
      redirect_to contrat_signature_path(@contrat)
    end
    
  end

  # POST /signatures
  # POST /signatures.xml
  def create
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @signature = Signature.new(clean_date_params(params[:signature]))
    @signature.contrat = @contrat
    @non_modifiables = @signature.get_non_modifiables
    respond_to do |format|
      if @signature.save
        flash[:notice] = ('La signature du contrat <strong>'+@contrat.acronyme+'</strong> à bien été crée.').html_safe()
        format.html { redirect_to contrat_signature_url(@contrat, @signature) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /signatures/1
  # PUT /signatures/1.xml
  def update
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @signature = @contrat.signature
    @non_modifiables = @signature.get_non_modifiables
    respond_to do |format|
      if @signature.update_attributes(clean_date_params(params[:signature]))
        flash[:notice] = ('La signature du contrat <strong>'+@contrat.acronyme+'</strong> à bien été mise à jour.').html_safe()
        format.html { redirect_to contrat_signature_url(@contrat, @signature) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def ask_delete
    @contrat = Contrat.find(params[:contrat_id])
    @signature = @contrat.signature
    respond_to do |format|
      format.html
    end
  end

  # DELETE /signatures/1
  # DELETE /signatures/1.xml
  def destroy
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @signature = @contrat.signature

    if @contrat.is_editable? current_user 
      @signature.destroy
      flash[:notice] = ('La signature du contrat <strong>'+@contrat.acronyme+'</strong> à bien été supprimée.').html_safe()
      respond_to do |format|
        format.html { redirect_to contrat_path(@contrat) }
      end
    else
        flash[:error] = ("Vos droits dans l'application ne vous permettent de supprimer la soumission du contrat "+@contrat.acronyme+".").html_safe()       
        redirect_to contrat_soumission_path(@contrat)
    end
  end
end
