#!/bin/env ruby
# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
admin = User.create(nom: 'admin', prenom: 'admin', email: 'admin@admin.fr', login: 'admin', password: 'admin', password_confirmation: 'admin', ldap: false)
admin.has_role('Administrateur')

BudgetaireReference.create(code: "Aucune", intitule: "Aucune")


def self.get_input_types_contrats
  input = ''
  STDOUT.flush
  input = STDIN.gets.chomp
  if input.casecmp("Y") == 0 or input.casecmp("O") == 0
    import_types_contrats
  elsif input.casecmp("N") == 0
    if ContratType.find(:all).size == 0 
      ContratType.create(nom: 'Dotation : utiliser ce type (ou des types enfants) pour saisir des depenses communes (sur dotation des tutelles)', verrou: 'Aucun', parent_id: 0)
      ContratType.create(nom: 'Financements européens', verrou: 'Aucun', parent_id: 0)
      ContratType.create(nom: 'Financements régionaux', verrou: 'Aucun', parent_id: 0)
      ContratType.create(nom: 'Financements nationaux', verrou: 'Aucun', parent_id: 0)
      ContratType.create(nom: 'Financements internationaux', verrou: 'Aucun', parent_id: 0)
    end
  else
    STDOUT.puts "Merci de repondre par O ou N"
    get_input_types_contrats
  end
end
  
def self.get_input_rubriques_comptables
  input = ''
  STDOUT.flush
  input = STDIN.gets.chomp
  if input.casecmp("Y") == 0 or input.casecmp("O") == 0
    import_rubriques_comptables
  elsif input.casecmp("N") == 0 
    if RubriqueComptable.find(:all).size == 0
      RubriqueComptable.create(label: "Aucune", parent_id: 0, numero_rubrique: "0")
    end
  else
    STDOUT.puts "Merci de repondre par O ou N"
    get_input_rubriques_comptables
  end
end   

