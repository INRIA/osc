#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class RubriqueComptable < ActiveRecord::Base
  acts_as_tree :order => "numero_rubrique"
  belongs_to :depense_fonctionnement_factures
  belongs_to :depense_equipement_factures
  
  validates_presence_of :numero_rubrique, :message => " doît être obligatoirement rempli"
  validates_presence_of :parent_id, :message => " doît être obligatoirement rempli"
  validates_uniqueness_of :numero_rubrique, :scope => :parent_id, :message => " : ce numéro de rubrique est déjà utilisé par une autre rubrique comptable dans cette branche"
  
  attr_accessible :numero_rubrique, :label, :parent_id
  
  def intitule
    if self.label != ''
      return self.numero_rubrique + ' - '+ self.label  
    else
      return self.numero_rubrique
    end   
  end
  
  def small_intitule
    temp = self.intitule.split("-").first
    if temp == "0"
      "-"
    else
      temp
    end
  end
end
