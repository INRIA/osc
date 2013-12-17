#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class TutelleSubscription < ActiveRecord::Base
  belongs_to :projet
  belongs_to :tutelle
  validates_presence_of :projet_id
  validates_presence_of :tutelle_id
  validates_uniqueness_of :projet_id, :scope => :tutelle_id
  
  attr_accessible :projet_id
end
