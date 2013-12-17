#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SousContratsController < ApplicationController
  # GET /sous_contrats
  # GET /sous_contrats.xml
  def index
    @sous_contrats = SousContrat.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @sous_contrats.to_xml }
    end
  end

  # GET /sous_contrats/1
  # GET /sous_contrats/1.xml
  def show
    @sous_contrat = SousContrat.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @sous_contrat.to_xml }
    end
  end

  # GET /sous_contrats/new
  def new
    @sous_contrat = SousContrat.new
  end

  # GET /sous_contrats/1;edit
  def edit
    @sous_contrat = SousContrat.find(params[:id])
  end

  # POST /sous_contrats
  # POST /sous_contrats.xml
  def create
    @sous_contrat = SousContrat.new(params[:sous_contrat])

    respond_to do |format|
      if @sous_contrat.save
        
        flash[:notice] = 'Association ajoutée avec succès.'
        if !@sous_contrat.contrat.notification.nil?
          if @sous_contrat.contrat.sous_contrats.size == 2
            for sc in @sous_contrat.contrat.sous_contrats
              scn = SousContratNotification.new()
              scn.sous_contrat_id = sc.id
              scn.notification_id = sc.contrat.notification.id
              if scn.save
                flash[:notice] += ' Valeurs de notification initialisées.'
              end
            end
          elsif @sous_contrat.contrat.sous_contrats.size > 2
            scn = SousContratNotification.new()
            scn.sous_contrat_id = @sous_contrat.id
            scn.notification_id = @sous_contrat.contrat.notification.id
            if scn.save
              flash[:notice] += ' Valeurs de notification initialisées.'
            end
          end
          
          
          if !@sous_contrat.contrat.echeancier.nil?
            if @sous_contrat.contrat.sous_contrats.size == 2
              for sc in @sous_contrat.contrat.sous_contrats
                echeancier = Echeancier.new( :echeanciable_type => "SousContrat",
                                             :echeanciable_id => sc.id,
                                             :global_depenses_frais_gestion => 0)
                if echeancier.save
                  flash[:notice] += ' Echéancier du sous contrat créee.'
                end
                for periode in @sous_contrat.contrat.echeancier.echeancier_periodes
                  echeancier_periode_sc = EcheancierPeriode.new()
                  echeancier_periode_sc.echeancier_id = echeancier.id
                  echeancier_periode_sc.date_debut = periode.date_debut
                  echeancier_periode_sc.date_fin = periode.date_fin
                  if echeancier_periode_sc.save
                    flash[:notice] += ' Période créee.'
                  end
                end
              end        
            elsif @sous_contrat.contrat.sous_contrats.size >2
              echeancier = Echeancier.new( :echeanciable_type => "SousContrat",
                                            :echeanciable_id => @sous_contrat.id,
                                            :global_depenses_frais_gestion => 0)
            
              if echeancier.save
                flash[:notice] += ' Echéancier du sous contrat créee.'
              end
            
              for periode in @sous_contrat.contrat.echeancier.echeancier_periodes
                echeancier_periode_sc = EcheancierPeriode.new()
                echeancier_periode_sc.echeancier_id = echeancier.id
                echeancier_periode_sc.date_debut = periode.date_debut
                echeancier_periode_sc.date_fin = periode.date_fin
                if echeancier_periode_sc.save
                  flash[:notice] += ' Période créee.'
                end
              end
            end
          end
        end
        format.html { redirect_to :back }
        format.xml  { head :created, :location => sous_contrat_url(@sous_contrat) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sous_contrat.errors.to_xml }
      end
    end
  end

  # PUT /sous_contrats/1
  # PUT /sous_contrats/1.xml
  def update
    @sous_contrat = SousContrat.find(params[:id])

    respond_to do |format|
      if @sous_contrat.update_attributes(params[:sous_contrat])
        flash[:notice] = 'SousContrat was successfully updated.'
        format.html { redirect_to sous_contrat_url(@sous_contrat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sous_contrat.errors.to_xml }
      end
    end
  end

  def ask_delete
    @sous_contrat = SousContrat.find(params[:id])
    @ligne_exist = true unless @sous_contrat.ligne.nil?
  end


  # DELETE /sous_contrats/1
  # DELETE /sous_contrats/1.xml
  def destroy

    @sous_contrat = SousContrat.find(params[:id])
    
    if !@sous_contrat.contrat.notification.nil?
      sous_contrat_notifications = @sous_contrat.contrat.notification.sous_contrat_notifications
      if sous_contrat_notifications.size == 2
        for sous_contrat_notification in sous_contrat_notifications
          sous_contrat_notification.destroy
        end
      end
    end

    if !@sous_contrat.contrat.echeancier.nil?
      if @sous_contrat.contrat.sous_contrats.size == 2
        for sc in @sous_contrat.contrat.sous_contrats
          if !sc.echeancier.nil?
            sc.echeancier.destroy
          end
        end
      else
        for sc in @sous_contrat.contrat.sous_contrats
          if sc.id == @sous_contrat.id
            if !sc.echeancier.nil?
              sc.echeancier.destroy
            end
          end
        end
      end
    end
    
    @sous_contrat.destroy

    respond_to do |format|
      flash[:notice] = 'Association supprimée avec succès.'
      
  #    format.html { redirect_to sous_contrats_url }
      format.html { redirect_to :back }   
      format.xml  { head :ok }
    end
  end
end
