#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Tutelle < ActiveRecord::Base
  has_many :tutelle_subscriptions, :dependent => :destroy
  has_many :projets, :through => :tutelle_subscriptions, :order => "nom"
  has_one :tutelle_logo
  validates_presence_of :nom, :message => " est obligatoire"

  attr_accessible :nom, :description
  
  def self.exist? tutel
    return self.find_by_nom(tutel)
  end
end