#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class NotificationsController < ApplicationController  
  before_filter :is_my_research_in_session?
  
  include UIEnhancements::SubList
  helper :SubList

  auto_complete_for :notification, :etablissement_rattachement_porteur
  auto_complete_for :notification, :etablissement_gestionnaire_du_coordinateur
  auto_complete_for :notification, :organisme_financeur
  auto_complete_for :notification, :organisme_payeur
  auto_complete_for :notification, :etablissement_gestionnaire
  auto_complete_for :notification, :poles_competivites

  sub_list 'NotificationFrancePartenaires', 'notification' do |new_notification_france_partenaire|
  end
  sub_list 'NotificationEuropePartenaires', 'notification' do |new_notification_europe_partenaire|
  end
  sub_list 'NotificationPartenaires', 'notification' do |new_notification_partenaire|
  end
  sub_list 'NotificationPersonnels', 'notification' do |new_notification_personnel|
  end
  sub_list 'SousContratNotification', 'notification' do |new_sous_contrat_notification|
  end
  sub_list 'Avenant', 'notification' do |avenant|
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


  # GET /notifications
  # GET /notifications.xml
  def index
    @notifications = Notification.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /notifications/1
  # GET /notifications/1.xml
  def show
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @notification = @contrat.notification

    respond_to do |format|
      format.html {
        if !@contrat.is_consultable? current_user
          flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'accéder au contrat "+@contrat.acronyme+".").html_safe()  
          redirect_to contrats_path
        end
      }
      format.pdf do
         pdf = PrawnPdfDrawer.new(@notification, request)
         send_data pdf.render, :filename => 'notification_'+@contrat.acronyme+'.pdf', :type => 'application/pdf', :disposition => 'inline'
      end
    end
  end

  # GET /notifications/new
  def new
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @key_words = KeyWord.find(:all)
    @soumission = @contrat.soumission    
    #@sous_contrats = @contrat.sous_contrats

    error = false
    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer une notification pour le contrat "+@contrat.acronyme+".").html_safe()       
      redirect_to contrat_path(@contrat)
      error = true
    else
      if !@contrat.notification.nil?
        flash[:error] = ("Il est impossible de créer une notification pour le contrat "+@contrat.acronyme+" car elle existe déja.").html_safe()       
        redirect_to contrat_notification_path(@contrat, @contrat.notification)
        error = true
      else
        if @contrat.soumission.nil? 
          flash[:error] = ("Il est impossible de créer une notification pour le contrat "+@contrat.acronyme+" car la 
          soumission n'est pas enregistrée. Merci de procéder à la création de la soumission.").html_safe()       
          redirect_to new_contrat_soumission_path(@contrat)
          error = true
        else
          if @contrat.signature.nil?
            flash[:error] = ("Il est impossible de créer une notification pour le contrat "+@contrat.acronyme+" car la signature 
            n'est pas enregistrée. Merci de procéder à la création de la signature.").html_safe()       
            redirect_to new_contrat_signature_path(@contrat)
            error = true
          end
          if !@contrat.refu.nil?
            flash[:error] = ("Il est impossible de créer une notification pour le contrat "+@contrat.acronyme+" car un refus à déjà été enregistré.").html_safe()       
            redirect_to contrat_refu_path(@contrat, @contrat.refu)
            error = true
          end
        end
      end
    end

    if !error
      @notification = Notification.new
      @non_modifiables = @notification.get_non_modifiables
      # Pré-chargement des infos de la soumission
      ## Généralités
      @notification.contrat_type_id = @soumission.contrat_type_id
      @notification.nombre_mois = @soumission.nombre_mois
      @notification.etablissement_gestionnaire = @soumission.etablissement_gestionnaire
      @notification.organisme_gestionnaire_id = @soumission.organisme_gestionnaire_id
      @notification.organisme_financeur = @soumission.organisme_financeur
      @notification.porteur = @soumission.porteur
      @notification.etablissement_rattachement_porteur = @soumission.etablissement_rattachement_porteur
      @notification.est_porteur = @soumission.est_porteur
      @notification.coordinateur = @soumission.coordinateur
      @notification.etablissement_gestionnaire_du_coordinateur = @soumission.etablissement_gestionnaire_du_coordinateur

      ## Mots clés et thématiques
      @notification.key_words = @soumission.key_words
      @notification.mots_cles_libres = @soumission.mots_cles_libres
      @notification.thematiques = @soumission.thematiques
      @notification.poles_competivites = @soumission.poles_competivites

      ## Partenaires
      #--- Pré-chargement des partenaires en France
      for partenaire in @soumission.soumission_france_partenaires
        a = @notification.notification_france_partenaires.build(
        :etablissement_gestionnaire => partenaire.etablissement_gestionnaire,
        :ville => partenaire.ville,
        :nom => partenaire.nom)
        # Assignation d'un identifiant
        a.id = Time.now.to_i+rand(1000000000000000).to_i
      end

      #--- Pré-chargement des partenaires en Europe
      for partenaire in @soumission.soumission_europe_partenaires
        a = @notification.notification_europe_partenaires.build(
        :etablissement_gestionnaire => partenaire.etablissement_gestionnaire,
        :ville => partenaire.ville,
        :nom => partenaire.nom,
        :pays => partenaire.pays)
        # Assignation d'un identifiant
        a.id = Time.now.to_i+rand(1000000000000000).to_i        
      end

      #--- Pré-chargement des partenaires hors Europe
      for partenaire in @soumission.soumission_partenaires
        a = @notification.notification_partenaires.build(
        :etablissement_gestionnaire => partenaire.etablissement_gestionnaire,
        :ville => partenaire.ville,
        :nom => partenaire.nom,
        :pays => partenaire.pays)
        # Assignation d'un identifiant
        a.id = Time.now.to_i+rand(1000000000000000).to_i        
      end

      ## Moyens accordés
      @notification.ma_type_montant = @soumission.md_type_montant
      @notification.ma_fonctionnement = @soumission.md_fonctionnement
      @notification.ma_equipement = @soumission.md_equipement
      @notification.ma_salaire = @soumission.md_salaire
      @notification.ma_mission = @soumission.md_mission
      @notification.ma_couts_indirects = @soumission.md_couts_indirects
      @notification.ma_frais_gestion_mutualises_local = 0.00
      @notification.ma_frais_gestion_mutualises = 0.00
      @notification.ma_allocation = @soumission.md_allocation
      @notification.ma_total = @soumission.md_total

      for sous_contrat in @contrat.sous_contrats
        a = @notification.sous_contrat_notifications.build(:sous_contrat_id => sous_contrat.id)
        a.id = Time.now.to_i+rand(1000000000000000).to_i        
      end


      ## Personnel accordé
      @notification.pa_doctorant = @soumission.pd_doctorant
      @notification.pa_post_doc = @soumission.pd_post_doc
      @notification.pa_ingenieur = @soumission.pd_ingenieur
      @notification.pa_autre = @soumission.pd_autre
      @notification.pa_equivalent_temps_plein = @soumission.pd_equivalent_temps_plein

      #--- Pré-chargement du personnel impliqué
      for personnel in @soumission.soumission_personnels
        a = @notification.notification_personnels.build(
        :nom => personnel.nom,
        :prenom => personnel.prenom,
        :statut => personnel.statut,
        :tutelle => personnel.tutelle,
        :pourcentage => personnel.pourcentage)
        # Assignation d'un identifiant
        a.id = Time.now.to_i+rand(1000000000000000).to_i        
      end


    end

  end

  # GET /notifications/1;edit
  def edit
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @notification = @contrat.notification
    @non_modifiables = @notification.get_non_modifiables

    if !@contrat.is_editable? current_user 
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'éditer la notification du contrat "+@contrat.acronyme+".").html_safe()       
      redirect_to contrat_notification_path(@contrat)
    end

    for sous_contrat in @contrat.sous_contrats
      if @notification.sous_contrat_notifications.find(:all, :conditions => ["sous_contrat_id = ?", sous_contrat.id]).size != 1
        a = @notification.sous_contrat_notifications.build(:sous_contrat_id => sous_contrat.id)
        a.id = Time.now.to_i+rand(1000000000000000).to_i
      end
    end

  end

  # POST /notifications
  # POST /notifications.xml
  def create
    params[:notification] = clean_date_params(params[:notification])
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])    

    params[:notification][:key_word_ids] ||= []

    @notification = Notification.new(params[:notification])
    @notification.contrat = @contrat
    @non_modifiables = @notification.get_non_modifiables
    success = true
    success &&= initialize_notification_france_partenaires
    success &&= initialize_notification_europe_partenaires
    success &&= initialize_notification_partenaires
    success &&= initialize_notification_personnels
    success &&= initialize_sous_contrat_notifications
    success &&= initialize_avenants    
    success &&= @notification.save

    respond_to do |format|
      if success
            
        if params[:notification][:ma_total].nil?
          ma_total = @notification.ma_fonctionnement.to_f + @notification.ma_equipement.to_f + @notification.ma_salaire.to_f +
          @notification.ma_mission.to_f + @notification.ma_non_ventile.to_f + @notification.ma_couts_indirects.to_f + @notification.ma_frais_gestion_mutualises.to_f + @notification.ma_frais_gestion_mutualises_local.to_f
        end
        
        if params[:notification][:pa_equivalent_temps_plein].nil?
          pa_equivalent_temps_plein = ( @notification.pa_doctorant + @notification.pa_post_doc + 
          @notification.pa_ingenieur + @notification.pa_autre ).to_f / @notification.nombre_mois.to_f 
        end
        
        if @notification.sous_contrat_notifications.size > 1
          a_total = []
          a_temps_pleins = []
          params[:sous_contrat_notification].sort.each do |key, values|
            if values[:ma_total].nil?
              a_total << (values[:ma_fonctionnement].to_f + values[:ma_equipement].to_f + values[:ma_salaire].to_f +
                          values[:ma_mission].to_f + values[:ma_non_ventile].to_f + values[:ma_couts_indirects].to_f + values[:ma_frais_gestion_mutualises].to_f + values[:ma_frais_gestion_mutualises_local].to_f)
            end
            if values[:pa_equivalent_temps_plein].nil?
              a_temps_pleins << (values[:pa_doctorant].to_f + values[:pa_post_doc].to_f + values[:pa_ingenieur].to_f +
                          values[:pa_autre].to_f) / @notification.nombre_mois.to_f
            end
          end
          i = 0
          for sc in @notification.sous_contrat_notifications
            sc.ma_total = a_total[i].to_f
            sc.pa_equivalent_temps_plein = a_temps_pleins[i].to_f
            sc.save
            i = i + 1
          end
        end
        
        notification = @contrat.notification
        notification.ma_total = ma_total
        notification.pa_equivalent_temps_plein = pa_equivalent_temps_plein
        notification.save

        flash[:notice] = ('La notification du contrat <strong>'+@contrat.acronyme+'</strong> a bien été créée.').html_safe()
        format.html { redirect_to contrat_notification_url(@contrat, @notification) }
      else
        prepare_notification_france_partenaires
        prepare_notification_europe_partenaires
        prepare_notification_partenaires
        prepare_notification_personnels
        prepare_sous_contrat_notifications
        prepare_avenants
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /notifications/1
  # PUT /notifications/1.xml
  def update
    params[:notification] = clean_date_params(params[:notification])
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @notification = @contrat.notification
    @non_modifiables = @notification.get_non_modifiables
    params[:notification][:key_word_ids] ||= []

    @notification.update_attributes(params[:notification])
    success = true
    success &&= initialize_notification_france_partenaires
    success &&= initialize_notification_europe_partenaires
    success &&= initialize_notification_partenaires
    success &&= initialize_notification_personnels
    success &&= initialize_sous_contrat_notifications   
    success &&= initialize_avenants    
    success &&= @notification.save

    respond_to do |format|
      if success

        if @notification.sous_contrat_notifications.size > 1
          for sc in @notification.sous_contrat_notifications
            if params[:sous_contrat_notification][sc.id.to_s][:ma_total].nil?
              params[:sous_contrat_notification][sc.id.to_s][:ma_total] = params[:sous_contrat_notification][sc.id.to_s][:ma_fonctionnement].to_f +
                                                                          params[:sous_contrat_notification][sc.id.to_s][:ma_equipement].to_f +
                                                                          params[:sous_contrat_notification][sc.id.to_s][:ma_salaire].to_f +
                                                                          params[:sous_contrat_notification][sc.id.to_s][:ma_mission].to_f +
                                                                          params[:sous_contrat_notification][sc.id.to_s][:ma_non_ventile].to_f +
                                                                          params[:sous_contrat_notification][sc.id.to_s][:ma_couts_indirects].to_f+
                                                                          params[:sous_contrat_notification][sc.id.to_s][:ma_frais_gestion_mutualises].to_f+
                                                                          params[:sous_contrat_notification][sc.id.to_s][:ma_frais_gestion_mutualises_local].to_f
            end
          end
          for sc in @notification.sous_contrat_notifications
            if params[:sous_contrat_notification][sc.id.to_s][:pa_equivalent_temps_plein].nil?
              params[:sous_contrat_notification][sc.id.to_s][:pa_equivalent_temps_plein] = (params[:sous_contrat_notification][sc.id.to_s][:pa_doctorant].to_f +
                                                                                            params[:sous_contrat_notification][sc.id.to_s][:pa_post_doc].to_f +
                                                                                            params[:sous_contrat_notification][sc.id.to_s][:pa_ingenieur].to_f +
                                                                                            params[:sous_contrat_notification][sc.id.to_s][:pa_autre].to_f) / 
                                                                                            params[:notification][:nombre_mois].to_f
            end
          end
          initialize_sous_contrat_notifications
        end

        if params[:notification][:ma_total].nil?
          params[:notification][:ma_total] =  @notification.ma_fonctionnement + @notification.ma_equipement + @notification.ma_salaire +
          @notification.ma_mission + @notification.ma_non_ventile + @notification.ma_couts_indirects + @notification.ma_frais_gestion_mutualises + @notification.ma_frais_gestion_mutualises_local;
        end
        if params[:notification][:pa_equivalent_temps_plein].nil?
          params[:notification][:pa_equivalent_temps_plein] = ( @notification.pa_doctorant + @notification.pa_post_doc + 
          @notification.pa_ingenieur + @notification.pa_autre ) / @notification.nombre_mois.to_f ;
        end  

        @notification.update_attributes(params[:notification])
        success &&= @notification.save


        flash[:notice] = ('La notification du contrat <strong>'+@contrat.acronyme+'</strong> a bien été mise à jour.').html_safe()       
        format.html { redirect_to contrat_notification_url(@contrat, @notification) }
      else
        prepare_notification_france_partenaires
        prepare_notification_europe_partenaires
        prepare_notification_partenaires
        prepare_notification_personnels
        prepare_sous_contrat_notifications
        prepare_avenants
        format.html { render :action => "edit" }
      end
    end
  end

  def ask_delete
    @contrat = Contrat.find(params[:contrat_id])
    @notification = @contrat.notification
    respond_to do |format|
      format.html
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.xml
  def destroy
    @contrats = Contrat.find(:all, :order => "acronyme")
    @contrat = Contrat.find(params[:contrat_id])
    @notification = @contrat.notification

    if @contrat.is_editable? current_user 
      @notification.destroy
      respond_to do |format|
        flash[:notice] = ('La notification du contrat <strong>'+@contrat.acronyme+'</strong> a bien été supprimée.').html_safe()       
        format.html { redirect_to contrat_path(@contrat) }
      end
    else
      flash[:error] = ("Vos droits dans l'application ne vous permettent de supprimer la notification du contrat "+@contrat.acronyme+".").html_safe()       
      format.html { redirect_to contrat_notification_path(@contrat) }
    end
  end
end
