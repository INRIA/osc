#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SoumissionsController < ApplicationController    
  before_filter :is_my_research_in_session?

  include UIEnhancements::SubList
  helper :SubList  
  
  auto_complete_for :soumission, :etablissement_rattachement_porteur
  auto_complete_for :soumission, :etablissement_gestionnaire_du_coordinateur
  auto_complete_for :soumission, :organisme_financeur
  auto_complete_for :soumission, :etablissement_gestionnaire
  auto_complete_for :soumission, :poles_competivites
  
  sub_list 'SoumissionPersonnel', 'soumission' do |new_soumission_personnel|
  end  
  sub_list 'SoumissionPartenaires', 'soumission' do |new_soumission_partenaire|
  end 
  sub_list 'SoumissionFrancePartenaires', 'soumission' do |new_soumission_partenaire|
  end  
  sub_list 'SoumissionEuropePartenaires', 'soumission' do |new_soumission_partenaire|
  end
  
  
  def update_type_contrat
    @contrat = Contrat.find(params[:contrat_id])
    @contrat_type = ContratType.find(params[:type])

    respond_to do |format|
      format.js {
        render :inline => "<%= display_contrat_type(@contrat_type) %>"
      }
    end
  end
  
  
  # GET /soumissions
  # GET /soumissions.xml
  def index
    @contrats = Contrat.find(:all, :order => "acronyme")
    @soumissions = @soumissions.find(:all)
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /soumissions/1
  # GET /soumissions/1.xml
  def show
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @soumission = @contrat.soumission
    
    respond_to do |format|
      format.html {
        if !@contrat.is_consultable? current_user
            flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'accéder au contrat "+@contrat.acronyme+".").html_safe()  
            redirect_to contrats_path()
        end
      }
      format.pdf do
         pdf = PrawnPdfDrawer.new(@soumission, request)
         send_data pdf.render, :filename => 'soumission_'+@contrat.acronyme+'.pdf', :type => 'application/pdf', :disposition => 'inline'
      end
    end
  end

  # GET /soumissions/new
  def new
    @contrats = Contrat.find(:all, :order => "acronyme")
    @soumission = Soumission.new
    @key_words = KeyWord.find(:all)
    @contrat = Contrat.find(params[:contrat_id])
    @non_modifiables = @soumission.get_non_modifiables
    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer une soumission pour le contrat "+@contrat.acronyme+".").html_safe()       
      redirect_to contrat_path(@contrat)
    elsif !@contrat.soumission.nil?
      flash[:error] = ("Il est impossible de créer une soumission pour le contrat "+@contrat.acronyme+" car elle existe déja.").html_safe()       
      redirect_to contrat_soumission_url(@contrat, @contrat.soumission)
    end
  end

  # GET /soumissions/1;edit
  def edit
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])    
    @soumission = @contrat.soumission
    @non_modifiables = @soumission.get_non_modifiables
    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'éditer la soumission du contrat "+@contrat.acronyme+".").html_safe()       
      redirect_to contrat_soumission_url(@contrat)
    end
    
  end

  # POST /soumissions
  # POST /soumissions.xml
  def create
    params[:soumission] = clean_date_params(params[:soumission])
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])    
    
    params[:soumission][:key_word_ids] ||= []
    
    @soumission = Soumission.new(params[:soumission])
    @non_modifiables = @soumission.get_non_modifiables
    if params[:soumission][:est_porteur] == "1"
      params[:soumission]["coordinateur"] = params[:soumission]["porteur"]
    end
    
    @soumission.contrat = @contrat
    
    success = true
    success &&= initialize_soumission_partenaires
    success &&= initialize_soumission_france_partenaires
    success &&= initialize_soumission_europe_partenaires
    success &&= initialize_soumission_personnels
    success &&= @soumission.save

    respond_to do |format|
      if success
        if params[:soumission][:md_total].nil?
          params[:soumission][:md_total] = @soumission.md_fonctionnement + @soumission.md_equipement + @soumission.md_salaire +
                                           @soumission.md_mission + @soumission.md_non_ventile + @soumission.md_couts_indirects ;
        end

        if params[:soumission][:total_subvention].nil?
          params[:soumission][:total_subvention] = params[:soumission][:md_total] * @soumission.taux_subvention ;
        end
        if params[:soumission][:pd_equivalent_temps_plein].nil?
          params[:soumission][:pd_equivalent_temps_plein] = (@soumission.pd_doctorant.to_f + @soumission.pd_post_doc.to_f +
                                                             @soumission.pd_ingenieur.to_f + @soumission.pd_autre.to_f) / @soumission.nombre_mois.to_f
        end
        @soumission.update_attributes(params[:soumission])
        @soumission.save
        flash[:notice] = ('La soumission du contrat <strong>'+@contrat.acronyme+'</strong> a bien été créée.').html_safe()       
        format.html { redirect_to contrat_soumission_url(@contrat, @soumission) }
      else
        prepare_soumission_partenaires
        prepare_soumission_france_partenaires
        prepare_soumission_europe_partenaires
        prepare_soumission_personnels
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /soumissions/1
  # PUT /soumissions/1.xml
  def update
    params[:soumission] = clean_date_params(params[:soumission])
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])    
    @soumission = @contrat.soumission
    @non_modifiables = @soumission.get_non_modifiables
    params[:soumission][:key_word_ids] ||= []
    
    if params[:soumission][:est_porteur] == "1"
      params[:soumission]["coordinateur"] = params[:soumission]["porteur"]
    end
    
    @soumission.update_attributes(params[:soumission])
    success = true
    success &&= initialize_soumission_partenaires
    success &&= initialize_soumission_france_partenaires
    success &&= initialize_soumission_europe_partenaires
    success &&= initialize_soumission_personnels
    success &&= @soumission.save
    
    respond_to do |format|
      if success
        if params[:soumission][:md_total].nil?
          params[:soumission][:md_total] = @soumission.md_fonctionnement + @soumission.md_equipement + @soumission.md_salaire +
                                           @soumission.md_mission + @soumission.md_non_ventile + @soumission.md_couts_indirects ;
        end

        if params[:soumission][:total_subvention].nil?
          params[:soumission][:total_subvention] = params[:soumission][:md_total] * @soumission.taux_subvention ;
        end

        if params[:soumission][:pd_equivalent_temps_plein].nil?
          params[:soumission][:pd_equivalent_temps_plein] = (@soumission.pd_doctorant.to_f + @soumission.pd_post_doc.to_f +
                                                             @soumission.pd_ingenieur.to_f + @soumission.pd_autre.to_f) / @soumission.nombre_mois.to_f
        end


        @soumission.update_attributes(params[:soumission])
        @soumission.save
    
        flash[:notice] = ('La soumission du contrat <strong>'+@contrat.acronyme+'</strong> a bien été mise à jour').html_safe()       
        format.html { redirect_to contrat_soumission_url(@contrat, @soumission) }
      else
        prepare_soumission_partenaires
        prepare_soumission_france_partenaires
        prepare_soumission_europe_partenaires
        prepare_soumission_personnels
        format.html { render :action => "edit" }
      end
    end
  end

  def ask_delete
    @contrat = Contrat.find(params[:contrat_id])  
    @soumission = @contrat.soumission  
    respond_to do |format|
      format.html
    end    
  end

  # DELETE /soumissions/1
  # DELETE /soumissions/1.xml
  def destroy
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])    
    @soumission = @contrat.soumission
    
    if @contrat.is_editable? current_user 
      @soumission.destroy
      flash[:notice] = ('La soumission du contrat <strong>'+@contrat.acronyme+'</strong> a bien été supprimée.').html_safe()       
      respond_to do |format|
        format.html { redirect_to contrat_path(@contrat) }
      end
    else
        flash[:error] = ("Vos droits dans l'application ne vous permettent de supprimer la soumission du contrat "+@contrat.acronyme+".").html_safe()       
        redirect_to contrat_soumission_url(@contrat)
    end

  end  
  
end
