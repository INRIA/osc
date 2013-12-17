#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
# Defines named roles for users that may be applied to
# objects in a polymorphic fashion. For example, you could create a role
# "moderator" for an instance of a model (i.e., an object), a model class,
# or without any specification at all.
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :group_rights, :dependent => :destroy
  has_many :groups, :through => :group_rights
  belongs_to :authorizable, :polymorphic => true
  
  attr_accessible :name, :authorizable
end
