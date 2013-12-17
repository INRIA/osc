#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class ReferentielContratAgent < ActiveRecord::Base
    
  validates_presence_of :date_debut, :message => ": la date de debut de contrat doit etre obligatoirement rempli"
  validates_presence_of :date_fin, :message => ": la date de fin de contrat doit etre obligatoirement rempli"
  validates_presence_of :agent_si_id, :message => ": l'identifiant systeme d'information de l'agent doit etre obligatoirement rempli"
  validates_presence_of :si_origine, :message => ": le systeme d'information d'origine doit etre obligatoirement rempli"
  validates_presence_of :libelle_structure, :message => ": le libelle de structure d'appartenance doit etre obligatoirement rempli"
  validates_presence_of :code_structure, :message => ": le code de structure d'appartenance doit etre obligatoirement rempli"
  validates_presence_of :num_contrat_etab, :message => ": le numero de contrat support doit etre obligatoirement rempli"
  validates_presence_of :statut, :message => ": le statut d'appartenance doit etre obligatoirement rempli"

end
