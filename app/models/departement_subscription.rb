#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepartementSubscription < ActiveRecord::Base
  belongs_to :projet
  belongs_to :departement
  validates_presence_of :projet_id
  validates_presence_of :departement_id
  validates_uniqueness_of :projet_id
  
  attr_accessible :projet_id, :departement_id

  def validate_on_create
    ds = LaboratoireSubscription.find(:all, :conditions => ["projet_id = ?", projet_id])
    if ds.size == 1
     errors.add("Projet déjà associé à un département !")
    end
  end
  
end
