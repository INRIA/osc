#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class KeyWord < ActiveRecord::Base
  belongs_to :laboratoire
  validates_uniqueness_of :intitule, :scope => :laboratoire_id
  validates_presence_of :intitule
  has_and_belongs_to_many :soumissions
  has_and_belongs_to_many :notifications
  
  attr_accessible :intitule, :section, :laboratoire_id
  
  # def section
  #   if self.section.nil?
  #     "aaa"
  #   else
  #     self.section
  #   end
  # end
  
end
