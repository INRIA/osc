#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Projet < ActiveRecord::Base
  acts_as_authorizable

  has_many :laboratoire_subscriptions, :dependent => :destroy
  has_many :laboratoires, :through => :laboratoire_subscriptions, :order => "nom"
  
  has_many :departement_subscriptions, :dependent => :destroy
  has_many :departements, :through => :departement_subscriptions, :order => "nom"
  
  has_many :tutelle_subscriptions, :dependent => :destroy
  has_many :tutelles, :through => :tutelle_subscriptions, :order => "nom"
  
  has_many :sous_contrats, :as => :entite
  has_many :roles , :as => :authorizable 
    
  validates_presence_of :nom, :message => " doît être obligatoirement rempli"
  validates_uniqueness_of :nom, :message => " est déjà utilisé par un autre projet"
  validates_presence_of :date_debut, :message => " doît être obligatoirement rempli"
  validates_presence_of :date_fin, :message => " doît être obligatoirement rempli"
  validate :date_fin_cannot_be_greater_than_date_debut
  
  def date_fin_cannot_be_greater_than_date_debut
      if self.date_debut > self.date_fin
        errors.add(:date_fin, " : la date de fin doit être supérieure à la date de début")
      end
  end
  
  def self.find_all_team_for(user)
    user_equipes_querry = ["SELECT p.id FROM projets p 
                           INNER JOIN roles AS r ON r.authorizable_type = 'Projet' and r.authorizable_id = p.id
                           INNER JOIN roles_users AS ru ON ru.role_id = r.id 
                           WHERE ru.user_id = ?",user.id]
                           
    mes_equipes = Projet.find_by_sql(user_equipes_querry)
    
    group_equipes_querry = ["SELECT p.id FROM projets p 
                            INNER JOIN roles AS r ON r.authorizable_type = 'Projet' and r.authorizable_id = p.id
                            INNER JOIN group_rights  as gr ON gr.role_id = r.id
                            INNER JOIN memberships AS m ON m.group_id = gr.group_id
                            WHERE m.user_id = ?",user.id]
    mes_equipes_from_group = Projet.find_by_sql(group_equipes_querry)
    mes_equipes = mes_equipes | mes_equipes_from_group
    
    return mes_equipes
  end
  
  def is_in_laboratoire? labo
    is_in = 0
    for laboratoire in self.laboratoires
      if laboratoire.id == labo.id
        is_in = is_in + 1
      end
    end
    for departement in self.departements
      if departement.laboratoire.id == labo.id
        is_in = is_in + 1
      end
    end
    if is_in == 0
      return false
    else
      return true
    end 
  end
  
  def is_in_tutelle? tutel
    is_in = 0
    for tutelle in self.tutelles
      if tutelle.id == tutel.id
        is_in = is_in + 1
      end
    end
    if is_in == 0
      return false
    else
      return true
    end 
  end
  
  def type
    return self.class
  end
end
