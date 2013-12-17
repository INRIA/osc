#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SoumissionPersonnel < ActiveRecord::Base
  belongs_to :soumissions
  validates_presence_of :nom, :message => "le nom doît être obligatoirement rempli"
  validates_presence_of :prenom, :message => "le prenom doît être obligatoirement rempli"
  validates_presence_of :statut, :message => "le statut doît être obligatoirement rempli"
  validates_presence_of :tutelle, :message => "la tutelle doît être obligatoirement rempli"
  validates_presence_of :pourcentage, :message => "le pourcentage doît être obligatoirement rempli"
  
  attr_accessible :nom, :prenom, :statut, :tutelle, :pourcentage
  
  before_validation :clean_data
  
  def clean_data
   if self.nom == 'Nom'
      self.nom = ''
    end
    if self.prenom == 'Prénom'
      self.prenom = ''
    end
    if self.statut == 'Statut'
      self.statut = ''
    end
    if self.tutelle == 'Tutelle'
      self.tutelle = ''
    end
    if self.pourcentage == '%'
      self.pourcentage = ''
    end
  end
end
