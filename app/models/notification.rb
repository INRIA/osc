#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Notification < ActiveRecord::Base
  belongs_to :contrat
  belongs_to :organisme_gestionnaire
  has_many :notification_france_partenaires, :dependent => :destroy
  has_many :notification_europe_partenaires, :dependent => :destroy
  has_many :notification_partenaires, :dependent => :destroy
  has_many :notification_personnels, :dependent => :destroy
  has_many :sous_contrat_notifications, :dependent => :destroy
  has_many :avenants, :dependent => :destroy
  
  belongs_to :contrat_type
  has_and_belongs_to_many :key_words, :join_table => "key_words_notifications", :foreign_key => "notification_id"
  
  before_destroy :destroy_echeancier
  
  validates_presence_of :contrat_type_id, :message => "Le champ <strong>Type de Contrat</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :organisme_gestionnaire_id, :message => "Le champ <strong>établissement gestionnaire</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :organisme_financeur, :message => "Le champ <strong>organisme financeur</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :organisme_payeur, :message => "Le champ <strong>organisme payeur</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :porteur, :message => "Le champ <strong>porteur</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :etablissement_rattachement_porteur, :message => "Le champ <strong>établissement de rattachement</strong> du porteur est un champ obligatoire, merci de le renseigner"
  validates_presence_of :coordinateur, :message => "Le champ <strong>coordinateur</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :etablissement_gestionnaire_du_coordinateur, :message => "Le champ <strong>établissement gestionnaire du coordinateur</strong> est un champ obligatoire, merci de le renseigner"
  validates_presence_of :ma_total, :message => "Le champ <strong>total des moyens demandés</strong> est un champ obligatoire, merci de le renseigner"
  validates_uniqueness_of :contrat_id
  validates_inclusion_of  :nombre_mois, :in => 1..9999,:message => "Le champ <strong>nombre de mois</strong> devrait être entre 1 et 180"
  validates_numericality_of :ma_fonctionnement, :message => "Le champ <strong>moyens accordés en fonctionnement</strong> doit être saisi dans un format numérique."
  validates_numericality_of :ma_equipement, :message => "Le champ <strong>moyens accordés en équipement</strong> doit être saisi dans un format numérique."
  validates_numericality_of :ma_salaire, :message => "Le champ <strong>moyens accordés en salaire</strong> doit être saisi dans un format numérique."
  validates_numericality_of :ma_mission, :message => "Le champ <strong>moyens accordés en mission</strong> doit être saisi dans un format numérique."
  validates_numericality_of :ma_non_ventile, :message => "Le champ <strong>moyens accordés non ventilé</strong> doit être saisi dans un format numérique."
  validates_numericality_of :ma_couts_indirects, :message => "Le champ <strong>moyens accordés coûts indirects</strong> doit être saisi dans un format numérique."
  validates_numericality_of :ma_frais_gestion_mutualises_local, :message => "Le champ <strong>moyens accord&eacute;s frais de gestion mut. loc. ou non justifi&eacute;s</strong> doit être saisi dans un format numérique."
  validates_numericality_of :ma_frais_gestion_mutualises, :message => "Le champ <strong>moyens accord&eacute; frais de gestion mutualis&eacute;s nationaux</strong> doit être saisi dans un format numérique."
  validates_numericality_of :ma_allocation, :message => "Le champ <strong>moyens accordés en allocation</strong> doit être saisi dans un format numérique."
  validates_numericality_of :ma_total, :message => "Le champ <strong>total des moyens accordés</strong> doit être saisi dans un format numérique."
  validates_numericality_of :pa_doctorant, :message => "Le champ <strong>personnel accordé - Doctorant</strong> doit être saisi dans un format numérique."
  validates_numericality_of :pa_post_doc, :message => "Le champ <strong>personnel accordé - Post_doc</strong> doit être saisi dans un format numérique."
  validates_numericality_of :pa_ingenieur, :message => "Le champ <strong>personnel accordé - Ingénieur</strong> doit être saisi dans un format numérique."
  validates_numericality_of :pa_autre, :message => "Le champ <strong>personnel accordé - Autre</strong> doit être saisi dans un format numérique."
  validates_numericality_of :pa_equivalent_temps_plein, :message => "Le champ <strong>personnel accordé - Equivalent temps plein</strong> doit être saisi dans un format numérique."
  validates_date  :date_debut, :message => "Le champ <strong>Date de début</strong> contient une date non valide"
  validates_date  :date_fin, :message => "Le champ <strong>Date de fin</strong> contient une date non valide"
  validates_date  :date_notification, :message => "Le champ <strong>Date de notification</strong> contient une date non valide"
 
  attr_accessible :contrat_type_id, :nombre_mois, :organisme_gestionnaire_id, :organisme_financeur, :organisme_payeur, :numero_ligne_budgetaire, :numero_contrat, :porteur, :etablissement_rattachement_porteur, :est_porteur, 
                  :coordinateur, :etablissement_gestionnaire_du_coordinateur, :url, :mots_cles_libres, :thematiques, :poles_competivites, :ma_allocation, :ma_total, :pa_doctorant, :pa_post_doc, :pa_ingenieur, :pa_autre, 
                  :pa_equivalent_temps_plein, :key_word_ids, :date_notification, :date_debut, :date_fin, :a_justifier, :ma_type_montant, :ma_fonctionnement, :ma_equipement, :ma_salaire, :ma_mission, :ma_non_ventile, 
                  :ma_couts_indirects, :ma_frais_gestion_mutualises_local, :ma_frais_gestion_mutualises
  
  
  #controle supprime puisqu'on prend en compte la date de millesime dans date_min qui est generalement fixe au debut de l'annee                
  #validates_date  :date_debut,
  #                :on => :update,
  #                :before => Proc.new { |n| n.date_min },
  #                :before_message => "la <strong>date de début</strong> doit être antérieur à toutes les dates des versements ou factures des lignes correspondantes au contrat"
  
  #controle supprimé puisqu'on permet la saisie de dépenses après la fin d'un contrat
  #validates_date  :date_fin,
  #               :on => :update,
  #              :after => Proc.new { |n| n.date_max },
  #             :after_message => "la <strong>date de fin</strong> doit être postérieur à toutes les dates des versements ou factures des lignes correspondantes au contrat"
  
  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
  
  after_create :up_contrat_etat
  after_destroy :down_contrat_etat              
  
  def up_contrat_etat
    update_contrat_etat("notification")  
  end
  
  def down_contrat_etat
    update_contrat_etat("signature")
  end
  
  def update_contrat_etat(nouvel_etat)
    c = self.contrat
    c.etat = nouvel_etat
    c.save
  end   
  
  #Surcharge de la methode de copie
  def clone   
    new_notification = self.dup
    
    for france_partenaire in self.notification_france_partenaires do
      new_france_partenaire= france_partenaire.dup
      new_notification.notification_france_partenaires << new_france_partenaire
    end
    
    for europe_partenaire in self.notification_europe_partenaires do
      new_europe_partenaire= europe_partenaire.dup
      new_notification.notification_europe_partenaires << new_europe_partenaire
    end
    
    for partenaire in self.notification_partenaires do
      new_partenaire= partenaire.dup
      new_notification.notification_partenaires << new_partenaire
    end
    
    for personnel in self.notification_personnels do
      new_personnel= personnel.dup
      new_notification.notification_personnels << new_personnel
    end
    
    for avenant in self.avenants do
      new_avenant= avenant.dup
      new_notification.avenants << new_avenant
    end
    
    for key_word in self.key_words do
      new_notification.key_words << key_word
    end
    new_notification.verrou = 'Aucun'
    new_notification.verrou_listchamps = nil
    return new_notification  
  end
  
  def date_min
    @dates = ["9999-01-01".to_date]
    for sc in self.contrat.sous_contrats
      if !sc.ligne.nil?
        @dates << sc.ligne.date_min
      end
    end
    return @dates.min + 1
  end
  
  def date_max
    @dates = ["0000-01-01".to_date]
    for sc in self.contrat.sous_contrats
      if !sc.ligne.nil?
        @dates << sc.ligne.date_max
      end
    end
    return @dates.max
  end
  
  def destroy_echeancier
    if !self.contrat.echeancier.nil?
      self.contrat.echeancier.destroy
    end
    if !self.contrat.sous_contrats.nil?
      self.contrat.sous_contrats.each do |sc|
        if !sc.echeancier.nil?
          sc.echeancier.destroy
        end
      end
    end
  end
  
  def equivalent_temps_plein_personnel
    total = 0.000000
		for personne in self.notification_personnels
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
