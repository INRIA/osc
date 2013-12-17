#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Descriptif < ActiveRecord::Base
  belongs_to :contrat
  belongs_to :langue
  validates_presence_of :descriptif, :message=>"Vous avez saisi un descriptif vide. Le champ est obligatoire."
  validates_uniqueness_of :langue_id, :scope=>:contrat_id, :message=> "Cette langue a déjà été choisie, vous ne pouvez saisir qu'un seul descriptif par langue."

  attr_accessible :descriptif, :langue_id
  
  def nomlangue(idLangue)
    return self.find_by_langue_id(idlangue)
  end
end