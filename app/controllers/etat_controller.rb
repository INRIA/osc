#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class EtatController < ApplicationController
  layout "layouts/application_etat", :except => :show_result
   
  before_filter :set_contrats_consultables
  before_filter :set_contrats_editables


  # Mise à jour du menu permettant de sélectionner les champs à
  # afficher en fonction du type de contrat selectionné
  def update_select
    @params = params

    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:type] == 'initial'
            page.hide  'select_choice_soumission'
            page.hide  'select_choice_refu'
            page.hide  'select_choice_signature'
            page.hide  'select_choice_notification'
            page.hide  'select_choice_cloture'
          end
          if params[:type] == 'soumission'
            page.show  'select_choice_soumission'
            page.hide  'select_choice_refu'
            page.hide  'select_choice_signature'
            page.hide  'select_choice_notification'
            page.hide  'select_choice_cloture'
          end
          if params[:type] == 'refu'
            page.show  'select_choice_soumission'
            page.show  'select_choice_refu'
            page.hide  'select_choice_signature'
            page.hide  'select_choice_notification'
            page.hide  'select_choice_cloture'
          end
          if params[:type] == 'signature'
            page.show  'select_choice_soumission'
            page.hide  'select_choice_refu'
            page.show  'select_choice_signature'
            page.hide  'select_choice_notification'
            page.hide  'select_choice_cloture'
          end
          if params[:type] == 'notification'
            page.hide  'select_choice_soumission'
            page.hide  'select_choice_refu'
            page.show  'select_choice_signature'
            page.show  'select_choice_notification'
            page.hide  'select_choice_cloture'
          end
          if params[:type] == 'cloture'
            page.hide  'select_choice_soumission'
            page.hide  'select_choice_refu'
            page.show  'select_choice_signature'
            page.show  'select_choice_notification'
            page.show  'select_choice_cloture'
          end
        end
      }
    end
  end



  # Affichage du résultat de la recherche
  def show_result

    prepare_result

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html "show_result_extraction", :partial => 'show_result'
          page.replace_html "result_count", @count_contrats.to_s+" contrats trouvés"
          page.replace_html "sort_and_filter", :partial => 'sort_and_filter'
          page.replace_html "paginate",  :partial => 'paginate'
        end
      end
    end
  end


  # Export csv du résultat de la recherche
  def export_csv

    prepare_result(true)
    #initialisation pour la conversion en UTF16 pour Excel (ms-office)
    if(['utf16'].include? params[:encode])
      codingTranslation = Iconv.new('WINDOWS-1252','UTF-8')
    else
      codingTranslation = Iconv.new('UTF-8','UTF-8')
    end
    options = {:row_sep => "\r\n", :col_sep => ";"}
    head = []
    @select.each{|s|
      head << codingTranslation.iconv(s[:intitule])
    }


    csv_string = CSV.generate(options) do |csv|
      csv << head
      @contrats.each do |c|
        ligne = []
        ligne << codingTranslation.iconv(c.acronyme)
        ligne << c.sous_contrats.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.entite.nom)+" ]"}*""  if params['contrats.associations']
        ligne << codingTranslation.iconv(c.etat) if params['contrats.etat']
        ligne << codingTranslation.iconv(c.nom) if params['contrats.nom']
        ligne << codingTranslation.iconv(c.num_contrat_etab) if params['contrats.num_contrat_etab']
        if params['contrats.etablissement.nom']
          if c.etablissement
            ligne << codingTranslation.iconv(c.etablissement.nom)
          else
            ligne << ""  
          end
        end
        
        
        if ['soumission', 'refu', 'signature', 'notification', 'cloture'].include? params[:type]
          # Soumission - Informations générales
          ligne << codingTranslation.iconv(c.soumission.contrat_type.nom_complet) if params['soumissions.contrat_type.nom']
          ligne << date_to_csv(c.soumission.date_depot) if params['soumissions.date_depot']
          ligne << c.soumission.nombre_mois if params['soumissions.nombre_mois']
          ligne << codingTranslation.iconv(c.soumission.organisme_gestionnaire.nom) if params['soumissions.organisme_gestionnaire.nom']
          ligne << codingTranslation.iconv(c.soumission.organisme_financeur) if params['soumissions.organisme_financeur']
          # Soumission - Porteur et coordinateur
          ligne << codingTranslation.iconv(c.soumission.porteur) if params['soumissions.porteur']
          ligne << codingTranslation.iconv(c.soumission.etablissement_rattachement_porteur) if params['soumissions.etablissement_rattachement_porteur']
          ligne << boolean_to_csv(c.soumission.est_porteur) if params['soumissions.est_porteur']
          ligne << codingTranslation.iconv(c.soumission.coordinateur) if params['soumissions.coordinateur']
          ligne << codingTranslation.iconv(c.soumission.etablissement_gestionnaire_du_coordinateur) if params['soumissions.etablissement_gestionnaire_du_coordinateur']
          # Soumission - Mots clés
          ligne << c.soumission.key_words.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.intitule)+" ]"}*"" if params['soumissions.mots_cles']
          ligne << c.soumission.mots_cles_libres.split(',').to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e)+" ]"}*"" if params['soumissions.mots_cles_libres']
          ligne << c.soumission.thematiques.split(',').to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e)+" ]"} if params['soumissions.thematiques']
          ligne << c.soumission.poles_competivites.split(',').to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e)+" ]"}*"" if params['soumissions.poles_competivites']
          # Soumission - Partenaires
          ligne << c.soumission.soumission_france_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.nom)+" ] "}*"" if params['soumission_france_partenaires.nom']
          ligne << c.soumission.soumission_france_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.laboratoire)+" ]"}*"" if params['soumission_france_partenaires.laboratoire']
          ligne << c.soumission.soumission_france_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.etablissement_gestionnaire)+" ]"}*"" if params['soumission_france_partenaires.etablissement_gestionnaire']
          ligne << c.soumission.soumission_france_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.ville)+" ]"}*"" if params['soumission_france_partenaires.ville']
          ligne << c.soumission.soumission_europe_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.nom)+" ]"}*"" if params['soumission_europe_partenaires.nom']
          ligne << c.soumission.soumission_europe_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.etablissement_gestionnaire)+" ]"}*""  if params['soumission_europe_partenaires.etablissement_gestionnaire']
          ligne << c.soumission.soumission_europe_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.ville)+" ]"}*""  if params['soumission_europe_partenaires.ville']
          ligne << c.soumission.soumission_europe_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.pays)+" ]"}*""  if params['soumission_europe_partenaires.pays']
          ligne << c.soumission.soumission_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.nom)+" ]"}*"" if params['soumission_partenaires.nom']
          ligne << c.soumission.soumission_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.etablissement_gestionnaire)+" ]"}*"" if params['soumission_partenaires.etablissement_gestionnaire']
          ligne << c.soumission.soumission_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.ville)+" ]"}*"" if params['soumission_partenaires.ville']
          ligne << c.soumission.soumission_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.pays)+" ]"}*"" if params['soumission_partenaires.pays']
          # Soumission - Moyens demandés
          ligne << codingTranslation.iconv(c.soumission.md_type_montant) if params['soumissions.md_type_montant']
          ligne << c.soumission.md_fonctionnement if params['soumissions.md_fonctionnement']
          ligne << c.soumission.md_equipement if params['soumissions.md_equipement']
          ligne << c.soumission.md_salaire if params['soumissions.md_salaire']
          ligne << c.soumission.md_mission if params['soumissions.md_mission']
          ligne << c.soumission.md_non_ventile if params['soumissions.md_non_ventile']
          ligne << c.soumission.md_couts_indirects if params['soumissions.md_couts_indirects']
          ligne << c.soumission.md_allocation if params['soumissions.md_allocation']
          ligne << c.soumission.md_total if params['soumissions.md_total']
          ligne << c.soumission.taux_subvention if params['soumissions.taux_subvention']
          ligne << c.soumission.total_subvention if params['soumissions.total_subvention']
          # Soumission - Personnel demandé
          ligne << c.soumission.pd_doctorant if params['soumissions.pd_doctorant']
          ligne << c.soumission.pd_post_doc if params['soumissions.pd_post_doc']
          ligne << c.soumission.pd_ingenieur if params['soumissions.pd_ingenieur']
          ligne << c.soumission.pd_autre if params['soumissions.pd_autre']
          ligne << c.soumission.pd_equivalent_temps_plein if params['soumissions.pd_equivalent_temps_plein']
          # Soumission - Personnel impliqué
          ligne << c.soumission.soumission_personnels.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.nom)+" ]"}*"" if params['soumission_personnels.nom']
          ligne << c.soumission.soumission_personnels.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.prenom)+" ]"}*"" if params['soumission_personnels.prenom']
          ligne << c.soumission.soumission_personnels.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.statut)+" ]"}*"" if params['soumission_personnels.statut']
          ligne << c.soumission.soumission_personnels.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.tutelle)+" ]"}*"" if params['soumission_personnels.tutelle']
          ligne << c.soumission.soumission_personnels.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.pourcentage.to_s)+" ]"}*"" if params['soumission_personnels.pourcentage']
        end
        if ['refu'].include? params[:type]
          ligne << date_to_csv(c.refu.date) if params['refus.date']
          ligne << boolean_to_csv(c.refu.liste_attente) if params['refus.liste_attente']
          ligne << boolean_to_csv(c.refu.labelise) if params['refus.labelise']
          ligne << codingTranslation.iconv(c.refu.commentaire) if params['refus.commentaire']
        end
        if ['signature', 'notification', 'cloture'].include? params[:type]
          ligne << date_to_csv(c.signature.date) if params['signatures.date']
          ligne << codingTranslation.iconv(c.signature.commentaire) if params['signatures.commentaire']
        end
        if ['notification', 'cloture'].include? params[:type]
          # Notification - Informations générales
          ligne << codingTranslation.iconv(contrat_type_to_csv(c.notification.contrat_type)) if params['notifications.contrat_type.nom']
          ligne << date_to_csv(c.notification.date_notification) if params['notifications.date_notification']
          ligne << date_to_csv(c.notification.date_debut) if params['notifications.date_debut']
          ligne << date_to_csv(c.notification.date_fin) if params['notifications.date_fin']
          ligne << c.notification.nombre_mois if params['notifications.nombre_mois']
          ligne << codingTranslation.iconv(c.notification.organisme_gestionnaire.nom) if params['notifications.organisme_gestionnaire.nom']
          ligne << codingTranslation.iconv(c.notification.organisme_financeur) if params['notifications.organisme_financeur']
          ligne << codingTranslation.iconv(c.notification.organisme_payeur) if params['notifications.organisme_payeur']
          ligne << c.notification.numero_ligne_budgetaire if params['notifications.numero_ligne_budgetaire']
          ligne << c.notification.numero_contrat if params['notifications.numero_contrat']
          ligne << boolean_to_csv(c.notification.a_justifier) if params['notifications.a_justifier']
          ligne << c.notification.url if params['notifications.url']
          # Notification - Porteur et coordinateur
          ligne << codingTranslation.iconv(c.notification.porteur) if params['notifications.porteur']
          ligne << codingTranslation.iconv(c.notification.etablissement_rattachement_porteur) if params['notifications.etablissement_rattachement_porteur']
          ligne << boolean_to_csv(c.notification.est_porteur) if params['notifications.est_porteur']
           
          ligne << codingTranslation.iconv(c.notification.coordinateur) if params['notifications.coordinateur']
          ligne << codingTranslation.iconv(c.notification.etablissement_gestionnaire_du_coordinateur) if params['notifications.etablissement_gestionnaire_du_coordinateur']
          # Notification - Mots clés
          ligne << c.notification.key_words.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.intitule)+" ]"}*"" if params['notifications.mots_cles']
          ligne << c.notification.mots_cles_libres.split(',').to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e)+" ]"}*"" if params['notifications.mots_cles_libres']
          ligne << c.notification.thematiques.split(',').to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e)+" ]"} if params['notifications.thematiques']
          ligne << c.notification.poles_competivites.split(',').to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e)+" ]"}*"" if params['notifications.poles']
          # Notification - Partenaires
          ligne << c.notification.notification_france_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.nom)+" ]"}*"" if params['notification_france_partenaires.nom']
          ligne << c.notification.notification_france_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.laboratoire)+" ]"}*"" if params['notification_france_partenaires.laboratoire']
          ligne << c.notification.notification_france_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.etablissement_gestionnaire)+" ]"}*"" if params['notification_france_partenaires.etablissement_gestionnaire']
          ligne << c.notification.notification_france_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.ville)+" ]"}*"" if params['notification_france_partenaires.ville']
          ligne << c.notification.notification_europe_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.nom)+" ]"}*"" if params['notification_europe_partenaires.nom']
          ligne << c.notification.notification_europe_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.etablissement_gestionnaire)+" ]"}*""  if params['notification_europe_partenaires.etablissement_gestionnaire']
          ligne << c.notification.notification_europe_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.ville)+" ]"}*""  if params['notification_europe_partenaires.ville']
          ligne << c.notification.notification_europe_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.pays)+" ]"}*""  if params['notification_europe_partenaires.pays']
          ligne << c.notification.notification_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.nom)+" ]"}*"" if params['notification_partenaires.nom']
          ligne << c.notification.notification_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.etablissement_gestionnaire)+" ]"}*"" if params['notification_partenaires.etablissement_gestionnaire']
          ligne << c.notification.notification_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.ville)+" ]"}*"" if params['notification_partenaires.ville']
          ligne << c.notification.notification_partenaires.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.pays)+" ]"}*"" if params['notification_partenaires.pays']
          # Notification - Moyens accordés
          ligne << codingTranslation.iconv(c.notification.ma_type_montant) if params['notifications.ma_type_montant']
          ligne << c.notification.ma_fonctionnement if params['notifications.ma_fonctionnement']
          ligne << c.notification.ma_equipement if params['notifications.ma_equipement']
          ligne << c.notification.ma_salaire if params['notifications.ma_salaire']
          ligne << c.notification.ma_mission if params['notifications.ma_mission']
          ligne << c.notification.ma_non_ventile if params['notifications.ma_non_ventile']
          ligne << c.notification.ma_couts_indirects if params['notifications.ma_couts_indirects']
          ligne << c.notification.ma_frais_gestion_mutualises_local if params['notifications.ma_frais_gestion_mutualises_local']
          ligne << c.notification.ma_frais_gestion_mutualises if params['notifications.ma_frais_gestion_mutualises']
          ligne << c.notification.ma_allocation if params['notifications.ma_allocation']
          ligne << c.notification.ma_total if params['notifications.ma_total']
          # Notification - Personnel accordés
          ligne << c.notification.pa_doctorant if params['notifications.pa_doctorant']
          ligne << c.notification.pa_post_doc if params['notifications.pa_post_doc']
          ligne << c.notification.pa_ingenieur if params['notifications.pa_ingenieur']
          ligne << c.notification.pa_autre if params['notifications.pa_autre']
          ligne << c.notification.pa_equivalent_temps_plein if params['notifications.pa_equivalent_temps_plein']
          # Soumission - Personnel impliqué
          ligne << c.notification.notification_personnels.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.nom)+" ]"}*"" if params['notification_personnels.nom']
          ligne << c.notification.notification_personnels.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.prenom)+" ]"}*"" if params['notification_personnels.prenom']
          ligne << c.notification.notification_personnels.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.statut)+" ]"}*"" if params['notification_personnels.statut']
          ligne << c.notification.notification_personnels.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.tutelle)+" ]"}*"" if params['notification_personnels.tutelle']
          ligne << c.notification.notification_personnels.to_enum(:each_with_index).collect{|e,i| "[ "+i.to_s+". "+codingTranslation.iconv(e.pourcentage.to_s)+" ]"}*"" if params['notification_personnels.pourcentage']
        end
        if ['cloture'].include? params[:type]
          ligne << date_to_csv(c.cloture.date_fin_depenses) if params['clotures.date_fin_depenses']
          ligne << codingTranslation.iconv(c.cloture.commentaires) if params['clotures.commentaires']
        end
        csv << ligne
      end
    end
    send_data csv_string, :type => 'text/csv',
                          :disposition => "attachment; filename=export_osc.csv" 
  end


  def extraction
    @ids_viewables = @ids_consultables+@ids_editables

    @select = []
    @select << {:id => "acronyme", :intitule => "Acronyme"}
    @select_for_sort = @select
    @select_for_filter = @select
    @params = params
    @sort_params = [:sort => "acronyme", :order => "ASC"]
    @filter_params = [:filter_item => "acronyme", :filter_type => "contient", :filter_value => ""]
  end

  def add_sort_item
    prepare_selected_fields
    respond_to do |format|
      format.js do
        render :update do |page|
          page.insert_html :bottom, "form_sort", :partial => 'add_sort_item', :locals => { :item => {} }
        end
      end
    end
  end

  def add_filter_item
    prepare_selected_fields
    respond_to do |format|
      format.js do
        render :update do |page|
          page.insert_html :bottom, "form_filter", :partial => 'add_filter_item', :locals => { :item => {} }
        end
      end
    end
  end

  # unobtrusive_date_picker_tags broken :(
  class SelectionPeriod
    attr_accessor :start, :end
    def initialize(d_start=nil, d_end=nil)
      if d_start and !d_start.is_a?(Date)
        throw 'arg1 should be a Date'
      else
        @start = d_start
      end
      if d_end and !d_end.is_a?(Date)
        throw 'arg2 should be a Date'
      else
        @end = d_end
      end
    end
  end

  def notification
    @ids_viewables = @ids_consultables+@ids_editables

    @acronyme         = params[:acronyme] || ""
    @noContrat        = params[:noContrat] || ""
    @equipe           = params[:equipe] || ""
    @laboratoire      = params[:laboratoire] || ""
    @departement      = params[:departement] || ""
    @app_laboratoire  = params[:app_laboratoire] || ""
    @app_departement  = params[:app_departement] || ""
    @app_tutelle      = params[:app_tutelle] || ""

    if @ids_viewables.size != 0

      @ids_contrats = Contrat.my_find_all(@ids_viewables,
        @acronyme,
        @noContrat,
        @equipe,
        @laboratoire,
        @departement,
        @app_laboratoire,
        @app_departement,
        @app_tutelle)

      @date_contrat_first = Contrat.minimum('notifications.date_debut', :include => [:notification],:joins => :notification,
        :conditions => [ "contrats.id in (?)", @ids_viewables]).to_date
      @date_contrat_last = Contrat.maximum('notifications.date_fin', :include => [:notification],:joins => :notification,
        :conditions => [ "contrats.id in (?)", @ids_viewables]).to_date
      @notification_period = setup_selection_period(@date_contrat_first,
        @date_contrat_last, 'notification_period')

      @ids_contrats = Contrat.find( :all,
        :select => "contrats.id",
        :joins => "LEFT OUTER JOIN `soumissions` ON soumissions.contrat_id = contrats.id
                   LEFT OUTER JOIN `notifications` ON notifications.contrat_id = contrats.id",
        :conditions => ["notifications.date_fin >= ?
                         AND notifications.date_debut <= ?
                         AND contrats.id in (?)",
          @notification_period.start.to_s,
          @notification_period.end.to_s,
          @ids_contrats]
        ).collect{|c| c.id}

      @ma_total = Notification.sum(:ma_total, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0
      @ma_fonctionnement_total = Notification.sum(:ma_fonctionnement, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0
      @ma_equipement_total = Notification.sum(:ma_equipement, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0
      @ma_salaire_total = Notification.sum(:ma_salaire, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0
      @ma_mission_total = Notification.sum(:ma_mission, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0
      @ma_non_ventile_total = Notification.sum(:ma_non_ventile, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0
      @ma_couts_indirects_total = Notification.sum(:ma_couts_indirects, :conditions => [ "contrat_id in (?)", @ids_contrats])   || 0
      @ma_frais_gestion_mutualises_local_total = Notification.sum(:ma_frais_gestion_mutualises_local, :conditions => [ "contrat_id in (?)", @ids_contrats])   || 0
      @ma_frais_gestion_mutualises_total = Notification.sum(:ma_frais_gestion_mutualises, :conditions => [ "contrat_id in (?)", @ids_contrats])   || 0
      @pa_doctorant_total               = Notification.sum(:pa_doctorant, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0
      @pa_post_doc_total                = Notification.sum(:pa_post_doc, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0
      @pa_ingenieur_total               = Notification.sum(:pa_ingenieur, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0
      @pa_autre_total                   = Notification.sum(:pa_autre, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0
      @pa_total = (@pa_doctorant_total + @pa_post_doc_total + @pa_ingenieur_total + @pa_autre_total).to_f
    else
      @ids_contrats = []
    end
  end


  def soumission_vs_notification

    @ids_viewables = @ids_consultables+@ids_editables

    @acronyme         = params[:acronyme] || ""
    @noContrat        = params[:noContrat] || ""
    @equipe           = params[:equipe] || ""
    @laboratoire      = params[:laboratoire] || ""
    @departement      = params[:departement] || ""
    @app_laboratoire  = params[:app_laboratoire] || ""
    @app_departement  = params[:app_departement] || ""
    @app_tutelle      = params[:app_tutelle] || ""

    if @ids_viewables.size != 0

      @ids_contrats = Contrat.my_find_all(@ids_viewables,
        @acronyme,
        @noContrat,
        @equipe,
        @laboratoire,
        @departement,
        @app_laboratoire,
        @app_departement,
        @app_tutelle)

      @date_depot_first = Contrat.minimum('soumissions.date_depot', :include => [:soumission],:joins => :soumission,
        :conditions => [ "contrats.id in (?)", @ids_viewables]).to_date
      @date_depot_last = Contrat.maximum('soumissions.date_depot', :include => [:soumission],:joins => :soumission,
        :conditions => [ "contrats.id in (?)", @ids_viewables]).to_date
      @depot_period = setup_selection_period(@date_depot_first, @date_depot_last, 'depot_period')

      @ids_contrats = Contrat.find( :all,
        :select => "contrats.id",
        :joins => " LEFT OUTER JOIN `soumissions` ON soumissions.contrat_id = contrats.id
                    LEFT OUTER JOIN `notifications` ON notifications.contrat_id = contrats.id",
        :conditions => ["EXTRACT(YEAR FROM soumissions.date_depot) in (?) AND contrats.id in (?)",
          @depot_period.start.year..@depot_period.end.year,
          @ids_contrats]
        ).collect{|c| c.id}

      @nb_contrats = Contrat.count(:all, :conditions => [ "contrats.id in (?)", @ids_contrats])
      @nb_contrats_soumis = Contrat.count(:all, :conditions => [ "etat != 'init' AND contrats.id in (?)", @ids_viewables])
      @nb_contrats_notifies = Contrat.count(:all, :conditions => [ "(etat = 'notification' OR etat = 'cloture') AND contrats.id in (?)", @ids_viewables])

      @md_total = Soumission.sum(:md_total, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0

      @ma_total = Notification.sum(:ma_total, :conditions => [ "contrat_id in (?)", @ids_contrats]) || 0

      @niveau_1_types = ContratType.find(:all,:conditions=>"parent_id = '0'",:order=>"nom")
      @types = []
      for type in @niveau_1_types
        for child in type.children
          @types << [:nom => child.nom, :parent => type.nom ,:count => 0]
        end
      end
    else
      @ids_contrats = []
    end
  end


  private


  def setup_selection_period(date_start, date_end, date_param_name=nil)
    selection_period = SelectionPeriod.new

    date_param = params[date_param_name]
    if date_param
      %w[start end].each { |i|
        args = %w[1 2 3].map {|j| date_param["#{i}(#{j}i)"].to_i} # convert date params to int args
        selection_period.send("#{i}=", Date.new(*args))
      }
      session[date_param_name] = selection_period

    elsif session[date_param_name]
      selection_period = session[date_param_name]

    else
      selection_period.start = date_start
      selection_period.end   = date_end
    end

    selection_period
  end

  # Préparatoire des variables pour les actions show_result et export en csv
  def prepare_result(csv = false)

    prepare_selected_fields

    @ids_viewables = @ids_consultables+@ids_editables
    @ids_viewables = ['-1'] if @ids_viewables.size == 0

    # Récupération de la liste des ids des contrats consultables par l'utilisateur courrant
    ids = Contrat.my_find_all( @ids_viewables,
      acronyme_research = "",
      noContrat_reseach = "",
      equipe_research = "",
      laboratoire_research = "",
      departement_research = "",
      in_laboratoire = "",
      in_departement = "",
      in_tutelle = "" )

    @params = params


    # Gestion des paramètres de tris
    @sort_params = []
    array_order = []
    params[:sort].each_with_index {|item, index|


      case params[:sort][index]
        
      when 'laboratoires.nom'
        @include << :laboratoire
        column = params[:sort][index] 

      when "notifications.contrat_type.nom"
        if params['soumissions.contrat_type.nom']
          column = "contrat_types_notifications.nom"
        else
          column = "contrat_types.nom"
        end

      when "soumissions.contrat_type.nom"
        column = "contrat_types.nom"

      when "notifications.organisme_gestionnaire.nom"
        if params['soumissions.organisme_gestionnaire.nom']
          column = "organisme_gestionnaires_notifications.nom"
        else
          column = "organisme_gestionnaires.nom"
        end

      when "soumissions.organisme_gestionnaire.nom"
        column = "organisme_gestionnaires.nom"
      else
        column = params[:sort][index]
      end

      @sort_params << { :sort => params[:sort][index], :order => params[:order][index] }

      if @select_for_sort.to_s.include? params[:sort][index]
        array_order << { :sort => column, :order => params[:order][index]}
      end

    }
    if !array_order.empty?
      order = array_order.collect{|e| e[:sort] +" "+e[:order]}.join(', ')
    else
      order = "acronyme ASC"
    end

    #
    # Gestion des paramètres de filtre
    #

    # Préparation de @filter_params, variable utilisée par le formulaire de filtre
    @filter_params = []
    params[:filter_item].each_with_index {|item, index|
      if @select_for_filter.to_s.include? params[:filter_item][index]
        
        case params[:filter_item][index]
        
        when "notifications.a_justifier"          
          if params[:filter_value][index] == "oui"
            params[:filter_value][index] = "1"
          elsif params[:filter_value][index] == "non"
            params[:filter_value][index] = "0"
            
          end
          
        end
        
        @filter_params << { :filter_item => params[:filter_item][index],
          :filter_type => params[:filter_type][index],
          :filter_value => params[:filter_value][index]}
      end
    }
    if @filter_params.empty?
      @filter_params << { :filter_item => 'acronyme',
        :filter_type => 'contient',
        :filter_value => ''}
    end
  


    # Construction des filtres pour la requete sql
    filters = Filtr.new

    params[:filter_item].each_with_index {|item, index|
      if @select_for_filter.to_s.include? params[:filter_item][index]

        values = params[:filter_value][index].split('+')

        case params[:filter_item][index]
        
        when 'laboratoires.nom'
          @include << :laboratoire   
        
        when "soumissions.organisme_gestionnaire.nom"
          params[:filter_item][index] = "organisme_gestionnaires.nom"

        when "notifications.organisme_gestionnaire.nom"
          params[:filter_item][index] = "organisme_gestionnaires.nom"

        when "notifications.contrat_type.nom"
          if params['soumissions.contrat_type.nom']
            params[:filter_item][index] = "contrat_types_notifications.nom"
          else
            params[:filter_item][index] = "contrat_types.nom"
          end
        
        when "soumissions.contrat_type.nom"
          params[:filter_item][index] = "contrat_types.nom"

        when "notifications.mots_cles"
          if params['soumissions.mots_cles']
            params[:filter_item][index] = "key_words.intitule" # ?? à creuser ...
          else
            params[:filter_item][index] = "key_words.intitule"
          end

        when "soumissions.mots_cles"
          params[:filter_item][index] = "key_words.intitule"
        else

        end

        case params[:filter_item][index]
        when "contrats.associations"
          for value in values
            if value == values.first
              add1 = "AND (("
            else
              add1 = "OR ("
            end
            if value == values.last
              add2 = "))"
            else
              add2 = ")"
            end
            filters.send params[:filter_type][index], value, "projets.nom", add1
            filters.send params[:filter_type][index], value, "departements.nom", "OR"
            filters.send params[:filter_type][index], value, "laboratoires.nom", "OR", add2
          end
        else
          for value in values
            if value == values.first
              add1 = "AND (("
            else
              add1 = "OR ("
            end
            if value == values.last
              add2 = "))"
            else
              add2 = ")"
            end
            filters.not_equal "1", "1", add1
            filters.send params[:filter_type][index], value, params[:filter_item][index], "OR", add2
          end
        end
      end
    }

    per_page = 25

    filters.multiple ids, 'contrats.id'

    if params[:type] == 'soumission'
      filters.is_not_null 'soumissions.contrat_id'
    end

    if params[:type] == 'refu'
      filters.is_not_null 'soumissions.contrat_id'
      filters.is_not_null 'refus.contrat_id'
    end

    if params[:type] == 'signature'
      filters.is_not_null 'soumissions.contrat_id'
      filters.is_not_null 'signatures.contrat_id'
    end

    if params[:type] == 'notification'
      filters.is_not_null 'soumissions.contrat_id'
      filters.is_not_null 'signatures.contrat_id'
      filters.is_not_null 'notifications.contrat_id'
    end

    if params[:type] == 'cloture'
      filters.is_not_null 'soumissions.contrat_id'
      filters.is_not_null 'signatures.contrat_id'
      filters.is_not_null 'notifications.contrat_id'
      filters.is_not_null 'clotures.contrat_id'
    end

    @count_contrats = Contrat.count(:all, :include => @include, :conditions => filters.conditions)
    if csv
      @contrats = Contrat.find(:all, :include => @include, :conditions => filters.conditions,
        :order => order)
    else
      @contrats = Contrat.paginate(:include => @include, :conditions => filters.conditions,
        :order => order,
        :page => params[:page]||1,
        :per_page => per_page)
    end
  end

  def prepare_selected_fields
    @select = []
    @include = []

    #
    #  Contrats
    #
    @select << {:sort => true, :id => "contrats.acronyme", :intitule => "Contrat : Acronyme"}
    if params['contrats.associations']
      @select << {:sort => false, :id => "contrats.associations", :intitule => "Contrat : Associations"}
      @include << :projets
      @include << :departements
      @include << :laboratoires
    end
    @select << {:sort => true, :id => "contrats.etat", :intitule => "Contrat : Etat"} if params['contrats.etat']
    @select << {:sort => true, :id => "contrats.nom", :intitule => "Contrat : Nom"} if params['contrats.nom']
    @select << {:sort => true, :id => "contrats.num_contrat_etab", :intitule => "Contrat : N° contrat établissement"} if params['contrats.num_contrat_etab']
    if params['contrats.etablissement.nom']
      @select << {:sort => true, :id => "laboratoires.nom", :intitule => "Contrat : Etablissement à l'origine de la saisie"}
    end
    


    #
    #  Soumissions
    #
    if ['soumission', 'refu', 'signature', 'notification', 'cloture'].include? params[:type]
      @include << :soumission

      # Soumission - Informations générales
      if params['soumissions.contrat_type.nom']
        @select << {:sort => true, :id => "soumissions.contrat_type.nom", :intitule => "Soumission : Type de contrat"}
        @include << {:soumission => :contrat_type}
      end
      @select << {:sort => true, :id => "soumissions.date_depot", :intitule =>"Soumission : Date de dépot"} if params['soumissions.date_depot']
      @select << {:sort => true, :id => "soumissions.nombre_mois", :intitule =>"Soumission : Nombre de mois"} if params['soumissions.nombre_mois']
      if params['soumissions.organisme_gestionnaire.nom']
        @select << {:sort => true, :id => "soumissions.organisme_gestionnaire.nom", :intitule =>"Soumission : Etablissement gestionnaire"}
        @include << {:soumission => :organisme_gestionnaire}
      end
      @select << {:sort => true, :id => "soumissions.organisme_financeur", :intitule =>"Soumission : Organisme financeur"} if params['soumissions.organisme_financeur']

      # Soumission - Porteur et coordinateur
      @select << {:sort => true, :id => "soumissions.porteur", :intitule =>"Soumission : Porteur"} if params['soumissions.porteur']
      @select << {:sort => true, :id => "soumissions.etablissement_rattachement_porteur", :intitule =>"Soumission : Etablissement de rattachement du porteur"} if params['soumissions.etablissement_rattachement_porteur']
      @select << {:sort => true, :id => "soumissions.est_porteur", :intitule =>"Soumission : Le porteur est coordinateur ?"} if params['soumissions.est_porteur']
      @select << {:sort => true, :id => "soumissions.coordinateur", :intitule =>"Soumission : Coordinateur"} if params['soumissions.coordinateur']
      @select << {:sort => true, :id => "soumissions.etablissement_gestionnaire_du_coordinateur", :intitule =>"Soumission : Etablissement gestionnaire du coordinateur"} if params['soumissions.etablissement_gestionnaire_du_coordinateur']

      # Soumission - Mots clés
      if params['soumissions.mots_cles']
        @select << {:sort => false, :id => "soumissions.mots_cles", :intitule =>"Soumission : Mots clés"}
        @include << {:soumission => :key_words}
      end
      @select << {:sort => false, :id => "soumissions.mots_cles_libres", :intitule =>"Soumission : Mots Clés libres"} if params['soumissions.mots_cles_libres']
      @select << {:sort => false, :id => "soumissions.thematiques", :intitule =>"Soumission : Thématiques"} if params['soumissions.thematiques']
      @select << {:sort => false, :id => "soumissions.poles_competivites", :intitule =>"Soumission : Pôles de compétivités"} if params['soumissions.poles_competivites']

      # Soumission - Partenaires
      sfp = 0
      (@select << {:sort => false, :id => "soumission_france_partenaires.nom", :intitule =>"Soumission : Nom - Partenaire en France "}; sfp = 1) if params['soumission_france_partenaires.nom']
      (@select << {:sort => false, :id => "soumission_france_partenaires.laboratoire", :intitule =>"Soumission : Laboratoire - Partenaire en France"}; sfp = 1) if params['soumission_france_partenaires.laboratoire']
      (@select << {:sort => false, :id => "soumission_france_partenaires.etablissement_gestionnaire", :intitule =>"Soumission : Etablissement gestionnaire - Partenaire en France"}; sfp = 1) if params['soumission_france_partenaires.etablissement_gestionnaire']
      (@select << {:sort => false, :id => "soumission_france_partenaires.ville", :intitule =>"Soumission : Ville - Partenaire en France"}; sfp = 1) if params['soumission_france_partenaires.ville']

      @include << {:soumission => :soumission_france_partenaires} if sfp == 1

      sep = 0
      (@select << {:sort => false, :id => "soumission_europe_partenaires.nom", :intitule =>"Soumission : Nom - Partenaire en Europe"}; sep = 1) if params['soumission_europe_partenaires.nom']
      (@select << {:sort => false, :id => "soumission_europe_partenaires.etablissement_gestionnaire", :intitule =>"Soumission : Etablissement gestionnaire - Partenaire en Europe"}; sep = 1) if params['soumission_europe_partenaires.etablissement_gestionnaire']
      (@select << {:sort => false, :id => "soumission_europe_partenaires.ville", :intitule =>"Soumission : Ville - Partenaire en Europe"}; sep = 1) if params['soumission_europe_partenaires.ville']
      (@select << {:sort => false, :id => "soumission_europe_partenaires.pays", :intitule =>"Soumission : Pays - Partenaire en Europe"}; sep = 1) if params['soumission_europe_partenaires.pays']

      @include << {:soumission => :soumission_europe_partenaires} if sep == 1

      sp = 0
      (@select << {:sort => false, :id => "soumission_partenaires.nom", :intitule =>"Soumission : Nom - Partenaire hors Europe"}; sp = 1) if params['soumission_partenaires.nom']
      (@select << {:sort => false, :id => "soumission_partenaires.etablissement_gestionnaire", :intitule =>"Soumission : Etablissement gestionnaire- Partenaire hors Europe"}; sp = 1) if params['soumission_partenaires.etablissement_gestionnaire']
      (@select << {:sort => false, :id => "soumission_partenaires.ville", :intitule =>"Soumission : Ville - Partenaire hors Europe"}; sp = 1) if params['soumission_partenaires.ville']
      (@select << {:sort => false, :id => "soumission_partenaires.pays", :intitule =>"Soumission : Pays - Partenaire hors Europe"}; sp = 1) if params['soumission_partenaires.pays']

      @include << {:soumission => :soumission_partenaires} if sp == 1

      # Soumission - Moyens demandés
      @select << {:sort => true, :id => "soumissions.md_type_montant", :intitule =>"Soumission : HT/TTC - Moyens demandés"} if params['soumissions.md_type_montant']
      @select << {:sort => true, :id => "soumissions.md_fonctionnement", :intitule =>"Soumission : Fonctionnement - Moyens demandés"} if params['soumissions.md_fonctionnement']
      @select << {:sort => true, :id => "soumissions.md_equipement", :intitule =>"Soumission : Equipement - Moyens demandés"} if params['soumissions.md_equipement']
      @select << {:sort => true, :id => "soumissions.md_salaire", :intitule =>"Soumission : Salaire - Moyens demandés"} if params['soumissions.md_salaire']
      @select << {:sort => true, :id => "soumissions.md_mission", :intitule =>"Soumission : Mission - Moyens demandés"} if params['soumissions.md_mission']
      @select << {:sort => true, :id => "soumissions.md_non_ventile", :intitule =>"Soumission : Non ventilé - Moyens demandés"} if params['soumissions.md_non_ventile']
      @select << {:sort => true, :id => "soumissions.md_couts_indirects", :intitule =>"Soumission : Coûts indirects - Moyens demandés"} if params['soumissions.md_couts_indirects']
      @select << {:sort => true, :id => "soumissions.md_allocation", :intitule =>"Soumission : Allocation - Moyens demandés"} if params['soumissions.md_allocation']
      @select << {:sort => true, :id => "soumissions.md_total", :intitule =>"Soumission : Total - Moyens demandés"} if params['soumissions.md_total']
      @select << {:sort => true, :id => "soumissions.taux_subvention", :intitule =>"Soumission : Taux de subvention - Moyens demandés"} if params['soumissions.taux_subvention']
      @select << {:sort => true, :id => "soumissions.total_subvention", :intitule =>"Soumission : Total subvention - Moyens demandés"} if params['soumissions.total_subvention']

      # Soumission - Personnel demandé
      @select << {:sort => true, :id => "soumissions.pd_doctorant", :intitule =>"Soumission : Doctorant - Personnel demandé"} if params['soumissions.pd_doctorant']
      @select << {:sort => true, :id => "soumissions.pd_post_doc", :intitule =>"Soumission : Post-doc - Personnel demandé"} if params['soumissions.pd_post_doc']
      @select << {:sort => true, :id => "soumissions.pd_ingenieur", :intitule =>"Soumission : Ingénieur - Personnel demandé"} if params['soumissions.pd_ingenieur']
      @select << {:sort => true, :id => "soumissions.pd_autre", :intitule =>"Soumission : Autre - Personnel demandé"} if params['soumissions.pd_autre']
      @select << {:sort => true, :id => "soumissions.pd_equivalent_temps_plein", :intitule =>"Soumission : Equivalent temps plein - Personnel demandé"} if params['soumissions.pd_equivalent_temps_plein']

      # Soumission - Personnel impliqué
      sp = 0
      (@select << {:sort => false, :id => "soumission_personnels.nom", :intitule =>"Soumission : Nom - Personnel impliqué"}; sp = 1) if params['soumission_personnels.nom']
      (@select << {:sort => false, :id => "soumission_personnels.prenom", :intitule =>"Soumission : Prénom - Personnel impliqué"}; sp = 1) if params['soumission_personnels.prenom']
      (@select << {:sort => false, :id => "soumission_personnels.statut", :intitule =>"Soumission : Statut - Personnel impliqué"}; sp = 1) if params['soumission_personnels.statut']
      (@select << {:sort => false, :id => "soumission_personnels.tutelle", :intitule =>"Soumission : Tutelle - Personnel impliqué"}; sp = 1) if params['soumission_personnels.tutelle']
      (@select << {:sort => false, :id => "soumission_personnels.pourcentage", :intitule =>"Soumission : Pourcentage - Personnel impliqué"}; sp = 1) if params['soumission_personnels.pourcentage']
      @include << {:soumission => :soumission_personnels} if sp == 1
    end

    #
    #  Refus
    #
    if ['refu'].include? params[:type]
      @include << :refu
      @select << {:sort => true, :id => "refus.date", :intitule =>"Refus : Date"} if params['refus.date']
      @select << {:sort => true, :id => "refus.liste_attente", :intitule =>"Refus : Est sur une liste d'attente ?"} if params['refus.liste_attente']
      @select << {:sort => true, :id => "refus.labelise", :intitule =>"Refus : Est labéllisé ?"} if params['refus.labelise']
      @select << {:sort => true, :id => "refus.commentaire", :intitule =>"Refus : Commentaires"} if params['refus.commentaire']
    end

    #
    #  Signatures
    #
    if ['signature', 'notification', 'cloture'].include? params[:type]
      @include << :signature
      @select << {:sort => true, :id => "signatures.date", :intitule =>"Signature : Date de signature"} if params['signatures.date']
      @select << {:sort => true, :id => "signatures.commentaire", :intitule =>"Signature : Commentaires"} if params['signatures.commentaire']
    end

    #
    #  Notifications
    #
    if ['notification', 'cloture'].include? params[:type]
      @include << :notification
      # Notification - Informations générales
      if params['notifications.contrat_type.nom']
        @select << {:sort => true, :id => "notifications.contrat_type.nom", :intitule =>"Notification : Type de contrat"}
        @include << {:notification => :contrat_type}
      end
      @select << {:sort => true, :id => "notifications.date_notification", :intitule =>"Notification : Date de notification"} if params['notifications.date_notification']
      @select << {:sort => true, :id => "notifications.date_debut", :intitule =>"Notification : Date de début"} if params['notifications.date_debut']
      @select << {:sort => true, :id => "notifications.date_fin", :intitule =>"Notification : Date de fin"} if params['notifications.date_fin']
      @select << {:sort => true, :id => "notifications.nombre_mois", :intitule =>"Notification : Nombre de mois"} if params['notifications.nombre_mois']
      if params['notifications.organisme_gestionnaire.nom']
        @select << {:sort => true, :id => "notifications.organisme_gestionnaire.nom", :intitule =>"Notification : Etablissement gestionnaire"}
        @include << {:notification => :organisme_gestionnaire}
      end
      @select << {:sort => true, :id => "notifications.organisme_financeur", :intitule =>"Notification : Organisme financeur"} if params['notifications.organisme_financeur']
      @select << {:sort => true, :id => "notifications.organisme_payeur", :intitule =>"Notification : Organisme payeur"} if params['notifications.organisme_payeur']
      @select << {:sort => true, :id => "notifications.numero_ligne_budgetaire", :intitule =>"Notification : N° ligne budgétaire"} if params['notifications.numero_ligne_budgetaire']
      @select << {:sort => true, :id => "notifications.numero_contrat", :intitule =>"Notification : N° de contrat"} if params['notifications.numero_contrat']
      @select << {:sort => true, :id => "notifications.a_justifier", :intitule =>"Notification : Contrat à justifier ?"} if params['notifications.a_justifier']
      @select << {:sort => true, :id => "notifications.url", :intitule =>"Notification : Site web (url)"} if params['notifications.url']

      # Notification - Porteur et coordinateur
      @select << {:sort => true, :id => "notifications.porteur", :intitule =>"Notification : Porteur"} if params['notifications.porteur']
      @select << {:sort => true, :id => "notifications.etablissement_rattachement_porteur", :intitule =>"Notification : Etablissement de rattachement du porteur"} if params['notifications.etablissement_rattachement_porteur']
      @select << {:sort => true, :id => "notifications.est_porteur", :intitule =>"Notification : Porteur est coordinateur ?"} if params['notifications.est_porteur']
      @select << {:sort => true, :id => "notifications.coordinateur", :intitule =>"Notification : Coordinateur"} if params['notifications.coordinateur']
      @select << {:sort => true, :id => "notifications.etablissement_gestionnaire_du_coordinateur", :intitule =>"Notification : Etablissement gestionnaire du coordinateur"} if params['notifications.etablissement_gestionnaire_du_coordinateur']

      # Notification - Mots clés
      if params['notifications.mots_cles']
        @select << {:sort => false, :id => "notifications.mots_cles", :intitule =>"Notification : Mots clés"}
        @include << {:notification => :key_words}
      end
      @select << {:sort => false, :id => "notifications.mots_cles_libres", :intitule =>"Notification : Mots Clés libres"} if params['notifications.mots_cles_libres']
      @select << {:sort => false, :id => "notifications.thematiques", :intitule =>"Notification : Thématiques"} if params['notifications.thematiques']
      @select << {:sort => false, :id => "notifications.poles_competivites", :intitule =>"Notification : Pôles de compétivités"} if params['notifications.poles']

      # Notification - Partenaires
      nfp = 0
      (@select << {:sort => false, :id => "notification_france_partenaires.nom", :intitule =>"Notification : Nom - Partenaire en France"}; nfp = 1) if params['notification_france_partenaires.nom']
      (@select << {:sort => false, :id => "notification_france_partenaires.laboratoire", :intitule =>"Notification : Laboratoire - Partenaire en France"}; nfp = 1) if params['notification_france_partenaires.laboratoire']
      (@select << {:sort => false, :id => "notification_france_partenaires.etablissement_gestionnaire", :intitule =>"Notification : Etablissement gestionnaire - Partenaire en France"}; nfp = 1) if params['notification_france_partenaires.etablissement_gestionnaire']
      (@select << {:sort => false, :id => "notification_france_partenaires.ville", :intitule =>"Notification : Ville - Partenaire en France"}; nfp = 1) if params['notification_france_partenaires.ville']
      @include << {:notification => :notification_france_partenaires} if nfp == 1

      nep = 0
      (@select << {:sort => false, :id => "notification_europe_partenaires.nom", :intitule =>"Notification : Nom - Partenaire en Europe"}; nep = 1) if params['notification_europe_partenaires.nom']
      (@select << {:sort => false, :id => "notification_europe_partenaires.etablissement_gestionnaire", :intitule =>"Notification : Etablissement gestionnaire - Partenaire en Europe"}; nep = 1) if params['notification_europe_partenaires.etablissement_gestionnaire']
      (@select << {:sort => false, :id => "notification_europe_partenaires.ville", :intitule =>"Notification : Ville - Partenaire en Europe"}; nep = 1) if params['notification_europe_partenaires.ville']
      (@select << {:sort => false, :id => "notification_europe_partenaires.pays", :intitule =>"Notification : Pays - Partenaire en Europe"}; nep = 1) if params['notification_europe_partenaires.pays']
      @include << {:notification => :notification_europe_partenaires} if nep == 1

      np = 0
      (@select << {:sort => false, :id => "notification_partenaires.nom", :intitule =>"Notification : Nom - Partenaire hors Europe"}; np = 1) if params['notification_partenaires.nom']
      (@select << {:sort => false, :id => "notification_partenaires.etablissement_gestionnaire", :intitule =>"Notification : Etablissement gestionnaire - Partenaire hors Europe"}; np = 1) if params['notification_partenaires.etablissement_gestionnaire']
      (@select << {:sort => false, :id => "notification_partenaires.ville", :intitule =>"Notification : Ville - Partenaire hors Europe"}; np = 1) if params['notification_partenaires.ville']
      (@select << {:sort => false, :id => "notification_partenaires.pays", :intitule =>"Notification : Pays - Partenaire hors Europe"}; np = 1) if params['notification_partenaires.pays']
      @include << {:notification => :notification_partenaires} if np == 1

      # Notification - Moyens Accordés
      @select << {:sort => true, :id => "notifications.ma_type_montant", :intitule =>"Notification : HT/TTC - Moyens accordés"} if params['notifications.ma_type_montant']
      @select << {:sort => true, :id => "notifications.ma_fonctionnement", :intitule =>"Notification : Fonctionnement - Moyens accordés"} if params['notifications.ma_fonctionnement']
      @select << {:sort => true, :id => "notifications.ma_equipement", :intitule =>"Notification : Equipement - Moyens accordés"} if params['notifications.ma_equipement']
      @select << {:sort => true, :id => "notifications.ma_salaire", :intitule =>"Notification : Salaire - Moyens accordés"} if params['notifications.ma_salaire']
      @select << {:sort => true, :id => "notifications.ma_mission", :intitule =>"Notification : Mission - Moyens accordés"} if params['notifications.ma_mission']
      @select << {:sort => true, :id => "notifications.ma_non_ventile", :intitule =>"Notification : Non ventilé - Moyens accordés"} if params['notifications.ma_non_ventile']
      @select << {:sort => true, :id => "notifications.ma_couts_indirects", :intitule =>"Notification : Coûts indirects - Moyens accordés"} if params['notifications.ma_couts_indirects']
      @select << {:sort => true, :id => "notifications.ma_frais_gestion_mutualises_local", :intitule =>"Notification : Frais de gestion mutualisés locaux ou non justifiés - Moyens accordés"} if params['notifications.ma_frais_gestion_mutualises_local']
      @select << {:sort => true, :id => "notifications.ma_frais_gestion_mutualises", :intitule =>"Notification : Frais de gestion mutualisés nationaux - Moyens accordés"} if params['notifications.ma_frais_gestion_mutualises']
      @select << {:sort => true, :id => "notifications.ma_allocation", :intitule =>"Notification : Allocation - Moyens accordés"} if params['notifications.ma_allocation']
      @select << {:sort => true, :id => "notifications.ma_total", :intitule =>"Notification : Total - Moyens accordés"} if params['notifications.ma_total']

      # Notification - Personnel accordé
      @select << {:sort => true, :id => "notifications.pa_doctorant", :intitule =>"Notification : Doctorant - Personnel accordés"} if params['notifications.pa_doctorant']
      @select << {:sort => true, :id => "notifications.pa_post_doc", :intitule =>"Notification : Post-doc - Personnel accordés"} if params['notifications.pa_post_doc']
      @select << {:sort => true, :id => "notifications.pa_ingenieur", :intitule =>"Notification : Ingénieur - Personnel accordés"} if params['notifications.pa_ingenieur']
      @select << {:sort => true, :id => "notifications.pa_autre", :intitule =>"Notification : Autre - Personnel accordés"} if params['notifications.pa_autre']
      @select << {:sort => true, :id => "notifications.pa_equivalent_temps_plein", :intitule =>"Notification : Equivalent temps plein - Personnel accordés"} if params['notifications.pa_equivalent_temps_plein']

      # Notification - Personnel impliqué
      np = 0
      (@select << {:sort => false, :id => "notification_personnels.nom", :intitule =>"Notification : Nom - Personnel impliqué"}; np = 1) if params['notification_personnels.nom']
      (@select << {:sort => false, :id => "notification_personnels.prenom", :intitule =>"Notification : Prénom - Personnel impliqué"}; np = 1) if params['notification_personnels.prenom']
      (@select << {:sort => false, :id => "notification_personnels.statut", :intitule =>"Notification : Statut - Personnel impliqué"}; np = 1) if params['notification_personnels.statut']
      (@select << {:sort => false, :id => "notification_personnels.tutelle", :intitule =>"Notification : Tutelle - Personnel impliqué"}; np = 1) if params['notification_personnels.tutelle']
      (@select << {:sort => false, :id => "notification_personnels.pourcentage", :intitule =>"Notification : Pourcentage - Personnel impliqué"}; np = 1) if params['notification_personnels.pourcentage']
      @include << {:notification => :notification_personnels} if np == 1
    end

    #
    #  Cloture
    #
    if ['cloture'].include? params[:type]
      @include << :cloture
      @select << {:sort => true, :id => "clotures.date_fin_depenses", :intitule =>"Cloture : Date de fin des dépenses"} if params['clotures.date_fin_depenses']
      @select << {:sort => true, :id => "clotures.commentaires", :intitule =>"Cloture : Commentaires"} if params['clotures.commentaires']
    end

    @select_for_sort = @select.reject{|s| s if s[:sort]==false}
    @select_for_filter = @select
  end


  # Formatage des booleen pour l'export en csv
  def boolean_to_csv(value)
    if value
      return "oui"
    else
      return "non"
    end
  end

  # Formatage des types de contrats pour l'export en csv
  def contrat_type_to_csv(element)
    ret = ""
    if !element.parent.nil?
      ret += contrat_type_to_csv(element.parent)+" > "
      ret += element.nom
    else
      ret += element.nom
    end
    ret
  end

  # Formatage des dates pour l'export csv
  def date_to_csv(value)
    return value.strftime("%d/%m/%Y")
  end
end
