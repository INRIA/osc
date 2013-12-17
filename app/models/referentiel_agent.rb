#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class ReferentielAgent < ActiveRecord::Base
    
  validates_presence_of :nom, :message => ": le nom doit etre obligatoirement rempli"
  validates_presence_of :prenom, :message => ": le prenom doit etre obligatoirement rempli"
  validates_presence_of :si_id, :message => ": l'identifiant systeme d'information doit etre obligatoirement rempli"
  validates_presence_of :si_origine, :message => ": le systeme d'information d'origine doit etre obligatoirement rempli"
  
end
