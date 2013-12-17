#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class EcheanciersController < ApplicationController 
  before_filter :is_my_research_in_session?

  include UIEnhancements::SubList
  helper :SubList
  
  sub_list 'EcheancierPeriode', 'echeancier' do |echeancier_periode|
  end
  
  # GET /echeanciers/1
  # GET /echeanciers/1.xml
  def show
    
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @echeancier = Echeancier.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /echeanciers/new
  def new
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @echeancier = Echeancier.new
    
    if params[:echeanciable_type] == "SousContrat"
      @echeancier.echeanciable_type = "SousContrat"
      @echeancier.echeanciable_id = params[:echeanciable_id]
    else
      @echeancier.echeanciable_type = "Contrat"
      @echeancier.echeanciable_id = @contrat.id
    end

  end

  # GET /echeanciers/1;edit
  def edit
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @echeancier = Echeancier.find(params[:id])
    
    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'éditer l'échéancier du contrat "+@contrat.acronyme+".").html_safe()  
      redirect_to contrat_echeancier_path(@contrat)
    end
    
  end

  # POST /echeanciers
  # POST /echeanciers.xml
  def create
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @echeancier = Echeancier.new(params[:echeancier])
    success = true
    success &&= initialize_echeancier_periodes
    success &&= @echeancier.save
    
    respond_to do |format|
      if success
        flash[:notice] = ("L'échéancier du contrat <strong>"+@contrat.acronyme+"<strong> a bien été été créé.").html_safe()
        for sc in @contrat.sous_contrats
          echeancier_sc = Echeancier.new( :echeanciable_type => "SousContrat",
                                          :echeanciable_id => sc.id,
                                          :global_depenses_frais_gestion => 0)
          echeancier_sc.save
          for periode in @echeancier.echeancier_periodes
            echeancier_periode_sc = EcheancierPeriode.new()
            echeancier_periode_sc.echeancier_id = echeancier_sc.id
            echeancier_periode_sc.date_debut = periode.date_debut
            echeancier_periode_sc.date_fin = periode.date_fin
            echeancier_periode_sc.save
          end
        end    
        format.html { redirect_to contrat_echeancier_url(@contrat, @echeancier) }
      else
        prepare_echeancier_periodes
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /echeanciers/1
  # PUT /echeanciers/1.xml
  def update
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @echeancier = Echeancier.find(params[:id])

    success = true
    success &&= initialize_echeancier_periodes
    success &&= @echeancier.update_attributes(params[:echeancier])
    

    respond_to do |format|
      info = []
      if success
        i = 0
        for p in @echeancier.echeancier_periodes
          info[i] = { "date_debut" => p.date_debut, "date_fin" => p.date_fin }
          i = i + 1
        end
        
        if @contrat.sous_contrats.size > 1
          for sc in @contrat.sous_contrats
            i=0
            for p in sc.echeancier.echeancier_periodes
              p.update_attributes(:date_debut => info[i]["date_debut"])
              p.update_attributes(:date_fin => info[i]["date_fin"])
              i = i + 1
            end
          end
        end        
        flash[:notice] = ("L'écheancier du contrat <strong>"+@contrat.acronyme+"</strong> à bien été mis à jour.").html_safe()
        
        if @contrat.sous_contrats.size > 1
          # Ajout d'une période dans l'échéancier du contrat => ajout dans tous le echéancier des sous_contrats
          if @contrat.sous_contrats.first.echeancier.echeancier_periodes.size < info.size
            j = @contrat.sous_contrats.first.echeancier.echeancier_periodes.size
            while j < info.size
              for sc in @contrat.sous_contrats
                echeancier_periode_sc = EcheancierPeriode.new()
                echeancier_periode_sc.echeancier_id = sc.echeancier.id
                echeancier_periode_sc.date_debut = info[j]["date_debut"]
                echeancier_periode_sc.date_fin = info[j]["date_fin"]
                echeancier_periode_sc.save
              end
              j = j + 1
            end
          end
        end 
        format.html { redirect_to contrat_echeancier_url(@contrat, @echeancier) }
      else
        prepare_echeancier_periodes
        format.html { render :action => "edit" }
      end
    end
  end


  def ask_delete
    @contrat = Contrat.find(params[:contrat_id])
    @echeancier = Echeancier.find(params[:id])
    respond_to do |format|
      format.html
    end
  end


  # DELETE /echeanciers/1
  # DELETE /echeanciers/1.xml
  def destroy
    @contrat = Contrat.find(params[:contrat_id])
    @echeancier = Echeancier.find(params[:id])    
    for sc in @contrat.sous_contrats
      if !sc.echeancier.nil?
        sc.echeancier.destroy
      end
    end
    @echeancier.destroy

    respond_to do |format|
      
      flash[:notice] = ("L'échéancier du contrat <strong>"+@contrat.acronyme+"<strong> a bien été supprimé.").html_safe()  
      format.js { render :js =>%(window.location.href='#{contrat_path(@contrat)}') }
      
      format.html { redirect_to contrat_path(@contrat) }
    end
  end
  
end
