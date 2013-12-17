#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class GroupRight < ActiveRecord::Base
  belongs_to :group 
  belongs_to :role
  validates_presence_of :group_id
  validates_presence_of :role_id
  validates_uniqueness_of :role_id, :scope => :group_id
end
