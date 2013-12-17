#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class BudgetaireReference < ActiveRecord::Base
  has_many :depense_communs

  validates_presence_of :intitule, :message => " doît être obligatoirement rempli"
  validates_presence_of :code, :message => " doît être obligatoirement rempli"
  validates_uniqueness_of :code, :case_sensitive => false, :message => " : ce code est déjà utilisé par une autre référence budgétaire"

  attr_accessible :code, :intitule
end
