class AddIndex < ActiveRecord::Migration
  def self.up
    add_index :memberships, :group_id
    add_index :memberships, :user_id
    
    add_index :group_rights, :group_id
    add_index :group_rights, :role_id
    
    add_index :user_images, :user_id
    
    add_index :roles_users, [:user_id, :role_id]
    add_index :roles_users, [:role_id, :user_id]
    add_index :roles, [:authorizable_id, :authorizable_type]
    
    add_index :departements, :laboratoire_id
    add_index :departement_subscriptions, :projet_id
    add_index :departement_subscriptions, :departement_id
    
    add_index :tutelle_subscriptions, :tutelle_id
    add_index :tutelle_subscriptions, :projet_id
    add_index :tutelle_logos, :tutelle_id
    
    add_index :laboratoire_subscriptions, :laboratoire_id
    add_index :laboratoire_subscriptions, :projet_id
    
    add_index :rubrique_comptables, :parent_id
    add_index :organisme_gestionnaire_tauxes, :organisme_gestionnaire_id
    add_index :key_words, :laboratoire_id
    add_index :contrat_types, :parent_id
    
    add_index :contrat_files, :contrat_id
    add_index :sous_contrats, :contrat_id
    add_index :sous_contrats, [:entite_id, :entite_type]
    
    add_index :todolists, :contrat_id
    add_index :todoitems, :todolist_id
    
    add_index :descriptifs, :contrat_id
    add_index :descriptifs, :langue_id
    
    add_index :soumissions, :contrat_id
    add_index :soumissions, :contrat_type_id
    add_index :soumissions, :organisme_gestionnaire_id
    add_index :soumission_partenaires, :soumission_id
    add_index :soumission_france_partenaires, :soumission_id
    add_index :soumission_europe_partenaires, :soumission_id
    add_index :soumission_personnels, :soumission_id
    add_index :key_words_soumissions, [:soumission_id, :key_word_id]
    add_index :key_words_soumissions, [:key_word_id, :soumission_id]
    
    add_index :signatures, :contrat_id
    
    add_index :notifications, :contrat_id
    add_index :notifications, :contrat_type_id
    add_index :notifications, :organisme_gestionnaire_id
    add_index :notification_partenaires, :notification_id
    add_index :notification_france_partenaires, :notification_id
    add_index :notification_europe_partenaires, :notification_id
    add_index :notification_personnels, :notification_id
    add_index :key_words_notifications, [:notification_id, :key_word_id]
    add_index :key_words_notifications, [:key_word_id, :notification_id]
    add_index :sous_contrat_notifications, :sous_contrat_id
    add_index :sous_contrat_notifications, :notification_id
    
    add_index :clotures, :contrat_id
    
    add_index :refus, :contrat_id
    
    add_index :avenants, :notification_id
    
    add_index :echeancier_periodes, :echeancier_id
    add_index :echeanciers, [:echeanciable_id, :echeanciable_type]
    
    add_index :lignes, :sous_contrat_id
    
    add_index :versements, :ligne_id
    
    add_index :depense_fonctionnements, :ligne_id
    add_index :depense_fonctionnement_factures, :rubrique_comptable_id, :name => 'index_dff_on_rc_id'
    add_index :depense_fonctionnement_factures, :depense_fonctionnement_id, :name => 'index_dff_on_df_id'
    
    add_index :depense_equipements, :ligne_id
    add_index :depense_equipement_factures, :rubrique_comptable_id
    add_index :depense_equipement_factures, :depense_equipement_id
    
    add_index :depense_missions, :ligne_id
    add_index :depense_mission_factures, :depense_mission_id, :name => 'index_dmf_on_dm_id'
    add_index :depense_mission_factures, :rubrique_comptable_id, :name => 'index_dmf_on_rc_id'
    
    add_index :depense_non_ventilees, :ligne_id
    add_index :depense_non_ventilee_factures, :depense_non_ventilee_id, :name => 'index_dnvf_on_dnv_id'
    add_index :depense_non_ventilee_factures, :rubrique_comptable_id, :name => 'index_dnvf_on_rc_id'
    
    add_index :depense_salaires, :ligne_id
    add_index :depense_salaire_factures, :depense_salaire_id
  end
  
  def self.down
    remove_index :memberships, :group_id
    remove_index :memberships, :user_id
    
    remove_index :group_rights, :group_id
    remove_index :group_rights, :role_id
    
    remove_index :user_images, :user_id
    
    remove_index :roles_users, [:user_id, :role_id]
    remove_index :roles_users, [:role_id, :user_id]
    remove_index :roles, [:authorizable_id, :authorizable_type]
    
    remove_index :departements, :laboratoire_id
    remove_index :departement_subscriptions, :projet_id
    remove_index :departement_subscriptions, :departement_id
    
    remove_index :tutelle_subscriptions, :tutelle_id
    remove_index :tutelle_subscriptions, :projet_id
    remove_index :tutelle_logos, :tutelle_id
    
    remove_index :laboratoire_subscriptions, :laboratoire_id
    remove_index :laboratoire_subscriptions, :projet_id
    
    remove_index :rubrique_comptables, :parent_id
    remove_index :organisme_gestionnaire_tauxes, :organisme_gestionnaire_id
    remove_index :key_words, :laboratoire_id
    remove_index :contrat_types, :parent_id
    
    remove_index :contrat_files, :contrat_id
    remove_index :sous_contrats, :contrat_id
    remove_index :sous_contrats, [:entite_id, :entite_type]
    
    remove_index :todolists, :contrat_id
    remove_index :todoitems, :todolist_id
    
    remove_index :descriptifs, :contrat_id
    remove_index :descriptifs, :langue_id
    
    remove_index :soumissions, :contrat_id
    remove_index :soumissions, :contrat_type_id
    remove_index :soumissions, :organisme_gestionnaire_id
    remove_index :soumission_partenaires, :soumission_id
    remove_index :soumission_france_partenaires, :soumission_id
    remove_index :soumission_europe_partenaires, :soumission_id
    remove_index :soumission_personnels, :soumission_id
    remove_index :key_words_soumissions, [:soumission_id, :key_word_id]
    remove_index :key_words_soumissions, [:key_word_id, :soumission_id]
    
    remove_index :signatures, :contrat_id
    
    remove_index :notifications, :contrat_id
    remove_index :notifications, :contrat_type_id
    remove_index :notifications, :organisme_gestionnaire_id
    remove_index :notification_partenaires, :notification_id
    remove_index :notification_france_partenaires, :notification_id
    remove_index :notification_europe_partenaires, :notification_id
    remove_index :notification_personnels, :notification_id
    remove_index :key_words_notifications, [:notification_id, :key_word_id]
    remove_index :key_words_notifications, [:key_word_id, :notification_id]
    
    remove_index :sous_contrat_notifications, :sous_contrat_id
    remove_index :sous_contrat_notifications, :notification_id
    
    remove_index :clotures, :contrat_id
    
    remove_index :refus, :contrat_id
    
    remove_index :avenants, :notification_id
    
    remove_index :echeancier_periodes, :echeancier_id
    remove_index :echeanciers, [:echeanciable_id, :echeanciable_type]
    
    remove_index :lignes, :sous_contrat_id
    
    remove_index :versements, :ligne_id
    
    remove_index :depense_fonctionnements, :ligne_id
    remove_index :depense_fonctionnement_factures, :name => 'index_dff_on_rc_id'
    remove_index :depense_fonctionnement_factures, :name => 'index_dff_on_df_id'
    
    remove_index :depense_equipements, :ligne_id
    remove_index :depense_equipement_factures, :rubrique_comptable_id
    remove_index :depense_equipement_factures, :depense_equipement_id
    
    remove_index :depense_missions, :ligne_id
    remove_index :depense_mission_factures, :name => 'index_dmf_on_dm_id'
    remove_index :depense_mission_factures, :name => 'index_dmf_on_rc_id'
    
    remove_index :depense_non_ventilees, :ligne_id
    remove_index :depense_non_ventilee_factures, :name => 'index_dnvf_on_dnv_id'
    remove_index :depense_non_ventilee_factures, :name => 'index_dnvf_on_rc_id'
    
    remove_index :depense_salaires, :ligne_id
    remove_index :depense_salaire_factures, :depense_salaire_id
  end
end
