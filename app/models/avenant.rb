#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Avenant < ActiveRecord::Base
  belongs_to :notifications
  validates_presence_of :commentaires,
                        :message => "Avenants : le champ <strong>commentaires</strong> est un champ obligatoire, merci de le renseigner"
  validates_date        :date, :message => "Le champ <strong>Date de l'avenant</strong> contient une date non valide"

  attr_accessible :commentaires, :date
end
