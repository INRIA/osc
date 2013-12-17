#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class SousContratNotification < ActiveRecord::Base
  belongs_to :sous_contrats
  belongs_to :notifications
  
  validates_presence_of :ma_total,
                        :message => "Le champ <strong>total des moyens demandés</strong> est un champ obligatoire, merci de le renseigner"

  attr_accessible :sous_contrat_id, :ma_fonctionnement, :ma_equipement, :ma_salaire, :ma_mission, :ma_non_ventile, :ma_couts_indirects, 
                  :ma_frais_gestion_mutualises_local, :ma_frais_gestion_mutualises, :ma_allocation, :ma_total, :pa_doctorant, :pa_post_doc, 
                  :pa_ingenieur, :pa_autre, :pa_equivalent_temps_plein
  
  def clone   
    new_sous_contrat_notification = self.dup
    new_sous_contrat_notification.verrou = 'Aucun'
    new_sous_contrat_notification.verrou_listchamps = nil
    return new_sous_contrat_notification
  end
end
