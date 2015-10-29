#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Contrat < ActiveRecord::Base
  include TypePere

  acts_as_authorizable

  has_many :soumission_partenaires, :through => :soumission
  has_many :soumission_france_partenaires, :through => :soumission
  has_many :soumission_europe_partenaires, :through => :soumission
  has_many :soumission_personnels, :through => :soumission

  has_many :notification_partenaires, :through => :notification
  has_many :notification_france_partenaires, :through => :notification
  has_many :notification_europe_partenaires, :through => :notification
  has_many :notification_personnels, :through => :notification

  has_many :projets, :through => :sous_contrats, :source => :entite, :source_type => 'Projet'
  has_many :departements, :through => :sous_contrats, :source => :entite, :source_type => 'Departement'
  has_many :laboratoires, :through => :sous_contrats, :source => :entite, :source_type => 'Laboratoire'

  has_many :todolists, :order => "position",  :dependent => :destroy
  has_many :todoitems, :through => :todolists

  has_many :sous_contrats,  :dependent => :destroy
  has_many :contrat_files,  :dependent => :destroy, :order => "created_at DESC"

  has_many :descriptifs, :dependent => :destroy

  has_one :soumission, :dependent => :destroy
  has_one :signature, :dependent => :destroy
  has_one :refu, :dependent => :destroy
  has_one :notification, :dependent => :destroy
  has_one :cloture, :dependent => :destroy

  has_one :echeancier, :as => :echeanciable, :dependent => :destroy
  has_many :roles , :as => :authorizable
  belongs_to :etablissement, :polymorphic => true
  belongs_to :laboratoire, foreign_key: 'etablissement_id', conditions: "contrats.etablissement_type = 'Laboratoire'"
  
  validates_presence_of :nom, :message => "est obligatoire"
  validates_presence_of :acronyme, :message => "est obligatoire"
  validates_length_of :num_contrat_etab, :within => 0..25, :message => "ne doit pas dépasser 25 caractères"
  
  
  attr_reader :contrat_dotation
  attr_accessible :etablissement_id, :etablissement_type
  
  before_update :strip_name_and_update
  before_create 'self.created_by = User.current_user.id',
                :strip_name_and_update
                
  def strip_name_and_update
    self.acronyme = self.acronyme.strip
    self.nom = self.nom.strip
    self.num_contrat_etab = self.num_contrat_etab.strip
    self.updated_by = User.current_user.id
  end

  #Surcharge de la methode de copie
  def clone
    ActiveRecord::Base.transaction do
      new_contrat = self.dup
      new_contrat.save
      #contrat_files: on ne les copie pas (choix metier)
      #todolists, todoitems : on ne les copie pas (choix metier)
      #descriptifs : on ne les copie pas (choix metier)

      #soumission
      if self.soumission
        new_soumission = self.soumission.clone
        new_soumission.contrat_id = new_contrat.id
        new_soumission.save
      end
      #signature
      if self.signature
       new_signature = self.signature.dup
       new_signature.contrat_id = new_contrat.id
       new_signature.verrou = 'Aucun'
       new_signature.verrou_listchamps = nil
       new_signature.save
      end
      #refu
      if self.refu
       new_refu = self.refu.dup
       new_refu.contrat_id = new_contrat.id
       new_refu.save
      end
      #notification
      if self.notification
        new_notification = self.notification.clone
        new_notification.contrat_id = new_contrat.id
        new_notification.save
      end
      #sous_contrats
      for sous_contrat in self.sous_contrats do
        new_sous_contrat= sous_contrat.clone
        #sous_contrat_notification
        if sous_contrat.sous_contrat_notification
          new_sous_contrat_notification = sous_contrat.sous_contrat_notification.clone
          new_sous_contrat.sous_contrat_notification = new_sous_contrat_notification
          new_sous_contrat.sous_contrat_notification.notification_id = new_notification.id
          new_sous_contrat.sous_contrat_notification.save
        end
        new_contrat.sous_contrats << new_sous_contrat
      end
      #cloture
      if self.cloture
        new_cloture = self.cloture.dup
        new_cloture.contrat_id = new_contrat.id
        new_cloture.save
      end
      #echeancier
      if self.echeancier
        new_echeancier = self.echeancier.clone
        new_echeancier.echeanciable_id = new_contrat.id
        new_echeancier.save
      end
      new_contrat.verrou = 'Aucun'
      new_contrat.verrou_listchamps = nil
      return new_contrat
    end
  end

  def contrat_dotation
          if find_type_pere(self.notification.contrat_type_id) == ID_CONTRAT_DOTATION
                  return true
          else
                  return false
          end
  end



  def long_acronyme
    unless self.num_contrat_etab.blank?
      self.acronyme+"-"+self.num_contrat_etab
    else
      self.acronyme
    end
  end

  def lignes
    lignes = []
    for sc in self.sous_contrats
      if !sc.ligne.nil?
        lignes << sc.ligne
      end
    end
    return lignes
  end

  def is_in_laboratoire? labo
    is_in = 0
    for projet in self.projets
      if projet.is_in_laboratoire? labo
          is_in = is_in + 1
        end
    end
    for departement in self.departements
      if departement.is_in_laboratoire? labo
          is_in = is_in + 1
        end
    end
    for laboratoire in self.laboratoires
      if laboratoire.nom == labo.nom
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
    is_in = false
    for projet in self.projets
      if projet.is_in_tutelle? tutel
        is_in = true
      end
    end
    return is_in
  end


  def is_consultable?(current_user)
    for current_user_group in current_user.groups
      if current_user_group.has_role? "Administrateur"
        return true
      elsif current_user_group.has_role? 'consultation', self
        return true
      end
    end
    if current_user.has_role? "Administrateur"
      return true
    elsif self.is_budget_editable? current_user
      return true
    elsif current_user.has_role? 'consultation', self
      return true
    end
    return false
  end

  def is_editable?(current_user)
   for current_user_group in current_user.groups
      if current_user_group.has_role? "Administrateur"
        return true
      elsif current_user_group.has_role? 'modification', self
        return true
      end
    end
    if (current_user.has_role? "Administrateur")
      return true
    elsif current_user.has_role? 'modification', self
      return true
    end
    return false
  end

  def is_budget_editable?(current_user)
    for current_user_group in current_user.groups
      if current_user_group.has_role? "Administrateur"
        return true
      # IG : optimisation de code : || à la place de or pour éviter des requêtes sup
      elsif ( current_user_group.has_role? 'modification', self ) || ( current_user_group.has_role? 'modification_budget', self )
        return true
      end
    end
    if current_user.has_role? "Administrateur"
      return true
    # IG : optimisation de code : || à la place de or pour éviter des requêtes sup
    elsif ( current_user.has_role? 'modification', self ) || ( current_user.has_role? 'modification_budget', self )
        return true
    end

    return false
  end


  # retourne les ids des contrats que l'utilisateur courant peut consulter
  def self.find_all_consultable(current_user)
    contrats_consultable_ids = []
    if current_user.is_admin?
      contrats_all = Contrat.find(:all, :order => "acronyme")
      for contrat in contrats_all
        contrats_consultable_ids << contrat.id
      end
    else
      roles_name = ['consultation','modification','modification_budget']
      roles_consultables_user = Role.find(:all,
        :select => "authorizable_id,authorizable_type",
        :include => :users,
        :conditions => ["roles.name in (?) and users.id = ?",roles_name,current_user.id])
      for role in roles_consultables_user
        if role.authorizable_type == 'Contrat'
          contrats_consultable_ids << role.authorizable_id
        elsif role.authorizable_type = 'Projet'
          projet = Projet.find(role.authorizable_id)
          for sous_contrat in projet.sous_contrats
            contrats_consultable_ids << sous_contrat.contrat_id
          end
        end
      end

      roles_consultables_group = Role.find(:all,
        :select => "authorizable_id,authorizable_type",
        :include => [{:groups => :users}],
        :conditions => ["roles.name in (?) and users.id = ?",roles_name,current_user.id])
      for role in roles_consultables_group
        if role.authorizable_type == 'Contrat'
          contrats_consultable_ids << role.authorizable_id
        elsif role.authorizable_type = 'Projet'
          projet = Projet.find(role.authorizable_id)
          for sous_contrat in projet.sous_contrats
            contrats_consultable_ids << sous_contrat.contrat_id
          end
        end
      end
    end
    return contrats_consultable_ids
  end

  # retourne les ids des contrats que l'utilisateur courant peut modifier
    def self.find_all_editable(current_user)
    contrats_editable_ids = []
    if current_user.is_admin?
      contrats_all = Contrat.find(:all, :order => "acronyme")
      for contrat in contrats_all
        contrats_editable_ids << contrat.id
      end
    else
      roles_name = ['modification']
      roles_editable_user = Role.find(:all,
        :select => "authorizable_id,authorizable_type",
        :include => :users,
        :conditions => ["roles.name in (?) and users.id = ?",roles_name,current_user.id])
      for role in roles_editable_user
        if role.authorizable_type == 'Contrat'
          contrats_editable_ids << role.authorizable_id
        elsif role.authorizable_type = 'Projet'
          projet = Projet.find(role.authorizable_id)
          for sous_contrat in projet.sous_contrats
            contrats_editable_ids << sous_contrat.contrat_id
          end
        end
      end

      roles_editable_group = Role.find(:all,
        :select => "authorizable_id,authorizable_type",
        :include => [{:groups => :users}],
        :conditions => ["roles.name in (?) and users.id = ?",roles_name,current_user.id])
      for role in roles_editable_group
        if role.authorizable_type == 'Contrat'
          contrats_editable_ids << role.authorizable_id
        elsif role.authorizable_type = 'Projet'
          projet = Projet.find(role.authorizable_id)
          for sous_contrat in projet.sous_contrats
            contrats_editable_ids << sous_contrat.contrat_id
          end
        end
      end
    end
    return contrats_editable_ids
  end

  # retourne les ids des contrats dont l'utilisateur courant peut modifier les informations budgetaires
    def self.find_all_budget_editable(current_user)
    contrats_budget_editable_ids = []
    if current_user.is_admin?
      contrats_all = Contrat.find(:all, :order => "acronyme")
      for contrat in contrats_all
        contrats_budget_editable_ids << contrat.id
      end
    else
      roles_name = ['modification','modification_budget']
      roles_budget_editable_user = Role.find(:all,
        :select => "authorizable_id,authorizable_type",
        :include => :users,
        :conditions => ["roles.name in (?) and users.id = ?",roles_name,current_user.id])
      for role in roles_budget_editable_user
        if role.authorizable_type == 'Contrat'
          contrats_budget_editable_ids << role.authorizable_id
        elsif role.authorizable_type = 'Projet'
          projet = Projet.find(role.authorizable_id)
          for sous_contrat in projet.sous_contrats
            contrats_budget_editable_ids << sous_contrat.contrat_id
          end
        end
      end
       roles_budget_editable_group = Role.find(:all,
        :select => "authorizable_id,authorizable_type",
        :include => [{:groups => :users}],
        :conditions => ["roles.name in (?) and users.id = ?",roles_name,current_user.id])
      for role in roles_budget_editable_group
        if role.authorizable_type == 'Contrat'
          contrats_budget_editable_ids << role.authorizable_id
        elsif role.authorizable_type = 'Projet'
          projet = Projet.find(role.authorizable_id)
          for sous_contrat in projet.sous_contrats
            contrats_budget_editable_ids << sous_contrat.contrat_id
          end
        end
      end
    end
    return contrats_budget_editable_ids
  end

  def self.my_find_all( ids,
                        acronyme_research = "Acronyme",
                        noContrat_research = "NumContrat",
                        equipe_research = "Equipe",
                        laboratoire_research = "Laboratoire",
                        departement_research = "",
                        in_laboratoire = "",
                        in_departement = "",
                        in_tutelle = "" )

    
  
      query = Array.new 
      query_string = "SELECT distinct contrats.id FROM contrats"
      query_where_string = " where contrats.id in (?) and "
      query.push ids
      if (acronyme_research != "Acronyme") and (acronyme_research != "")
        query_where_string += "contrats.acronyme like ? and "
        query.push "%"+acronyme_research+"%"
      end
      if (noContrat_research != "NumContrat") and (noContrat_research != "")
        query_where_string += "contrats.num_contrat_etab like ? and "
        query.push "%"+noContrat_research+"%"
      end
      if (equipe_research != "Equipe") and (equipe_research != "")
        query_string += " inner join sous_contrats as sc_equipe_research on sc_equipe_research.contrat_id = contrats.id and sc_equipe_research.entite_type = 'Projet'
                         inner join projets as p_equipe_research on sc_equipe_research.entite_id = p_equipe_research.id"
        query_where_string += "p_equipe_research.nom like ? and "
        query.push "%"+equipe_research+"%"
      end
      if (laboratoire_research != "Laboratoire") and (laboratoire_research != "")
        query_string += " inner join sous_contrats as sc_laboratoire_research on sc_laboratoire_research.contrat_id = contrats.id and sc_laboratoire_research.entite_type = 'Laboratoire'
                         inner join laboratoires as l_laboratoire_research on sc_laboratoire_research.entite_id = l_laboratoire_research.id"
        query_where_string += "l_laboratoire_research.nom like ? and "
        query.push "%"+laboratoire_research+"%"
      end
      if (departement_research != "")
        query_string += " inner join sous_contrats as sc_departement_research on sc_departement_research.contrat_id = contrats.id and sc_departement_research.entite_type = 'Departement'
                         inner join departements as d_departement_research on sc_departement_research.entite_id = d_departement_research.id"
        query_where_string += "d_departement_research.nom like ? and "
        query.push "%"+departement_research+"%"
      end
      if(in_laboratoire != "")
        query_string += " left outer join sous_contrats as sc_in_laboratoire_1 on sc_in_laboratoire_1.contrat_id = contrats.id and sc_in_laboratoire_1.entite_type = 'Projet'
                          left outer join laboratoire_subscriptions as ls_in_laboratoire on sc_in_laboratoire_1.entite_id = ls_in_laboratoire.projet_id
                          left outer join laboratoires as l_in_laboratoire_1 on l_in_laboratoire_1.id = ls_in_laboratoire.laboratoire_id
                          left outer join sous_contrats as sc_in_laboratoire_2 on sc_in_laboratoire_2.contrat_id = contrats.id and sc_in_laboratoire_2.entite_type = 'Laboratoire'
                          left outer join laboratoires as l_in_laboratoire_2 on sc_in_laboratoire_2.entite_id = l_in_laboratoire_2.id
                          left outer join sous_contrats as sc_in_laboratoire_3 on sc_in_laboratoire_3.contrat_id = contrats.id and sc_in_laboratoire_3.entite_type = 'Departement'
                          left outer join departements as d_in_laboratoire_1 on sc_in_laboratoire_3.entite_id = d_in_laboratoire_1.id
                          left outer join laboratoires as l_in_laboratoire_3 on d_in_laboratoire_1.laboratoire_id = l_in_laboratoire_3.id
                          left outer join sous_contrats as sc_in_laboratoire_4 on sc_in_laboratoire_4.contrat_id = contrats.id and sc_in_laboratoire_4.entite_type = 'Projet'
                          left outer join departement_subscriptions as ds_in_laboratoire on sc_in_laboratoire_4.entite_id = ds_in_laboratoire.projet_id
                          left outer join departements as d_in_laboratoire_2 on d_in_laboratoire_2.id = ds_in_laboratoire.departement_id
                          left outer join laboratoires as l_in_laboratoire_4 on d_in_laboratoire_2.laboratoire_id = l_in_laboratoire_4.id"
        query_where_string += "(l_in_laboratoire_1.nom like ? or l_in_laboratoire_2.nom like ? or l_in_laboratoire_3.nom like ? or l_in_laboratoire_4.nom like ?) and "
        query.push "%"+in_laboratoire.to_s+"%"
        query.push "%"+in_laboratoire.to_s+"%"
        query.push "%"+in_laboratoire.to_s+"%"
        query.push "%"+in_laboratoire.to_s+"%"
      end
      if(in_departement != "")
        query_string += " left outer join sous_contrats as sc_in_departement_1 on sc_in_departement_1.contrat_id = contrats.id and sc_in_departement_1.entite_type = 'Projet'
                          left outer join departement_subscriptions as ds_in_departement on sc_in_departement_1.entite_id = ds_in_departement.projet_id
                          left outer join departements as departement_in_departement_1 on departement_in_departement_1.id = ds_in_departement.departement_id
                          left outer join sous_contrats as sc_in_departement_2 on sc_in_departement_2.contrat_id = contrats.id and sc_in_departement_2.entite_type = 'Departement'
                          left outer join departements as departement_in_departement_2 on sc_in_departement_2.entite_id = departement_in_departement_2.id"
        query_where_string += "(departement_in_departement_1.nom like ? or departement_in_departement_2.nom like ?) and "
        query.push "%"+in_departement.to_s+"%"
        query.push "%"+in_departement.to_s+"%"
      end
      if(in_tutelle != "")
        query_string += " inner join sous_contrats as sc_in_tutelle on sc_in_tutelle.contrat_id = contrats.id and sc_in_tutelle.entite_type = 'Projet'
                       inner join tutelle_subscriptions as ts_in_tutelle on sc_in_tutelle.entite_id = ts_in_tutelle.projet_id
                       inner join tutelles as t_in_tutelle on t_in_tutelle.id = ts_in_tutelle.tutelle_id"
        query_where_string += "t_in_tutelle.nom like ? and "
        query.push "%"+in_tutelle.to_s+"%"
      end
      query_where_string += "true"
      query.insert(0, (query_string+query_where_string) )
      
      
      ids_contrats = Contrat.find_by_sql(query)
    return ids_contrats
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

  def projets_small_list
    associations = []
    nb_projets = self.projets.size
    max_projet = [3,nb_projets].min
    for i in 1..max_projet
        associations << self.projets[i-1].nom
    end    
    if nb_projets > 3
      associations << "ET "+ (nb_projets-3).to_s + " DE PLUS..."
    end
    return associations
  end
  
  def departements_small_list
    associations=[]
    nb_departements = self.departements.size
    max_departement = [3,nb_departements].min
    for i in 1..max_departement
        associations << self.departements[i-1].nom
    end    
    if nb_departements > 3
      associations << "ET "+ (nb_departements-3).to_s + " DE PLUS..."
    end
    return associations
  end
 
  def laboratoires_small_list
    associations=[]
    nb_laboratoires = self.laboratoires.size
    max_laboratoire = [3,nb_laboratoires].min
    for i in 1..max_laboratoire
        associations << self.laboratoires[i-1].nom
    end    
    if nb_laboratoires > 3
      associations << "ET "+ (nb_laboratoires-3).to_s + " DE PLUS..."
    end
    return associations
  end

end
