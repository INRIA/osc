#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Group < ActiveRecord::Base
  has_many :memberships , :dependent => :destroy
  has_many :users, :through => :memberships
  has_many :group_rights, :dependent => :destroy
  has_many :roles, :through => :group_rights
  validates_presence_of :nom
   
  attr_accessible :nom, :description
  
  def has_role?( role_name, authorizable_obj = nil )
    if authorizable_obj.nil?
      for role in self.roles
        if role.name == role_name
          return true
        end
      end
    else
      for role in self.roles
        if (role.name == role_name ) && (authorizable_obj.class.to_s == role.authorizable_type) && (authorizable_obj.id == role.authorizable_id)
          return true
        end
        if(role.name == role_name) && (authorizable_obj.class.to_s == 'Contrat') && (role.authorizable_type == 'Projet')
          projet = Projet.find(role.authorizable_id)
          if authorizable_obj.projets.include? projet
            return true
          end
        end
      end
    end
    return false
  end
    
    
  def self.find_with_role(contrat_id)
    groups_with_role = Hash.new{ |h,k| h[k] = "" }
    groups_with_role_from_projet = Hash.new{ |h,k| h[k] = "" }
    
    groups_with_role[:consultation] = Group.find(:all, :order => "nom", :include => :roles,
      :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",contrat_id,"consultation","Contrat"])
    groups_with_role[:modification] = Group.find(:all, :order => "nom", :include => :roles,
      :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",contrat_id,"modification","Contrat"])
    groups_with_role[:modification_budget] = Group.find(:all, :order => "nom", :include => :roles,
      :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",contrat_id,"modification_budget","Contrat"])
    groups_with_role[:admin_contrat] = Group.find(:all, :order => "nom", :include => :roles,
      :conditions => ["roles.name = 'Administrateur de contrat'"])
    
    projets = SousContrat.find_by_sql("SELECT distinct entite_id FROM sous_contrats WHERE entite_type = 'Projet' AND contrat_id = '"+contrat_id.to_s+"'")
    for projet in projets
      groups_with_role_from_projet[:consultation] = Group.find(:all, :order => "nom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"consultation","Projet"])
      groups_with_role_from_projet[:modification] = Group.find(:all, :order => "nom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"modification","Projet"])
      groups_with_role_from_projet[:modification_budget] = Group.find(:all, :order => "nom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"modification_budget","Projet"])
      groups_with_role[:consultation] = groups_with_role[:consultation] | groups_with_role_from_projet[:consultation]
      groups_with_role[:modification] = groups_with_role[:modification] | groups_with_role_from_projet[:modification]
      groups_with_role[:modification_budget] = groups_with_role[:modification_budget] | groups_with_role_from_projet[:modification_budget]
    end
      
    return groups_with_role
  end
          
  def self.find_with_role_consultation(contrat_id)
    groups_with_role_consulsation = []
    groups_with_role_consulsation_from_projet = []
    role_consultation = Role.find(:first,:conditions => ["authorizable_id = ? AND name = ? AND authorizable_type = ?",contrat_id,"consultation","Contrat"])
    groups_with_role_consulsation = Group.find(:all,:order => "nom", :joins => " INNER JOIN `group_rights` ON group_rights.group_id = groups.id", :conditions => ["group_rights.role_id = ?",role_consultation.id])

    projets = SousContrat.find_by_sql("SELECT distinct entite_id FROM sous_contrats WHERE entite_type = 'Projet' AND contrat_id = '"+contrat_id.to_s+"'")   
    for projet in projets
      groups_with_role_consulsation_from_projet = Group.find(:all, :order => "nom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"consultation","Projet"])
      groups_with_role_consulsation = groups_with_role_consulsation | groups_with_role_consulsation_from_projet
    end
       
    return groups_with_role_consulsation
    
   
  end
  
  def self.find_with_role_modification(contrat_id)
    groups_with_role_modification = []
    groups_with_role_modification_from_projet = []
    
    role_modification = Role.find(:first,:conditions => ["authorizable_id = ? AND name = ? AND authorizable_type = ?",contrat_id,"modification","Contrat"])
    groups_with_role_modification = Group.find(:all,:order => "nom", :joins => " INNER JOIN `group_rights` ON group_rights.group_id = groups.id", :conditions => ["group_rights.role_id = ?",role_modification.id])

    projets = SousContrat.find_by_sql("SELECT distinct entite_id FROM sous_contrats WHERE entite_type = 'Projet' AND contrat_id = '"+contrat_id.to_s+"'")   
    for projet in projets
      groups_with_role_modification_from_projet = Group.find(:all, :order => "nom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"modification","Projet"])
      groups_with_role_modification = groups_with_role_modification | groups_with_role_modification_from_projet
    end
    
    return groups_with_role_modification
  end
  
  def self.find_with_role_modification_budget(contrat_id)
    groups_with_role_modification_budget = []
    groups_with_role_modification_budget_from_projet = []
    
    role_modification_budget = Role.find(:first,:conditions => ["authorizable_id = ? AND name = ? AND authorizable_type = ?",contrat_id,"modification_budget","Contrat"])
    groups_with_role_modification_budget = Group.find(:all,:order => "nom", :joins => " INNER JOIN `group_rights` ON group_rights.group_id = groups.id", :conditions => ["group_rights.role_id = ?",role_modification_budget.id])
    
    projets = SousContrat.find_by_sql("SELECT distinct entite_id FROM sous_contrats WHERE entite_type = 'Projet' AND contrat_id = '"+contrat_id.to_s+"'")   
    for projet in projets
      groups_with_role_modification_budget_from_projet = Group.find(:all, :order => "nom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"modification_budget","Projet"])
      groups_with_role_modification_budget = groups_with_role_modification_budget | groups_with_role_modification_budget_from_projet
    end
    

    return groups_with_role_modification_budget
  end
end
