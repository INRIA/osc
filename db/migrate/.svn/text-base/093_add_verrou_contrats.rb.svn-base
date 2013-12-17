class AddVerrouContrats < ActiveRecord::Migration
  def self.up
    add_column :contrats, :verrou, :string, :default => 'Aucun'
    add_column :contrats, :verrou_listchamps, :text, :default => ''
    add_column :lignes, :verrou, :string, :default => 'Aucun'
    add_column :lignes, :verrou_listchamps, :text, :default => ''
    add_column :soumissions, :verrou, :string, :default => 'Aucun'
    add_column :soumissions, :verrou_listchamps, :text, :default => ''
    add_column :notifications, :verrou, :string, :default => 'Aucun'
    add_column :notifications, :verrou_listchamps, :text, :default => ''
    add_column :sous_contrats, :verrou, :string, :default => 'Aucun'
    add_column :sous_contrats, :verrou_listchamps, :text, :default => ''
    add_column :sous_contrat_notifications, :verrou, :string, :default => 'Aucun'
    add_column :sous_contrat_notifications, :verrou_listchamps, :text, :default => ''
    add_column :echeanciers, :verrou, :string, :default => 'Aucun'
    add_column :echeanciers, :verrou_listchamps, :text, :default => ''
    add_column :echeancier_periodes, :verrou, :string, :default => 'Aucun'
    add_column :echeancier_periodes, :verrou_listchamps, :text, :default => ''
    add_column :signatures, :verrou, :string, :default => 'Aucun'
    add_column :signatures, :verrou_listchamps, :text, :default => ''
    add_column :contrat_types, :verrou, :string, :default => 'Aucun'
    add_column :contrat_types, :verrou_listchamps, :text, :default => ''
    
  end

  def self.down
    remove_column :contrats, :verrou
    remove_column :contrats, :verrou_listchamps
    remove_column :lignes, :verrou
    remove_column :lignes, :verrou_listchamps
    remove_column :soumissions, :verrou
    remove_column :soumissions, :verrou_listchamps
    remove_column :notifications, :verrou
    remove_column :notifications, :verrou_listchamps
    remove_column :sous_contrats, :verrou
    remove_column :sous_contrats, :verrou_listchamps
    remove_column :sous_contrat_notifications, :verrou
    remove_column :sous_contrat_notifications, :verrou_listchamps
    remove_column :echeanciers, :verrou
    remove_column :echeanciers, :verrou_listchamps
    remove_column :echeancier_periodes, :verrou
    remove_column :echeancier_periodes, :verrou_listchamps
    remove_column :signatures, :verrou
    remove_column :signatures, :verrou_listchamps
    remove_column :contrat_types, :verrou
    remove_column :contrat_types, :verrou_listchamps
  end
end
