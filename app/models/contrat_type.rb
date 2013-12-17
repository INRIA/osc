#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class ContratType < ActiveRecord::Base
  acts_as_tree :order => "nom"

  has_many :soumissions
  has_many :notifications
  
  validates_presence_of :nom, :message => " doît être obligatoirement rempli"
  validates_presence_of :parent_id, :message => " doît être obligatoirement rempli"
  validates_uniqueness_of :nom, :scope => :parent_id, :message => " : ce nom est déjà utilisé par un autre type de contrat dans cette branche"

  attr_accessible :nom, :parent_id
  
  def nom_complet
    ret = ""
    if !self.parent.nil?
     ret += self.parent.nom_complet+" > "
     ret += self.nom 
    else
     ret += self.nom
    end
    ret
  end

  def all_children(ids = [])
  
    if self.children.size != 0
      for c in self.children
        ids << c.id
        ids << c.all_children
      end
    end
    
    return ids.flatten
  
  
  end

  def self.find_all_dotation_type_id
    dotation_pere = self.find(:first,:conditions => ["id = (?)",ID_CONTRAT_DOTATION])
    all_dotation_type = dotation_pere.all_children
    all_dotation_type << dotation_pere.id
    return all_dotation_type
  end

end
