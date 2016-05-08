#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class AllLignesController < ApplicationController
  layout "layouts/application_suivi_budgetaire"
  before_filter :set_contrats_editables, :set_contrats_consultables, :set_lignes_editables, :set_lignes_consultables
  before_filter :set_mes_equipes, :only =>[:extraction,:bilans]
  # GET /extraction/
  # Visualisation et extraction au format csv :
  # - des crédits
  # - des dépenses en fonctionnement
  # - des dépenses en equipement
  # - des dépenses en mission
  # - des dépenses en salaire
  # - des dépenses non ventilée
  # de l'ensemble des lignes visualisables par l'utilisateur courant
  # Pagination, possibilité de tris, sélection et sélections avancées
  def extraction
    setup_all_lignes_filter
    setup_type_montant(true)
    mes_projets_nom_query = ["SELECT p.nom from projets p where p.id in (?) ORDER BY p.nom",@ids_mes_equipes]
    mes_projets_nom = Projet.find_by_sql(mes_projets_nom_query).collect{|d| d.nom}
    @tool_tip_mes_equipes =""
    for nom in mes_projets_nom do
      @tool_tip_mes_equipes += nom+" \\n"
    end
    
    @index=true
    
    @per_page = 15
    @type_depense = "depenses_all"
    @order_type = "desc"

    case params['data']
    when nil                    # Demande d'affichage des crédits
      @type_depense = "all"
      @order_value = "date_effet" 
    when 'commun', 'fonctionnement', 'equipement', 'non_ventilee', 'mission','toutes_depenses_hors_salaires'
      @order_value = "date_commande" 
    when 'salaire'
      @order_value = "date_debut"
    else
      throw 'Unknown depense type'
    end

  end

  def compute_totaux
    @compute_totaux_globaux = true
    prepare_result
    @total_montant_engages = 0
    @total_montant_paye_ht = 0
    @total_montant_paye_ttc = 0
    @total_montant_paye_htr = 0
    @total_cout_periode = 0
    
    case params['data']
    when 'commun'
      if @ref_cp.blank?
        @colspan_totals = 9
        @total_montant_engages = @depenses.inject(0) { |s,d| s += d.montant_engage }  
        @total_montant_paye_ht = @depenses.inject(0) { |s,d| s += d.montant_paye('ht') }
        @total_montant_paye_ttc = @depenses.inject(0) { |s,d| s += d.montant_paye('ttc') }
      else
        @colspan_totals = 10
        @total_montant_engages = @depenses.inject(0) { |s,d| s += d.depense_commun.montant_engage }  
        @total_montant_paye_ht = @depenses.inject(0) { |s,d| s += (d.cout_ht) }
        @total_montant_paye_ttc = @depenses.inject(0) { |s,d| s += (d.cout_ttc) }       
      end

    when 'salaire'
      @colspan_totals = 10
      @total_cout_periode = @depenses.inject(0) { |s,d| s += d.cout_periode }  
      @total_montant_paye_htr = @depenses.inject(0) { |s,d| s += d.montant_paye('htr') }   
      @total_montant_paye_ttc = @depenses.inject(0) { |s,d| s += d.montant_paye('ht') }

    when 'fonctionnement', 'equipement', 'non_ventilee', 'mission', 'toutes_depenses_hors_salaires'
      # Ajustement du nb total de colonnes avant les colonnes de montant
      if params['data']=='toutes_depenses_hors_salaires'
        @ref_cp.blank? ? @colspan_totals = 9 : @colspan_totals = 14
      elsif params['data']=='mission'
        @ref_cp.blank? ? @colspan_totals = 11 : @colspan_totals = 14
      else
        @ref_cp.blank? ? @colspan_totals = 8 : @colspan_totals = 10
      end

      if @ref_cp.blank?
        @total_montant_engages = @depenses.inject(0) { |s,d| s += d.montant_engage }  
        @total_montant_paye_htr = @depenses.inject(0) { |s,d| s += d.montant_paye('htr') }
        @total_montant_paye_ht = @depenses.inject(0) { |s,d| s += d.montant_paye('ht') }
        @total_montant_paye_ttc = @depenses.inject(0) { |s,d| s += d.montant_paye('ttc') }
      else
        case params['data']
        when 'fonctionnement'
          for depense in @depenses
            
          end
          @total_montant_engages = @depenses.inject(0) { |s,d| s += d.depense_fonctionnement.montant_engage }
        when 'equipement'
          @total_montant_engages = @depenses.inject(0) { |s,d| s += d.depense_equipement.montant_engage }
        when 'non_ventilee'
          @total_montant_engages = @depenses.inject(0) { |s,d| s += d.depense_non_ventilee.montant_engage }
        when 'mission'
          @total_montant_engages = @depenses.inject(0) { |s,d| s += d.depense_mission.montant_engage }
        when 'toutes_depenses_hors_salaires'
          for fc in @depenses
            if fc.is_a?(DepenseFonctionnementFacture)
              depense = fc.depense_fonctionnement
            elsif fc.is_a?(DepenseEquipementFacture)
              depense = fc.depense_equipement
            elsif fc.is_a?(DepenseNonVentileeFacture)              
              depense = fc.depense_non_ventilee
            elsif fc.is_a?(DepenseMissionFacture)
              depense = fc.depense_mission
            end
            @total_montant_engages +=  depense.montant_engage
            @total_montant_paye_htr += fc.montant_htr || 0
            @total_montant_paye_ht += fc.cout_ht || 0
            @total_montant_paye_ttc +=  fc.cout_ttc  || 0
          end       
        end
        if params['data']!='toutes_depenses_hors_salaires'
          @total_montant_paye_htr = @depenses.inject(0) { |s,d| s += (d.montant_htr || 0) }
          @total_montant_paye_ht = @depenses.inject(0) { |s,d| s += (d.cout_ht || 0) }
          @total_montant_paye_ttc = @depenses.inject(0) { |s,d| s += (d.cout_ttc || 0) }
        end
      end
    else
      throw 'Unknown depense type'
    end
    
    render :partial => 'list_totaux_globaux'  
  end
  
  
  # GET /list/
  # Mise à jour AJAX ou non de la liste de crédits ou dépenses demandées
  def list
    # Préparation des variables nécessaire à l'affichage
    prepare_result

    # Mise à jour de <div id="list"></div> en ajax
    # Direction vers le bon partiel en fonction du type de données demandées
    partial_prefix = params['ref_cp'].blank? ? 'list_depenses_' : 'list_factures_'
    # ATTENTION: lorsque 'ref_cp' est renseigné, on traite et affiche des *factures*
    case params['data']
    when blank? || ''
      partial_name = 'list_credits'
    when 'commun'
      partial_name = "#{partial_prefix}communs"
    when 'fonctionnement', 'equipement', 'non_ventilee'
      partial_name = "#{partial_prefix}default"
    when 'mission'
      partial_name = "#{partial_prefix}missions"
    when 'salaire'
      partial_name = "#{partial_prefix}salaires"
      throw 'no factures for depense_salaires' if !params['ref_cp'].blank?
    when 'toutes_depenses_hors_salaires'
      partial_prefix.sub!(/^list_/,'list_toutes_')
      partial_name = "#{partial_prefix}hors_salaires"
    else
      throw 'Unknown depense type'
    end

    render :partial => partial_name
  end


  # GET /export_csv/
  # Export csv
  def export_csv
    # Preparation des variables nécessaires aux vues csv
    prepare_result(true)
    #initialisation pour la conversion en UTF16 pour Excel (ms-office)
    if params[:encode] == 'utf16'
      codingTranslation = Iconv.new('WINDOWS-1252','UTF-8')
    else
      codingTranslation = Iconv.new('UTF-8','UTF-8')
    end
    options = {:row_sep => "\r\n", :col_sep => ";"}
    # Demande d'affichage des crédits
    if params['data'].blank?
      csv_string = CSV.generate(options) do |csv|
        # Entête du csv
        ligne = ["Ligne","Verrou", "Date d'effet","Compte budgétaire","Code analytique", "Référence", "Origine", "Ventilation", "Commentaire", "Montant", "url"]
 
        #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne
        # Corp du csv
        @credits.each do |c|
          ligne = []
          ligne << codingTranslation.iconv(c.ligne.nom)
          ligne << c.verrou
          ligne << date_to_csv(c.date_effet)
          ligne << codingTranslation.iconv(c.compte_budgetaire)
          ligne << codingTranslation.iconv(c.code_analytique)
          ligne << codingTranslation.iconv(c.reference)
          ligne << codingTranslation.iconv(c.origine)
          ligne << codingTranslation.iconv(c.ventilation)
          ligne << codingTranslation.iconv(c.commentaire)
          ligne << c.montant
          ligne << ligne_versement_url(c.ligne, c)
          csv << ligne
        end
      end
    end

    # Demande d'affichage des dépenses hors salaires
    if params['data'] == 'toutes_depenses_hors_salaires'
      csv_string = CSV.generate(options) do |csv|
        ligne = ["Ligne", "Commande soldée ?","Verrou", "Date de demande d'achat", "Compte budgétaire", "Code analytique", "N° de mission ou de commande",
          "Intitulé", "Fournisseur", "Agent", "Montant Engagé","Montant Payé HTR","Montant Payé HT", "Montant Payé TTC", "url"]
        if !@ref_cp.blank?
          ligne.insert(10, "Date Fac.", "N° Fac.", "Date Mand.", "N° Mand.", "Rub.CP.") 
        elsif @show_factures == "yes"
          ligne.insert(15, "N° de facture", "Date de facture", "Millesime de facture" ,"Date de  Mand.", "N° Mand.","Fournisseur (mission)", "Justifiable", "Rub.CP.", "Taux TVA", "Payé HTR", "Payé HT", "Payé TTC")
        end 
        #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne
        @depenses.each do |c|
          if @ref_cp.blank?
            ligne = []
            ligne << codingTranslation.iconv(c.ligne.nom)
            ligne << boolean_to_csv(c.commande_solde)
            ligne << c.verrou
            ligne << date_to_csv(c.date_commande)
            ligne << codingTranslation.iconv(c.compte_budgetaire)
            ligne << codingTranslation.iconv(c.code_analytique)
            ligne << codingTranslation.iconv(c.reference)
            ligne << codingTranslation.iconv(c.intitule)
            if c.is_a?(DepenseFonctionnement) || c.is_a?(DepenseEquipement) || c.is_a?(DepenseNonVentilee)
              ligne << codingTranslation.iconv(c.fournisseur)
            else 
              ligne << ''
            end
            if c.is_a?(DepenseMission)
              ligne << codingTranslation.iconv(c.agent)
            else
              ligne << ''
            end
     
            ligne << c.montant_engage
            ligne << c.montant_paye('htr')
            ligne << c.montant_paye('ht')
            ligne << c.montant_paye('ttc')
            if c.is_a?(DepenseFonctionnement)
              ligne << ligne_depense_fonctionnement_url(c.ligne, c)
              factures = c.depense_fonctionnement_factures
            elsif c.is_a?(DepenseEquipement)
              ligne << ligne_depense_equipement_url(c.ligne, c)
              factures = c.depense_equipement_factures
            elsif c.is_a?(DepenseNonVentilee)
              ligne << ligne_depense_non_ventilee_url(c.ligne, c)
              factures = c.depense_non_ventilee_factures
            elsif c.is_a?(DepenseMission)
              ligne << ligne_depense_mission_url(c.ligne, c)
              factures = c.depense_mission_factures
            end
            csv << ligne
            if @show_factures == 'yes'
              for facture in factures do
                ligne = ["FACTURE ->","",facture.verrou,"","","","","","","","","","","",""]
                ligne << facture.numero_facture
                ligne << date_to_csv(facture.date)
                ligne << (facture.millesime.blank? ? "" : date_to_csv(facture.millesime) )
                ligne << (facture.date_mandatement.blank? ? "" : date_to_csv(facture.date_mandatement) )
                ligne << facture.numero_mandat
                if c.is_a?(DepenseMission)
                  ligne << facture.fournisseur
                else
                  ligne << ""
                end
                ligne << (facture.justifiable.blank? ? "" : facture.justifiable)
                ligne << facture.rubrique_comptable.small_intitule
                ligne << facture.taux_tva
                ligne << facture.montant_htr
                ligne << facture.cout_ht
                ligne << facture.cout_ttc
                csv << ligne
              end
            end
            # si une référence comptable a été sélectionnée, alors on affiche une ligne par facture
            # et non pas une ligne par depense
          else
            if c.is_a?(DepenseFonctionnementFacture)
              depense = c.depense_fonctionnement
            elsif c.is_a?(DepenseEquipementFacture)
              depense = c.depense_equipement
            elsif c.is_a?(DepenseNonVentileeFacture)
              depense = c.depense_non_ventilee
            elsif c.is_a?(DepenseMissionFacture)
              depense = c.depense_mission
            end
            ligne = []
            ligne << codingTranslation.iconv(depense.ligne.nom)
            ligne << boolean_to_csv(depense.commande_solde)
            ligne << depense.verrou
            ligne << date_to_csv(depense.date_commande)
            ligne << codingTranslation.iconv(depense.compte_budgetaire)
            ligne << codingTranslation.iconv(depense.code_analytique)
            ligne << codingTranslation.iconv(depense.reference)
            ligne << codingTranslation.iconv(depense.intitule)
            if depense.is_a?(DepenseFonctionnement) || depense.is_a?(DepenseEquipement) || depense.is_a?(DepenseNonVentilee)
              ligne << codingTranslation.iconv(depense.fournisseur)
            elsif depense.is_a?(DepenseMission)
              ligne << codingTranslation.iconv(c.fournisseur)
            else 
              ligne << ''
            end
            if depense.is_a?(DepenseMission)
              ligne << codingTranslation.iconv(depense.agent)
            else
              ligne << ''
            end
            ligne << date_to_csv(c.date)
            ligne << codingTranslation.iconv(c.numero_facture)
            ligne << (c.date_mandatement.blank? ? c.date_mandatement : date_to_csv(c.date_mandatement))
            ligne << codingTranslation.iconv(c.numero_mandat)
            ligne << codingTranslation.iconv(c.rubrique_comptable.numero_rubrique)
            ligne << depense.montant_engage
            ligne << c.montant_htr
            ligne << c.cout_ht
            ligne << c.cout_ttc
            if c.is_a?(DepenseFonctionnementFacture)
              ligne << ligne_depense_fonctionnement_url(depense.ligne, c)
            elsif c.is_a?(DepenseEquipementFacture)
              ligne << ligne_depense_equipement_url(depense.ligne, c)
            elsif c.is_a?(DepenseNonVentileeFacture)
              ligne << ligne_depense_non_ventilee_url(depense.ligne, c)
            elsif c.is_a?(DepenseMissionFacture)
              ligne << ligne_depense_mission_url(depense.ligne, c)
            end
            csv << ligne
          end
        end
      end
    end

    # Demande d'affichage des dépenses en fonctionnement ou en équipement ou non ventilées
    if ['fonctionnement', 'equipement', 'non_ventilee'].include? params['data']
      csv_string = CSV.generate(options) do |csv|
        ligne = ["Ligne", "Commande soldée ?","Verrou", "Date de demande d'achat","Compte budgétaire", "Code analytique", "N° de demande d'achat",
          "Intitulé", "Fournisseur", "Montant Engagé", "Montant Payé HTR","Montant Payé HT", "Montant Payé TTC", "url"]
        if !@ref_cp.blank?
          ligne.insert(9, "Date Fac.", "N° Fac.", "Date Mand.", "N° Mand.", "Rub.CP.")
        elsif @show_factures == "yes"
          ligne.insert(14, "N° de facture", "Date de facture", "Millesime de facture" ,"Date de  Mand.", "N° Mand.", "Justifiable", "Rub.CP.", "Taux TVA", "Payé HTR", "Payé HT", "Payé TTC")
        end 
        #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne
        depense_method = "depense_#{params['data']}"
        depense_method_sym = depense_method.to_sym
        @depenses.each do |c|
          if @ref_cp.blank?
            ligne = []
            ligne << codingTranslation.iconv(c.ligne.nom)
            ligne << boolean_to_csv(c.commande_solde)
            ligne << c.verrou
            ligne << date_to_csv(c.date_commande)
            ligne << codingTranslation.iconv(c.compte_budgetaire)
            ligne << codingTranslation.iconv(c.code_analytique)
            ligne << codingTranslation.iconv(c.reference)
            ligne << codingTranslation.iconv(c.intitule)
            ligne << codingTranslation.iconv(c.fournisseur)
            ligne << c.montant_engage
            ligne << c.montant_paye('htr')
            ligne << c.montant_paye('ht')
            ligne << c.montant_paye('ttc')
            ligne << send("ligne_#{depense_method}_url".to_sym, c.ligne, c)
            csv << ligne
            if @show_factures == 'yes'
              for facture in c.send(depense_method+"_factures") do
                ligne = ["FACTURE ->","",facture.verrou,"","","","","","","","","","",""]
                ligne << facture.numero_facture
                ligne << date_to_csv(facture.date)
                ligne << (facture.millesime.blank? ? "" : date_to_csv(facture.millesime) )
                ligne << (facture.date_mandatement.blank? ? "" : date_to_csv(facture.date_mandatement) )
                ligne << facture.numero_mandat
                ligne << (facture.justifiable.blank? ? "" : facture.justifiable)
                ligne << facture.rubrique_comptable.small_intitule
                ligne << facture.taux_tva
                ligne << facture.montant_htr
                ligne << facture.cout_ht
                ligne << facture.cout_ttc
                csv << ligne
              end
            end
            # si une référence comptable a été sélectionnée, alors on affiche une ligne par facture
            # et non pas une ligne par depense
          else
            ligne = []
            ligne << codingTranslation.iconv(c.send(depense_method_sym).ligne.nom)
            ligne << boolean_to_csv(c.send(depense_method_sym).commande_solde)
            ligne << c.send(depense_method_sym).verrou
            ligne << date_to_csv(c.send(depense_method_sym).date_commande)
            ligne << codingTranslation.iconv(c.send(depense_method_sym).compte_budgetaire)
            ligne << codingTranslation.iconv(c.send(depense_method_sym).code_analytique)
            ligne << codingTranslation.iconv(c.send(depense_method_sym).reference)
            ligne << codingTranslation.iconv(c.send(depense_method_sym).intitule)
            ligne << codingTranslation.iconv(c.send(depense_method_sym).fournisseur)
            ligne << date_to_csv(c.date)
            ligne << codingTranslation.iconv(c.numero_facture)
            ligne << (c.date_mandatement.blank? ? c.date_mandatement : date_to_csv(c.date_mandatement))
            ligne << codingTranslation.iconv(c.numero_mandat)
            ligne << codingTranslation.iconv(c.rubrique_comptable.numero_rubrique)
            ligne << c.send(depense_method_sym).montant_engage
            ligne << c.montant_htr
            ligne << c.cout_ht
            ligne << c.cout_ttc
            ligne << send("ligne_#{depense_method}_url".to_sym, c.send(depense_method_sym).ligne, c)
            csv << ligne
          end
        end
      end
    end

    # Demande d'affichage des dépenses en missions
    if params['data'] == 'mission'
      csv_string = CSV.generate(options) do |csv|
        ligne = ["Ligne", "Commande soldée ?","Verrou", "Date de demande d'achat","Compte budgétaire", "Code analytique", "N° d'OM - Référence",
          "Agent", "Date de départ", "Date de retour", "Lieux", "Objet de la mission", "Montant Engagé",
          "Montant Payé HTR","Montant Payé HT", "Montant Payé TTC", "url"]
        if !@ref_cp.blank?
          ligne.insert(12, "Tiers Réglé", "Date Fac.", "N° Fac.", "Date Mand.", "N° Mand.", "Rub.CP.")
        elsif @show_factures == "yes"
          ligne.insert(17, "N° de facture", "Date de facture", "Millesime de facture" ,"Date de  Mand.", "N° Mand.", "Justifiable", "Rub.CP.","Tiers Réglé", "Taux TVA", "Payé HTR", "Payé HT", "Payé TTC")
        end 
        #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne
        @depenses.each do |c|
          if @ref_cp.blank?
            ligne = []
            ligne << codingTranslation.iconv(c.ligne.nom)
            ligne << boolean_to_csv(c.commande_solde)
            ligne << c.verrou
            ligne << date_to_csv(c.date_commande)  
            ligne << codingTranslation.iconv(c.compte_budgetaire)
            ligne << codingTranslation.iconv(c.code_analytique)
            ligne << codingTranslation.iconv(c.reference)
            ligne << codingTranslation.iconv(c.agent)
            ligne << date_to_csv(c.date_depart)
            ligne << date_to_csv(c.date_retour)
            ligne << codingTranslation.iconv(c.lieux)
            ligne << codingTranslation.iconv(c.intitule)
            ligne << c.montant_engage
            ligne << c.montant_paye('htr')
            ligne << c.montant_paye('ht')
            ligne << c.montant_paye('ttc')
            ligne << ligne_depense_mission_url(c.ligne, c)
            csv << ligne
            if @show_factures == 'yes'
              for facture in c.depense_mission_factures do
                ligne = ["FACTURE ->","",facture.verrou,"","","","","","","","","","","","","",""]
                ligne << facture.numero_facture
                ligne << date_to_csv(facture.date)
                ligne << (facture.millesime.blank? ? "" : date_to_csv(facture.millesime) )
                ligne << (facture.date_mandatement.blank? ? "" : date_to_csv(facture.date_mandatement) )
                ligne << facture.numero_mandat
                ligne << (facture.justifiable.blank? ? "" : facture.justifiable)
                ligne << facture.rubrique_comptable.small_intitule
                ligne << facture.fournisseur
                ligne << facture.taux_tva
                ligne << facture.montant_htr
                ligne << facture.cout_ht
                ligne << facture.cout_ttc
                csv << ligne
              end
            end
          else
            ligne = []
            ligne << codingTranslation.iconv(c.depense_mission.ligne.nom)
            ligne << boolean_to_csv(c.depense_mission.commande_solde)
            ligne << c.depense_mission.verrou
            ligne << date_to_csv(c.depense_mission.date_commande)
            ligne << codingTranslation.iconv(c.depense_mission.compte_budgetaire)
            ligne << codingTranslation.iconv(c.depense_mission.code_analytique)
            ligne << codingTranslation.iconv(c.depense_mission.reference)
            ligne << codingTranslation.iconv(c.depense_mission.agent)
            ligne << date_to_csv(c.depense_mission.date_depart)
            ligne << date_to_csv(c.depense_mission.date_retour)
            ligne << codingTranslation.iconv(c.depense_mission.lieux)
            ligne << codingTranslation.iconv(c.depense_mission.intitule)
            ligne << codingTranslation.iconv(c.fournisseur)
            ligne << date_to_csv(c.date)
            ligne << codingTranslation.iconv(c.numero_facture)
            ligne << (c.date_mandatement.blank? ? c.date_mandatement : date_to_csv(c.date_mandatement))
            ligne << codingTranslation.iconv(c.numero_mandat)
            ligne << codingTranslation.iconv(c.rubrique_comptable.numero_rubrique)
            ligne << c.depense_mission.montant_engage
            ligne << c.montant_htr
            ligne << c.cout_ht
            ligne << c.cout_ttc
            ligne << ligne_depense_mission_url(c.depense_mission.ligne, c)
            csv << ligne
          end
        end
      end
    end

    # Demande d'affichage des dépenses en salaire
    if params['data'] == 'salaire'
      csv_string = CSV.generate(options) do |csv|
        ligne = ["Ligne", "Salaire soldé ?","Verrou","Compte budgétaire","Code analytique", "Agent", "Type de contrat",
          "Statut", "Date de début", "Date de fin", "Nombre de mois",
          "Coût Mensuel", "Coût Période", "Montant Payé HTR", "Montant Payé",
          "url"]
        if @show_factures == "yes"
          ligne.insert(16, "N° de mandat", "Date de mandatement", "Millesime" ,"Commentaire", "Payé HTR", "Payé TTC")
        end 
        #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne

        @depenses.each do |c|
          ligne = []
          ligne << codingTranslation.iconv(c.ligne.nom)
          ligne << boolean_to_csv(c.commande_solde)
          ligne << c.verrou
          ligne << codingTranslation.iconv(c.compte_budgetaire)
          ligne << codingTranslation.iconv(c.code_analytique)
          ligne << codingTranslation.iconv(c.nom_agent)
          ligne << codingTranslation.iconv(c.type_contrat)
          ligne << codingTranslation.iconv(c.statut)
          ligne << date_to_csv(c.date_debut)
          ligne << date_to_csv(c.date_fin)
          ligne << c.nb_mois
          ligne << c.cout_mensuel
          ligne << c.cout_periode
          ligne << c.montant_paye('htr')
          ligne << c.montant_paye('ttc')
          ligne << ligne_depense_salaire_url(c.ligne, c)
          csv << ligne
          if @show_factures == 'yes'
            for facture in c.depense_salaire_factures do
              ligne = ["PAYE ->","",facture.verrou,"","","","","","","","","","","","",""]
              ligne << facture.numero_mandat
              ligne << date_to_csv(facture.date_mandatement)
              ligne << (facture.millesime.blank? ? "" : date_to_csv(facture.millesime))
              ligne << facture.commentaire 
              ligne << facture.montant_htr
              ligne << facture.cout 
              csv << ligne
            end
          end
        end
      end
    end

    # Demande d'affichage des dépenses du commun
    if params['data'] == 'commun'
      csv_string = CSV.generate(options) do |csv|
        ligne = ["Ligne", "Commande soldée ?","Verrou", "Date de demande d'achat","Compte budgétaire","Code analytique", "N° de demande d'achat",
          "Réf.Budg.", "Intitulé", "Fournisseur", "Montant Engagé","Montant Payé HT",  "Montant Payé TTC", "url"]
        if !@ref_cp.blank?
          ligne.insert(10, "Date Fac.", "N° Fac.", "Date Mand.", "N° Mand.", "Rub.CP.") 
        elsif @show_factures == "yes"
          ligne.insert(14, "N° de facture", "Date de facture", "Millesime de facture" ,"Date de  Mand.", "N° Mand.", "Justifiable", "Rub.CP.", "Taux TVA", "Payé HT", "Payé TTC")
        end 
        #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne
        @depenses.each do |c|
          if @ref_cp.blank?
            ligne = []
            ligne << codingTranslation.iconv(c.ligne.nom)
            ligne << boolean_to_csv(c.commande_solde)
            ligne << c.verrou
            ligne << date_to_csv(c.date_commande)
            ligne << codingTranslation.iconv(c.compte_budgetaire)
            ligne << codingTranslation.iconv(c.code_analytique)
            ligne << codingTranslation.iconv(c.reference)
            ligne << codingTranslation.iconv(c.budgetaire_reference.code)
            ligne << codingTranslation.iconv(c.intitule)
            ligne << codingTranslation.iconv(c.fournisseur)
            ligne << c.montant_engage
            ligne << c.montant_paye('ht')
            ligne << c.montant_paye('ttc')
            ligne << ligne_depense_commun_url(c.ligne, c)
            csv << ligne
            if @show_factures == 'yes'
              for facture in c.depense_commun_factures do
                ligne = ["FACTURE ->","",facture.verrou,"","","","","","","","","","",""]
                ligne << facture.numero_facture
                ligne << date_to_csv(facture.date)
                ligne << (facture.millesime.blank? ? "" : date_to_csv(facture.millesime) )
                ligne << (facture.date_mandatement.blank? ? "" : date_to_csv(facture.date_mandatement) )
                ligne << facture.numero_mandat
                ligne << (facture.justifiable.blank? ? "" : facture.justifiable)
                ligne << facture.rubrique_comptable.small_intitule
                ligne << facture.taux_tva
                ligne << facture.cout_ht
                ligne << facture.cout_ttc
                csv << ligne
              end
            end
          else
            ligne = []
            ligne << codingTranslation.iconv(c.depense_commun.ligne.nom)
            ligne << boolean_to_csv(c.depense_commun.commande_solde)
            ligne << c.depense_commun.verrou
            ligne << date_to_csv(c.depense_commun.date_commande)
            ligne << codingTranslation.iconv(c.depense_commun.compte_budgetaire)
            ligne << codingTranslation.iconv(c.depense_commun.code_analytique)
            ligne << codingTranslation.iconv(c.depense_commun.reference)
            ligne << codingTranslation.iconv(c.depense_commun.budgetaire_reference.code)
            ligne << codingTranslation.iconv(c.depense_commun.intitule)
            ligne << codingTranslation.iconv(c.depense_commun.fournisseur)
            ligne << date_to_csv(c.date)
            ligne << codingTranslation.iconv(c.numero_facture)
            ligne << (c.date_mandatement.blank? ? "" : date_to_csv(c.date_mandatement))
            ligne << codingTranslation.iconv(c.numero_mandat)
            ligne << codingTranslation.iconv(c.rubrique_comptable.numero_rubrique)
            ligne << c.depense_commun.montant_engage
            ligne << c.cout_ht
            ligne << c.cout_ttc
            ligne << ligne_depense_commun_url(c.depense_commun.ligne, c)
            csv << ligne
          end
        end
      end
    end
    send_data csv_string, :type => 'text/csv',
                          :disposition => "attachment; filename=export_osc.csv" 
  end

  def bilans
    setup_all_lignes_filter
    setup_type_montant(true)
    mes_projets_nom_query = ["SELECT p.nom from projets p where p.id in (?) ORDER BY p.nom",@ids_mes_equipes]
    mes_projets_nom = Projet.find_by_sql(mes_projets_nom_query).collect{|d| d.nom}
    @tool_tip_mes_equipes =""
    for nom in mes_projets_nom do
      @tool_tip_mes_equipes += nom+" \\n"
    end
    # les contrats editables sont consultables par défaut
    @ids_contrats_viewables = @ids_consultables
    @ids_contrats_viewables = ['-1'] if @ids_contrats_viewables.size == 0
    
    @filtre_mes_projets_checked = false;
    @filtre_mes_projets   = params['filtre_projet'] || ""

    
    
    req = ["SELECT DISTINCT c.*, n.contrat_type_id FROM contrats c
            INNER JOIN notifications AS n ON n.contrat_id = c.id
            INNER JOIN sous_contrats AS sc ON sc.contrat_id = c.id
            INNER JOIN lignes AS l ON l.sous_contrat_id = sc.id 
            WHERE c.id IN (?)
            ORDER BY c.acronyme", @ids_contrats_viewables]
    
    @contrats_for_select_all = Contrat.find_by_sql(req)
    
    @affiche_selection = false
    
    # choix de l'annee
    @annee_for_select=[]
    for i in 0..30
      @annee_for_select << (2030-i)
    end
    # On va différencier les contrats du commun
    @contrats_dotation_for_select = []
    @contrats_for_select = [""]
    @ids_contrats_for_select= Array.new
    @ids_contrats_dotation_for_select = Array.new
    if @contrats_for_select_all.size != 0
      @contrats_for_select_all.each {|c|
        if c.contrat_type_id.to_i == ID_CONTRAT_DOTATION
          @contrats_dotation_for_select << c
          @contrats_for_select_all.delete(c)
          @ids_contrats_dotation_for_select << c.id
        else
          @ids_contrats_for_select << c.id
        end
      }
      
      @affiche_selection = true
      req_projet = ["SELECT DISTINCT p.nom FROM projets p
                     INNER JOIN sous_contrats AS sc ON sc.entite_type = 'Projet' AND sc.entite_id = p.id
                  WHERE sc.contrat_id IN (?) ORDER BY p.nom ", @ids_contrats_for_select]
    
      @projets_for_select = Projet.find_by_sql(req_projet).collect{|p| p.nom}
      
      @projets_for_select.insert(0,"")
      
      req_departement = ["SELECT DISTINCT d.nom FROM departements d, sous_contrats sc, departement_subscriptions ds
                    WHERE ((sc.entite_type = 'Departement' AND sc.entite_id = d.id) OR (sc.entite_type = 'Projet' AND sc.entite_id = ds.projet_id AND d.id = ds.departement_id )) AND sc.contrat_id IN (?) ORDER BY d.nom ", @ids_contrats_for_select]
      
      @departements_for_select = Departement.find_by_sql(req_departement).collect{|d| d.nom}
      
      @departements_for_select.insert(0,"")
      
      @contrats_for_select      = [""]+@contrats_for_select_all.collect{ |c| c.acronyme+(c.num_contrat_etab.to_s.blank? ? "" : c.num_contrat_etab.to_s.gsub(/(^[\s]*)/,' N° \1') )}
      @contrats_dotation_for_select = [""]+@contrats_dotation_for_select.collect{|c|c.acronyme+(c.num_contrat_etab.to_s.blank? ? "" : c.num_contrat_etab.to_s.gsub(/(^[\s]*)/,' N° \1') )} if @contrats_dotation_for_select.size > 0
    end
    
    @laboratoires_for_select = [""]+Laboratoire.find(:all, :order => "nom").collect{ |c| c.nom}
    @tutelles_for_select = [""]+Tutelle.find(:all, :order => "nom").collect{ |c| c.nom}
    @organisme_gestionnaires = [""]+OrganismeGestionnaire.find(:all, :order => "nom").collect{ |c| c.nom}

    @datas = Hash.new
    if !params['type_recherche'].blank?
      @type_bilan = params['type_recherche']
    else
      @type_bilan = "sommes_engagees"
    end

    @type_montant = 'ttc' if params['type_affichage'] == 'contrat_dotation'

    if !params['type_detail'].blank?
      @bilan_detail = params['type_detail']
    else
      @bilan_detail = 'global'
    end
    
    if !(params['contrat'].blank? && params['equipe'].blank? && params['laboratoire'].blank? && params['departement'].blank? && params['organisme_gestionnaire'].blank? && (@filtre_mes_projets == "") && params['in_laboratoire'].blank? && params['in_departement'].blank? && params['in_tutelle'].blank?)
      if !params['contrat'].blank?
        contrat = params['contrat'].split(/ N° /)
      end
      

      if @filtre_mes_projets and @filtre_mes_projets == 'filtre_projet_active'
        @filtre_mes_projets_checked = true;
        @ids_lignes = Ligne.find_all_with_projects_for(current_user,@show_contrat_clos)
      else      
        ids_contrats_auth = (params['type_affichage'] == 'contrat_dotation' ? @ids_contrats_dotation_for_select : @ids_contrats_for_select)
        ids_contrats_auth = ['-1'] if ids_contrats_auth.size == 0
        @equipe_research = params['equipe'].nil? ? "" : params['equipe']
        @laboratoire_research = params['laboratoire'].nil? ? "" : params['laboratoire']
        @departement_research = params['departement'].nil? ? "" : params['departement'] 
        @in_laboratoire = params['in_laboratoire'].nil? ? "" : params['in_laboratoire']
        @in_departement = params['in_departement'].nil? ? "" : params['in_departement']
        @in_tutelle = params['in_tutelle'].nil? ? "" : params['in_tutelle']
        
        @ids_lignes = Ligne.my_find_all(ids_contrats_auth,
                                        @acronyme_research = (contrat.nil? ? "" : contrat[0]),
                                        @noContrat_research = (contrat.nil? ? "" : contrat[1]),
                                        @equipe_research,
                                        @laboratoire_research,
                                        @departement_research,
                                        @in_laboratoire,
                                        @in_departement,
                                        @in_tutelle,
                                        @show_contrat_clos)
      end

      @ids_lignes = ['-1'] if @ids_lignes.size == 0

      sql_query = ["SELECT l.* from lignes l 
                   INNER JOIN sous_contrats AS sc ON sc.id = l.sous_contrat_id
                   WHERE l.id IN (?)
                   ORDER BY sc.entite_id, l.nom",@ids_lignes]
                   
      lignes = Ligne.find_by_sql(sql_query)
      @filtered_lignes_non_paginees = []
      if !params['organisme_gestionnaire'].blank? 
        for ligne in lignes
          if ligne.organisme_gestionnaire.nom == params['organisme_gestionnaire']
            @filtered_lignes_non_paginees << ligne
          end
        end
      else
        @filtered_lignes_non_paginees = lignes

      end
      #Mise en place de la Pagination pour les tros grosses requetes
      @per_page = 100
      @page =  params['page'] || '1'
      @filtered_lignes = @filtered_lignes_non_paginees.paginate(:page => @page, :per_page =>@per_page)
      
      @somme_versements_commun = 0
      @somme_versements_fonctionnement = 0
      @somme_versements_equipement = 0
      @somme_versements_mission = 0
      @somme_versements_fem = 0
      @somme_versements_salaire = 0
      @somme_versements_non_ventile = 0
      @total_versements = 0

      @somme_depense_commun = 0
      @somme_depense_fonctionnement = 0
      @somme_depense_equipement = 0
      @somme_depense_mission = 0
      @somme_depense_fem = 0
      @somme_depense_salaire = 0
      @somme_depense_non_ventilee = 0
      @total_depenses = 0

      @total_commun = 0
      @total_fonctionnement = 0
      @total_equipement = 0
      @total_mission = 0
      @total_fem = 0
      @total_salaire = 0
      @total_non_ventilee = 0
      @total = 0

      @reste_a_ouvrir_commun = 0
      @reste_a_ouvrir_fonctionnement = 0
      @reste_a_ouvrir_equipement = 0
      @reste_a_ouvrir_mission = 0
      @reste_a_ouvrir_fem = 0
      @reste_a_ouvrir_salaire = 0
      @reste_a_ouvrir_non_ventilee = 0
      @reste_a_ouvrir_total = 0

      @reste_a_depenser_commun = 0
      @reste_a_depenser_fonctionnement = 0
      @reste_a_depenser_equipement = 0
      @reste_a_depenser_mission = 0
      @reste_a_depenser_fem = 0
      @reste_a_depenser_salaire = 0
      @reste_a_depenser_non_ventilee = 0
      @reste_a_depenser_total = 0

      for ligne in @filtered_lignes do
        #calcul des versements et dépenses totaux pour une ligne:
        total_depenses_commun_ligne = ligne.depense_communs.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant) }
        total_depenses_equipement_ligne = ligne.depense_equipements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant) }
        total_depenses_fonctionnement_ligne = ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant) }
        total_depenses_mission_ligne = ligne.depense_missions.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant) }
        total_depenses_salaire_ligne = ligne.depense_salaires.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant) }
        total_depenses_non_ventile_ligne = ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant) }
        total_depenses_ligne = total_depenses_commun_ligne + total_depenses_fonctionnement_ligne + total_depenses_equipement_ligne + total_depenses_mission_ligne + total_depenses_salaire_ligne + total_depenses_non_ventile_ligne

        total_versements_ligne = ligne.versements.find(:all).sum{ |d| d.montant }
        total_versements_equipement_ligne = ligne.versements.find(:all, :conditions => { :ventilation => "Equipement" }).sum{ |d| d.montant }
        total_versements_fonctionnement_ligne = ligne.versements.find(:all, :conditions => { :ventilation => "Fonctionnement" }).sum{ |d| d.montant }
        total_versements_mission_ligne = ligne.versements.find(:all, :conditions => { :ventilation => "Mission" }).sum{ |d| d.montant }
        total_versements_non_ventile_ligne = ligne.versements.find(:all, :conditions => { :ventilation => "Non Ventilé" }).sum{ |d| d.montant }
        total_versements_salaire_ligne = ligne.versements.find(:all, :conditions => { :ventilation => "Salaire" }).sum{ |d| d.montant }

        if (ligne.sous_contrat.sous_contrat_notification)
          total_a_ouvrir_ligne = ligne.sous_contrat.sous_contrat_notification.ma_total - ligne.sous_contrat.sous_contrat_notification.ma_frais_gestion_mutualises - ligne.sous_contrat.sous_contrat_notification.ma_frais_gestion_mutualises_local
          total_a_ouvrir_equipement_ligne = ligne.sous_contrat.sous_contrat_notification.ma_equipement
          total_a_ouvrir_fonctionnement_ligne = ligne.sous_contrat.sous_contrat_notification.ma_fonctionnement + ligne.sous_contrat.sous_contrat_notification.ma_couts_indirects
          total_a_ouvrir_mission_ligne = ligne.sous_contrat.sous_contrat_notification.ma_mission
          total_a_ouvrir_salaire_ligne = ligne.sous_contrat.sous_contrat_notification.ma_salaire
          total_a_ouvrir_non_ventile_ligne = ligne.sous_contrat.sous_contrat_notification.ma_non_ventile
        else
          total_a_ouvrir_ligne = ligne.contrat.notification.ma_total - ligne.contrat.notification.ma_frais_gestion_mutualises - ligne.contrat.notification.ma_frais_gestion_mutualises_local
          total_a_ouvrir_equipement_ligne = ligne.contrat.notification.ma_equipement
          total_a_ouvrir_fonctionnement_ligne = ligne.contrat.notification.ma_fonctionnement + ligne.contrat.notification.ma_couts_indirects
          total_a_ouvrir_mission_ligne = ligne.contrat.notification.ma_mission
          total_a_ouvrir_salaire_ligne = ligne.contrat.notification.ma_salaire
          total_a_ouvrir_non_ventile_ligne = ligne.contrat.notification.ma_non_ventile
        end
        reste_a_ouvrir_ligne = total_a_ouvrir_ligne - total_versements_ligne
        reste_a_ouvrir_equipement_ligne = total_a_ouvrir_equipement_ligne - total_versements_equipement_ligne
        reste_a_ouvrir_fonctionnement_ligne = total_a_ouvrir_fonctionnement_ligne - total_versements_fonctionnement_ligne
        reste_a_ouvrir_mission_ligne = total_a_ouvrir_mission_ligne - total_versements_mission_ligne
        reste_a_ouvrir_salaire_ligne = total_a_ouvrir_salaire_ligne - total_versements_salaire_ligne
        reste_a_ouvrir_non_ventile_ligne = total_a_ouvrir_non_ventile_ligne - total_versements_non_ventile_ligne

        reste_a_depenser_ligne = total_a_ouvrir_ligne - total_depenses_ligne
        reste_a_depenser_equipement_ligne = total_a_ouvrir_equipement_ligne - total_depenses_equipement_ligne
        reste_a_depenser_fonctionnement_ligne = total_a_ouvrir_fonctionnement_ligne - total_depenses_fonctionnement_ligne
        reste_a_depenser_mission_ligne = total_a_ouvrir_mission_ligne - total_depenses_mission_ligne
        reste_a_depenser_salaire_ligne = total_a_ouvrir_salaire_ligne - total_depenses_salaire_ligne
        reste_a_depenser_non_ventile_ligne = total_a_ouvrir_non_ventile_ligne - total_depenses_non_ventile_ligne

        @reste_a_ouvrir_fonctionnement += reste_a_ouvrir_fonctionnement_ligne
        @reste_a_ouvrir_equipement += reste_a_ouvrir_equipement_ligne
        @reste_a_ouvrir_mission += reste_a_ouvrir_mission_ligne
        @reste_a_ouvrir_fem += reste_a_ouvrir_fonctionnement_ligne + reste_a_ouvrir_equipement_ligne + reste_a_ouvrir_mission_ligne
        @reste_a_ouvrir_salaire += reste_a_ouvrir_salaire_ligne
        @reste_a_ouvrir_non_ventilee += reste_a_ouvrir_non_ventile_ligne
        @reste_a_ouvrir_total += reste_a_ouvrir_ligne

        @reste_a_depenser_fonctionnement += reste_a_depenser_fonctionnement_ligne
        @reste_a_depenser_equipement += reste_a_depenser_equipement_ligne
        @reste_a_depenser_mission += reste_a_depenser_mission_ligne
        @reste_a_depenser_fem += reste_a_depenser_equipement_ligne + reste_a_depenser_fonctionnement_ligne + reste_a_depenser_mission_ligne
        @reste_a_depenser_salaire += reste_a_depenser_salaire_ligne
        @reste_a_depenser_non_ventilee += reste_a_depenser_non_ventile_ligne
        @reste_a_depenser_total += reste_a_depenser_ligne

      end

      if @filtered_lignes.size != 0
        
        if params[:csv]
          @date_min = @filtered_lignes.collect{ |lig| lig.date_debut}.sort.first
          @date_max = @filtered_lignes.collect{ |lig| lig.date_fin_selection}.sort.last
        else
          @date_min = @filtered_lignes.collect{ |lig| lig.date_min}.sort.first
          @date_max = @filtered_lignes.collect{ |lig| lig.date_max}.sort.last
        end
      
      

        @totaux = Hash.new
  
        if @bilan_detail == 'detail'
          for year in @date_min.year..@date_max.year
            calcul_bilan(year)
          end
        elsif @bilan_detail == 'global'
          calcul_bilan(0)
        else
          calcul_bilan(@bilan_detail.to_i)
        end
     end
    end

    @datas.each_value { |data|
      data = data.sort_by { |my_item| my_item['ligne_organisme_gestionnaire_nom'] }
    }
    @datas = @datas.sort { |a,b| a <=> b}

    @datas.reverse!
    
    if params[:csv]
      export_bilan_csv
    end
    
    if params[:partial] == "yes"
      render :partial => 'list_bilans'
    end
    
  end


  private
  
  # Préparation de variables pour les actions
  # - list : cvs = false
  # - export_csv : csv = true
  #
  # Return @per_page : nombre d'item par page (pagination)
  # Return @page : numéro de la page courante
  # Return @order_value : champ sur lequel porte le tris
  # Return @order_type : type de tris : asc || desc
  # Return @credits si la demande d'affichage correspond aux crédits
  # Return @dépenses si la de demande d'affichage correspond aux dépenses
  def prepare_result(csv = false)
    setup_all_lignes_filter
    setup_type_montant

    # Paramètres pour la pagination
    if csv
      @per_page = 1000000000
    else
      @per_page = params['per_page']
    end
    @page =  params['page'] || '1'

    # Paramètre de tris à passer à la requête sql
    if params['action_for_update'] == "order"
      @order_value = params['value']
      if params['saved_order_value'] == params['value']
        if params['saved_order_type'] == 'desc'
          @order_type = "asc"
        else
          @order_type = "desc"
        end
      else
        @order_type = "asc"
      end
    else
      @order_value = params['saved_order_value']
      @order_type = params['saved_order_type']
    end

    # Tris sql pour tous les champ à l'exception des Montant Payé des depenses, qui seront
    # effectués en ruby
    type_montant_facture = nil
   # if @order_value =~ /^montant_factures_(ttc|htr|ht?)$/ and params['ref_cp'].blank?
   #   type_montant_facture = $1
   # end
    if @order_value =~ /^montant_paye_(ttc|htr|ht?)$/ and params['ref_cp'].blank?
      type_montant_facture = $1
    end
    order = @order_value+" "+@order_type


    # Recherche Avancées
    @acronyme_research    = params['acronyme_research']
    @noContrat_research   = params['noContrat_research'] || ""
    @equipe_research      = params['equipe_research'] || ""
    @laboratoire_research = params['laboratoire_research'] || ""
    @departement_research = params['departement_research'] || ""
    @in_laboratoire       = params['in_laboratoire'] || ""
    @in_departement       = params['in_departement'] || ""
    @in_tutelle           = params['in_tutelle'] || ""
    @organisme_gestionnaire = params['organisme_gestionnaire'] || ""
    @filtre_mes_projets   = params['filtre_projet'] || ""

    @annee                = params['annee'] || ""
    @annee2               = params['annee2'] || ""
    @annee3               = params['annee3'] || ""
    @millesime            = params['millesime'] || ""
    @reference            = params['reference'] || ""
    @origine              = params['origine'] || ""
    @commentaire          = params['commentaire'] || ""
    @compte_budgetaire    = params['compte_budgetaire'] || ""
    @code_analytique      = params['code_analytique'] || ""
    @lieux                = params['lieux'] || ""
    @agent                = params['agent'] || ""
    @intitule             = params['intitule'] || ""
    @fournisseur          = params['fournisseur'] || ""
    @statut               = params['statut'] || ""
    @type_contrat         = params['type_contrat'] || ""
    @ref_bud              = params['ref_bud'] || ""
    @ref_cp               = params['ref_cp'] || ""

    @filtre_mes_projets_checked = false;
    if @filtre_mes_projets and @filtre_mes_projets == 'filtre_projet_active'
      @filtre_mes_projets_checked = true;
      @ids_lignes = Ligne.find_all_with_projects_for(current_user,@show_contrat_clos ="no")
    else
      @ids_contrats_viewables = @ids_consultables+@ids_editables
      @ids_contrats_viewables = ['-1'] if @ids_contrats_viewables.size == 0
      @ids_lignes = Ligne.my_find_all(@ids_contrats_viewables,
                                        @acronyme_research,
                                        @noContrat_research,
                                        @equipe_research,
                                        @laboratoire_research,
                                        @departement_research,
                                        @in_laboratoire,
                                        @in_departement,
                                        @in_tutelle,
                                        @show_contrat_clos)
    end

    @ids_lignes = ['-1'] if @ids_lignes.size == 0

    if !params['organisme_gestionnaire'].blank?
      lignes = Ligne.find(:all, :conditions => {:id => @ids_lignes})
      @filtered_lignes_id = []
      if !params['equipe_research'].blank? 
        for ligne in lignes
          if (ligne.entite.nom.upcase.include? params['equipe_research'].upcase ) and (ligne.organisme_gestionnaire.nom.upcase.include? @organisme_gestionnaire.upcase)
            @filtered_lignes_id << ligne.id
          end
        end
      else
        for ligne in lignes
          if ligne.organisme_gestionnaire.nom.upcase.include? @organisme_gestionnaire.upcase
            @filtered_lignes_id << ligne.id
          end
        end
      end    
    elsif !params['equipe_research'].blank?
      lignes = Ligne.find(:all, :conditions => {:id => @ids_lignes})
      @filtered_lignes_id = []
      for ligne in lignes
        if ligne.entite.nom.upcase.include? params['equipe_research'].upcase
          @filtered_lignes_id << ligne.id
        end
      end
    else
      @filtered_lignes_id = @ids_lignes
    end

    @filtered_lignes_id = ['-1'] if @filtered_lignes_id.size == 0

    filters = Filtr.new
    filters.multiple @filtered_lignes_id, 'lignes.id'

    # Paramètres de type de dépenses
    filters.equal '1', 'commande_solde'  if @type_depense == "depenses_soldees"
    filters.equal '0', 'commande_solde'  if @type_depense == "depenses_non_soldees"
    filters.equal 'Fonctionnement', 'ventilation'  if @type_depense == "fonctionnement"
    filters.equal 'Equipement', 'ventilation'  if @type_depense == "equipement"
    filters.equal 'Mission', 'ventilation'  if @type_depense == "mission"
    filters.equal 'Salaire', 'ventilation'  if @type_depense == "salaire"
    filters.equal 'Non ventilé', 'ventilation'  if @type_depense == "non_ventilee"

    case params['data']
    when blank?  || ''                 # Demande d'affichage des crédits
      filters.contient @annee, 'date_effet'
      filters.contient @reference, 'reference'
      filters.contient @origine, 'origine'
      filters.contient @commentaire, 'commentaire'
      filters.contient @compte_budgetaire, 'compte_budgetaire'
      filters.contient @code_analytique, 'code_analytique'

      @credits = Versement.paginate(:include => [:ligne],
        :conditions => filters.conditions, :order => order,
        :page => @page, :per_page => @per_page)

    when 'commun'
      filters.contient @annee, 'date_commande'
      filters.contient @reference, 'reference'
      filters.contient @intitule, 'depense_communs.intitule'
      filters.contient @fournisseur, 'fournisseur'
      filters.contient @compte_budgetaire, 'compte_budgetaire'
      filters.contient @code_analytique, 'code_analytique'
      filters.contient @ref_bud, 'budgetaire_references.code' unless @ref_bud.blank?
      filters.contient @ref_cp, 'rubrique_comptables.numero_rubrique' unless @ref_cp.blank?
      @depenses = prepare_depenses([:ligne, :budgetaire_reference], filters, order)
 
    when 'fonctionnement', 'equipement', 'non_ventilee'
      filters.contient @annee, 'date_commande'
      filters.contient @reference, 'reference'
      filters.contient @intitule, 'intitule'
      filters.contient @fournisseur, 'fournisseur'
      filters.contient @compte_budgetaire, 'compte_budgetaire'
      filters.contient @code_analytique, 'code_analytique'
      filters.contient @ref_cp, 'rubrique_comptables.numero_rubrique' unless @ref_cp.blank?
      @depenses = prepare_depenses([:ligne, :rubrique_comptables], filters, order)

    when 'mission'
      filters.contient @annee, 'date_commande'
      filters.contient @reference, 'reference'
      filters.contient @intitule, 'intitule'
      filters.contient @annee2, 'date_depart'
      filters.contient @annee3, 'date_retour'
      filters.contient @agent, 'agent'
      filters.contient @lieux, 'lieux'
      filters.contient @compte_budgetaire, 'compte_budgetaire'
      filters.contient @code_analytique, 'code_analytique'
      filters.contient @ref_cp, 'rubrique_comptables.numero_rubrique' unless @ref_cp.blank?
      @depenses = prepare_depenses([:ligne, :rubrique_comptables], filters, order)

    when 'salaire'
      filter_req = ""
      if @type_depense == "depenses_soldees"
        @soldee = '1'
        filter_req=" AND d.commande_solde = '"+@soldee+"'"
      elsif @type_depense == "depenses_non_soldees"
        @soldee = '0'
        filter_req=" AND d.commande_solde = '"+@soldee+"'"
      else
        @soldee = '%'
      end
      filters.contient @annee, 'date_debut'
      filters.contient @annee2, 'date_fin'
      filters.contient @agent, 'agent'
      filters.contient @statut, 'statut'
      filters.contient @compte_budgetaire, 'compte_budgetaire'
      filters.contient @code_analytique, 'code_analytique'
      filters.contient @type_contrat, 'type_contrat'
      if !@annee.blank?
        @annee = '%'+@annee+'%'
        filter_req+= " AND d.date_debut like '"+@annee+"'"
      end
      if !@annee2.blank?
        @annee2 = '%'+@annee2+'%'
        filter_req+= " AND d.date_fin like '"+@annee2+"'"
      end
      if !@statut.blank?
        @statut = '%'+@statut+'%'
        filter_req+= " AND d.statut like '"+@statut+"'"
      end
      if !@compte_budgetaire.blank?
        @compte_budgetaire = '%'+@compte_budgetaire+'%'  
        filter_req+= " AND d.compte_budgetaire like '"+@compte_budgetaire+"'"
      end
      if !@code_analytique.blank?
        @code_analytique = '%'+@code_analytique+'%'  
        filter_req+= " AND d.code_analytique like '"+@code_analytique+"'"
      end
      if !@type_contrat.blank?
        @type_contrat = '%'+@type_contrat+'%'
        filter_req+= " AND d.type_contrat like '"+@type_contrat+"'"
      end
      ## NEED REFACTORING
      if @agent.blank?
        salaires_request = ["SELECT d.*
            FROM depense_salaires d
            WHERE d.ligne_id IN (?) "+filter_req,@filtered_lignes_id]
        @depenses_non_paginees = DepenseSalaire.find_by_sql(salaires_request)
      else
        @agent = '%'+@agent+'%'
        salaires_not_from_ref_request = ["SELECT d.*
            FROM depense_salaires d
            WHERE d.ligne_id IN (?)
            AND d.agent like ?
            AND d.agent_si_origine = ''"+filter_req,
              @filtered_lignes_id,@agent]
        salaires_not_from_ref = DepenseSalaire.find_by_sql(salaires_not_from_ref_request)
        
        salaires_from_ref_request = ["SELECT d.*
            FROM depense_salaires d
            LEFT OUTER JOIN referentiel_agents r ON (r.si_id = d.agent AND r.si_origine = d.agent_si_origine )
            WHERE d.ligne_id IN (?)
            AND r.nom like ?"+filter_req,
              @filtered_lignes_id,@agent]
        salaires_from_ref = DepenseSalaire.find_by_sql(salaires_from_ref_request)
        
        @depenses_non_paginees = salaires_not_from_ref + salaires_from_ref        
      end
      
      if @compute_totaux_globaux
        @depenses = @depenses_non_paginees
      else
        args = [@order_value.to_sym]
        if @order_value == "montant_paye_ttc" or @order_value == "montant_paye_htr" or @order_value == "montant_paye_ht"
           @depenses_non_paginees.sort! {|a,b|
             a.montant_paye(type_montant_facture) <=> b.montant_paye(type_montant_facture)}
        else
          @depenses_non_paginees.sort! { |a,b| a.send(*args) <=> b.send(*args) }
        end  
      
        @depenses_non_paginees.reverse! if @order_type != "asc"
        @depenses = @depenses_non_paginees.paginate(:page => @page, :per_page =>@per_page)  
      end

    when 'toutes_depenses_hors_salaires'
     
      def depense_request(depense_table_name)
        facture_table_name = depense_table_name.chop+'_factures'
        
        @filter_req = ""
        if !@annee.blank?
          @annee = '%'+@annee+'%'
          @filter_req+= " AND d.date_commande like '"+@annee+"'"
        end
        if !@reference.blank?
          @reference = '%'+@reference+'%'  
          @filter_req+= " AND d.reference like '"+@reference+"'"
        end
        if !@compte_budgetaire.blank?
          @compte_budgetaire = '%'+@compte_budgetaire+'%'  
          @filter_req+= " AND d.compte_budgetaire like '"+@compte_budgetaire+"'"
        end
        if !@code_analytique.blank?
          @code_analytique = '%'+@code_analytique+'%'  
          @filter_req+= " AND d.code_analytique like '"+@code_analytique+"'"
        end
        if !@intitule.blank?
          @intitule = '%'+@intitule+'%'
          @filter_req+= " AND d.intitule like '"+@intitule  +"'"
        end
        if !@millesime.blank?
          @millesime = '%'+@millesime+'%' unless @millesime.blank?  
          @filter_req+= " AND ( d.millesime LIKE '"+@millesime+"' OR f.millesime LIKE '"+@millesime+"' ) "  
        end
         
        if @type_depense == "depenses_soldees"
          @soldee = '1'
          @filter_req=" AND d.commande_solde = '"+@soldee+"'"
        elsif @type_depense == "depenses_non_soldees"
          @soldee = '0'
          @filter_req=" AND d.commande_solde = '"+@soldee+"'"
        else
          @soldee = '%'
        end
          
        req ="SELECT d.id,d.ligne_id,d.intitule,d.reference,d.compte_budgetaire,d.code_analytique,d.date_commande,d.montant_engage,d.commande_solde,d.montant_paye,d.millesime,d.verif,d.verrou"
        req_facture =" ,f.id,f.#{depense_table_name.chop}_id,f.date,f.date_mandatement,f.rubrique_comptable_id,f.numero_facture, f.millesime,f.numero_mandat,f.montant_htr,f.cout_ht,f.cout_ttc, r.numero_rubrique"
        if depense_table_name == 'depense_missions'
          req +=',d.agent'
          req_facture += ",f.fournisseur"
        else
          req+=',d.fournisseur'  
        end
                
        # FIXME: refactor with prepare_depenses()
        if @ref_cp.blank?
          req += " FROM #{depense_table_name} d"
          if !@millesime.blank?       
            req += " LEFT OUTER JOIN #{facture_table_name} f ON d.id = f.#{depense_table_name.chop}_id  "        
          end
          [req+" WHERE d.ligne_id IN (?) "+@filter_req,@filtered_lignes_id]
        else
          @ref_cp = '%'+@ref_cp+'%'
          @filter_req += " AND r.numero_rubrique like '"+@ref_cp+"'"
          req += req_facture + " FROM #{facture_table_name} f"
          req += " LEFT OUTER JOIN #{depense_table_name} d ON d.id = f.#{depense_table_name.chop}_id"
          req += " LEFT OUTER JOIN rubrique_comptables r ON f.rubrique_comptable_id = r.id"
          [req+" WHERE d.ligne_id IN (?) "+@filter_req,@filtered_lignes_id]
        end
      end

      if @ref_cp.blank?
        depenses_fonctionnement = DepenseFonctionnement.find_by_sql(depense_request('depense_fonctionnements'))
        depenses_equipement = DepenseEquipement.find_by_sql(depense_request('depense_equipements'))
        depenses_mission = DepenseMission.find_by_sql(depense_request('depense_missions'))
        depenses_non_ventilees = DepenseNonVentilee.find_by_sql(depense_request('depense_non_ventilees'))
      else
        depenses_fonctionnement = DepenseFonctionnementFacture.find_by_sql(depense_request('depense_fonctionnements'))
        depenses_equipement = DepenseEquipementFacture.find_by_sql(depense_request('depense_equipements'))
        depenses_mission = DepenseMissionFacture.find_by_sql(depense_request('depense_missions'))
        depenses_non_ventilees = DepenseNonVentileeFacture.find_by_sql(depense_request('depense_non_ventilees'))
      end
      depenses_fonctionnement.uniq!
      depenses_equipement.uniq!
      depenses_mission.uniq!
      depenses_non_ventilees.uniq!
      @depenses_non_paginees = depenses_fonctionnement + depenses_equipement +
        depenses_mission + depenses_non_ventilees

      if @compute_totaux_globaux
        @depenses = @depenses_non_paginees
      else
        
        if type_montant_facture
          @depenses_non_paginees.sort! {|a,b|
            a.montant_paye(type_montant_facture) <=> b.montant_paye(type_montant_facture)}
        elsif @order_value == "montant_engage"
          @depenses_non_paginees.sort! {|a,b| a.montant_engage <=> b.montant_engage}
        elsif @order_value == "date_commande"
          @depenses_non_paginees.sort! {|a,b| a.date_commande <=> b.date_commande}
        elsif @order_value == "intitule"
          @depenses_non_paginees.sort! {|a,b| a.intitule.casecmp(b.intitule)}
        elsif @order_value == "reference"
          @depenses_non_paginees.sort! {|a,b| a.reference.casecmp(b.reference)}
        elsif @order_value == "compte_budgetaire"
          @depenses_non_paginees.sort! {|a,b| a.compte_budgetaire.casecmp(b.compte_budgetaire)}
        elsif @order_value == "code_analytique"
          @depenses_non_paginees.sort! {|a,b| a.code_analytique.casecmp(b.code_analytique)}
        elsif  @order_value == "date"  # date de facture
          @depenses_non_paginees.sort! {|a,b| a.date <=> b.date}
        elsif  @order_value == "numero_facture" 
          @depenses_non_paginees.sort! {|a,b| a.numero_facture.casecmp(b.numero_facture)}
        elsif  @order_value == "date_mandatement" 
          @depenses_non_paginees.sort! {|a,b| (a.date_mandatement.nil? ? '1900-01-01'.to_date : a.date_mandatement) <=> (b.date_mandatement.nil? ? '1900-01-01'.to_date : b.date_mandatement)}
        elsif  @order_value == "numero_mandat" 
          @depenses_non_paginees.sort! {|a,b| a.numero_mandat.casecmp(b.numero_mandat)}
        elsif  @order_value == "numero_rubrique" 
          @depenses_non_paginees.sort! {|a,b| a.numero_rubrique.casecmp(b.numero_rubrique)}
        elsif  @order_value == "montant_htr" # montant facture
          @depenses_non_paginees.sort! {|a,b| a.montant_htr <=> b.montant_htr}
        elsif  @order_value == "cout_ht" # cout facture
          @depenses_non_paginees.sort! {|a,b| a.cout_ht <=> b.cout_ht}
        elsif  @order_value == "cout_ttc" # cout_facture
          @depenses_non_paginees.sort! {|a,b| a.cout_ttc <=> b.cout_ttc}
        elsif @order_value == "fournisseur"
          @depenses_non_paginees.sort! {|a,b| (a.respond_to?(:fournisseur) ? a.fournisseur : '') <=> (b.respond_to?(:fournisseur) ? b.fournisseur : '') }
        elsif @order_value == "agent"
          @depenses_non_paginees.sort! {|a,b| (a.respond_to?(:agent) ? a.agent : '') <=> (b.respond_to?(:agent) ? b.agent : '') }
        else
          # NOOP
        end

        @depenses_non_paginees.reverse! if @order_type != "asc"
        @depenses = @depenses_non_paginees.paginate(:page => @page, :per_page =>@per_page)
      end

    else
      throw 'Unknown depense type'
    end
     
  end

  def prepare_depenses(include, filters, order)
    depense_table_name = "depense_#{params['data']}s"
    depense_class = Object.const_get(depense_table_name.classify)
    facture_table_name = depense_table_name.chop+'_factures'
    facture_class = Object.const_get(facture_table_name.classify)

    # add millesime filter
    conditions = filters.conditions
    if !@millesime.blank?
      conditions_literals = conditions.shift
      conditions_literals += " AND ( #{depense_table_name}.millesime LIKE ? \
      OR #{facture_table_name}.millesime LIKE ? )"
      conditions << "%#{@millesime}%" << "%#{@millesime}%"
      conditions.unshift conditions_literals
    end

    if @ref_cp.blank?
      include.unshift facture_table_name.to_sym unless include.include?("#{facture_table_name}")
      depenses = nil
      if @compute_totaux_globaux
        depenses = depense_class.find(:all,:include=>include,:conditions => conditions)
      
      elsif @order_value =~ /montant_paye_(ttc|htr|ht?)/
        depenses = depense_class.find(:all, :include => include, :conditions => conditions)
        depenses.sort! {|a,b| a.montant_paye($1) <=> b.montant_paye($1)}
        depenses.reverse! if @order_type != "asc"
        depenses = depenses.paginate(:page => @page, :per_page => @per_page)
  
      else
        depenses = depense_class.paginate(:include => include,
                      :conditions => conditions, :order => order,
                      :page => @page, :per_page => @per_page)
      end
    # si une référence comptable a été sélectionnée, on affiche une facture /ligne et non plus une depense /ligne
    else
      include = []
      include << :rubrique_comptable
      include << {"#{depense_table_name}".chop.to_sym => :ligne}
      depenses = nil
      if @compute_totaux_globaux
        depenses = facture_class.find(:all,:include=>include,:conditions => conditions)
        
      else
        depenses = facture_class.paginate(:include => include,
              :conditions => conditions, :order => order,
              :page => @page, :per_page => @per_page)
      end
    end
  end

  def calcul_bilan(year)
    @datas["#{year.to_s}"]=[]
    @totaux["#{year.to_s}"] = Hash.new

    date_debut = Date.new(year,01,01)
    date_fin = Date.new(year,12,31)

    for ligne in @filtered_lignes
      if year != 0
        if ligne.date_debut <= date_fin and ligne.date_fin_selection >= date_debut
          @current_date_start = date_debut.to_s
          @date_start = date_debut
          if ligne.date_fin_selection < date_fin
            @current_date_end =  ligne.date_fin_selection.to_s
            @date_end   = ligne.date_fin_selection
          else
            @current_date_end = date_fin.to_s
            @date_end = date_fin
          end
        else
          next
        end
      else
        @current_date_start = date_debut.to_s
        @current_date_end =  ligne.date_fin_selection.to_s
        @date_start = date_debut
        @date_end   = ligne.date_fin_selection
      end
      @total_day  = @date_end - @date_start

      #calcul des versements et dépenses totaux pour une ligne:
      total_depenses_commun_ligne = ligne.depense_communs.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',@type_bilan,@type_montant) }
      total_depenses_equipement_ligne = ligne.depense_equipements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',@type_bilan,@type_montant) }
      total_depenses_fonctionnement_ligne = ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',@type_bilan,@type_montant) }
      total_depenses_mission_ligne = ligne.depense_missions.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',@type_bilan,@type_montant) }
      total_depenses_salaire_ligne = ligne.depense_salaires.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',@type_bilan,@type_montant) }
      total_depenses_non_ventile_ligne = ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',@type_bilan,@type_montant) }
      total_depenses_ligne = total_depenses_commun_ligne + total_depenses_fonctionnement_ligne + total_depenses_equipement_ligne + total_depenses_mission_ligne + total_depenses_salaire_ligne + total_depenses_non_ventile_ligne
      total_versements_ligne = ligne.versements.find(:all).sum{ |d| d.montant }

      if (ligne.sous_contrat.sous_contrat_notification)
        total_a_ouvrir = ligne.sous_contrat.sous_contrat_notification.ma_total - ligne.sous_contrat.sous_contrat_notification.ma_frais_gestion_mutualises - ligne.sous_contrat.sous_contrat_notification.ma_frais_gestion_mutualises_local
      else
        total_a_ouvrir = ligne.contrat.notification.ma_total - ligne.contrat.notification.ma_frais_gestion_mutualises - ligne.contrat.notification.ma_frais_gestion_mutualises_local
      end

      reste_a_ouvrir = total_a_ouvrir - total_versements_ligne
      
      if @type_bilan != "sommes_engagees"
        total_depenses_commun_ligne_engagees = ligne.depense_communs.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01',"sommes_engagees", @type_montant)  }
        total_depenses_equipement_ligne_engagees = ligne.depense_equipements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', "sommes_engagees", @type_montant) }
        total_depenses_fonctionnement_ligne_engagees = ligne.depense_fonctionnements.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', "sommes_engagees", @type_montant) }
        total_depenses_mission_ligne_engagees = ligne.depense_missions.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', "sommes_engagees", @type_montant) }
        total_depenses_salaire_ligne_engagees = ligne.depense_salaires.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', "sommes_engagees", @type_montant) }
        total_depenses_non_ventile_ligne_engagees = ligne.depense_non_ventilees.find(:all).sum{ |d| d.montant('1900-01-01', '4000-01-01', "sommes_engagees", @type_montant) }   
        total_depense_fem_engagees = total_depenses_equipement_ligne_engagees + total_depenses_fonctionnement_ligne_engagees + total_depenses_mission_ligne_engagees
        total_depenses_ligne_engagees = total_depenses_commun_ligne_engagees + total_depenses_fonctionnement_ligne_engagees + total_depenses_equipement_ligne_engagees + total_depenses_mission_ligne_engagees + total_depenses_salaire_ligne_engagees + total_depenses_non_ventile_ligne_engagees

        reste_a_depenser = total_a_ouvrir - total_depenses_ligne_engagees
      else
        reste_a_depenser = total_a_ouvrir - total_depenses_ligne
      end
      

      @condition = "(( date_effet >= '"+@current_date_start+"') && ( date_effet <= '"+@current_date_end+"'))"
      somme_versements_commun  = 0
      somme_versements_fonctionnement  = ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Fonctionnement')").sum{ |d| d.montant }
      somme_versements_equipement      = ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Equipement')").sum{ |d| d.montant }
      somme_versements_mission         = ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Mission')").sum{ |d| d.montant }
      somme_versements_fem             = somme_versements_fonctionnement + somme_versements_equipement + somme_versements_mission
      somme_versements_salaire         = ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Salaire')").sum{ |d| d.montant }
      somme_versements_non_ventile     = ligne.versements.find(:all, :conditions => @condition+" AND (ventilation = 'Non ventilé')").sum{ |d| d.montant }
      total_versements = somme_versements_commun + somme_versements_fonctionnement + somme_versements_equipement + somme_versements_mission + somme_versements_salaire + somme_versements_non_ventile

      @condition = " (( date_max >= '"+@current_date_start+"') && ( date_min <= '"+@current_date_end+"'))"
      somme_depense_commun         = ligne.depense_communs.find(:all, :conditions => @condition).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan,@type_montant) }
      somme_depense_fonctionnement = ligne.depense_fonctionnements.find(:all, :conditions => @condition).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan,@type_montant) }
      somme_depense_equipement     = ligne.depense_equipements.find(:all, :conditions => @condition).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan,@type_montant) }
      somme_depense_mission        = ligne.depense_missions.find(:all, :conditions => @condition).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan,@type_montant) }
      somme_depense_fem            = somme_depense_fonctionnement + somme_depense_equipement + somme_depense_mission
      somme_depense_salaire        = ligne.depense_salaires.find(:all, :conditions => @condition).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan,@type_montant) }
      somme_depense_non_ventilee   = ligne.depense_non_ventilees.find(:all, :conditions => @condition).sum{ |d| d.montant(@current_date_start, @current_date_end, @type_bilan,@type_montant) }
      total_depenses = somme_depense_commun + somme_depense_fonctionnement + somme_depense_equipement + somme_depense_mission + somme_depense_salaire + somme_depense_non_ventilee

      total_fonctionnement = somme_versements_fonctionnement - somme_depense_fonctionnement
      if !@totaux.has_key?("#{ligne.id}")
        @totaux["#{ligne.id}"] = {"total_fonctionnement" => somme_versements_fonctionnement - somme_depense_fonctionnement}
      else
        @totaux["#{ligne.id}"]["total_fonctionnement"] = (somme_versements_fonctionnement - somme_depense_fonctionnement)
      end
      total_equipement     = somme_versements_equipement - somme_depense_equipement
      if !@totaux["#{ligne.id}"].has_key?("total_equipement")
        @totaux["#{ligne.id}"]["total_equipement"] = somme_versements_equipement - somme_depense_equipement
      else
        @totaux["#{ligne.id}"]["total_equipement"] = (somme_versements_equipement - somme_depense_equipement)
      end
      total_mission        = somme_versements_mission - somme_depense_mission
      if !@totaux["#{ligne.id}"].has_key?("total_mission")
        @totaux["#{ligne.id}"]["total_mission"] = somme_versements_mission - somme_depense_mission
      else
        @totaux["#{ligne.id}"]["total_mission"] = (somme_versements_mission - somme_depense_mission)
      end
      total_fem        = somme_versements_fem - somme_depense_fem
      if !@totaux["#{ligne.id}"].has_key?("total_fem")
        @totaux["#{ligne.id}"]["total_fem"] = somme_versements_fem - somme_depense_fem
      else
        @totaux["#{ligne.id}"]["total_fem"] = (somme_versements_fem - somme_depense_fem)
      end
      total_salaire        = somme_versements_salaire - somme_depense_salaire
      if !@totaux["#{ligne.id}"].has_key?("total_salaire")
        @totaux["#{ligne.id}"]["total_salaire"] = somme_versements_salaire - somme_depense_salaire
      else
        @totaux["#{ligne.id}"]["total_salaire"] = (somme_versements_salaire - somme_depense_salaire)
      end
      total_non_ventilee   = somme_versements_non_ventile - somme_depense_non_ventilee
      if !@totaux["#{ligne.id}"].has_key?("total_non_ventilee")
        @totaux["#{ligne.id}"]["total_non_ventilee"] = somme_versements_non_ventile - somme_depense_non_ventilee
      else
        @totaux["#{ligne.id}"]["total_non_ventilee"] = (somme_versements_non_ventile - somme_depense_non_ventilee)
      end
      total                = total_versements - total_depenses
      if !@totaux["#{ligne.id}"].has_key?("total")
        @totaux["#{ligne.id}"]["total"] = total_versements - total_depenses
      else
        @totaux["#{ligne.id}"]["total"] = (total_versements - total_depenses)
      end

      @datas["#{year}"] << { "ligne_id" => ligne.id,
                    "ligne_nom" => ligne.nom,
                    "association" => ligne.sous_contrat.entite_id,
                    "date_debut" => ligne.sous_contrat.contrat.notification.date_debut,
                    "date_fin" => ligne.date_fin_selection,
                    "ligne_organisme_gestionnaire_nom" => ligne.organisme_gestionnaire.nom,
                    "somme_versements_fonctionnement" => somme_versements_fonctionnement,
                    "somme_versements_equipement" => somme_versements_equipement,
                    "somme_versements_mission" => somme_versements_mission,
                    "somme_versements_fem" => somme_versements_fem,
                    "somme_versements_salaire" => somme_versements_salaire,
                    "somme_versements_non_ventile" => somme_versements_non_ventile,
                    "total_versements" => total_versements,
                    "somme_depense_commun" => somme_depense_commun,
                    "somme_depense_fonctionnement" => somme_depense_fonctionnement,
                    "somme_depense_equipement" => somme_depense_equipement,
                    "somme_depense_mission" => somme_depense_mission,
                    "somme_depense_fem" => somme_depense_fem,
                    "somme_depense_salaire" => somme_depense_salaire,
                    "somme_depense_non_ventilee" => somme_depense_non_ventilee,
                    "total_depenses" => total_depenses,
                    "total_fonctionnement" => @totaux["#{ligne.id}"]["total_fonctionnement"],
                    "total_equipement" => @totaux["#{ligne.id}"]["total_equipement"],
                    "total_mission" => @totaux["#{ligne.id}"]["total_mission"],
                    "total_fem" => @totaux["#{ligne.id}"]["total_fem"],
                    "total_salaire" => @totaux["#{ligne.id}"]["total_salaire"],
                    "total_non_ventilee" => @totaux["#{ligne.id}"]["total_non_ventilee"],
                    "total" => @totaux["#{ligne.id}"]["total"],
                    "notification_total" => total_a_ouvrir,
                    "reste_a_ouvrir" => reste_a_ouvrir,
                    "reste_a_depenser" => reste_a_depenser
      }

      @somme_versements_fonctionnement += somme_versements_fonctionnement
      if @totaux["#{year}"].has_key?("somme_versements_fonctionnement")
        @totaux["#{year}"]["somme_versements_fonctionnement"] += somme_versements_fonctionnement
      else
        @totaux["#{year}"]["somme_versements_fonctionnement"] = somme_versements_fonctionnement
      end
      @somme_versements_equipement += somme_versements_equipement
      if @totaux["#{year}"].has_key?("somme_versements_equipement")
        @totaux["#{year}"]["somme_versements_equipement"] += somme_versements_equipement
      else
        @totaux["#{year}"]["somme_versements_equipement"] = somme_versements_equipement
      end
      @somme_versements_mission += somme_versements_mission
      if @totaux["#{year}"].has_key?("somme_versements_mission")
        @totaux["#{year}"]["somme_versements_mission"] += somme_versements_mission
      else
        @totaux["#{year}"]["somme_versements_mission"] = somme_versements_mission
      end
      @somme_versements_fem += somme_versements_fem
      if @totaux["#{year}"].has_key?("somme_versements_fem")
        @totaux["#{year}"]["somme_versements_fem"] += somme_versements_fem
      else
        @totaux["#{year}"]["somme_versements_fem"] = somme_versements_fem
      end
      @somme_versements_salaire += somme_versements_salaire
      if @totaux["#{year}"].has_key?("somme_versements_salaire")
        @totaux["#{year}"]["somme_versements_salaire"] += somme_versements_salaire
      else
        @totaux["#{year}"]["somme_versements_salaire"] = somme_versements_salaire
      end
      @somme_versements_non_ventile += somme_versements_non_ventile
      if @totaux["#{year}"].has_key?("somme_versements_non_ventile")
        @totaux["#{year}"]["somme_versements_non_ventile"] += somme_versements_non_ventile
      else
        @totaux["#{year}"]["somme_versements_non_ventile"] = somme_versements_non_ventile
      end
      @total_versements += total_versements
      if @totaux["#{year}"].has_key?("total_versements")
        @totaux["#{year}"]["total_versements"] += total_versements
      else
        @totaux["#{year}"]["total_versements"] = total_versements
      end

      @somme_depense_commun += somme_depense_commun
      if @totaux["#{year}"].has_key?("somme_depense_commun")
        @totaux["#{year}"]["somme_depense_commun"] += somme_depense_commun
      else
        @totaux["#{year}"]["somme_depense_commun"] = somme_depense_commun
      end
      @somme_depense_fonctionnement += somme_depense_fonctionnement
      if @totaux["#{year}"].has_key?("somme_depense_fonctionnement")
        @totaux["#{year}"]["somme_depense_fonctionnement"] += somme_depense_fonctionnement
      else
        @totaux["#{year}"]["somme_depense_fonctionnement"] = somme_depense_fonctionnement
      end
      @somme_depense_equipement += somme_depense_equipement
      if @totaux["#{year}"].has_key?("somme_depense_equipement")
        @totaux["#{year}"]["somme_depense_equipement"] += somme_depense_equipement
      else
        @totaux["#{year}"]["somme_depense_equipement"] = somme_depense_equipement
      end
      @somme_depense_mission += somme_depense_mission
      if @totaux["#{year}"].has_key?("somme_depense_mission")
        @totaux["#{year}"]["somme_depense_mission"] += somme_depense_mission
      else
        @totaux["#{year}"]["somme_depense_mission"] = somme_depense_mission
      end
      @somme_depense_fem += somme_depense_fem
      if @totaux["#{year}"].has_key?("somme_depense_fem")
        @totaux["#{year}"]["somme_depense_fem"] += somme_depense_fem
      else
        @totaux["#{year}"]["somme_depense_fem"] = somme_depense_fem
      end
      @somme_depense_salaire += somme_depense_salaire
      if @totaux["#{year}"].has_key?("somme_depense_salaire")
        @totaux["#{year}"]["somme_depense_salaire"] += somme_depense_salaire
      else
        @totaux["#{year}"]["somme_depense_salaire"] = somme_depense_salaire
      end
      @somme_depense_non_ventilee += somme_depense_non_ventilee
      if @totaux["#{year}"].has_key?("somme_depense_non_ventilee")
        @totaux["#{year}"]["somme_depense_non_ventilee"] += somme_depense_non_ventilee
      else
        @totaux["#{year}"]["somme_depense_non_ventilee"] = somme_depense_non_ventilee
      end
      @total_depenses += total_depenses
      if @totaux["#{year}"].has_key?("total_depenses")
        @totaux["#{year}"]["total_depenses"] += total_depenses
      else
        @totaux["#{year}"]["total_depenses"] = total_depenses
      end

      @total_fonctionnement += total_fonctionnement
      if @totaux["#{year}"].has_key?("total_fonctionnement")
        @totaux["#{year}"]["total_fonctionnement"] += total_fonctionnement
      else
        @totaux["#{year}"]["total_fonctionnement"] = total_fonctionnement
      end
      @total_equipement += total_equipement
      if @totaux["#{year}"].has_key?("total_equipement")
        @totaux["#{year}"]["total_equipement"] += total_equipement
      else
        @totaux["#{year}"]["total_equipement"] = total_equipement
      end
      @total_mission += total_mission
      if @totaux["#{year}"].has_key?("total_mission")
        @totaux["#{year}"]["total_mission"] += total_mission
      else
        @totaux["#{year}"]["total_mission"] = total_mission
      end
      @total_fem += total_fem
      if @totaux["#{year}"].has_key?("total_fem")
        @totaux["#{year}"]["total_fem"] += total_fem
      else
        @totaux["#{year}"]["total_fem"] = total_fem
      end
      @total_salaire += total_salaire
      if @totaux["#{year}"].has_key?("total_salaire")
        @totaux["#{year}"]["total_salaire"] += total_salaire
      else
        @totaux["#{year}"]["total_salaire"] = total_salaire
      end
      @total_non_ventilee += total_non_ventilee
      if @totaux["#{year}"].has_key?("total_non_ventilee")
        @totaux["#{year}"]["total_non_ventilee"] += total_non_ventilee
      else
        @totaux["#{year}"]["total_non_ventilee"] = total_non_ventilee
      end
      @total += total
      if @totaux["#{year}"].has_key?("total")
        @totaux["#{year}"]["total"] += total
      else
        @totaux["#{year}"]["total"] = total
      end

    end
  end
  
  def export_bilan_csv
    if params[:csv] == 'utf16'
      codingTranslation = Iconv.new('WINDOWS-1252','UTF-8')
    else
      codingTranslation = Iconv.new('UTF-8','UTF-8')
    end
    options = {:row_sep => "\r\n", :col_sep => ";"}
    type_montant = "Montants"
    case @type_montant.to_s
      when "htr" then type_montant   = "Montants HTR"
      when "ht" then type_montant = "Montants HT"
      when "ttc" then type_montant  = "Montants TTC"
    end
    csv_string = CSV.generate(options) do |csv|
      if @datas.size ==0
        csv << ['Aucune donnee selectionnee!']
      elsif @datas.size ==1     
        @datas.each { |year,datas|
          if year != '0'
            csv_ligne = [type_montant,"Annee "+year]
          else
            csv_ligne = [type_montant,"Pour l'ensemble des annees"]  
          end  
          csv << csv_ligne
          if params['type_affichage'] != 'contrat_dotation'
            csv << ['','','','Fonctionnement','Equipement','Mission','Sous-Total FEM','Salaire','Non ventile','Total']
          else
            csv << ['','','','Montant']
          end
          datas.each do |data|
            csv << [codingTranslation.iconv(data['ligne_nom'])]
            csv << [codingTranslation.iconv(data['ligne_organisme_gestionnaire_nom'])]
            if params['type_affichage'] != 'contrat_dotation'
              csv << ['Montant initial',data['notification_total'],'Credits',data['somme_versements_fonctionnement'],data['somme_versements_equipement'],data['somme_versements_mission'],data['somme_versements_fem'],data['somme_versements_salaire'],data['somme_versements_non_ventile'],data['total_versements']]  
              csv << ['Reste a ouvrir',data['reste_a_ouvrir'],'Depenses',data['somme_depense_fonctionnement'] * -1,data['somme_depense_equipement'] * -1,data['somme_depense_mission'] * -1,data['somme_depense_fem'] * -1,data['somme_depense_salaire'] * -1,data['somme_depense_non_ventilee']  * -1,data['total_depenses'] * -1]
              csv << ['Reste a engager',data['reste_a_depenser'],'Total',data["total_fonctionnement"],data["total_equipement"],data["total_mission"],data["total_fem"],data["total_salaire"],data["total_non_ventilee"],data["total"]]
            else
              csv << ['Montant initial',data['notification_total'],'Credits',data['total_versements']]  
              csv << ['Reste a ouvrir',data['reste_a_ouvrir'],'Depenses',data['total_depenses'] * -1]
              csv << ['Reste a engager',data['reste_a_depenser'],'Total',data["total"]]            
            end
            csv << ["du "+date_to_csv(data['date_debut'])+" au "+date_to_csv(data['date_fin'])]            
            csv << ['']
          end
        }
        csv << ['']
        if params['type_affichage'] != 'contrat_dotation'
          csv << ['','','Bilan Total','Fonctionnement','Equipement','Mission','Sous-Total FEM','Salaire','Non ventile','Total']
          csv << ['','','Credit',@somme_versements_fonctionnement,@somme_versements_equipement,@somme_versements_mission,@somme_versements_fem,@somme_versements_salaire,@somme_versements_non_ventile,@total_versements]
          csv << ['','','Depense',(@somme_depense_fonctionnement * -1),(@somme_depense_equipement * -1),(@somme_depense_mission * -1),(@somme_depense_fem * -1),(@somme_depense_salaire * -1),(@somme_depense_non_ventilee * -1),(@total_depenses * -1)]
          csv << ['','','Total',@total_fonctionnement,@total_equipement,@total_mission,@total_fem,@total_salaire,@total_non_ventilee,@total]
          csv << ['','','Reste a ouvrir',@reste_a_ouvrir_fonctionnement,@reste_a_ouvrir_equipement,@reste_a_ouvrir_mission,@reste_a_ouvrir_fem,@reste_a_ouvrir_salaire,@reste_a_ouvrir_non_ventilee,@reste_a_ouvrir_total]
          csv << ['','','Reste a engager',@reste_a_depenser_fonctionnement,@reste_a_depenser_equipement,@reste_a_depenser_mission,@reste_a_depenser_fem,@reste_a_depenser_salaire,@reste_a_depenser_non_ventilee,@reste_a_depenser_total]
        else
          csv << ['','','Bilan Total']
          csv << ['','','Credit',@total_versements]
          csv << ['','','Depense',(@total_depenses * -1)]
          csv << ['','','Total',@total]
          csv << ['','','Reste a ouvrir',@reste_a_ouvrir_total]
          csv << ['','','Reste a engager',@reste_a_depenser_total]
        end
      else
        csv_ligne = [type_montant]
        csv << csv_ligne  
        
        ligne_array = []
        ligne_array << ''
        ligne_legend = []
        ligne_legend << ''
        for ligne in @filtered_lignes
          ligne_array << ligne.nom
          ligne_array << 'Du '+ date_to_csv(ligne.date_debut) + ' au '+ date_to_csv(ligne.date_fin)

          if params['type_affichage'] != 'contrat_dotation'
            for i in 1..6 do
              ligne_array << ''
            end
            
            ligne_legend << 'Fonctionnement'
            ligne_legend << 'Equipement'
            ligne_legend << 'Mission'
            ligne_legend << 'Sous-Total FEM'
            ligne_legend << 'Salaire'
            ligne_legend << 'Non ventile'
            ligne_legend << 'Total'
          else
            ligne_array << ''
            ligne_array << ''
            ligne_legend << 'Montant'
          end
          ligne_legend << ''
        end
        
        ligne_array << 'Total'
        if params['type_affichage'] != 'contrat_dotation'
          ligne_legend << 'Fonctionnement'
          ligne_legend << 'Equipement'
          ligne_legend << 'Mission'
          ligne_legend << 'Sous-Total FEM'
          ligne_legend << 'Salaire'
          ligne_legend << 'Non ventile'
          ligne_legend << 'Total'
          ligne_legend << ''
        else
          ligne_legend << 'Montant'
        end
        csv << ligne_array
        csv << ligne_legend
        @datas.each { |year,datas|
          total_tab = ['Total']
          credit_tab = ['Credit']
          depense_tab = ['Depense']
          if @bilan_detail == 'detail'
            csv << ['Pour la periode du '+date_to_csv(Date.new(year.to_i,01,01))+' au '+date_to_csv(Date.new(year.to_i,12,31))]
          end
          datas.each do |data|
            index = ligne_array.index(data['ligne_nom'])
            if params['type_affichage'] != 'contrat_dotation'
              credit_tab[index] = data['somme_versements_fonctionnement']
              credit_tab[index+1] = data['somme_versements_equipement']
              credit_tab[index+2] = data['somme_versements_mission']
              credit_tab[index+3] = data['somme_versements_fem']
              credit_tab[index+4] = data['somme_versements_salaire']
              credit_tab[index+5] = data['somme_versements_non_ventile']
              credit_tab[index+6] = data['total_versements']
              depense_tab[index]= data['somme_depense_fonctionnement'] * -1
              depense_tab[index+1]= data['somme_depense_equipement'] * -1
              depense_tab[index+2]= data['somme_depense_mission'] * -1
              depense_tab[index+3]= data['somme_depense_fem'] * -1 
              depense_tab[index+4]= data['somme_depense_salaire'] * -1
              depense_tab[index+5]= data['somme_depense_non_ventilee']  * -1
              depense_tab[index+6]= data['total_depenses'] * -1
              total_tab[index]=data["total_fonctionnement"]
              total_tab[index+1]=data["total_equipement"]
              total_tab[index+2]=data["total_mission"]
              total_tab[index+3]=data["total_fem"]
              total_tab[index+4]=data["total_salaire"]
              total_tab[index+5]=data["total_non_ventilee"]
              total_tab[index+6]=data['total']
            else
              credit_tab[index] = data['total_versements']
              depense_tab[index] = data['total_depenses'] * -1
              total_tab[index] = data['total']
            end
          end
          if params['type_affichage'] != 'contrat_dotation'
            credit_tab[ligne_array.index('Total')] = @totaux[year]["somme_versements_fonctionnement"]
            credit_tab[ligne_array.index('Total')+1] = @totaux[year]["somme_versements_equipement"]
            credit_tab[ligne_array.index('Total')+2] = @totaux[year]["somme_versements_mission"]
            credit_tab[ligne_array.index('Total')+3] = @totaux[year]["somme_versements_fem"]
            credit_tab[ligne_array.index('Total')+4] = @totaux[year]["somme_versements_salaire"]
            credit_tab[ligne_array.index('Total')+5] = @totaux[year]["somme_versements_non_ventile"]
            credit_tab[ligne_array.index('Total')+6] = @totaux[year]["total_versements"]
            depense_tab[ligne_array.index('Total')]= @totaux[year]["somme_depense_fonctionnement"] * -1
            depense_tab[ligne_array.index('Total')+1]= @totaux[year]['somme_depense_equipement'] * -1
            depense_tab[ligne_array.index('Total')+2]= @totaux[year]['somme_depense_mission'] * -1
            depense_tab[ligne_array.index('Total')+3]= @totaux[year]['somme_depense_fem'] * -1 
            depense_tab[ligne_array.index('Total')+4]= @totaux[year]['somme_depense_salaire'] * -1
            depense_tab[ligne_array.index('Total')+5]= @totaux[year]['somme_depense_non_ventilee']  * -1
            depense_tab[ligne_array.index('Total')+6]= @totaux[year]['total_depenses'] * -1
            total_tab[ligne_array.index('Total')]=@totaux[year]["total_fonctionnement"]
            total_tab[ligne_array.index('Total')+1]=@totaux[year]["total_equipement"]
            total_tab[ligne_array.index('Total')+2]=@totaux[year]["total_mission"]
            total_tab[ligne_array.index('Total')+3]=@totaux[year]["total_fem"]
            total_tab[ligne_array.index('Total')+4]=@totaux[year]["total_salaire"]
            total_tab[ligne_array.index('Total')+5]=@totaux[year]["total_non_ventilee"]
            total_tab[ligne_array.index('Total')+6]=@totaux[year]['total']
          else
            credit_tab[ligne_array.index('Total')] = @totaux[year]["total_versements"]
            depense_tab[ligne_array.index('Total')] = @totaux[year]['total_depenses'] * -1
            total_tab[ligne_array.index('Total')] = @totaux[year]['total']
          end
          csv << credit_tab
          csv << depense_tab
          csv << total_tab
        }
        csv << ['']
        if params['type_affichage'] != 'contrat_dotation'
          csv << ['Bilan Total','Fonctionnement','Equipement','Mission','Sous-Total FEM','Salaire','Non ventile','Total']
          csv << ['Credit',@somme_versements_fonctionnement,@somme_versements_equipement,@somme_versements_mission,@somme_versements_fem,@somme_versements_salaire,@somme_versements_non_ventile,@total_versements]
          csv << ['Depense',(@somme_depense_fonctionnement * -1),(@somme_depense_equipement * -1),(@somme_depense_mission * -1),(@somme_depense_fem * -1),(@somme_depense_salaire * -1),(@somme_depense_non_ventilee * -1),(@total_depenses * -1)]
          csv << ['Total',@total_fonctionnement,@total_equipement,@total_mission,@total_fem,@total_salaire,@total_non_ventilee,@total]
          csv << ['Reste a ouvrir',@reste_a_ouvrir_fonctionnement,@reste_a_ouvrir_equipement,@reste_a_ouvrir_mission,@reste_a_ouvrir_fem,@reste_a_ouvrir_salaire,@reste_a_ouvrir_non_ventilee,@reste_a_ouvrir_total]
          csv << ['Reste a engager',@reste_a_depenser_fonctionnement,@reste_a_depenser_equipement,@reste_a_depenser_mission,@reste_a_depenser_fem,@reste_a_depenser_salaire,@reste_a_depenser_non_ventilee,@reste_a_depenser_total]
        else
          csv << ['Bilan Total']
          csv << ['Credit',@total_versements]
          csv << ['Depense',(@total_depenses * -1)]
          csv << ['Total',@total]
          csv << ['Reste a ouvrir',@reste_a_ouvrir_total]
          csv << ['Reste a engager',@reste_a_depenser_total]
        end
      end
      
    end
    send_data csv_string, :type => 'text/csv',
                          :disposition => "attachment; filename=export_osc.csv" 
  end

end
