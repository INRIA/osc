#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseMissionFacture < ActiveRecord::Base
  belongs_to :depense_mission
  belongs_to :rubrique_comptable
  
  validates_presence_of :cout_ht
  validates_presence_of :taux_tva
  validates_presence_of :rubrique_comptable_id

  validates_date  :date,
                  :before => Proc.new{ |r| r.depense_mission.ligne.date_fin_depenses+ 1.day},
                  :after => Proc.new{ |r| r.depense_mission.ligne.date_debut- 1.day},
                  :after_message => "doit être posterieur à la date de début de la notification",
                  :before_message => "doit être antérieur à la date de cloture (fin des dépenses) du contrat",
                  :message => "n'est pas valide"

  validates_date :date_mandatement, :allow_nil => true

	validates_date  :millesime, :allow_nil => true

  validates_numericality_of :cout_ht
  validates_numericality_of :montant_htr, :allow_nil => true
  validate :cout_ht_cannot_be_greater_than_montant_htr
  
  before_update :update_depense
  before_create 'self.created_by = User.current_user.id',
                :update_depense
                
  after_destroy :update_depense_destroy
  
  before_validation :compute_cout
   
  attr_accessible :date, :millesime, :numero_facture, :commentaire, :numero_mandat, :date_mandatement, :fournisseur, 
                  :cout_ht, :taux_tva, :montant_htr, :justifiable, :rubrique_comptable_id, :code_analytique, :compte_budgetaire
        
  def update_depense
    self.updated_by = User.current_user.id
    self.depense_mission.updated_at = Time.now
    self.depense_mission.save!
  end

  def update_depense_destroy
    self.depense_mission.update_dates_min_max
    self.depense_mission.updated_at = Time.now
    self.depense_mission.save!
  end

  def compute_cout
    if !self.cout_ht.nil?
      self.cout_ttc = (self.cout_ht * (100+self.taux_tva.to_f)) / 100
    end
  end
  
  def cout_ht_cannot_be_greater_than_montant_htr
    if cout_ht
      errors.add(:cout_ht, "ne peut être supérieur au montant HTR") if !montant_htr.blank? and montant_htr.abs < cout_ht.abs
    end
  end

  def self.localized_human_attribute_name(attr)
    return case attr
      when "numero_facture" then "N° de facture"
      when "cout_ht"        then "Coût HT"
      when "taux_tva"       then "Taux de TVA"
      when "montant_htr"    then "Montant HTR"  
      else attr.humanize
    end
  end
  
  def taux_cout_projet
    year = self.date_mandatement.year
    organisme_gestionnaire_id = self.depense_mission.ligne.organisme_gestionnaire.id
    organisme_gestionnaire = OrganismeGestionnaire.find_by_id(organisme_gestionnaire_id)
    if !organisme_gestionnaire.organisme_gestionnaire_tauxes.find_by_annee(year).nil?
      taux = organisme_gestionnaire.organisme_gestionnaire_tauxes.find_by_annee(year).taux
    else
      taux =  1
    end
    return taux
  end
  
  def cout_projet
    if !self.date_mandatement.blank?
      return (self.cout_ht * ( (self.taux_tva.to_f+100) / 100)) * self.taux_cout_projet
    else
      return (self.cout_ht * ( (self.taux_tva.to_f+100) / 100)) * 1
    end
  end
  
  def get_non_modifiables
    non_modifiables = []
    # Dé-commenter pour tester, si besoin ...
    #non_modifiables << 'date'
    #non_modifiables << 'numero_facture'
    #non_modifiables << 'commentaire'
    #non_modifiables << 'numero_mandat'
    #non_modifiables << 'date_mandatement'
    #non_modifiables << 'fournisseur'
    #non_modifiables << 'cout_ht'
    #non_modifiables << 'taux_tva'
    #non_modifiables << 'justifiable'
    #non_modifiables << 'rubrique_comptable_id'
    #non_modifiables << 'montant_htr'
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

end
