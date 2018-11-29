#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Ligne < ActiveRecord::Base
  include TypePere

  belongs_to :sous_contrat

  has_many :versements,  :dependent => :destroy
  has_many :depense_fonctionnements,  :dependent => :destroy
  has_many :depense_equipements,  :dependent => :destroy
  has_many :depense_missions,  :dependent => :destroy
  has_many :depense_salaires,  :dependent => :destroy
  has_many :depense_non_ventilees,  :dependent => :destroy
  has_many :depense_communs,  :dependent => :destroy

  attr_reader :contrat_dotation

  validates_presence_of :sous_contrat_id

  before_update 'self.updated_by = User.current_user.id'
  before_create 'self.created_by = User.current_user.id',
                'self.updated_by = User.current_user.id'
  
  attr_accessible :sous_contrat_id
    
  def self.my_find_all( ids_contrats,
                        acronyme_research = "Acronyme",
                        noContrat_research = "NumContrat",
                        equipe_research = "Equipe",
                        laboratoire_research = "Laboratoire",
                        departement_research = "",
                        in_laboratoire = "",
                        in_departement = "",
                        in_tutelle = "",
                        show_contrat_clos ="no")

    
      if (acronyme_research == "Acronyme") or (acronyme_research == "") or (acronyme_research == "%%")
        acronyme_research = nil
      elsif acronyme_research.include? " + "
         acronyme_research_array = acronyme_research.split(" + ")
      end
      end
      if (noContrat_research == "NumContrat") or (noContrat_research == "") or (noContrat_research == "%%")
        noContrat_research = nil
      elsif noContrat_research.include? " + "
         noContrat_research_array = noContrat_research.split(" + ")
      end
      if (equipe_research == "Equipe") or (equipe_research == "") or (equipe_research == "%%")
        equipe_research = nil
      elsif equipe_research.include? " + "
         equipe_research_array = equipe_research.split(" + ")
      end
      if (laboratoire_research == "Laboratoire") or (laboratoire_research == "") or (laboratoire_research == "%%")
        laboratoire_research = nil
      end
      if (departement_research == "") or (departement_research == "%%")
        departement_research = nil
      end
      if (in_laboratoire == "") or (in_laboratoire == "%%")
        in_laboratoire = nil
      end
      if (in_departement == "") or (in_departement == "%%")
        in_departement = nil
      end
      if (in_tutelle == "") or (in_tutelle == "%%")
        in_tutelle = nil
      end
      
      query = Array.new 
      query_string = "SELECT distinct lignes.id FROM lignes"
      query_string +=" inner join sous_contrats as sous_contrats_ligne on sous_contrats_ligne.id = lignes.sous_contrat_id"
      query_string +=" inner join contrats as contrats_ligne on contrats_ligne.id = sous_contrats_ligne.contrat_id "
      query_where_string = " where contrats_ligne.id in (?) and "
      query.push ids_contrats
      if(show_contrat_clos == "lignes_desactivees")
        query_where_string += "contrats_ligne.etat != \'cloture\' and " 
      elsif(show_contrat_clos == "no")
        query_where_string += "lignes.active is true and contrats_ligne.etat != \'cloture\' and "
      elsif(show_contrat_clos == "yes")
        query_where_string += "lignes.active is true and "
      end
      if acronyme_research
        if acronyme_research_array
          acronyme_research_iterator = 1
          for acronyme in  acronyme_research_array
            if acronyme_research_iterator == 1
              query_where_string +="("
            end            
            if acronyme_research_iterator == acronyme_research_array.length
              query_where_string += "contrats_ligne.acronyme like ? ) and "
            else
              query_where_string += "contrats_ligne.acronyme like ? or "  
            end
            query.push "%"+acronyme+"%"  
            acronyme_research_iterator += 1
          end
        else
          query_where_string += "contrats_ligne.acronyme like ? and "
          query.push "%"+acronyme_research+"%"
        end     
      end
      if noContrat_research
        if noContrat_research_array
          noContrat_research_array_iterator = 1
          for noContrat in  noContrat_research_array
            if noContrat_research_array_iterator == 1
              query_where_string +="("
            end            
            if noContrat_research_array_iterator == noContrat_research_array.length
              query_where_string += "contrats_ligne.num_contrat_etab like ? ) and "
            else
              query_where_string += "contrats_ligne.num_contrat_etab like ? or "  
            end
            query.push "%"+noContrat+"%"  
            noContrat_research_array_iterator += 1
          end
        else
          query_where_string += "contrats_ligne.num_contrat_etab like ? and "
          query.push "%"+noContrat_research+"%"
        end   
      end
      if equipe_research
        query_string += " inner join sous_contrats as sc_equipe_research on sc_equipe_research.id = lignes.sous_contrat_id and sc_equipe_research.entite_type = 'Projet'
                         inner join projets as p_equipe_research on sc_equipe_research.entite_id = p_equipe_research.id"
        if equipe_research_array
          equipe_iterator = 1
          for equipe in  equipe_research_array
            if equipe_iterator == 1
              query_where_string +="("
            end            
            if equipe_iterator == equipe_research_array.length
              query_where_string += "p_equipe_research.nom like ? ) and "
            else
              query_where_string += "p_equipe_research.nom like ? or "  
            end
            query.push "%"+equipe+"%"  
            equipe_iterator += 1
          end
        else
          query_where_string += "p_equipe_research.nom like ? and "
          query.push "%"+equipe_research+"%"  
        end        
      end
      if laboratoire_research
        query_string += " inner join sous_contrats as sc_laboratoire_research on sc_laboratoire_research.id = lignes.sous_contrat_id and sc_laboratoire_research.entite_type = 'Laboratoire'
                         inner join laboratoires as l_laboratoire_research on sc_laboratoire_research.entite_id = l_laboratoire_research.id"
        query_where_string += "l_laboratoire_research.nom like ? and "
        query.push "%"+laboratoire_research+"%"
      end
      if departement_research
        query_string += " inner join sous_contrats as sc_departement_research on sc_departement_research.id = lignes.sous_contrat_id and sc_departement_research.entite_type = 'Departement'
                         inner join departements as d_departement_research on sc_departement_research.entite_id = d_departement_research.id"
        query_where_string += "d_departement_research.nom like ? and "
        query.push "%"+departement_research+"%"
      end
      if in_laboratoire
        query_string += " left outer join sous_contrats as sc_in_laboratoire_1 on sc_in_laboratoire_1.id = lignes.sous_contrat_id and sc_in_laboratoire_1.entite_type = 'Projet'
                          left outer join laboratoire_subscriptions as ls_in_laboratoire on sc_in_laboratoire_1.entite_id = ls_in_laboratoire.projet_id
                          left outer join laboratoires as l_in_laboratoire_1 on l_in_laboratoire_1.id = ls_in_laboratoire.laboratoire_id
                          left outer join sous_contrats as sc_in_laboratoire_2 on sc_in_laboratoire_2.id = lignes.sous_contrat_id and sc_in_laboratoire_2.entite_type = 'Laboratoire'
                          left outer join laboratoires as l_in_laboratoire_2 on sc_in_laboratoire_2.entite_id = l_in_laboratoire_2.id
                          left outer join sous_contrats as sc_in_laboratoire_3 on sc_in_laboratoire_3.id = lignes.sous_contrat_id and sc_in_laboratoire_3.entite_type = 'Departement'
                          left outer join departements as d_in_laboratoire_1 on sc_in_laboratoire_3.entite_id = d_in_laboratoire_1.id
                          left outer join laboratoires as l_in_laboratoire_3 on d_in_laboratoire_1.laboratoire_id = l_in_laboratoire_3.id
                          left outer join sous_contrats as sc_in_laboratoire_4 on sc_in_laboratoire_4.id = lignes.sous_contrat_id and sc_in_laboratoire_4.entite_type = 'Projet'
                          left outer join departement_subscriptions as ds_in_laboratoire on sc_in_laboratoire_4.entite_id = ds_in_laboratoire.projet_id
                          left outer join departements as d_in_laboratoire_2 on d_in_laboratoire_2.id = ds_in_laboratoire.departement_id
                          left outer join laboratoires as l_in_laboratoire_4 on d_in_laboratoire_2.laboratoire_id = l_in_laboratoire_4.id"
        query_where_string += "(l_in_laboratoire_1.nom like ? or l_in_laboratoire_2.nom like ? or l_in_laboratoire_3.nom like ? or l_in_laboratoire_4.nom like ?) and "
        query.push "%"+in_laboratoire.to_s+"%"
        query.push "%"+in_laboratoire.to_s+"%"
        query.push "%"+in_laboratoire.to_s+"%"
        query.push "%"+in_laboratoire.to_s+"%"
      end
      if in_departement
        query_string += " left outer join sous_contrats as sc_in_departement_1 on sc_in_departement_1.id = lignes.sous_contrat_id and sc_in_departement_1.entite_type = 'Projet'
                          left outer join departement_subscriptions as ds_in_departement on sc_in_departement_1.entite_id = ds_in_departement.projet_id
                          left outer join departements as departement_in_departement_1 on departement_in_departement_1.id = ds_in_departement.departement_id
                          left outer join sous_contrats as sc_in_departement_2 on sc_in_departement_2.id = lignes.sous_contrat_id and sc_in_departement_2.entite_type = 'Departement'
                          left outer join departements as departement_in_departement_2 on sc_in_departement_2.entite_id = departement_in_departement_2.id"
        query_where_string += "(departement_in_departement_1.nom like ? or departement_in_departement_2.nom like ?) and "
        query.push "%"+in_departement.to_s+"%"
        query.push "%"+in_departement.to_s+"%"
      end
      if in_tutelle
        query_string += " inner join sous_contrats as sc_in_tutelle on sc_in_tutelle.id = lignes.sous_contrat_id and sc_in_tutelle.entite_type = 'Projet'
                       inner join tutelle_subscriptions as ts_in_tutelle on sc_in_tutelle.entite_id = ts_in_tutelle.projet_id
                       inner join tutelles as t_in_tutelle on t_in_tutelle.id = ts_in_tutelle.tutelle_id"
        query_where_string += "t_in_tutelle.nom like ? and "
        query.push "%"+in_tutelle.to_s+"%"
      end
      query_where_string += "true"
      query.insert(0, (query_string+query_where_string) )
      
      
      ids_lignes = Ligne.find_by_sql(query)
    return ids_lignes
  end
  
  def self.find_all_with_projects_for(user,show_contrat_clos ="no")
    if user.id == User.current_user.id and @ids_mes_equipes
      projets_id = @ids_mes_equipes   
    else
      projets_id = Projet.find_all_team_for(user)  
    end
        
    req_string = "SELECT distinct l.id FROM lignes l
                  inner join sous_contrats sc on sc.id = l.sous_contrat_id
                  inner join projets p on p.id = sc.entite_id
                  inner join contrats c on c.id = sc.contrat_id
          WHERE sc.entite_type = 'Projet'
          AND p.id IN (?)"
    if show_contrat_clos =='yes'
      req_string += ' and l.active is true'
    elsif show_contrat_clos =='lignes_desactivees'
      req_string += ' and c.etat != \'cloture\''
    elsif show_contrat_clos == 'no'
      req_string += ' and l.active is true and c.etat != \'cloture\''
    end
    req = [req_string, projets_id]
    ids_lignes  = Ligne.find_by_sql(req).collect{|l| l.id}
    return ids_lignes
  end
  
  def activation
    if !self.active
      self.active = true
      self.save
    end
  end
  
  def desactivation
    if self.active
      self.active = false
      self.save
    end
  end
  
  def periodes
    if self.has_periods?
      if self.sous_contrat.contrat.sous_contrats.size >1
        self.sous_contrat.echeancier.echeancier_periodes
      else
        self.sous_contrat.contrat.echeancier.echeancier_periodes
      end
    else
      return nil
    end
  end

  def has_periods?
    if !self.sous_contrat.contrat.echeancier.nil?
      !self.sous_contrat.contrat.echeancier.echeancier_periodes.nil?
    else
      false
    end
  end

  # retourne les ids des lignes que l'utilisateur courant peut consulter
  def self.find_all_consultable(current_user)
    valid_contrats = Contrat.find_all_consultable(current_user)
    req = ["SELECT l.id FROM lignes l, sous_contrats sc, contrats c
          WHERE sc.contrat_id = c.id AND l.sous_contrat_id = sc.id
            AND c.id IN (?)", valid_contrats]
    return Ligne.find_by_sql(req).collect{|l| l.id}
  end

  # retourne les ids des lignes que l'utilisateur courant peut consulter
  def self.find_all_editable(current_user)
    valid_contrats = Contrat.find_all_budget_editable(current_user)
    req = ["SELECT l.id FROM lignes l, sous_contrats sc, contrats c
          WHERE sc.contrat_id = c.id AND l.sous_contrat_id = sc.id
            AND c.id IN (?)", valid_contrats]
    return Ligne.find_by_sql(req).collect{|l| l.id}
  end

  def etat
    return self.sous_contrat.etat
  end

  def update_record_without_timestamping
    class << self
      def record_timestamps; false; end
    end

    save!

    class << self
      def record_timestamps; super ; end
    end
  end


  def update_nom
    unless self.sous_contrat.contrat.num_contrat_etab.blank?
        self.nom =  self.sous_contrat.contrat.acronyme+"-"+self.sous_contrat.contrat.num_contrat_etab+" - "+self.sous_contrat.entite.nom
    else
        self.nom =  self.sous_contrat.contrat.acronyme+" - "+self.sous_contrat.entite.nom
    end
    self.update_record_without_timestamping
  end

  def organisme_gestionnaire
    return self.contrat.notification.organisme_gestionnaire
  end

  def entite
    return self.sous_contrat.entite
  end

  def taux_by_year(year)
    if self.organisme_gestionnaire.organisme_gestionnaire_tauxes.find_by_annee(year).nil?
      1
    else
      self.organisme_gestionnaire.organisme_gestionnaire_tauxes.find_by_annee(year).taux
    end
  end

  def contrat
    self.sous_contrat.contrat
  end

  # Date qui servira aux contrôles des dates de commande, de facture, de mandatement des
  # différentes dépenses saisies : tant que le contrat n'est pas cloturé, on peut saisir
  # des dépenses (limite non bornée)
  def date_fin_depenses
    if !self.sous_contrat.contrat.cloture.nil?
      self.sous_contrat.contrat.cloture.date_fin_depenses
    else
      #dates=[]
      #dates << self.sous_contrat.contrat.notification.date_fin
      #dates.max + 2.years
      "9999-01-01".to_date
    end
  end

  def date_debut
    [(self.sous_contrat.contrat.notification.date_debut.year.to_s+"-01-01").to_date,self.date_min].min
  end

  def date_fin
    @dates =[]
    @dates << self.sous_contrat.contrat.notification.date_fin
    if !self.sous_contrat.contrat.cloture.nil?
      @dates << self.sous_contrat.contrat.cloture.date_fin_depenses
    end
    @dates.max
  end

  # date de fin de selection possible : date max entre date de fin/date de cloture
  #  et dates max des dépenses saisies
  def date_fin_selection
    [self.date_fin,self.date_max].max
  end

  # date min de toutes les opérations de la ligne
  def date_min
    [self.versements_date_min, self.communs_date_min, self.fonctionnements_date_min, self.equipements_date_min, self.missions_date_min, self.salaires_date_min, self.non_ventilees_date_min].min
  end

  # date max de toutes les opérations de la ligne
  def date_max
    [self.versements_date_max, self.communs_date_max, self.fonctionnements_date_max, self.equipements_date_max, self.missions_date_max, self.salaires_date_max, self.non_ventilees_date_max].max
  end

  def versements_date_min
    self.versements.minimum(:date_effet) || "9999-01-01".to_date
  end

  def versements_date_max
    self.versements.maximum(:date_effet) || "0000-01-01".to_date
  end

  def communs_date_min
    self.depense_communs.minimum(:date_min) || "9999-01-01".to_date
  end

  def communs_date_max
    self.depense_communs.maximum(:date_max) || "0000-01-01".to_date
  end

  def fonctionnements_date_min
    self.depense_fonctionnements.minimum(:date_min) || "9999-01-01".to_date
  end

  def fonctionnements_date_max
    self.depense_fonctionnements.maximum(:date_max) || "0000-01-01".to_date
  end

  def equipements_date_min
    self.depense_equipements.minimum(:date_min) || "9999-01-01".to_date
  end

  def equipements_date_max
    self.depense_equipements.maximum(:date_max) || "0000-01-01".to_date
  end

  def missions_date_min
    self.depense_missions.minimum(:date_min) || "9999-01-01".to_date
  end

  def missions_date_max
    self.depense_missions.maximum(:date_max) || "0000-01-01".to_date
  end

  def salaires_date_min
    self.depense_salaires.minimum(:date_min) || "9999-01-01".to_date
  end

  def salaires_date_max
    self.depense_salaires.maximum(:date_max) || "0000-01-01".to_date
  end

  def non_ventilees_date_min
    self.depense_non_ventilees.minimum(:date_min) || "9999-01-01".to_date
  end

  def non_ventilees_date_max
    self.depense_non_ventilees.maximum(:date_max) || "0000-01-01".to_date
  end

  def contrat_dotation
    find_type_pere(self.contrat.notification.contrat_type_id) == ID_CONTRAT_DOTATION
  end

end
