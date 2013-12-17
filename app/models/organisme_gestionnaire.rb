#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class OrganismeGestionnaire < ActiveRecord::Base
  has_many :organisme_gestionnaire_tauxes,  :dependent => :destroy,  :order => "annee"
  has_many :soumissions
  has_many :notifications
  
  validates_presence_of :nom , :message => " doît être obligatoirement rempli"
  validates_uniqueness_of :nom
  
  attr_accessible :nom
    
  def self.localized_human_attribute_name(attr)
    return case attr
      when "organisme_gestionnaire_tauxes" then "Taux par année"
      else attr.humanize
    end
  end
  
end
