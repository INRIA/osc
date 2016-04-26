#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseNonVentilee < ActiveRecord::Base
  belongs_to :ligne
  has_many :depense_non_ventilee_factures, :dependent => :destroy
	has_many :rubrique_comptables, :through => :depense_non_ventilee_factures

  validates_presence_of :montant_engage
  validates_presence_of :intitule

  validates_date  :date_commande,
                  :after => Proc.new{ |r| r.ligne.date_debut- 1.day},
                  :before => Proc.new{ |r| r.ligne.date_fin_depenses+1.day},
                  :after_message => "doit être posterieur à la date de début de la notification",
                  :before_message => "doit être antérieur à la date de cloture (fin des dépenses) du contrat",
                  :message => "n'est pas valide"

  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'

  attr_accessible :ligne_id, :reference, :date_commande, :fournisseur, :structure, :commentaire, :montant_engage, 
                  :intitule, :commande_solde, :tache, :eligible, :type_activite, :code_analytique, :compte_budgetaire
  
  def self.localized_human_attribute_name(attr)
    return case attr
      when "montant_engage"               then "Montant engagé"
      when "intitule"                     then "Intitulé"
      when "date_commande"                then "Date de commande"
      when "depense_non_ventilee_factures"  then "Facture"
      else attr.humanize
    end
  end

  def taux_by_year(year)
    if self.ligne.organisme_gestionnaire.organisme_gestionnaire_tauxes.find_by_annee(year).nil?
      1
    else
      self.ligne.organisme_gestionnaire.organisme_gestionnaire_tauxes.find_by_annee(year).taux
    end
  end

  # dates minimum et maximum des factures
  # max = la + grande des dates entre :
  #       * la + grande des dates de facture
  #       * la + grande des dates millesime des factures
  #       * la date de la commande de la depense
  # min = la + petite de ces dates
  def update_dates_min_max
    millesime = self.millesime||self.date_commande
    if self.depense_non_ventilee_factures.size != 0
      facture_date_max = [self.depense_non_ventilee_factures.maximum(:date),self.depense_non_ventilee_factures.maximum(:millesime)||self.date_commande].max || self.date_commande
      self.date_max = [facture_date_max, self.date_commande,millesime].max
      facture_date_min = [self.depense_non_ventilee_factures.minimum(:date),self.depense_non_ventilee_factures.minimum(:millesime)||self.date_commande].min || self.date_commande
      self.date_min = [facture_date_min, self.date_commande,millesime].min
    else
      self.date_max = [self.date_commande,millesime].max
      self.date_min = [self.date_commande,millesime].min
    end
  end

  # calcule la somme des montants HTR/TTC des factures liées à la dépense dans
  # l'intervalle de date indiqué.
  # la date prise en compte est celle de la facture, sauf si la date de millésime est indiquée.
  def montant_factures(include_taxes = 'htr', date_start = '1900-01-01', date_end = '4000-01-01')
		find_conditions = "date >= '"+date_start+"' AND date <= '"+date_end+"'"
    if (include_taxes == 'ttc')
      montant_method = :cout_ttc
    elsif (include_taxes == 'ht')
      find_conditions = nil
      montant_method = :cout_ht
    elsif (include_taxes == 'htr')
      montant_method = :montant_htr
      find_conditions += " AND #{montant_method} IS NOT NULL"
    else
      throw 'Invalid include_taxes: '+include_taxes+'.'
    end

    factures = self.depense_non_ventilee_factures.find(:all, :conditions => find_conditions)
    somme = 0
    for facture in factures
      if facture.millesime.nil?
        date_facture = facture.date
      else
        date_facture = facture.millesime
      end
      if date_facture.to_date <= date_end.to_date && date_facture.to_date >= date_start.to_date
        somme = somme + facture.send(montant_method)
      end
    end
    somme
  end

  # Calcule le montant de la dépense :
  # Si la commande est soldée et qu'il existe des factures, retourne la somme des montants des factures
  # dans l'intervalle de date indiqué (la date de la facture prise en compte est soit la date de millèsime
  # si elle a été saisie, soit la date de la facture).
  # Si la commande n'est pas soldée ou s'il n'existe pas de factures, retourne le montant engagé
  # de la commande.
  def montant(date_start = '1900-01-01', date_end = '4000-01-01', type_bilan = "sommes_engagees", type_montant = "ttc")
		if self.millesime.nil?
      date_commande = self.date_commande
    else
      date_commande = self.millesime
    end

    if type_bilan == "sommes_engagees"
      if self.commande_solde && (self.depense_non_ventilee_factures.size !=0)
        self.montant_factures(type_montant, date_start, date_end)
      else
        if date_commande.to_date <= date_end.to_date && date_commande.to_date >= date_start.to_date
          self.montant_engage
        else
          0
        end
      end
#    elsif type_bilan =="sommes_engagees_htr"
#      if self.commande_solde && (self.depense_non_ventilee_factures.size !=0)
#        self.montant_factures('htr', date_start, date_end)
#      else
#        if self.date_commande.to_date <= date_end.to_date && self.date_commande.to_date >= date_start.to_date
#          self.montant_engage
#        else
#          0
#        end
#      end
#    elsif type_bilan =="factures_htr"
#      self.montant_factures('htr', date_start, date_end)
    else
      self.montant_factures(type_montant, date_start, date_end)
    end
  end

  def montant_paye(type_montant = 'htr', date_start = '1900-01-01', date_end = '4000-01-01')
    date_commande = self.millesime || self.date_commande
    if self.depense_non_ventilee_factures.size != 0
      self.montant_factures(type_montant, date_start, date_end)
    elsif self.commande_solde && date_commande.to_date <= date_end.to_date && date_commande.to_date >= date_start.to_date 
      self.montant_engage
    else
      0
    end    
  end
  
  def get_non_modifiables
    non_modifiables = []
    # Dé-commenter pour tester, si besoin ...
    #non_modifiables << 'reference'
    #non_modifiables << 'date_commande'
    #non_modifiables << 'fournisseur'
    #non_modifiables << 'tache'
    #non_modifiables << 'destination_budgetaire'
    #non_modifiables << 'eligible'
    #non_modifiables << 'type_activite'
    #non_modifiables << 'montant_engage'
    #non_modifiables << 'intitule'
    #non_modifiables << 'commande_solde'
    if (self.verrou == 'SI INRIA') and self.verrou_listchamps
      verrou_listchamps_tableau = self.verrou_listchamps.split(';')
      for champ in verrou_listchamps_tableau do
        non_modifiables << champ
      end
    end
    return non_modifiables
  end

  def come_from_inria?
    true if self.verrou == "SI INRIA" || false
  end

  def save
    self.ligne.activation
    super
  end
end
