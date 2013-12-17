#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Echeancier < ActiveRecord::Base
  belongs_to :echeanciable, :polymorphic => true
  has_many :echeancier_periodes, :dependent => :destroy
  
  validates_presence_of :global_depenses_frais_gestion,
                        :message => "Le champ <strong>frais de gestion</strong> est un champ obligatoire, merci de le renseigner"
  validates_numericality_of :global_depenses_frais_gestion,
                            :message => "Le champ <strong>frais de gestion</strong> doit être un nombre"
  
  validates_each :echeancier_periodes do |echeancier, attr, value|
    echeancier.errors.add_to_base "Un échancier ne peut avoir plus de " + MAX_PERIODS_COUNT.to_s + " périodes" if echeancier.echeancier_periodes.size > MAX_PERIODS_COUNT
  end
  
  attr_accessible :global_depenses_frais_gestion, :echeanciable_type, :echeanciable_id
  
  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
                
  #Surcharge de la methode de copie
  def clone   
    new_echeancier = self.dup
    for periode in self.echeancier_periodes do
      new_periode= periode.dup
      new_periode.verrou = 'Aucun'
      new_periode.verrou_listchamps = nil
      new_echeancier.echeancier_periodes << new_periode
    end
    new_echeancier.verrou = 'Aucun'
    new_echeancier.verrou_listchamps = nil
    return new_echeancier
  end

  # ---- credit & solde_credit
  def credit
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_total
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_total
    end
  end
  
  def solde_credit
    if !self.echeancier_periodes.sum(:credit).nil?
      self.credit - self.echeancier_periodes.sum(:credit)
    else
      self.credit
    end
  end
  
  
  # ---- depenses_non_ventile & solde_depenses_non_ventile
  def depenses_non_ventile
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_non_ventile
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_non_ventile 
    end
  end
  
  def solde_depenses_non_ventile
    if !self.echeancier_periodes.sum(:depenses_non_ventile).nil?
      self.depenses_non_ventile - self.echeancier_periodes.sum(:depenses_non_ventile)
    else
      self.depenses_non_ventile
    end
  end
  
  # ---- depenses_commun & solde_depenses_commun
  def depenses_commun
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_total
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_total
    end
  end

  def solde_depenses_commun
    if !self.echeancier_periodes.sum(:depenses_commun).nil?
     self.depenses_commun - self.echeancier_periodes.sum(:depenses_commun)
    else
     self.depenses_commun
    end
  end

  
  # ---- depenses_fonctionnement & solde_depenses_fonctionnement
  def depenses_fonctionnement
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_fonctionnement
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_fonctionnement 
    end
  end
  
  def solde_depenses_fonctionnement
    if !self.echeancier_periodes.sum(:depenses_fonctionnement).nil?
     self.depenses_fonctionnement - self.echeancier_periodes.sum(:depenses_fonctionnement)
    else
     self.depenses_fonctionnement
    end
  end
  
  # --- depenses_equipement & solde_depenses_equipement
  def depenses_equipement
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_equipement
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_equipement 
    end
  end
  
  def solde_depenses_equipement
    if !self.echeancier_periodes.sum(:depenses_equipement).nil?
      self.depenses_equipement - self.echeancier_periodes.sum(:depenses_equipement) 
    else
      self.depenses_equipement
    end
  end
  
  
  # ---- depenses_salaires & solde_depenses_salaires
  def depenses_salaires
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_salaire
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_salaire 
    end
  end
  
  def solde_depenses_salaires
    if !self.echeancier_periodes.sum(:depenses_salaires).nil?
      self.depenses_salaires - self.echeancier_periodes.sum(:depenses_salaires)
    else
      self.depenses_salaires
    end
  end
  
  
  # ---- depenses_missions & solde_depenses_missions
  def depenses_missions
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_mission
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_mission 
    end
  end
  
  def solde_depenses_missions
    if !self.echeancier_periodes.sum(:depenses_missions).nil?
      self.depenses_missions - self.echeancier_periodes.sum(:depenses_missions)
    else
      self.depenses_missions
    end
  end
  
  # ---- depenses_couts_indirects & solde_depenses_couts_indirects
  def depenses_couts_indirects
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_couts_indirects
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_couts_indirects 
    end
  end
  
  def solde_depenses_couts_indirects
    if !self.echeancier_periodes.sum(:depenses_couts_indirects).nil?
      self.depenses_couts_indirects - self.echeancier_periodes.sum(:depenses_couts_indirects)
    else
      self.depenses_couts_indirects
    end
  end
  
  
  # ---- depenses_frais_gestion_mut & solde_depenses_frais_gestion_mut
   def depenses_frais_gestion_mut
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_frais_gestion_mutualises
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_frais_gestion_mutualises 
    end
  end
  
  def solde_depenses_frais_gestion_mut
    if !self.echeancier_periodes.sum(:depenses_frais_gestion_mut).nil?
      self.depenses_frais_gestion_mut - self.echeancier_periodes.sum(:depenses_frais_gestion_mut) 
    else
      self.depenses_frais_gestion_mut
    end
  end
  
  def depenses_frais_gestion_mut_local
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_frais_gestion_mutualises_local
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_frais_gestion_mutualises_local 
    end
  end
  
  def solde_depenses_frais_gestion_mut_local
    if !self.echeancier_periodes.sum(:depenses_frais_gestion_mut_local).nil?
      self.depenses_frais_gestion_mut_local - self.echeancier_periodes.sum(:depenses_frais_gestion_mut_local) 
    else
      self.depenses_frais_gestion_mut_local
    end
  end
  
  # ---- solde_depenses_frais_gestion
  
  def solde_depenses_frais_gestion
    if !self.echeancier_periodes.sum(:depenses_frais_gestion).nil?
      self.global_depenses_frais_gestion - self.echeancier_periodes.sum(:depenses_frais_gestion) 
    else
      self.global_depenses_frais_gestion
    end
  end
  
  # ---- allocations & solde_allocations
  def allocations
    if self.echeanciable_type == "Contrat"
      Contrat.find_by_id(self.echeanciable_id).notification.ma_allocation
    else
      SousContrat.find_by_id(self.echeanciable_id).sous_contrat_notification.ma_allocation 
    end
  end
  
  def solde_allocations
    if !self.echeancier_periodes.sum(:allocations).nil?
      self.allocations.to_i - self.echeancier_periodes.sum(:allocations) 
    else
      self.allocations.to_i
    end
  end

end
