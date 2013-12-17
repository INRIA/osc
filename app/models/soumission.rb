#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Soumission < ActiveRecord::Base
  
  belongs_to :contrat
  belongs_to :organisme_gestionnaire
  has_many :soumission_france_partenaires, :dependent => :destroy
  has_many :soumission_europe_partenaires, :dependent => :destroy
  has_many :soumission_partenaires, :dependent => :destroy
  has_many :soumission_personnels, :dependent => :destroy
  belongs_to :contrat_type
  
  has_and_belongs_to_many :key_words, :join_table => "key_words_soumissions", :foreign_key => "soumission_id"
  
  validates_presence_of :contrat_type_id, :message => "Le champ <strong>Type de Contrat</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :porteur, :message => "Le champ <strong>porteur</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :etablissement_rattachement_porteur, :message => "Le champ <strong>établissement de rattachement</strong> du porteur est un champ obligatoire, merci de le renseigner"
  validates_presence_of :organisme_gestionnaire_id, :message => "Le champ <strong>établissement gestionnaire</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :organisme_financeur, :message => "Le champ <strong>organisme financeur</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :coordinateur, :message => "Le champ <strong>coordinateur</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :etablissement_gestionnaire_du_coordinateur, :message => "Le champ <strong>établissement gestionnaire du coordinateur</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :md_total, :message => "Le champ <strong>total des moyens demandés</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :total_subvention, :message => "Le champ <strong>total subvention</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :taux_subvention, :message => "Le champ <strong>taux subvention</strong> est un champ obligatoire, merci de le renseigner"
  validates_uniqueness_of :contrat_id, :message => "Enregistrement impossible : une seule soumission peut être enregistrée par contrat."
  validates_inclusion_of  :nombre_mois, :in => 1..9999, :message => "Le champ <strong>Nombre de mois</strong> doit être entre 1 et 180"
  validates_numericality_of :md_fonctionnement, :message => "Le champ <strong>moyens demandés en fonctionnement</strong> doit être saisi dans un format numérique."
  validates_numericality_of :md_equipement, :message => "Le champ <strong>moyens demandés en équipement</strong> doit être saisi dans un format numérique."
  validates_numericality_of :md_salaire, :message => "Le champ <strong>moyens demandés en salaire</strong> doit être saisi dans un format numérique."
  validates_numericality_of :md_mission, :message => "Le champ <strong>moyens demandés en mission</strong> doit être saisi dans un format numérique."
  validates_numericality_of :md_non_ventile, :message => "Le champ <strong>moyens demandés non ventilé</strong> doit être saisi dans un format numérique."
  validates_numericality_of :md_couts_indirects, :message => "Le champ <strong>moyens demandés coûts indirects</strong> doit être saisi dans un format numérique."
  validates_numericality_of :md_allocation, :message => "Le champ <strong>moyens demandés en allocation</strong> doit être saisi dans un format numérique."
  validates_numericality_of :md_total, :message => "Le champ <strong>total des moyens demandés</strong> doit être saisi dans un format numérique."
  validates_numericality_of :taux_subvention, :message => "Le champ <strong>taux de subvention</strong> doit être saisi dans un format numérique."
  validates_numericality_of :total_subvention, :message => "Le champ <strong>total subvention</strong> doit être saisi dans un format numérique."
  validates_inclusion_of  :taux_subvention, :in => 0..1, :message => "Le champ <strong>taux de subvention</strong> doit être entre 0 et 1"
  validates_date          :date_depot, :message => "Le champ <strong>Date de dépôt</strong> contient une date non valide"
  
  attr_accessible :contrat_type_id, :nombre_mois, :organisme_gestionnaire_id, :organisme_financeur, :porteur, :etablissement_rattachement_porteur, :est_porteur, :coordinateur, :etablissement_gestionnaire_du_coordinateur, 
                  :mots_cles_libres, :thematiques, :poles_competivites, :md_type_montant, :md_fonctionnement, :md_equipement, :md_salaire, :md_mission, :md_non_ventile, :md_couts_indirects, :md_allocation, :taux_subvention, 
                  :total_subvention, :pd_doctorant, :pd_post_doc, :pd_ingenieur, :pd_autre, :key_word_ids, :md_total, :pd_equivalent_temps_plein, :date_depot
  
  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
                
  after_create :up_contrat_etat
  after_destroy :down_contrat_etat              
  
  def up_contrat_etat
    update_contrat_etat("soumission")   
  end
  
  def down_contrat_etat
    update_contrat_etat("init")
  end
  
  def update_contrat_etat(nouvel_etat)
    c = self.contrat
    c.etat = nouvel_etat
    c.save
  end   
  
  #Surcharge de la methode de copie
  def clone   
    new_soumission = self.dup
    
    for france_partenaire in self.soumission_france_partenaires do
      new_france_partenaire= france_partenaire.dup
      new_soumission.soumission_france_partenaires << new_france_partenaire
    end
    
    for europe_partenaire in self.soumission_europe_partenaires do
      new_europe_partenaire= europe_partenaire.dup
      new_soumission.soumission_europe_partenaires << new_europe_partenaire
    end
    
    for partenaire in self.soumission_partenaires do
      new_partenaire= partenaire.dup
      new_soumission.soumission_partenaires << new_partenaire
    end
    
    for personnel in self.soumission_personnels do
      new_personnel= personnel.dup
      new_soumission.soumission_personnels << new_personnel
    end
    
    for key_word in self.key_words do
      new_soumission.key_words << key_word
    end
    new_soumission.verrou = 'Aucun'
    new_soumission.verrou_listchamps = nil
    return new_soumission  
  end
  
  def equivalent_temps_plein_personnel
    total = 0.000000
		for personne in self.soumission_personnels
			total = total + personne.pourcentage
		end
    total = total / 100
    return total
  end
  
  def get_non_modifiables
    non_modifiables = []
    if (self.verrou == 'SI INRIA') and self.verrou_listchamps
      verrou_listchamps_tableau = self.verrou_listchamps.split(';')
      for champ in verrou_listchamps_tableau do
        non_modifiables << champ
      end
    end
    return non_modifiables
  end
  
  def come_from_inria?
    true if self.verrou == "SI INRIA" || false
  end
  
end
