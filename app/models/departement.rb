#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Departement < ActiveRecord::Base
  
  belongs_to :laboratoire
  has_many :departement_subscriptions, :dependent => :destroy
  has_many :projets, :through => :departement_subscriptions, :order => "nom"
  has_many :sous_contrats, :as => :entite
  
  validates_presence_of :laboratoire_id, :message => " doît être obligatoirement rempli"
  validates_presence_of :nom, :message => " doît être obligatoirement rempli"
  validates_uniqueness_of :nom, :message => " : le nom est déjà utilisé par un autre département"
  
  attr_accessible :nom, :parent_id,:laboratoire_id, :description
  
  def is_in_laboratoire? labo
    if self.laboratoire.nom == labo.nom
      return true
    else
      return false
    end
  end
  
  def type
    return self.class
  end
  
end
