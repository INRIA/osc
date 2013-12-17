#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Cloture < ActiveRecord::Base
  belongs_to :contrat
  validates_uniqueness_of :contrat_id  
  
  
  validates_date  :date_fin_depenses,
                  :after => Proc.new { |n| n.date_max },
                  :after_message => "Le champ <strong>Date de fin des dépenses</strong> doit être supérieure ou égale à la date de fin du contrat définie dans la notification et à toutes les dates des versements ou factures des lignes correspondantes au contrat",
                  :message => "Le champ <strong>Date de fin des dépenses</strong>  doit être une date valide"
  
  attr_accessible :commentaires, :date_fin_depenses
  
  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
  
  after_create :up_contrat_etat
  after_destroy :down_contrat_etat              
  
  def up_contrat_etat
    update_contrat_etat("cloture")  
  end
  
  def down_contrat_etat
    update_contrat_etat("notification")
  end
  
  def update_contrat_etat(nouvel_etat)
    c = self.contrat
    c.etat = nouvel_etat
    c.save
  end   
  
  def date_max
    @dates = [self.contrat.notification.date_fin]
    for sc in self.contrat.sous_contrats
      if !sc.ligne.nil?
        @dates << sc.ligne.date_max
      end
    end
    return @dates.max
  end

end