def self.import_types_contrats
  ContratType.delete_all
  a = ContratType.new
  a.id = 1
  a.nom = "Dotation : utiliser ce type (ou des types enfants) pour saisir des depenses communes (sur dotation des tutelles) "
  a.parent_id = 0
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 15
  a.nom = "Financements nationaux"
  a.parent_id = 0
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 16
  a.nom = "ANR"
  a.parent_id = 15
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 19
  a.nom = "Blanc"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 20
  a.nom = "Jeunes Chercheurs"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 21
  a.nom = "Masse de Données et Connaissances (MDCO)"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 22
  a.nom = "Systèmes Interactifs et Robotique (PSIROB)"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 23
  a.nom = "Audiovisuel et Multimédia (RIAM)"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 24
  a.nom = "Technologies Logicielles (RNTL)"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 25
  a.nom = "Sécurité et Sûreté Informatique (SESUR)"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 26
  a.nom = "Transports sûrs et fiables (PREDIT)"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 30
  a.nom = "Financements régionaux"
  a.parent_id = 0
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 31
  a.nom = "Région Rhône-Alpes"
  a.parent_id = 30
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 32
  a.nom = "Clusters"
  a.parent_id = 31
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 33
  a.nom = 'Cible (projets "blancs")'
  a.parent_id = 31
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 34
  a.nom = "Autres financements Région"
  a.parent_id = 31
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 35
  a.nom = "Financements établissements"
  a.parent_id = 0
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 36
  a.nom = "BQR"
  a.parent_id = 35
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 37
  a.nom = "Autres financements nationaux"
  a.parent_id = 15
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 38
  a.nom = "Fonds de Compétitivité des Entreprises (FCE)"
  a.parent_id = 37
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 2
  a.nom = "Financements européens"
  a.parent_id = 0
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 40
  a.nom = "Commission Européenne"
  a.parent_id = 2
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 43
  a.nom = "FP6"
  a.parent_id = 40
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 44
  a.nom = "STREP"
  a.parent_id = 43
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 45
  a.nom = "IP"
  a.parent_id = 43
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 46
  a.nom = "NOE"
  a.parent_id = 43
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 47
  a.nom = "CA"
  a.parent_id = 43
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 48
  a.nom = "SSA"
  a.parent_id = 43
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 49
  a.nom = "Marie Curie"
  a.parent_id = 43
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 50
  a.nom = "FP7"
  a.parent_id = 40
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 51
  a.nom = "STREP"
  a.parent_id = 50
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 52
  a.nom = "IP"
  a.parent_id = 50
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 53
  a.nom = "NOE"
  a.parent_id = 50
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 54
  a.nom = "People (ex-Marie Curie)"
  a.parent_id = 50
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 55
  a.nom = "Autres financements européens"
  a.parent_id = 2
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 56
  a.nom = "ITEA"
  a.parent_id = 55
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 57
  a.nom = "MEDEA"
  a.parent_id = 55
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 58
  a.nom = "Financements internationaux"
  a.parent_id = 0
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 59
  a.nom = "Campus France (ex Egide)"
  a.parent_id = 58
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 60
  a.nom = "Partenariats Hubert Curien (PHC) [ex-PAI]"
  a.parent_id = 59
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 61
  a.nom = "Autres financements Campus France (ex Egide)"
  a.parent_id = 59
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 62
  a.nom = "Agence Française du Développement"
  a.parent_id = 58
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 63
  a.nom = "Programme STIC (Asie, etc.)"
  a.parent_id = 62
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 64
  a.nom = "Ministère des Affaires Etrangères"
  a.parent_id = 58
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 65
  a.nom = "Programme ECOS (Nord ou Sud)"
  a.parent_id = 64
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 66
  a.nom = "Autres"
  a.parent_id = 64
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 67
  a.nom = "Autres financements internationaux"
  a.parent_id = 58
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 68
  a.nom = "Industriel"
  a.parent_id = 0
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 69
  a.nom = "Réseau National de Recherche en Télécommunications (RNRT)"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 70
  a.nom = "Masse de données - Connaissances Ambiantes (MDCA)"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 71
  a.nom = "Corpus et outils de la recherche en sciences humaines et sociales"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 72
  a.nom = "MSTIC"
  a.parent_id = 35
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 73
  a.nom = "FNS"
  a.parent_id = 37
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 74
  a.nom = "ARA Sécurité"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 75
  a.nom = "Réseau Thématique de Recherche Avancée et Fondation (RTRA)"
  a.parent_id = 37
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 76
  a.nom = "Cosinus"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 77
  a.nom = "Ministères"
  a.parent_id = 15
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 78
  a.nom = "FNRAE"
  a.parent_id = 98
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 79
  a.nom = "Subvention"
  a.parent_id = 31
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 80
  a.nom = "Calcul Intensif et Grilles de Calcul"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 81
  a.nom = "Autres Etablissements publics "
  a.parent_id = 15
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 82
  a.nom = "Agence de l'Innovation Industrielle (AII)"
  a.parent_id = 37
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 83
  a.nom = "Domaines émergents"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 84
  a.nom = "Contenus et interactions"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 85
  a.nom = "VERSO : réseaux du futur et services"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 86
  a.nom = "ARPEGE : systèmes embarqués et grandes infrastructures"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 87
  a.nom = "Inscriptions  Colloques/congrès"
  a.parent_id = 0
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 88
  a.nom = "Fonds Européen de Développement Régional"
  a.parent_id = 55
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 89
  a.nom = "projet PEPS"
  a.parent_id = 35
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 91
  a.nom = "Sciences, technologies et savoirs en sociétés"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 92
  a.nom = "Blanc International"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 93
  a.nom = "Habitat intelligent et solaire photovoltaique"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 94
  a.nom = "pirstec"
  a.parent_id = 35
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 95
  a.nom = "PPF Pegasus"
  a.parent_id = 35
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 96
  a.nom = "Risques naturels"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 97
  a.nom = "programme ISCC"
  a.parent_id = 35
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 98
  a.nom = "Financements Privés"
  a.parent_id = 0
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 99
  a.nom = "FUI "
  a.parent_id = 37
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 100
  a.nom = "PIRIBIO"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 101
  a.nom = "ICT"
  a.parent_id = 50
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 102
  a.nom = "Preciput ANR"
  a.parent_id = 35
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 103
  a.nom = "ERC Advanced Grant"
  a.parent_id = 55
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 130
  a.nom = "ARC"
  a.parent_id = 31
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 132
  a.nom = "Dotation Laboratoire"
  a.parent_id = 10
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 133
  a.nom = "Leonardo da Vinci- programme sectoriel"
  a.parent_id = 55
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 134
  a.nom = "CHIST-ERA"
  a.parent_id = 16
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 135
  a.nom = "Agence de l'Environnement et de la Maîtrise de l'Energie (ADEME)"
  a.parent_id = 81
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 137
  a.nom = "AGIR"
  a.parent_id = 35
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 138
  a.nom = "PRS projets de recherche structurants"
  a.parent_id = 35
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 139
  a.nom = "Projets internes"
  a.parent_id = 35
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 140
  a.nom = "GDR"
  a.parent_id = 81
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 141
  a.nom = "Programme d'investissement d'avenir (PIA)"
  a.parent_id = 15
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 142
  a.nom = "Fonds national pour la société numerique (FSN)"
  a.parent_id = 141
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 143
  a.nom = "programme CAPES COFECUB"
  a.parent_id = 59
  a.verrou = "Aucun"
  a.save!
   
  a = ContratType.new
  a.id = 147
  a.nom = "CIFRE"
  a.parent_id = 68
  a.verrou = "Aucun"
