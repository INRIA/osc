#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseSalaire < ActiveRecord::Base
  belongs_to :ligne
  has_many :depense_salaire_factures, :dependent => :destroy

  validates_presence_of :agent
  validates_presence_of :type_contrat
  validates_presence_of :statut

  validates_presence_of     :nb_mois
  validates_numericality_of :nb_mois

  validates_presence_of     :cout_mensuel
  validates_numericality_of :cout_mensuel

  validates_presence_of     :cout_periode
  validates_numericality_of :cout_periode

  validates_presence_of     :nb_heures_declarees, :if => :type_is_titulaire?
  validates_numericality_of :nb_heures_declarees, :only_integer => true, :if => :type_is_titulaire?

  validates_presence_of     :nb_heures_justifiees, :if => :type_is_known?
  validates_numericality_of :nb_heures_justifiees, :only_integer => true, :if => :type_is_known?

  validates_presence_of     :cout_indirect_unitaire, :if => :type_is_known?
  validates_numericality_of :cout_indirect_unitaire, :if => :type_is_known?

  validates_presence_of     :somme_salaires_charges, :if => :type_is_known?
  validates_numericality_of :somme_salaires_charges, :if => :type_is_known?
  
  validates_presence_of     :pourcentage
  validates_numericality_of :pourcentage

  validates_date  :date_debut,
                  :before => Proc.new{ |r| r.ligne.date_fin_depenses + 1.day },
                  :after => Proc.new{ |r| r.ligne.date_debut- 1.day},
                  :before_message => "doit être antérieur à la date de cloture (fin des dépenses) de la ligne",
                  :after_message => "doit être postérieure à la date de début de la période de la ligne",
                  :message => "n'est pas valide"

  validates_date  :date_fin,
                  :before => Proc.new{ |r| r.ligne.date_fin_depenses + 1.day },
                  :after => Proc.new{ |r| r.ligne.date_debut- 1.day},
                  :before_message => "doit être antérieur à la date de cloture (fin des dépenses) de la ligne",
                  :after_message => "doit être postérieure à la date de début de la période de la ligne",
                  :message => "n'est pas valide"

  validate :date_fin_cannot_be_greater_than_date_debut
  
  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
   
  attr_accessible :ligne_id, :agent_si_origine, :agent, :type_contrat, :statut, :date_debut, :date_fin, :structure, 
                  :nb_mois, :cout_mensuel, :pourcentage, :commentaire, :commande_solde, :tache, :eligible, :type_personnel, 
                  :date_debut_prise_en_charge_sur_contrat, :date_fin_prise_en_charge_sur_contrat, :nb_heures_declarees, :nb_heures_justifiees, 
                  :cout_indirect_unitaire, :somme_salaires_charges, :cout_periode, :type_activite, :code_analytique, :compte_budgetaire, :code_projet
               
  def date_fin_cannot_be_greater_than_date_debut
      if self.date_debut > self.date_fin
        errors.add(:date_fin, " : la date de fin doit être supérieure à la date de début")
      end
  end
  #retourne le nombre de mois calcule a partir des dates de debut et de fin
  def compute_nb_mois
    nb_mois_int = (self.date_fin.to_date.year*12+self.date_fin.to_date.month) - (self.date_debut.to_date.year*12+self.date_debut.to_date.month)   
    days_in_first_month = self.date_debut.to_date.day
    days_in_last_month =  self.date_fin.to_date.day 
    month_ratio_for_first_month = (Time.days_in_month(self.date_debut.to_date.month, self.date_debut.to_date.year)-days_in_first_month+1).to_f/Time.days_in_month(self.date_debut.to_date.month, self.date_debut.to_date.year)
    month_ratio_for_last_month = days_in_last_month.to_f/Time.days_in_month(self.date_fin.to_date.month, self.date_fin.to_date.year)
    nb_mois = nb_mois_int - 1+month_ratio_for_last_month+month_ratio_for_first_month
    return nb_mois
  
  end
  
  def type_is_titulaire?
    self.type_personnel == 'Titulaire'
  end

  def type_is_contractuel?
    self.type_personnel == 'Contractuel'
  end

  def type_is_known?
    self.type_personnel == 'Titulaire' || self.type_personnel == 'Contractuel'
  end

  def cout_indirect_total
    if !self.cout_indirect_unitaire.nil? && !self.nb_heures_justifiees.nil?
      self.cout_indirect_unitaire * self.nb_heures_justifiees
    else
      0
    end
  end

  def cout_total
    if !self.somme_salaires_charges.nil?
      self.somme_salaires_charges + self.cout_indirect_total
    else
      self.cout_indirect_total
    end
  end

  def self.localized_human_attribute_name(attr)
    return case attr
      when "agent" then "Agent"
      when "type_contrat" then "Type de contrat"
      when "statut" then "Statut"
      when "date_debut" then "Date de début"
      when "date_fin" then "Date de fin"
      when "nb_mois" then "Nombre de mois"
      when "cout_mensuel" then "Coût mensuel"
      when "cout_periode" then "Coût période"
      when "nb_heures_declarees" then "Nombre d'heures déclarées"
      when "nb_heures_justifiees" then "Nombre d'heures justifiées"
      when "cout_indirect_unitaire" then "Coût indirect unitaire"
      when "somme_salaires_charges" then "Somme des salaires chargés"
      else attr.humanize
    end
  end

  # dates minimum et maximum des factures
  # max = la + grande des dates entre :
  #       * la + grande des dates de facture
  #       * la + grande des dates millesime des factures
  #       * les dates de debut et fin de la depense
  # min = la + petite de ces dates
  def update_dates_min_max
    if self.depense_salaire_factures.size != 0
      facture_date_max = [self.depense_salaire_factures.maximum(:date_mandatement),self.depense_salaire_factures.maximum(:millesime)||self.date_fin].max 
      self.date_max = [facture_date_max, self.date_fin].max
      facture_date_min = [self.depense_salaire_factures.minimum(:date_mandatement),self.depense_salaire_factures.minimum(:millesime)||self.date_debut].min 
      self.date_min = [facture_date_min, self.date_debut].min
    else
      self.date_max = self.date_fin
      self.date_min = self.date_debut
    end
  end

  def montant_factures(include_taxes = 'htr', date_start = '1900-01-01', date_end = '4000-01-01')
    if (include_taxes == 'ttc')
      montant_method = :cout
    elsif (include_taxes == 'ht')
      montant_method = :cout
    elsif (include_taxes == 'htr')
      montant_method = :montant_htr
      find_conditions = "#{montant_method} IS NOT NULL"
    else
      throw 'Invalid include_taxes: '+include_taxes+'.'
    end

    factures = self.depense_salaire_factures.find(:all, :conditions => find_conditions)
    somme = 0
    for facture in factures
      if facture.millesime.nil?
        date_facture = facture.date_mandatement
      else
        date_facture = facture.millesime
      end
      if date_facture.to_date <= date_end.to_date && date_facture.to_date >= date_start.to_date
        somme = somme + facture.send(montant_method)
      end
    end
    return somme
  end

  def montant(date_start = '1900-01-01', date_end = '4000-01-01', type_bilan = "sommes_engagees", type_montant = "ttc")
    if type_bilan == "sommes_engagees"
      if self.commande_solde && (self.montant_factures('ttc', date_start, date_end) !=0)
        self.montant_factures(type_montant, date_start, date_end)
      else
        if self.date_debut.to_date <= date_end.to_date && self.date_debut.to_date >= date_start.to_date
          self.cout_periode
        else
          0
        end
      end
