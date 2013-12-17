#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class EcheancierPeriode < ActiveRecord::Base
  belongs_to :echeancier
  before_destroy :remove_associated_periodes
  
  validates_presence_of :credit,
                        :message => "Le champ <strong>total</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :depenses_non_ventile,
                        :message => "Le champ <strong>non ventilé</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :depenses_fonctionnement,
                        :message => "Le champ <strong>fonctionnement</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :depenses_equipement,
                        :message => "Le champ <strong>équipement</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :depenses_salaires,
                        :message => "Le champ <strong>salaires</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :depenses_missions,
                        :message => "Le champ <strong>missions</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :depenses_couts_indirects,
                        :message => "Le champ <strong>coûts indirects</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :depenses_frais_gestion_mut_local,
                        :message => "Le champ <strong>Frais de gestion mutualis&eacute;s locaux</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :depenses_frais_gestion_mut,
                        :message => "Le champ <strong>Frais de gestion mutualis&eacute;s nationaux</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :depenses_frais_gestion,
                        :message => "Le champ <strong>frais de gestion</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :allocations,
                        :message => "Le champ <strong>allocation</strong> est un champ obligatoire, merci de le renseigner"

  validates_numericality_of :credit,
                            :message => "Le champ <strong>total</strong> doit être un nombre"
  validates_numericality_of :depenses_non_ventile,
                            :message => "Le champ <strong>non ventil&eacute;</strong> doit être un nombre"
  validates_numericality_of :depenses_fonctionnement,
                            :message => "Le champ <strong>fonctionnement</strong> doit être un nombre"
  validates_numericality_of :depenses_equipement,
                            :message => "Le champ <strong>&eacute;quipement</strong> doit être un nombre"
  validates_numericality_of :depenses_salaires,
                            :message => "Le champ <strong>salaires</strong> doit être un nombre"
  validates_numericality_of :depenses_missions,
                            :message => "Le champ <strong>missions</strong> doit être un nombre"
  validates_numericality_of :depenses_couts_indirects,
                            :message => "Le champ <strong>coûts indirects</strong> doit être un nombre"
  validates_numericality_of :depenses_frais_gestion_mut_local,
                            :message => "Le champ <strong>Frais de gestion mutualis&eacute;s locaux</strong> doit être un nombre"
  validates_numericality_of :depenses_frais_gestion_mut,
                            :message => "Le champ <strong>Frais de gestion mutualis&eacute;s nationaux</strong> doit être un nombre"
  validates_numericality_of :depenses_frais_gestion,
                            :message => "Le champ <strong>frais de gestion</strong> doit être un nombre"
  validates_numericality_of :allocations,
                            :message => "Le champ <strong>allocation</strong> doit être un nombre"

  attr_accessible :date_debut, :date_fin, :reference_financeur, :numero_contrat_etablissement_gestionnaire, :depenses_fonctionnement, :depenses_equipement, :depenses_salaires, :depenses_missions, :depenses_non_ventile, :depenses_couts_indirects, :depenses_frais_gestion_mut_local, :depenses_frais_gestion_mut, :depenses_frais_gestion, :allocations, :credit
  
  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
                
  def remove_associated_periodes  
    if self.echeancier.echeanciable_type == "Contrat"
      self.echeancier.echeancier_periodes.each_with_index do |p, i|
        if p.id == self.id
          self.echeancier.echeanciable.sous_contrats.each do |sc|
            if !sc.echeancier.nil?
              sc.echeancier.echeancier_periodes.each_with_index do |sc_p, j|
                if i == j
                  sc_p.destroy
                end
              end
            end
          end
        end
      end
    end
  end
  
end
