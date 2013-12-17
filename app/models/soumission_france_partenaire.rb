#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SoumissionFrancePartenaire < ActiveRecord::Base
  belongs_to :soumissions
  
  validates_presence_of :nom,
                        :message => "Le champ <strong>nom</strong> est un champ obligatoire, merci de le renseigner"
  
  attr_accessible :nom, :laboratoire, :etablissement_gestionnaire, :ville
  
  before_validation :clean_data
  
  def clean_data
    if self.nom == 'Nom'
      self.nom = ''
    end
    if self.laboratoire == 'Laboratoire'
      self.laboratoire = ''
    end
    if self.etablissement_gestionnaire == 'Etab. gestionnaire'
      self.etablissement_gestionnaire = ''
    end
    if self.ville == 'Ville'
      self.ville = ''
    end
  end
  
end