a.save!

end

def self.import_rubriques_comptables
  RubriqueComptable.delete_all
  a = RubriqueComptable.new
  a.id = 1
  a.label = " Achats d'études et prestations de services"
  a.parent_id = 4
  a.numero_rubrique = "604 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 2
  a.label = " Achat non stockés de matières et fournitures"
  a.parent_id = 4
  a.numero_rubrique = "606 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 3
  a.label = " Comptes de charges"
  a.parent_id = 0
  a.numero_rubrique = "6 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 4
  a.label = " Achats"
  a.parent_id = 3
  a.numero_rubrique = "60 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 5
  a.label = " Acquisition de papier"
  a.parent_id = 2
  a.numero_rubrique = "6062 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 6
  a.label = " Fournitures d'entretien et petit équipement"
  a.parent_id = 2
  a.numero_rubrique = "6063 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 7
  a.label = " Fournitures administratives"
  a.parent_id = 2
  a.numero_rubrique = "6064 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 8
  a.label = " Fournitures et matériel d'enseignement et de recherche non immobilisées"
  a.parent_id = 2
  a.numero_rubrique = "6067 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 9
  a.label = " Sous traitance générale"
  a.parent_id = 39
  a.numero_rubrique = "611 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 10
  a.label = " Redevance de crédit bail"
  a.parent_id = 39
  a.numero_rubrique = "612 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 11
  a.label = " Redevance de crédit bail mobilier"
  a.parent_id = 10
  a.numero_rubrique = "6122 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 12
  a.label = " Locations"
  a.parent_id = 39
  a.numero_rubrique = "613 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 13
  a.label = " Travaux d'entretien et de réparation"
  a.parent_id = 39
  a.numero_rubrique = "615 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 14
  a.label = " Sur biens mobiliers (hors contrats)"
  a.parent_id = 13
  a.numero_rubrique = "6155 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 15
  a.label = " Maintenance (contrats)"
  a.parent_id = 13
  a.numero_rubrique = "6156 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 16
  a.label = " Etudes et recherches"
  a.parent_id = 39
  a.numero_rubrique = "617 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 17
  a.label = " Divers"
  a.parent_id = 39
  a.numero_rubrique = "618 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 18
  a.label = " Documentation générale et administrative"
  a.parent_id = 17
  a.numero_rubrique = "6181 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 19
  a.label = " Ouvrages"
  a.parent_id = 18
  a.numero_rubrique = "61832 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 20
  a.label = " Reprographie"
  a.parent_id = 17
  a.numero_rubrique = "6184 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 21
  a.label = " Frais de colloques, séminaires, conférences"
  a.parent_id = 17
  a.numero_rubrique = "6185 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 22
  a.label = " Aucune"
  a.parent_id = 0
  a.numero_rubrique = "0 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 23
  a.label = " Rémunérations d'intermédiaires et honoraires"
  a.parent_id = 40
  a.numero_rubrique = "622 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 24
  a.label = " Honoraires"
  a.parent_id = 23
  a.numero_rubrique = "6226 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 25
  a.label = " Publicité, publications, relations publiques"
  a.parent_id = 40
  a.numero_rubrique = "623 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 26
  a.label = " Annonces et insertions"
  a.parent_id = 25
  a.numero_rubrique = "6231 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 27
  a.label = " Catalogues et imprimés"
  a.parent_id = 25
  a.numero_rubrique = "6236 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 28
  a.label = " Publications"
  a.parent_id = 25
  a.numero_rubrique = "6237 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 29
  a.label = " Transports de biens et transports collectifs de personnes"
  a.parent_id = 40
  a.numero_rubrique = "624 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 30
  a.label = " Transports sur achats"
  a.parent_id = 29
  a.numero_rubrique = "6241 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 31
  a.label = " Transports collectifs du personnel"
  a.parent_id = 29
  a.numero_rubrique = "6247 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 32
  a.label = " Déplacements, missions, receptions"
  a.parent_id = 40
  a.numero_rubrique = "625 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 33
  a.label = " Frais d'inscription aux colloques"
  a.parent_id = 32
  a.numero_rubrique = "6254 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 34
  a.label = " Missions"
  a.parent_id = 32
  a.numero_rubrique = "6256 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 35
  a.label = " Réceptions"
  a.parent_id = 32
  a.numero_rubrique = "6257 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 36
  a.label = " Frais postaux et télécommunications"
  a.parent_id = 40
  a.numero_rubrique = "626 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 37
  a.label = " Téléphone"
  a.parent_id = 36
  a.numero_rubrique = "6264 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 38
  a.label = " Affranchissements"
  a.parent_id = 36
  a.numero_rubrique = "6265 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 39
  a.label = " Services extérieurs"
  a.parent_id = 3
  a.numero_rubrique = "61 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 40
  a.label = " Autres services extérieurs"
  a.parent_id = 3
  a.numero_rubrique = "62 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 41
  a.label = " Services bancaires et assimilés"
  a.parent_id = 40
  a.numero_rubrique = "627 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 42
  a.label = " Autres frais et commissions bancaires"
  a.parent_id = 41
  a.numero_rubrique = "6278 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 43
  a.label = " Divers"
  a.parent_id = 40
  a.numero_rubrique = "628 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 44
  a.label = " Concours divers (cotisations ...)"
  a.parent_id = 43
  a.numero_rubrique = "6281 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 45
  a.label = " Formation continue du personnel de l'Etablissement"
  a.parent_id = 43
  a.numero_rubrique = "6283 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 46
  a.label = " Autres prestations extérieures diverses"
  a.parent_id = 43
  a.numero_rubrique = "6288 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 47
  a.label = " Autres charges de gestion courante"
  a.parent_id = 3
  a.numero_rubrique = "65 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 48
  a.label = " Redevances pour concessions, brevets, licences, marques, procédés, logiciels, droits et valeurs similaires"
  a.parent_id = 47
  a.numero_rubrique = "651 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 49
  a.label = " Redevances pour conceptions, brevets, licences, marques, procédés et logiciels"
  a.parent_id = 48
  a.numero_rubrique = "6511 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 50
  a.label = " Redevances droits d'auteurs et de reproduction"
  a.parent_id = 48
  a.numero_rubrique = "6516 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 51
  a.label = "Charges Spécifiques"
  a.parent_id = 47
  a.numero_rubrique = "657"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 52
  a.label = " Bourses"
  a.parent_id = 51
  a.numero_rubrique = "6571 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 53
  a.label = " Charges diverses de gestion courante"
  a.parent_id = 47
  a.numero_rubrique = "658 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 54
  a.label = " Charges de gestion courante provenant de l'annulation de titres de recettes des exercices antérieurs"
  a.parent_id = 53
  a.numero_rubrique = "6583 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 55
  a.label = " Autres charges diverses de gestion courante (infrastructure)"
  a.parent_id = 53
  a.numero_rubrique = "6588 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 56
  a.label = " Charges financières"
  a.parent_id = 3
  a.numero_rubrique = "66 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 57
  a.label = " Charges d'intérêts"
  a.parent_id = 56
  a.numero_rubrique = "661 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 58
  a.label = " Intérêts Moratoires"
  a.parent_id = 57
  a.numero_rubrique = "66181 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 59
  a.label = " Charges exceptionnelles"
  a.parent_id = 3
  a.numero_rubrique = "67 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 60
  a.label = " Charges exceptionnelles sur opérations de gestion"
  a.parent_id = 59
  a.numero_rubrique = "671 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 61
  a.label = " Pénalités sur contrats et conventions"
  a.parent_id = 60
  a.numero_rubrique = "6711 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 62
  a.label = " Subventions accordées"
  a.parent_id = 60
  a.numero_rubrique = "6715 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 63
  a.label = " Dotations aux amortissements, dépréciations et provision"
  a.parent_id = 3
  a.numero_rubrique = "68 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 64
  a.label = " Charges d’exploitation"
  a.parent_id = 63
  a.numero_rubrique = "681 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 65
  a.label = " Comptes d'immobilisations"
  a.parent_id = 0
  a.numero_rubrique = "2 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 66
  a.label = " Immobilisations incorporelles"
  a.parent_id = 65
  a.numero_rubrique = "20 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 67
  a.label = " Concessions et droits similaires, brevets, licences, marques, procédés, logiciels, droits et valeurs similaires"
  a.parent_id = 66
  a.numero_rubrique = "205 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 68
  a.label = " Logiciels accquis ou sous traités"
  a.parent_id = 67
  a.numero_rubrique = "20531 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 69
  a.label = " Autres concessions et droits similaires, brevets, micences, marques, procédés, droits et valeurs similaires"
  a.parent_id = 67
  a.numero_rubrique = "2058 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 70
  a.label = " Autres immobilisations corporelles"
  a.parent_id = 71
  a.numero_rubrique = "218 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 71
  a.label = " Immobilisations corporelles"
  a.parent_id = 65
  a.numero_rubrique = "21 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 72
  a.label = " Installations générales, agencements, aménagements divers"
  a.parent_id = 70
  a.numero_rubrique = "2181 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 73
  a.label = " Installations générales, agencements, aménagements divers acquis"
  a.parent_id = 72
  a.numero_rubrique = "21817 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 74
  a.label = " Matériel de bureau acquis"
  a.parent_id = 75
  a.numero_rubrique = "21837 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 75
  a.label = " Matériel de bureau et matériel informatique"
  a.parent_id = 70
  a.numero_rubrique = "2183 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 76
  a.label = " Mobilier acquis"
  a.parent_id = 75
  a.numero_rubrique = "21847 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 77
  a.label = " Matériel informatique acquis"
  a.parent_id = 75
  a.numero_rubrique = "21877 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 78
  a.label = " Impôts, taxes et versements assimilés"
  a.parent_id = 3
  a.numero_rubrique = "63 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 79
  a.label = " Charges de personnel"
  a.parent_id = 3
  a.numero_rubrique = "64 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 80
  a.label = " Rémunérations du personnel"
  a.parent_id = 79
  a.numero_rubrique = "641 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 81
  a.label = " Salaires, appointements"
  a.parent_id = 80
  a.numero_rubrique = "6411 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 82
  a.label = " Contrats de recherche"
  a.parent_id = 80
  a.numero_rubrique = "64145 "
  a.save!
   
  a = RubriqueComptable.new
  a.id = 83
  a.label = ""
  a.parent_id = 34
  a.numero_rubrique = "62561"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 84
  a.label = ""
  a.parent_id = 34
  a.numero_rubrique = "62562"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 85
  a.label = ""
  a.parent_id = 109
  a.numero_rubrique = "218322"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 86
  a.label = ""
  a.parent_id = 35
  a.numero_rubrique = "62572"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 87
  a.label = ""
  a.parent_id = 35
  a.numero_rubrique = "62571"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 88
  a.label = ""
  a.parent_id = 71
  a.numero_rubrique = "215"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 89
  a.label = ""
  a.parent_id = 32
  a.numero_rubrique = "6251"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 90
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "646113"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 91
  a.label = ""
  a.parent_id = 40
  a.numero_rubrique = "6214"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 92
  a.label = ""
  a.parent_id = 47
  a.numero_rubrique = "656"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 93
  a.label = ""
  a.parent_id = 88
  a.numero_rubrique = "2152"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 94
  a.label = ""
  a.parent_id = 25
  a.numero_rubrique = "6233"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 95
  a.label = ""
  a.parent_id = 17
  a.numero_rubrique = "6183"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 96
  a.label = ""
  a.parent_id = 68
  a.numero_rubrique = "205312"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 97
  a.label = ""
  a.parent_id = 13
  a.numero_rubrique = "6157"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 98
  a.label = ""
  a.parent_id = 65
  a.numero_rubrique = "2315"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 99
  a.label = ""
  a.parent_id = 106
  a.numero_rubrique = "2183182"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 100
  a.label = ""
  a.parent_id = 65
  a.numero_rubrique = "2314"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 101
  a.label = ""
  a.parent_id = 65
  a.numero_rubrique = "238"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 102
  a.label = ""
  a.parent_id = 62
  a.numero_rubrique = "67153"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 103
  a.label = ""
  a.parent_id = 29
  a.numero_rubrique = "6248"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 104
  a.label = ""
  a.parent_id = 51
  a.numero_rubrique = "6572"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 105
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "64682"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 106
  a.label = ""
  a.parent_id = 75
  a.numero_rubrique = "21831"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 107
  a.label = ""
  a.parent_id = 12
  a.numero_rubrique = "6132"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 108
  a.label = ""
  a.parent_id = 25
  a.numero_rubrique = "6238"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 109
  a.label = ""
  a.parent_id = 75
  a.numero_rubrique = "21832"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 110
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "64621"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 111
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "6438"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 112
  a.label = ""
  a.parent_id = 12
  a.numero_rubrique = "6135"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 113
  a.label = ""
  a.parent_id = 17
  a.numero_rubrique = "6186"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 114
  a.label = ""
  a.parent_id = 109
  a.numero_rubrique = "218321"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 115
  a.label = ""
  a.parent_id = 23
  a.numero_rubrique = "6227"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 116
  a.label = ""
  a.parent_id = 78
  a.numero_rubrique = "6378"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 117
  a.label = ""
  a.parent_id = 23
  a.numero_rubrique = "6224"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 118
  a.label = ""
  a.parent_id = 106
  a.numero_rubrique = "2183172"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 119
  a.label = ""
  a.parent_id = 69
  a.numero_rubrique = "20582"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 120
  a.label = ""
  a.parent_id = 65
  a.numero_rubrique = "2318"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 121
  a.label = ""
  a.parent_id = 32
  a.numero_rubrique = "6255"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 122
  a.label = ""
  a.parent_id = 23
  a.numero_rubrique = "6228"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 123
  a.label = ""
  a.parent_id = 2
  a.numero_rubrique = "6068"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 124
  a.label = ""
  a.parent_id = 43
  a.numero_rubrique = "6284"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 125
  a.label = ""
  a.parent_id = 68
  a.numero_rubrique = "205311"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 126
  a.label = ""
  a.parent_id = 62
  a.numero_rubrique = "67151"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 127
  a.label = ""
  a.parent_id = 13
  a.numero_rubrique = "6152"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 128
  a.label = ""
  a.parent_id = 29
  a.numero_rubrique = "6244"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 129
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "64622"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 130
  a.label = ""
  a.parent_id = 2
  a.numero_rubrique = "60611"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 131
  a.label = ""
  a.parent_id = 2
  a.numero_rubrique = "60612"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 132
  a.label = ""
  a.parent_id = 46
  a.numero_rubrique = "62886"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 133
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "6478"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 134
  a.label = ""
  a.parent_id = 2
  a.numero_rubrique = "60613"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 135
  a.label = ""
  a.parent_id = 43
  a.numero_rubrique = "6286"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 136
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "6458"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 137
  a.label = ""
  a.parent_id = 43
  a.numero_rubrique = "6287"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 138
  a.label = ""
  a.parent_id = 78
  a.numero_rubrique = "63514"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 139
  a.label = ""
  a.parent_id = 46
  a.numero_rubrique = "62888"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 140
  a.label = ""
  a.parent_id = 4
  a.numero_rubrique = "607"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 141
  a.label = ""
  a.parent_id = 62
  a.numero_rubrique = "67152"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 142
  a.label = ""
  a.parent_id = 39
  a.numero_rubrique = "616"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 143
  a.label = ""
  a.parent_id = 70
  a.numero_rubrique = "21822"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 144
  a.label = ""
  a.parent_id = 39
  a.numero_rubrique = "614"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 145
  a.label = ""
  a.parent_id = 2
  a.numero_rubrique = "6065"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 146
  a.label = ""
  a.parent_id = 51
  a.numero_rubrique = "6573"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 147
  a.label = ""
  a.parent_id = 65
  a.numero_rubrique = "237"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 148
  a.label = ""
  a.parent_id = 70
  a.numero_rubrique = "21842"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 149
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "64712"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 150
  a.label = ""
  a.parent_id = 2
  a.numero_rubrique = "60617"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 151
  a.label = ""
  a.parent_id = 67
  a.numero_rubrique = "205322"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 152
  a.label = ""
  a.parent_id = 48
  a.numero_rubrique = "6518"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 153
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "64713"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 154
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "64626"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 155
  a.label = ""
  a.parent_id = 60
  a.numero_rubrique = "67185"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 156
  a.label = ""
  a.parent_id = 65
  a.numero_rubrique = "2313"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 157
  a.label = ""
  a.parent_id = 71
  a.numero_rubrique = "213572"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 158
  a.label = ""
  a.parent_id = 71
  a.numero_rubrique = "213172"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 159
  a.label = ""
  a.parent_id = 65
  a.numero_rubrique = "275"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 160
  a.label = ""
  a.parent_id = 2
  a.numero_rubrique = "60615"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 161
  a.label = ""
  a.parent_id = 60
  a.numero_rubrique = "67183"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 162
  a.label = ""
  a.parent_id = 60
  a.numero_rubrique = "6712"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 163
  a.label = ""
  a.parent_id = 0
  a.numero_rubrique = "4861"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 164
  a.label = ""
  a.parent_id = 59
  a.numero_rubrique = "675"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 165
  a.label = ""
  a.parent_id = 60
  a.numero_rubrique = "67181"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 166
  a.label = "Gratifications de stage"
  a.parent_id = 51
  a.numero_rubrique = "6578"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 167
  a.label = ""
  a.parent_id = 0
  a.numero_rubrique = "CGDA"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 168
  a.label = ""
  a.parent_id = 0
  a.numero_rubrique = "1674"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 169
  a.label = ""
  a.parent_id = 43
  a.numero_rubrique = "6289"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 170
  a.label = ""
  a.parent_id = 48
  a.numero_rubrique = "6517"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 171
  a.label = ""
  a.parent_id = 56
  a.numero_rubrique = "666"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 172
  a.label = ""
  a.parent_id = 41
  a.numero_rubrique = "6272"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 173
  a.label = ""
  a.parent_id = 71
  a.numero_rubrique = "21412"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 174
  a.label = ""
  a.parent_id = 69
  a.numero_rubrique = "20581"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 175
  a.label = ""
  a.parent_id = 78
  a.numero_rubrique = "63542"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 176
  a.label = ""
  a.parent_id = 60
  a.numero_rubrique = "6714"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 177
  a.label = ""
  a.parent_id = 43
  a.numero_rubrique = "6282"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 178
  a.label = ""
  a.parent_id = 71
  a.numero_rubrique = "21452"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 179
  a.label = ""
  a.parent_id = 40
  a.numero_rubrique = "6211"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 180
  a.label = ""
  a.parent_id = 70
  a.numero_rubrique = "21841"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 181
  a.label = ""
  a.parent_id = 71
  a.numero_rubrique = "213571"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 182
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "64561"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 183
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "645341"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 184
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "645343"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 185
  a.label = ""
  a.parent_id = 78
  a.numero_rubrique = "6331"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 186
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "64513"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 187
  a.label = ""
  a.parent_id = 78
  a.numero_rubrique = "6311"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 188
  a.label = ""
  a.parent_id = 80
  a.numero_rubrique = "6414183"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 189
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "64543"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 190
  a.label = ""
  a.parent_id = 139
  a.numero_rubrique = "628885"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 191
  a.label = ""
  a.parent_id = 139
  a.numero_rubrique = "628888"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 192
  a.label = ""
  a.parent_id = 139
  a.numero_rubrique = "628881"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 193
  a.label = ""
  a.parent_id = 139
  a.numero_rubrique = "628883"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 194
  a.label = ""
  a.parent_id = 139
  a.numero_rubrique = "628884"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 195
  a.label = ""
  a.parent_id = 139
  a.numero_rubrique = "628882"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 196
  a.label = ""
  a.parent_id = 139
  a.numero_rubrique = "628886"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 197
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "6453211"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 198
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "64511"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 199
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "645322"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 200
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "646251"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 201
  a.label = ""
  a.parent_id = 80
  a.numero_rubrique = "6414152"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 202
  a.label = ""
  a.parent_id = 80
  a.numero_rubrique = "641611"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 203
  a.label = ""
  a.parent_id = 80
  a.numero_rubrique = "641311"
  a.save!
   
  a = RubriqueComptable.new
  a.id = 204
  a.label = ""
  a.parent_id = 79
  a.numero_rubrique = "6431131"
  a.save!
end 

STDOUT.puts "Voulez-vous charger le referentiel des types de contrats (supprime tous les types existants, ne surtout pas le faire si la base contient des contrats !)? (O/N)"
get_input_types_contrats

STDOUT.puts "Voulez-vous charger le referentiel de rubrique comptable (supprime toutes les rubriques existantes, ne surtout pas le faire si la base contient des dépenses/factures !)? (O/N)"
get_input_rubriques_comptables