#    elsif type_bilan =="sommes_engagees_htr"
#      if self.commande_solde && (self.montant_factures('htr', date_start, date_end) !=0)
#        self.montant_factures('htr', date_start, date_end)
#      else
#        if self.date_debut.to_date <= date_end.to_date && self.date_debut.to_date >= date_start.to_date
#          self.cout_periode
#        else
#          0
#        end
#      end
#    elsif type_bilan =="factures_htr"
#      self.montant_factures('htr', date_start, date_end)
    else
      self.montant_factures(type_montant, date_start, date_end)
    end
  end

  def montant_paye(type_montant = 'htr', date_start = '1900-01-01', date_end = '4000-01-01')
    if self.depense_salaire_factures.size != 0
      self.montant_factures(type_montant, date_start, date_end)
    elsif self.commande_solde && self.date_debut.to_date <= date_end.to_date && self.date_debut.to_date >= date_start.to_date
      self.cout_periode
    else
      0
    end    
  end

  def reporting_montant(date_start = '1900-01-01', date_end = '4000-01-01', type = 'facture_htr')
    if type == 'facture_htr'
      return self.montant_factures('htr', date_start, date_end)
    end

    if type == 'engage'
      if self.date_debut.to_date <= date_end.to_date && self.date_debut.to_date >= date_start.to_date
        return self.cout_total
      else
        return 0
      end
    end

    if type == 'engage_non_realise'
      if self.depense_salaire_factures.size == 0
        if self.date_debut.to_date <= date_end.to_date && self.date_debut.to_date >= date_start.to_date
          return self.cout_total
        else
          return 0
        end
      else
        return 0
      end
    end
  end


  def self.reporting_total_depense(ids = [], options = {})
    options   = options.stringify_keys
    date_min           = options["date_min"] || '1900-01-01'
    date_max           = options["date_max"] || '4000-01-01'
    type               = options["type"] || "realisees"
    type_personnel     = options["type_personnel"] || "unknown"
    eligible           = options["eligible"] || true
    type_activite      = options["type_activite"] || false

    # Dépenses provenants du système d'information de l'INRIA et éligibles
    # Calcul : somme des montants HTR des factures
    if type == "realisees"
      if type_activite == false
        conditions = ["ligne_id in (?) AND eligible = ? AND verrou = 'SI INRIA' AND type_personnel = ?", ids, eligible, type_personnel]
      else
        conditions = ["ligne_id in (?) AND eligible = ? AND verrou = 'SI INRIA' AND type_personnel in (?) AND type_activite = ?", ids, eligible, ['Contractuel', 'Titulaire'], type_activite]
      end
      return self.find(:all, :conditions => conditions).sum{ |d| d.reporting_montant(date_min.to_s, date_max.to_s, "facture_htr")}
    end

    # Dépenses ne provenants pas du système d'information de l'INRIA et éligibles.
    # Calcul : somme des montants engagés des demandes d'achat
    if type == "previsionnelles"
      if type_activite == false
        conditions = ["ligne_id in (?) AND eligible = ? AND verrou != 'SI INRIA' AND type_personnel = ?", ids, eligible, type_personnel]
      else
        conditions = ["ligne_id in (?) AND eligible = ? AND verrou != 'SI INRIA' AND type_personnel in (?) AND type_activite = ?", ids, eligible, ['Contractuel', 'Titulaire'], type_activite]
      end
      return self.find(:all, :conditions => conditions).sum{ |d| d.reporting_montant(date_min.to_s, date_max.to_s, "engage")}
    end

    # Dépenses provenants du système d'information de l'INRIA, éligibles et sans facture.
    # Calcul : somme des montants engagés des demandes d'achat
    if type == "engagees_non_realisees"
      if type_activite == false
        conditions = ["ligne_id in (?) AND eligible = ? AND verrou = 'SI INRIA' AND type_personnel = ?", ids, eligible, type_personnel]
      else
        conditions = ["ligne_id in (?) AND eligible = ? AND verrou = 'SI INRIA' AND type_personnel in (?) AND type_activite = ?", ids, eligible, ['Contractuel', 'Titulaire'], type_activite]
      end
      return self.find(:all, :conditions => conditions).sum{ |d| d.reporting_montant(date_min.to_s, date_max.to_s, "engage_non_realise")}
    end
  end




  def get_non_modifiables
    non_modifiables = []
    # Dé-commenter pour tester, si besoin ...
    #non_modifiables << 'agent'
    #non_modifiables << 'type_contrat'
    #non_modifiables << 'statut'
    #non_modifiables << 'date_debut'
    #non_modifiables << 'date_fin'
    #non_modifiables << 'tache'
    #non_modifiables << 'destination_budgetaire'
    #non_modifiables << 'eligible'
    #non_modifiables << 'type_activite'
    #non_modifiables << 'nb_mois'
    #non_modifiables << 'cout_mensuel'
    #non_modifiables << 'cout_periode'
    #non_modifiables << 'commande_solde'
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
  
  def agent_from_referentiel?
    true if ((self.agent_si_origine) and (self.agent_si_origine != "")) || false   
  end
  
  def nom_agent
    if !(self.agent_from_referentiel?)
      return self.agent
    else
      agent = ReferentielAgent.find(:first,:conditions =>["si_origine = ? AND si_id =?",self.agent_si_origine,self.agent])
      if agent
        return agent.nom+" "+agent.prenom+" ( "+self.agent_si_origine+" ) "
      else
        return "Agent introuvable dans le referentiel : "+self.agent_si_origine
      end
    end
  end

  def save
    self.ligne.activation
    super
  end
end
