#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Signature < ActiveRecord::Base
  belongs_to :contrat
  validates_uniqueness_of :contrat_id
  validates_date          :date, :message => "La date doit être valide"
  
  attr_accessible :commentaire, :date
    
  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
  
  after_create :up_contrat_etat
  after_destroy :down_contrat_etat              
  
  def up_contrat_etat
    update_contrat_etat("signature")  
  end
  
  def down_contrat_etat
    update_contrat_etat("soumission")
  end
  
  def update_contrat_etat(nouvel_etat)
    c = self.contrat
    c.etat = nouvel_etat
    c.save
  end   
  
  def get_non_modifiables
    non_modifiables = []
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
