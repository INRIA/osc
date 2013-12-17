#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Todoitem < ActiveRecord::Base
  belongs_to :todolist
  
  # belongs_to :contrat, :through => :todolist
  
  acts_as_list :scope => :todolist
  validates_presence_of :intitule, :message => "can't be blank"
  
  attr_accessible :intitule,:has_alerte,:date
  
  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
                
end
