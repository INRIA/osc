# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 122) do

  create_table "INFO_WEB", :id => false, :force => true do |t|
    t.integer "id",                  :default => 0, :null => false
    t.string  "acronyme"
    t.string  "nom"
    t.text    "mots_cles"
    t.date    "date_debut"
    t.date    "Date_fin"
    t.integer "lien_partenaires_id", :default => 0
  end

  create_table "V_contrats_labo_publiables", :id => false, :force => true do |t|
    t.string  "laboratoire"
    t.integer "id",          :default => 0, :null => false
    t.string  "nom"
    t.string  "acronyme"
    t.string  "etat"
  end

  create_table "V_contrats_tutelle_publiables", :id => false, :force => true do |t|
    t.string  "tutelle"
    t.integer "id",       :default => 0,      :null => false
    t.string  "nom"
    t.string  "acronyme"
    t.string  "etat",     :default => "init"
  end

  create_table "avenants", :force => true do |t|
    t.integer  "notification_id"
    t.date     "date"
    t.text     "commentaires"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "avenants", ["notification_id"], :name => "index_avenants_on_notification_id"

  create_table "budgetaire_references", :force => true do |t|
    t.string "code",     :limit => 10, :null => false
    t.string "intitule",               :null => false
  end

  create_table "clotures", :force => true do |t|
    t.integer  "contrat_id"
    t.date     "date_fin_depenses"
    t.text     "commentaires"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "clotures", ["contrat_id"], :name => "index_clotures_on_contrat_id"

  create_table "contrat_files", :force => true do |t|
    t.integer  "contrat_id"
    t.string   "file"
    t.string   "description"
    t.datetime "created_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "contrat_files", ["contrat_id"], :name => "index_contrat_files_on_contrat_id"

  create_table "contrat_types", :force => true do |t|
    t.integer "parent_id"
    t.string  "nom"
    t.string  "verrou",            :default => "Aucun"
    t.text    "verrou_listchamps"
  end

  add_index "contrat_types", ["parent_id"], :name => "index_contrat_types_on_parent_id"

  create_table "contrats", :force => true do |t|
    t.string   "nom"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "acronyme"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "etat",                            :default => "init"
    t.boolean  "publicite",                       :default => true
    t.string   "num_contrat_etab",  :limit => 25,                      :null => false
    t.string   "verrou",                          :default => "Aucun"
    t.text     "verrou_listchamps"
  end

  add_index "contrats", ["nom"], :name => "nom"

  create_table "departement_subscriptions", :force => true do |t|
    t.integer  "projet_id"
    t.integer  "departement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departement_subscriptions", ["departement_id"], :name => "index_departement_subscriptions_on_departement_id"
  add_index "departement_subscriptions", ["projet_id"], :name => "index_departement_subscriptions_on_projet_id"

  create_table "departements", :force => true do |t|
    t.string   "nom"
    t.text     "description"
    t.integer  "laboratoire_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departements", ["laboratoire_id"], :name => "index_departements_on_laboratoire_id"

  create_table "depense_commun_factures", :force => true do |t|
    t.integer  "depense_commun_id",                                                                       :null => false
    t.integer  "rubrique_comptable_id",                                                                   :null => false
    t.date     "date"
    t.string   "numero_facture",        :limit => 20
    t.decimal  "cout_ht",                             :precision => 10, :scale => 2, :default => 0.0
    t.string   "taux_tva",              :limit => 10,                                                     :null => false
    t.decimal  "cout_ttc",                            :precision => 10, :scale => 2, :default => 0.0
    t.string   "justifiable",           :limit => 25
    t.text     "commentaire"
    t.string   "numero_mandat",         :limit => 20
    t.date     "date_mandatement"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "millesime"
    t.string   "verrou",                                                             :default => "Aucun"
    t.text     "verrou_listchamps"
  end

  add_index "depense_commun_factures", ["depense_commun_id"], :name => "index_depense_commun_factures_on_depense_commun_id"
  add_index "depense_commun_factures", ["rubrique_comptable_id"], :name => "index_depense_commun_factures_on_rubrique_comptable_id"

  create_table "depense_communs", :force => true do |t|
    t.integer  "ligne_id",                                                                    :null => false
    t.integer  "budgetaire_reference_id",                                                     :null => false
    t.string   "reference"
    t.string   "fournisseur"
    t.text     "intitule",                                                                    :null => false
    t.date     "date_commande"
    t.date     "date_min"
    t.date     "date_max"
    t.decimal  "montant_engage",          :precision => 10, :scale => 2, :default => 0.0
    t.boolean  "commande_solde"
    t.string   "tache"
    t.boolean  "eligible",                                               :default => false
    t.string   "type_activite"
    t.boolean  "prestation_service",                                     :default => false
    t.string   "commentaire"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "millesime"
    t.boolean  "verif",                                                  :default => false
    t.string   "verrou",                                                 :default => "Aucun"
    t.text     "verrou_listchamps"
  end

  add_index "depense_communs", ["ligne_id"], :name => "index_depense_communs_on_ligne_id"

  create_table "depense_equipement_factures", :force => true do |t|
    t.integer  "depense_equipement_id"
    t.date     "date"
    t.string   "numero_facture"
    t.decimal  "cout_ht",                       :precision => 10, :scale => 2
    t.string   "taux_tva"
    t.decimal  "cout_ttc",                      :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "cout_projet",                   :precision => 10, :scale => 2, :default => 0.0
    t.string   "justifiable"
    t.text     "commentaire"
    t.integer  "rubrique_comptable_id"
    t.string   "numero_mandat"
    t.date     "date_mandatement"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                                       :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
    t.decimal  "montant_htr",                   :precision => 10, :scale => 2
    t.string   "amortissement",                                                :default => "100%"
    t.integer  "duree_amortissement"
    t.date     "date_amortissement_debut"
    t.date     "date_amortissement_fin"
    t.decimal  "taux_amortissement",            :precision => 3,  :scale => 2, :default => 0.0
    t.decimal  "montant_justifiable_htr",       :precision => 8,  :scale => 2, :default => 0.0
    t.boolean  "amortissement_is_in_auto_mode",                                :default => true
    t.date     "millesime"
  end

  add_index "depense_equipement_factures", ["depense_equipement_id"], :name => "index_depense_equipement_factures_on_depense_equipement_id"
  add_index "depense_equipement_factures", ["rubrique_comptable_id"], :name => "index_depense_equipement_factures_on_rubrique_comptable_id"

  create_table "depense_equipements", :force => true do |t|
    t.integer  "ligne_id"
    t.string   "fournisseur"
    t.text     "intitule"
    t.string   "reference"
    t.date     "date_commande"
    t.date     "date_min"
    t.date     "date_max"
    t.decimal  "montant_engage",    :precision => 10, :scale => 2
    t.boolean  "commande_solde"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                           :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
    t.string   "tache",                                            :default => ""
    t.decimal  "montant_paye",      :precision => 10, :scale => 2, :default => 0.0
    t.string   "structure"
    t.boolean  "eligible",                                         :default => false
    t.string   "type_activite",                                    :default => ""
    t.text     "commentaire"
    t.date     "millesime"
    t.boolean  "verif",                                            :default => false
  end

  add_index "depense_equipements", ["ligne_id"], :name => "index_depense_equipements_on_ligne_id"

  create_table "depense_fonctionnement_factures", :force => true do |t|
    t.integer  "depense_fonctionnement_id"
    t.date     "date"
    t.string   "numero_facture"
    t.decimal  "cout_ht",                   :precision => 10, :scale => 2
    t.string   "taux_tva"
    t.decimal  "cout_ttc",                  :precision => 10, :scale => 2, :default => 0.0
    t.string   "justifiable"
    t.text     "commentaire"
    t.integer  "rubrique_comptable_id"
    t.string   "numero_mandat"
    t.date     "date_mandatement"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                                   :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
    t.decimal  "montant_htr",               :precision => 10, :scale => 2
    t.date     "millesime"
  end

  add_index "depense_fonctionnement_factures", ["depense_fonctionnement_id"], :name => "index_dff_on_df_id"
  add_index "depense_fonctionnement_factures", ["rubrique_comptable_id"], :name => "index_dff_on_rc_id"

  create_table "depense_fonctionnements", :force => true do |t|
    t.integer  "ligne_id"
    t.string   "fournisseur"
    t.text     "intitule"
    t.string   "reference"
    t.date     "date_commande"
    t.date     "date_min"
    t.date     "date_max"
    t.decimal  "montant_engage",     :precision => 10, :scale => 2
    t.boolean  "commande_solde"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                            :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
    t.string   "tache",                                             :default => ""
    t.decimal  "montant_paye",       :precision => 10, :scale => 2, :default => 0.0
    t.string   "structure"
    t.boolean  "eligible",                                          :default => false
    t.string   "type_activite",                                     :default => ""
    t.boolean  "prestation_service",                                :default => false
    t.text     "commentaire"
    t.date     "millesime"
    t.boolean  "verif",                                             :default => false
  end

  add_index "depense_fonctionnements", ["ligne_id"], :name => "index_depense_fonctionnements_on_ligne_id"

  create_table "depense_mission_factures", :force => true do |t|
    t.integer  "depense_mission_id"
    t.date     "date"
    t.text     "fournisseur"
    t.string   "numero_facture"
    t.decimal  "cout_ht",               :precision => 10, :scale => 2
    t.string   "taux_tva"
    t.decimal  "cout_ttc",              :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "cout_projet",           :precision => 10, :scale => 2, :default => 0.0
    t.string   "justifiable"
    t.text     "commentaire"
    t.integer  "rubrique_comptable_id"
    t.string   "numero_mandat"
    t.date     "date_mandatement"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                               :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
    t.decimal  "montant_htr",           :precision => 10, :scale => 2
    t.date     "millesime"
  end

  add_index "depense_mission_factures", ["depense_mission_id"], :name => "index_dmf_on_dm_id"
  add_index "depense_mission_factures", ["rubrique_comptable_id"], :name => "index_dmf_on_rc_id"

  create_table "depense_missions", :force => true do |t|
    t.integer  "ligne_id"
    t.string   "agent"
    t.string   "reference"
    t.date     "date_commande"
    t.date     "date_depart"
    t.date     "date_retour"
    t.date     "date_min"
    t.date     "date_max"
    t.string   "lieux"
    t.text     "intitule"
    t.decimal  "montant_engage",    :precision => 10, :scale => 2
    t.boolean  "commande_solde"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                           :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
    t.string   "tache",                                            :default => ""
    t.decimal  "montant_paye",      :precision => 10, :scale => 2, :default => 0.0
    t.string   "structure"
    t.boolean  "eligible",                                         :default => false
    t.string   "type_activite",                                    :default => ""
    t.text     "commentaire"
    t.date     "millesime"
    t.boolean  "verif",                                            :default => false
  end

  add_index "depense_missions", ["ligne_id"], :name => "index_depense_missions_on_ligne_id"

  create_table "depense_non_ventilee_factures", :force => true do |t|
    t.integer  "depense_non_ventilee_id"
    t.date     "date"
    t.string   "numero_facture"
    t.decimal  "cout_ht",                 :precision => 10, :scale => 2
    t.string   "taux_tva"
    t.decimal  "cout_ttc",                :precision => 10, :scale => 2, :default => 0.0
    t.string   "justifiable"
    t.text     "commentaire"
    t.integer  "rubrique_comptable_id"
    t.string   "numero_mandat"
    t.date     "date_mandatement"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                                 :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
    t.decimal  "montant_htr",             :precision => 10, :scale => 2
    t.date     "millesime"
  end

  add_index "depense_non_ventilee_factures", ["depense_non_ventilee_id"], :name => "index_dnvf_on_dnv_id"
  add_index "depense_non_ventilee_factures", ["rubrique_comptable_id"], :name => "index_dnvf_on_rc_id"

  create_table "depense_non_ventilees", :force => true do |t|
    t.integer  "ligne_id"
    t.string   "fournisseur"
    t.text     "intitule"
    t.string   "reference"
    t.date     "date_commande"
    t.date     "date_min"
    t.date     "date_max"
    t.decimal  "montant_engage",    :precision => 10, :scale => 2
    t.boolean  "commande_solde"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                           :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
    t.string   "tache",                                            :default => ""
    t.decimal  "montant_paye",      :precision => 10, :scale => 2, :default => 0.0
    t.string   "structure"
    t.boolean  "eligible",                                         :default => false
    t.string   "type_activite",                                    :default => ""
    t.text     "commentaire"
    t.date     "millesime"
    t.boolean  "verif",                                            :default => false
  end

  add_index "depense_non_ventilees", ["ligne_id"], :name => "index_depense_non_ventilees_on_ligne_id"

  create_table "depense_salaire_factures", :force => true do |t|
    t.integer  "depense_salaire_id"
    t.decimal  "cout",                  :precision => 10, :scale => 2
    t.text     "commentaire"
    t.string   "numero_mandat"
    t.date     "date_mandatement"
    t.integer  "rubrique_comptable_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                               :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
    t.decimal  "montant_htr",           :precision => 10, :scale => 2
    t.date     "millesime"
  end

  add_index "depense_salaire_factures", ["depense_salaire_id"], :name => "index_depense_salaire_factures_on_depense_salaire_id"

  create_table "depense_salaires", :force => true do |t|
    t.integer  "ligne_id"
    t.string   "agent"
    t.string   "type_contrat"
    t.string   "statut"
    t.date     "date_commande"
    t.date     "date_debut"
    t.date     "date_fin"
    t.date     "date_min"
    t.date     "date_max"
    t.decimal  "nb_mois",                                :precision => 10, :scale => 2
    t.decimal  "cout_mensuel",                           :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "cout_periode",                           :precision => 10, :scale => 2
    t.boolean  "commande_solde"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                                                :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
    t.string   "tache",                                                                 :default => ""
    t.decimal  "montant_paye",                           :precision => 10, :scale => 2, :default => 0.0
    t.string   "structure"
    t.boolean  "eligible",                                                              :default => false
    t.string   "type_activite",                                                         :default => ""
    t.string   "type_personnel",                                                        :default => "unknown"
    t.integer  "nb_heures_justifiees"
    t.decimal  "cout_indirect_unitaire",                 :precision => 8,  :scale => 2, :default => 0.0
    t.decimal  "somme_salaires_charges",                 :precision => 8,  :scale => 2, :default => 0.0
    t.integer  "nb_heures_declarees"
    t.date     "date_debut_prise_en_charge_sur_contrat"
    t.date     "date_fin_prise_en_charge_sur_contrat"
    t.text     "commentaire"
    t.string   "agent_si_origine",                                                      :default => ""
    t.boolean  "verif",                                                                 :default => false
    t.decimal  "pourcentage",                            :precision => 10, :scale => 2, :default => 100.0
  end

  add_index "depense_salaires", ["ligne_id"], :name => "index_depense_salaires_on_ligne_id"

  create_table "descriptifs", :force => true do |t|
    t.integer  "contrat_id",              :null => false
    t.string   "langue_id",  :limit => 2, :null => false
    t.text     "descriptif",              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "descriptifs", ["contrat_id"], :name => "index_descriptifs_on_contrat_id"
  add_index "descriptifs", ["langue_id"], :name => "index_descriptifs_on_langue_id"

  create_table "echeancier_periodes", :force => true do |t|
    t.integer  "echeancier_id"
    t.string   "reference_financeur"
    t.string   "numero_contrat_etablissement_gestionnaire"
    t.date     "date_debut"
    t.date     "date_fin"
    t.decimal  "credit",                                    :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "depenses_non_ventile",                      :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "depenses_fonctionnement",                   :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "depenses_equipement",                       :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "depenses_salaires",                         :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "depenses_missions",                         :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "depenses_couts_indirects",                  :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "depenses_frais_gestion",                    :precision => 12, :scale => 2, :default => 0.0
    t.integer  "allocations",                                                              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "verrou",                                                                   :default => "Aucun"
    t.text     "verrou_listchamps"
    t.decimal  "depenses_frais_gestion_mut",                :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "depenses_frais_gestion_mut_local",          :precision => 8,  :scale => 2, :default => 0.0
  end

  add_index "echeancier_periodes", ["echeancier_id"], :name => "index_echeancier_periodes_on_echeancier_id"

  create_table "echeanciers", :force => true do |t|
    t.integer  "echeanciable_id"
    t.string   "echeanciable_type"
    t.decimal  "global_depenses_frais_gestion", :precision => 12, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "verrou",                                                       :default => "Aucun"
    t.text     "verrou_listchamps"
  end

  add_index "echeanciers", ["echeanciable_id", "echeanciable_type"], :name => "index_echeanciers_on_echeanciable_id_and_echeanciable_type"

  create_table "group_rights", :force => true do |t|
    t.integer  "group_id",   :null => false
    t.integer  "role_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_rights", ["group_id"], :name => "index_group_rights_on_group_id"
  add_index "group_rights", ["role_id"], :name => "index_group_rights_on_role_id"

  create_table "groups", :force => true do |t|
    t.string   "nom"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "key_words", :force => true do |t|
    t.integer "laboratoire_id"
    t.string  "intitule"
    t.string  "section"
  end

  add_index "key_words", ["laboratoire_id"], :name => "index_key_words_on_laboratoire_id"

  create_table "key_words_notifications", :id => false, :force => true do |t|
    t.integer "key_word_id"
    t.integer "notification_id"
  end

  add_index "key_words_notifications", ["key_word_id", "notification_id"], :name => "index_key_words_notifications_on_key_word_id_and_notification_id"
  add_index "key_words_notifications", ["notification_id", "key_word_id"], :name => "index_key_words_notifications_on_notification_id_and_key_word_id"

  create_table "key_words_soumissions", :id => false, :force => true do |t|
    t.integer "key_word_id"
    t.integer "soumission_id"
  end

  add_index "key_words_soumissions", ["key_word_id", "soumission_id"], :name => "index_key_words_soumissions_on_key_word_id_and_soumission_id"
  add_index "key_words_soumissions", ["soumission_id", "key_word_id"], :name => "index_key_words_soumissions_on_soumission_id_and_key_word_id"

  create_table "laboratoire_subscriptions", :force => true do |t|
    t.integer  "projet_id"
    t.integer  "laboratoire_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "laboratoire_subscriptions", ["laboratoire_id"], :name => "index_laboratoire_subscriptions_on_laboratoire_id"
  add_index "laboratoire_subscriptions", ["projet_id"], :name => "index_laboratoire_subscriptions_on_projet_id"

  create_table "laboratoires", :force => true do |t|
    t.string   "nom"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
  end

  create_table "langues", :force => true do |t|
    t.string "langue_id",  :limit => 2,  :null => false
    t.string "nom_langue", :limit => 30, :null => false
  end

  create_table "lignes", :force => true do |t|
    t.integer  "sous_contrat_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",            :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "nom",                                    :null => false
    t.boolean  "active",            :default => true
  end

  add_index "lignes", ["nom"], :name => "index_lignes_on_nom"
  add_index "lignes", ["sous_contrat_id"], :name => "index_lignes_on_sous_contrat_id", :unique => true

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["group_id"], :name => "index_memberships_on_group_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "notification_europe_partenaires", :force => true do |t|
    t.integer "notification_id"
    t.string  "nom"
    t.string  "etablissement_gestionnaire"
    t.string  "ville"
    t.string  "pays"
    t.string  "localisation",               :default => "europe"
  end

  add_index "notification_europe_partenaires", ["notification_id"], :name => "index_notification_europe_partenaires_on_notification_id"

  create_table "notification_france_partenaires", :force => true do |t|
    t.integer "notification_id"
    t.string  "nom"
    t.string  "laboratoire"
    t.string  "etablissement_gestionnaire"
    t.string  "ville"
    t.string  "pays",                       :default => "France"
    t.string  "localisation",               :default => "France"
  end

  add_index "notification_france_partenaires", ["notification_id"], :name => "index_notification_france_partenaires_on_notification_id"

  create_table "notification_partenaires", :force => true do |t|
    t.integer "notification_id"
    t.string  "nom"
    t.string  "etablissement_gestionnaire"
    t.string  "ville"
    t.string  "pays"
    t.string  "localisation",               :default => "autre"
  end

  add_index "notification_partenaires", ["notification_id"], :name => "index_notification_partenaires_on_notification_id"

  create_table "notification_personnels", :force => true do |t|
    t.integer "notification_id"
    t.string  "nom"
    t.string  "prenom"
    t.string  "statut"
    t.string  "tutelle"
    t.integer "pourcentage"
  end

  add_index "notification_personnels", ["notification_id"], :name => "index_notification_personnels_on_notification_id"

  create_table "notifications", :force => true do |t|
    t.integer  "contrat_id"
    t.integer  "contrat_type_id"
    t.date     "date_notification"
    t.date     "date_debut"
    t.integer  "nombre_mois"
    t.date     "date_fin"
    t.string   "etablissement_gestionnaire"
    t.string   "organisme_financeur"
    t.boolean  "a_justifier"
    t.string   "organisme_payeur"
    t.string   "numero_ligne_budgetaire"
    t.string   "numero_contrat"
    t.string   "url"
    t.string   "porteur"
    t.string   "etablissement_rattachement_porteur"
    t.boolean  "est_porteur"
    t.string   "coordinateur"
    t.string   "etablissement_gestionnaire_du_coordinateur"
    t.text     "mots_cles_libres"
    t.text     "thematiques"
    t.string   "poles_competivites"
    t.text     "ma_type_montant"
    t.decimal  "ma_fonctionnement",                          :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "ma_equipement",                              :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "ma_salaire",                                 :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "ma_mission",                                 :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "ma_non_ventile",                             :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "ma_couts_indirects",                         :precision => 12, :scale => 2, :default => 0.0
    t.integer  "ma_allocation",                                                             :default => 0
    t.decimal  "ma_total",                                   :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "pa_doctorant",                               :precision => 4,  :scale => 0, :default => 0
    t.decimal  "pa_post_doc",                                :precision => 4,  :scale => 0, :default => 0
    t.decimal  "pa_ingenieur",                               :precision => 4,  :scale => 0, :default => 0
    t.decimal  "pa_autre",                                   :precision => 4,  :scale => 0, :default => 0
    t.decimal  "pa_equivalent_temps_plein",                  :precision => 5,  :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organisme_gestionnaire_id"
    t.decimal  "ma_frais_gestion_mutualises",                :precision => 12, :scale => 2, :default => 0.0
    t.string   "verrou",                                                                    :default => "Aucun"
    t.text     "verrou_listchamps"
    t.decimal  "ma_frais_gestion_mutualises_local",          :precision => 10, :scale => 2, :default => 0.0
  end

  add_index "notifications", ["contrat_id"], :name => "index_notifications_on_contrat_id"
  add_index "notifications", ["contrat_type_id"], :name => "index_notifications_on_contrat_type_id"
  add_index "notifications", ["organisme_gestionnaire_id"], :name => "index_notifications_on_organisme_gestionnaire_id"

  create_table "organisme_gestionnaire_tauxes", :force => true do |t|
    t.integer  "organisme_gestionnaire_id"
    t.decimal  "taux",                      :precision => 5, :scale => 4, :default => 0.0
    t.string   "annee"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisme_gestionnaire_tauxes", ["organisme_gestionnaire_id"], :name => "index_organisme_gestionnaire_tauxes_on_organisme_gestionnaire_id"

  create_table "organisme_gestionnaires", :force => true do |t|
    t.string   "nom"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projets", :force => true do |t|
    t.string   "nom"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date_debut"
    t.date     "date_fin"
    t.string   "logo"
    t.string   "verrou",            :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "code_structure",    :default => ""
  end

  add_index "projets", ["nom"], :name => "nom"

  create_table "referentiel_agents", :force => true do |t|
    t.string  "si_id"
    t.string  "si_origine"
    t.string  "nom"
    t.string  "prenom"
    t.integer "dedoublonnage"
  end

  create_table "referentiel_contrat_agents", :force => true do |t|
    t.string  "agent_si_id"
    t.string  "si_origine"
    t.string  "date_debut"
    t.string  "date_fin"
    t.string  "libelle_structure"
    t.string  "num_contrat_etab"
    t.string  "statut"
    t.string  "code_structure"
    t.decimal "pourcentage",       :precision => 10, :scale => 2, :default => 100.0
  end

  create_table "refus", :force => true do |t|
    t.integer  "contrat_id"
    t.date     "date"
    t.boolean  "liste_attente", :default => false
    t.boolean  "labelise",      :default => false
    t.text     "commentaire"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "refus", ["contrat_id"], :name => "index_refus_on_contrat_id"

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 30
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "commentaire"
  end

  add_index "roles", ["authorizable_id", "authorizable_type"], :name => "index_roles_on_authorizable_id_and_authorizable_type"
  add_index "roles", ["authorizable_id"], :name => "authorizable_id"
  add_index "roles", ["authorizable_type"], :name => "authorizable_type"
  add_index "roles", ["name"], :name => "name"

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id"
  add_index "roles_users", ["user_id", "role_id"], :name => "index_roles_users_on_user_id_and_role_id"

  create_table "rubrique_comptables", :force => true do |t|
    t.string  "label"
    t.integer "parent_id"
    t.string  "numero_rubrique", :default => ""
  end

  add_index "rubrique_comptables", ["parent_id"], :name => "index_rubrique_comptables_on_parent_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                     :null => false
    t.text     "data",       :limit => 16777215
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "signatures", :force => true do |t|
    t.integer  "contrat_id"
    t.date     "date"
    t.text     "commentaire"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "verrou",            :default => "Aucun"
    t.text     "verrou_listchamps"
  end

  add_index "signatures", ["contrat_id"], :name => "index_signatures_on_contrat_id"

  create_table "soumission_europe_partenaires", :force => true do |t|
    t.integer "soumission_id"
    t.string  "nom"
    t.string  "etablissement_gestionnaire"
    t.string  "ville"
    t.string  "pays"
    t.string  "localisation",               :default => "europe"
  end

  add_index "soumission_europe_partenaires", ["soumission_id"], :name => "index_soumission_europe_partenaires_on_soumission_id"

  create_table "soumission_france_partenaires", :force => true do |t|
    t.integer "soumission_id"
    t.string  "nom"
    t.string  "laboratoire"
    t.string  "etablissement_gestionnaire"
    t.string  "ville"
    t.string  "pays",                       :default => "France"
    t.string  "localisation",               :default => "france"
  end

  add_index "soumission_france_partenaires", ["soumission_id"], :name => "index_soumission_france_partenaires_on_soumission_id"

  create_table "soumission_partenaires", :force => true do |t|
    t.integer "soumission_id"
    t.string  "nom"
    t.string  "etablissement_gestionnaire"
    t.string  "ville"
    t.string  "pays"
    t.string  "localisation",               :default => "autre"
  end

  add_index "soumission_partenaires", ["soumission_id"], :name => "index_soumission_partenaires_on_soumission_id"

  create_table "soumission_personnels", :force => true do |t|
    t.integer "soumission_id"
    t.string  "nom"
    t.string  "prenom"
    t.string  "statut"
    t.string  "tutelle"
    t.decimal "pourcentage",   :precision => 3, :scale => 0
  end

  add_index "soumission_personnels", ["soumission_id"], :name => "index_soumission_personnels_on_soumission_id"

  create_table "soumissions", :force => true do |t|
    t.integer  "contrat_id"
    t.integer  "contrat_type_id"
    t.date     "date_depot"
    t.integer  "nombre_mois"
    t.string   "etablissement_gestionnaire"
    t.string   "organisme_financeur"
    t.text     "mots_cles_libres"
    t.text     "poles_competivites"
    t.string   "porteur"
    t.string   "etablissement_rattachement_porteur"
    t.boolean  "est_porteur"
    t.string   "coordinateur"
    t.string   "etablissement_gestionnaire_du_coordinateur"
    t.decimal  "taux_subvention",                            :precision => 3,  :scale => 2, :default => 1.0
    t.decimal  "total_subvention",                           :precision => 12, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "thematiques"
    t.text     "md_type_montant"
    t.decimal  "md_fonctionnement",                          :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "md_equipement",                              :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "md_salaire",                                 :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "md_mission",                                 :precision => 12, :scale => 2, :default => 0.0
    t.integer  "md_allocation",                                                             :default => 0
    t.decimal  "md_total",                                   :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "pd_doctorant",                               :precision => 4,  :scale => 0, :default => 0
    t.decimal  "pd_post_doc",                                :precision => 4,  :scale => 0, :default => 0
    t.decimal  "pd_ingenieur",                               :precision => 4,  :scale => 0, :default => 0
    t.decimal  "pd_autre",                                   :precision => 4,  :scale => 0, :default => 0
    t.decimal  "md_couts_indirects",                         :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "pd_equivalent_temps_plein",                  :precision => 4,  :scale => 2, :default => 0.0
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "organisme_gestionnaire_id"
    t.decimal  "md_non_ventile",                             :precision => 12, :scale => 2, :default => 0.0
    t.string   "verrou",                                                                    :default => "Aucun"
    t.text     "verrou_listchamps"
  end

  add_index "soumissions", ["contrat_id"], :name => "index_soumissions_on_contrat_id"
  add_index "soumissions", ["contrat_type_id"], :name => "index_soumissions_on_contrat_type_id"
  add_index "soumissions", ["organisme_gestionnaire_id"], :name => "index_soumissions_on_organisme_gestionnaire_id"

  create_table "sous_contrat_notifications", :force => true do |t|
    t.integer "sous_contrat_id"
    t.integer "notification_id"
    t.decimal "ma_fonctionnement",                 :precision => 12, :scale => 2, :default => 0.0
    t.decimal "ma_equipement",                     :precision => 12, :scale => 2, :default => 0.0
    t.decimal "ma_salaire",                        :precision => 12, :scale => 2, :default => 0.0
    t.decimal "ma_mission",                        :precision => 12, :scale => 2, :default => 0.0
    t.decimal "ma_non_ventile",                    :precision => 12, :scale => 2, :default => 0.0
    t.decimal "ma_couts_indirects",                :precision => 12, :scale => 2, :default => 0.0
    t.string  "ma_allocation",                                                    :default => "0"
    t.decimal "ma_total",                          :precision => 12, :scale => 2, :default => 0.0
    t.decimal "pa_doctorant",                      :precision => 4,  :scale => 0, :default => 0
    t.decimal "pa_post_doc",                       :precision => 4,  :scale => 0, :default => 0
    t.decimal "pa_ingenieur",                      :precision => 4,  :scale => 0, :default => 0
    t.decimal "pa_autre",                          :precision => 4,  :scale => 0, :default => 0
    t.decimal "pa_equivalent_temps_plein",         :precision => 5,  :scale => 2, :default => 0.0
    t.decimal "ma_frais_gestion_mutualises",       :precision => 12, :scale => 2, :default => 0.0
    t.string  "verrou",                                                           :default => "Aucun"
    t.text    "verrou_listchamps"
    t.decimal "ma_frais_gestion_mutualises_local", :precision => 10, :scale => 2, :default => 0.0
  end

  add_index "sous_contrat_notifications", ["notification_id"], :name => "index_sous_contrat_notifications_on_notification_id"
  add_index "sous_contrat_notifications", ["sous_contrat_id"], :name => "index_sous_contrat_notifications_on_sous_contrat_id"

  create_table "sous_contrat_notifications_bad", :id => false, :force => true do |t|
    t.integer "id",                                                         :default => 0,       :null => false
    t.integer "sous_contrat_id"
    t.integer "notification_id"
    t.decimal "ma_fonctionnement",           :precision => 10, :scale => 2, :default => 0.0
    t.decimal "ma_equipement",               :precision => 10, :scale => 2, :default => 0.0
    t.decimal "ma_salaire",                  :precision => 10, :scale => 2, :default => 0.0
    t.decimal "ma_mission",                  :precision => 10, :scale => 2, :default => 0.0
    t.decimal "ma_non_ventile",              :precision => 10, :scale => 2, :default => 0.0
    t.decimal "ma_couts_indirects",          :precision => 10, :scale => 2, :default => 0.0
    t.string  "ma_allocation",                                              :default => "0"
    t.decimal "ma_total",                    :precision => 10, :scale => 2, :default => 0.0
    t.decimal "pa_doctorant",                :precision => 4,  :scale => 0, :default => 0
    t.decimal "pa_post_doc",                 :precision => 4,  :scale => 0, :default => 0
    t.decimal "pa_ingenieur",                :precision => 4,  :scale => 0, :default => 0
    t.decimal "pa_autre",                    :precision => 4,  :scale => 0, :default => 0
    t.decimal "pa_equivalent_temps_plein",   :precision => 5,  :scale => 2, :default => 0.0
    t.decimal "ma_frais_gestion_mutualises", :precision => 10, :scale => 2, :default => 0.0
    t.string  "verrou",                                                     :default => "Aucun"
    t.text    "verrou_listchamps"
    t.date    "created_at"
  end

  create_table "sous_contrats", :force => true do |t|
    t.integer  "contrat_id"
    t.integer  "entite_id"
    t.string   "entite_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",            :default => "Aucun"
    t.text     "verrou_listchamps"
  end

  add_index "sous_contrats", ["contrat_id"], :name => "index_sous_contrats_on_contrat_id"
  add_index "sous_contrats", ["entite_id", "entite_type"], :name => "index_sous_contrats_on_entite_id_and_entite_type"

  create_table "todoitems", :force => true do |t|
    t.integer  "todolist_id"
    t.text     "intitule"
    t.integer  "position"
    t.boolean  "done",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.boolean  "has_alerte",  :default => false
    t.date     "date"
  end

  add_index "todoitems", ["todolist_id"], :name => "index_todoitems_on_todolist_id"

  create_table "todolists", :force => true do |t|
    t.integer  "contrat_id"
    t.string   "nom"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "todolists", ["contrat_id"], :name => "index_todolists_on_contrat_id"

  create_table "tutelle_logos", :force => true do |t|
    t.integer  "tutelle_id"
    t.string   "logo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tutelle_logos", ["tutelle_id"], :name => "index_tutelle_logos_on_tutelle_id"

  create_table "tutelle_subscriptions", :force => true do |t|
    t.integer  "projet_id"
    t.integer  "tutelle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tutelle_subscriptions", ["projet_id"], :name => "index_tutelle_subscriptions_on_projet_id"
  add_index "tutelle_subscriptions", ["tutelle_id"], :name => "index_tutelle_subscriptions_on_tutelle_id"

  create_table "tutelles", :force => true do |t|
    t.string   "nom"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
  end

  create_table "user_images", :force => true do |t|
    t.integer  "user_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_images", ["user_id"], :name => "index_user_images_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "nom"
    t.string   "prenom"
    t.string   "email"
    t.string   "image"
    t.string   "commentaire"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "ldap",                                    :default => false
    t.string   "type_ldap"
    t.string   "photose"
  end

  create_table "versements", :force => true do |t|
    t.integer  "ligne_id"
    t.date     "date_effet"
    t.string   "reference"
    t.decimal  "montant",           :precision => 10, :scale => 2, :default => 0.0
    t.string   "ventilation"
    t.string   "origine"
    t.text     "commentaire"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verrou",                                           :default => "Aucun"
    t.text     "verrou_listchamps"
    t.string   "si_id"
  end

  add_index "versements", ["ligne_id"], :name => "index_versements_on_ligne_id"

end
