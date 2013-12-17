#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Versement < ActiveRecord::Base
  belongs_to :ligne
  validates_presence_of :date_effet, :montant, :ventilation
  validates_numericality_of :montant
  
  validates_date  :date_effet, 
                  :after => Proc.new{ |r| r.ligne.date_debut}, 
                  :before => Proc.new{ |r| r.ligne.date_fin_depenses},
                  :after_message => "doit être posterieur à la date de début de la notification",
                  :before_message => "doit être antérieur à la date de cloture (fin des dépenses) du contrat",
                  :message => "n'est pas valide"

  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
  
  attr_accessible :ligne_id,:date_effet, :reference, :montant, :ventilation, :origine, :commentaire
  
  def come_from_inria?
    true if self.verrou == "SI INRIA" || false
  end
  
  def save
    self.ligne.activation
    super
  end
  
end
