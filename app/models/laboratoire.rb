#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Laboratoire < ActiveRecord::Base
  
  has_many :laboratoire_subscriptions, :dependent => :destroy
  has_many :departements, :dependent => :destroy
  has_many :key_words, :dependent => :destroy
  
  has_many :projets, :through => :laboratoire_subscriptions, :order => "nom"
  
  has_many :sous_contrats, :as => :entite
  
  validates_presence_of :nom, :message => " est obligatoire"
  
  attr_accessible :nom, :description

  def self.exist? labo
   return self.find_by_nom(labo)
  end

  def type
    return self.class
  end
end
