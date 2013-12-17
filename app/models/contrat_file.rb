#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class ContratFile < ActiveRecord::Base
  belongs_to :contrat
  file_column :file
  validates_presence_of :file, :message => "Le fichier doit être obligatoirement renseigné."
  validates_presence_of :description, :message => "La description du fichier doit être obligatoirement renseignée."
  
  attr_accessible :file_temp, :file, :description
  
  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
  
end
