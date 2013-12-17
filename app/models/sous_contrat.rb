#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SousContrat < ActiveRecord::Base
  has_one :sous_contrat_notification, :dependent => :destroy
  belongs_to :entite, :polymorphic => true
  belongs_to :contrat
  has_one :echeancier, :as => :echeanciable, :dependent => :destroy
  has_one :ligne, :dependent => :destroy
  
  attr_accessible :entite_id, :entite_type, :contrat_id
  
  def clone
    new_sous_contrat = self.dup
    
    #echeancier
    if self.echeancier
      new_echeancier = self.echeancier.clone
      new_sous_contrat.echeancier = new_echeancier
    end
    #on ne copie pas les lignes budgetaires(choix metier)
    new_sous_contrat.verrou = 'Aucun'
    new_sous_contrat.verrou_listchamps = nil
    return new_sous_contrat
  end
    
  
  def nom
    unless self.contrat.num_contrat_etab.blank?
      return self.contrat.acronyme+"-"+self.contrat.num_contrat_etab+" - "+self.entite.nom
    else
      return self.contrat.acronyme+" - "+self.entite.nom
    end
  end
  
  def etat
    self.contrat.etat
  end
  
  def is_consultable?(current_user)
    response = false
    if current_user.has_role? 'consultation', self
       response = true
    end
    if current_user.has_role? 'consultation', self.contrat
       response = true
    end
    if current_user.has_role? 'consultation', self.entite
       response = true
    end
    return response
  end
  
  def is_editable?(current_user)
    response = false
    if current_user.has_role? 'modification', self
       response = true
    end
    if (current_user.has_role? 'modification', self.contrat) && !(current_user.has_role? 'consultation', self)
       response = true
    end
    if (current_user.has_role? 'modification', self.entite) && !(current_user.has_role? 'consultation', self)
       response = true
    end
    return response
  end
  
end
