#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseSalaireFacture < ActiveRecord::Base
  belongs_to :depense_salaire
  
  validates_presence_of     :cout
  validates_numericality_of :cout
  
  validates_date  :date_mandatement, 
                  :before => Proc.new{ |r| r.depense_salaire.ligne.date_fin_depenses + 1.day},
                  :after => Proc.new{ |r| r.depense_salaire.ligne.date_debut- 1.day}, 
                  :before_message => "doit être antérieur à la date de cloture (fin des dépenses) du contrat",
                  :after_message => "doit être postérieure à la date de début de la période de la ligne",
                  :message => "n'est pas valide"
  
  validates_date  :millesime, :allow_nil => true
                  
  validates_numericality_of :montant_htr, :allow_nil => true

  before_update :update_depense
  before_create 'self.created_by = User.current_user.id',
                :update_depense
                
  after_destroy :update_depense_destroy
  
  attr_accessible :millesime,:cout, :montant_htr, :commentaire, :numero_mandat, :date_mandatement
  
  def update_depense
    self.updated_by = User.current_user.id
    self.depense_salaire.updated_at = Time.now
    self.depense_salaire.save!
  end
  
  def update_depense_destroy
    self.depense_salaire.updated_at = Time.now
    self.depense_salaire.save!
  end
             
  def cout_cannot_be_greater_than_montant_htr
    if cout
      errors.add(:cout, "ne peut être supérieur au montant HTR") if !montant_htr.blank? and montant_htr < cout
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
  
  def get_non_modifiables
    non_modifiables = []
    # Dé-commenter pour tester, si besoin ...
    #non_modifiables << 'cout'
    #non_modifiables << 'commentaire'
    #non_modifiables << 'numero_mandat'
    #non_modifiables << 'date_mandatement'
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
