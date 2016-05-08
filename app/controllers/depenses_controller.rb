#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepensesController < ApplicationController

  def export_csv(depenses,data)
    if params[:encode] == 'utf16'
      codingTranslation = Iconv.new('WINDOWS-1252','UTF-8')
    else
      codingTranslation = Iconv.new('UTF-8','UTF-8')
    end
    options = {:row_sep => "\r\n", :col_sep => ";"}
    if ['fonctionnement', 'equipement', 'non_ventilee'].include? data
      CSV.generate(options) do |csv|
        ligne = ["Commande soldée ?","Verrou", "Date de demande d'achat","Date de millesime", "N° de demande d'achat",
          "Compte Budgetaire","Code Analytique","Intitulé", "Fournisseur", "Montant Engagé", "Montant Facturé "+@type_montant,
          "Engagé/Payé "+@type_montant]
         #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne
        depenses.each do |c|
          ligne = []
          ligne << boolean_to_csv(c.commande_solde)
          ligne << c.verrou
          ligne << date_to_csv(c.date_commande)
          if(c.millesime)
            ligne << date_to_csv(c.millesime)
          else
            ligne << "non renseigne" 
          end
          ligne << codingTranslation.iconv(c.reference)
          ligne << codingTranslation.iconv(c.compte_budgetaire)
          ligne << codingTranslation.iconv(c.code_analytique)
          ligne << codingTranslation.iconv(c.intitule)
          ligne << codingTranslation.iconv(c.fournisseur)
          ligne << c.montant_engage
          ligne << c.montant_factures(@type_montant, @current_date_start, @current_date_end)
          ligne << c.montant(@current_date_start, @current_date_end, "sommes_engagees", @type_montant)
          csv << ligne        
        end
      end
    elsif data=='mission'
      CSV.generate(options) do |csv|
        ligne = ["Commande soldée ?","Verrou", "Date de demande d'achat","Date de millesime", "N° d'OM - Référence",
          "Compte Budgetaire","Code Analytique","Agent", "Date de départ", "Date de retour", "Lieux", 
          "Objet de la mission", "Montant Engagé","Montant Facturé "+@type_montant,"Engagé/Payé "+@type_montant]
        #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne
        depenses.each do |c|
          ligne = []
          ligne << boolean_to_csv(c.commande_solde)
          ligne << c.verrou
          ligne << date_to_csv(c.date_commande)
          if(c.millesime)
            ligne << date_to_csv(c.millesime)
          else
            ligne << "non renseigne" 
          end
          ligne << codingTranslation.iconv(c.reference)
          ligne << codingTranslation.iconv(c.compte_budgetaire)
          ligne << codingTranslation.iconv(c.code_analytique)
          ligne << codingTranslation.iconv(c.agent)
          ligne << date_to_csv(c.date_depart)
          ligne << date_to_csv(c.date_retour)
          ligne << codingTranslation.iconv(c.lieux)
          ligne << codingTranslation.iconv(c.intitule)
          ligne << c.montant_engage
          ligne << c.montant_factures(@type_montant, @current_date_start, @current_date_end)
          ligne << c.montant(@current_date_start, @current_date_end, "sommes_engagees", @type_montant)
          csv << ligne
        end
      end
    elsif data=='salaire'
      CSV.generate(options) do |csv|
        ligne = ["Salaire soldé ?","Verrou", "Compte Budgetaire","Code Analytique","Agent", 
          "Type de contrat","Statut", "Date de début", "Date de fin", "Nombre de mois",
          "Coût Mensuel", "Coût Période", "Montant Payé HTR", "Montant Payé"]

        #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne

        depenses.each do |c|
          ligne = []
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
          ligne << c.montant_factures('htr')
          ligne << c.montant_factures('ttc')
          csv << ligne
        end
      end
    elsif data =='commun'
      CSV.generate(options) do |csv|
        ligne = ["Commande soldée ?","Verrou", "Date de demande d'achat","Date de millesime", "N° de demande d'achat",
            "Compte Budgetaire","Code Analytique","Réf.Budg.", "Intitulé", "Fournisseur", "Montant Engagé",
            "Montant Facturé "+@type_montant,"Engagé/Payé "+@type_montant]
        #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne
        depenses.each do |c|
          ligne = []
            ligne << boolean_to_csv(c.commande_solde)
            ligne << c.verrou
            ligne << date_to_csv(c.date_commande)
            if(c.millesime)
              ligne << date_to_csv(c.millesime)
            else
              ligne << "non renseigne" 
            end
            ligne << codingTranslation.iconv(c.reference)
            ligne << codingTranslation.iconv(c.compte_budgetaire)
            ligne << codingTranslation.iconv(c.code_analytique)
            ligne << codingTranslation.iconv(c.budgetaire_reference.code)
            ligne << codingTranslation.iconv(c.intitule)
            ligne << codingTranslation.iconv(c.fournisseur)
            ligne << c.montant_engage
            ligne << c.montant_factures(@type_montant, @current_date_start, @current_date_end)
            ligne << c.montant(@current_date_start, @current_date_end, "sommes_engagees", @type_montant)
            csv << ligne
        end
      end
    elsif data =='credit'
      CSV.generate(options) do |csv|
        ligne = ["Verrou","Date d'effet", "Référence","Compte Budgetaire","Code Analytique", "Ventilation", "Origine", "Commentaire", "Montant"]
        #Conversion en UTF16 pour Excel (ms-office)
        new_ligne = []
        for l in ligne
          newl = codingTranslation.iconv(l)
          new_ligne << newl
        end
        csv << new_ligne
        depenses.each do |c|
          ligne = []
            ligne << c.verrou
            ligne << date_to_csv(c.date_effet)
            ligne << codingTranslation.iconv(c.reference)
            ligne << codingTranslation.iconv(c.compte_budgetaire)
            ligne << codingTranslation.iconv(c.code_analytique)
            ligne << codingTranslation.iconv(c.ventilation)
            ligne << codingTranslation.iconv(c.origine)
            ligne << codingTranslation.iconv(c.commentaire)
            ligne << c.montant
            csv << ligne
        end
      end
    end
  end

  def toggle_check
    if params['type_depense'] && params['id']
      klass = Object.const_get(('depense_'+params['type_depense']).classify)
      depense = klass.find(params['id'])
      if depense
        if depense.verif
          depense.verif = false
          depense.save
        else
          depense.verif = true
          depense.save
        end
      end
    end
    render :nothing => true  
  end
  
  private
  
  def setup_depenses_filter
    if !params['filter'].nil?
      @filter = params['filter']
      cookies[:depenses_filter] = @filter
    else
      if !cookies[:depenses_filter].nil?
        @filter = cookies[:depenses_filter]
      else
        @filter = 'all'
      end
    end

    case @filter
      when "all"         then @filter_condition = "1 = 1"
      when "soldees"     then @filter_condition = "commande_solde = 1"
      when "non_soldees" then @filter_condition = "commande_solde = 0"
    end
  end

  def setup_depenses_facture
    if cookies[:afficher_factures].nil?
      cookies[:afficher_factures] = 'false'
      @afficher_factures = 'false'
    end
    if !params['afficher_factures'].nil? && params['page'].nil?
      if cookies[:afficher_factures] == 'false'
        cookies[:afficher_factures] = 'true'
        @afficher_factures = 'true'
      else
        cookies[:afficher_factures] = 'false'
        @afficher_factures = 'false'
      end
    else
      @afficher_factures = cookies[:afficher_factures]
    end
  end

  def setup_depenses_dates
    @ligne = Ligne.find(params[:ligne_id])
    if !params['date_start'].nil?
      cookies['date_start_'+@ligne.id.to_s] = params['date_start'].to_s
      cookies['date_end_'+@ligne.id.to_s] = params['date_end'].to_s
      @current_date_start = params['date_start'].to_s
      @current_date_end   = params['date_end'].to_s
    else
      if !cookies['date_start_'+@ligne.id.to_s].nil?
        @current_date_start = cookies['date_start_'+@ligne.id.to_s].to_s
        @current_date_end   = cookies['date_end_'+@ligne.id.to_s].to_s
      else
        @current_date_start = Date.new(@ligne.date_debut.year,01,01).to_s
        @current_date_end   = Date.new(@ligne.date_fin_selection.year,12,31).to_s
      end
    end
    
    @date_condition = " AND (( date_max >= '"+@current_date_start+"') && ( date_min <= '"+@current_date_end+"'))"

    @date_fin_budget = @ligne.date_fin_selection
    @date_debut_budget = @ligne.date_debut
    @date_start = Date.new(@date_debut_budget.year,01,01)
    @date_end   = Date.new(@date_fin_budget.year,12,31)
    @total_day  = @date_end - @date_start

    if @current_date_start.to_date == @date_start && @current_date_end.to_date == @date_end
      @all_selected = true
    else
      @all_selected = false
    end
  end

  def setup_depenses_dates_salaires
    @ligne = Ligne.find(params[:ligne_id])
    if !params['date_start'].nil?
      cookies['date_start_'+@ligne.id.to_s] = params['date_start'].to_s
      cookies['date_end_'+@ligne.id.to_s] = params['date_end'].to_s
      @current_date_start = params['date_start'].to_s
      @current_date_end   = params['date_end'].to_s
    else
      if !cookies['date_start_'+@ligne.id.to_s].nil?
        @current_date_start = cookies['date_start_'+@ligne.id.to_s].to_s
        @current_date_end   = cookies['date_end_'+@ligne.id.to_s].to_s
      else
        @current_date_start = @ligne.date_debut.to_s
        @current_date_end   = @ligne.date_fin_selection.to_s
      end
    end
    
    @date_condition = " AND (( date_max >= '"+@current_date_start+"') && ( date_min <= '"+@current_date_end+"'))"

    @date_start = @ligne.date_debut
    @date_end   = @ligne.date_fin_selection
    @total_day  = @date_end - @date_start

    if @current_date_start.to_date == @date_start && @current_date_end.to_date == @date_end
      @all_selected = true
    else
      @all_selected = false
    end
  end

  def setup_depenses_totals(depenses, depense_class)
    @display_subtotals = (@items_per_page.to_i < depenses.length)
    @colspan_totals = 7

    ['montant_engage', 'cout_mensuel', 'cout_periode'].each { |m|
      if depense_class.new.respond_to?(m)
        sum_depenses = depenses.inject(0) { |s,d| s += d.send(m.to_sym) }
        self.instance_variable_set "@total_#{m}s", sum_depenses
        self.instance_variable_set "@subtotal_#{m}s", 0 # computed in the view for performance
      end
    }

    if depense_class.new.respond_to?('montant_factures')
      @total_montant_factures = depenses.inject(0) { |s,d| s += d.montant_factures(@type_montant,@current_date_start,@current_date_end) }
      @subtotal_montant_factures = 0 # computed in the view for performance
    end
      @total_montant_paye = depenses.inject(0) { |s,d| s += d.montant(@current_date_start,@current_date_end,"sommes_engagees",@type_montant) }
      @subtotal_montant_paye = 0 # computed in the view for performance
  end

  def sort_and_paginate_depenses(depenses)
    args = [@order_by_field.to_sym]
    args.push(@type_montant,@current_date_start,@current_date_end) if @order_by_field == 'montant_factures'
    args.push(@current_date_start,@current_date_end,"sommes_engagees",@type_montant) if @order_by_field == 'montant'
    depenses.sort! { |a,b| a.send(*args) <=> b.send(*args) }

    depenses.reverse! if @order_by_direction != "asc"

    depenses.paginate(
      :page       => params[:page],
      :per_page   => @items_per_page)
  end
end
