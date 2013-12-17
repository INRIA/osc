#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class OrganismeGestionnaireTaux < ActiveRecord::Base
  belongs_to :organisme_gestionnaire
  
  validates_presence_of :taux
  validates_numericality_of :taux, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1
  validates_presence_of :annee
  validates_numericality_of :annee, :greater_than_or_equal_to => 1950, :less_than_or_equal_to => 2100
    
  def self.localized_human_attribute_name(attr)
    return case attr
      when "taux"   then "Taux"
      when "annee"  then "Année"
      else attr.humanize
    end
  end
  
end
