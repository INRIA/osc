#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Membership < ActiveRecord::Base
  belongs_to :group 
  belongs_to :user
  validates_presence_of :group_id
  validates_presence_of :user_id
  validates_uniqueness_of :user_id, :scope => :group_id
  
  attr_accessible :group_id, :user_id
end
