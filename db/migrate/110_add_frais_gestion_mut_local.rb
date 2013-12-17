class AddFraisGestionMutLocal < ActiveRecord::Migration
  def self.up
    add_column :notifications, :ma_frais_gestion_mutualises_local, :decimal, :precision => 10, :scale => 2, :default => 0.0
    add_column :sous_contrat_notifications, :ma_frais_gestion_mutualises_local, :decimal, :precision => 10, :scale => 2, :default => 0.0
    add_column :echeancier_periodes, :depenses_frais_gestion_mut_local, :decimal, :precision => 8, :scale =>2, :default => 0.0
  end

  def self.down
    remove_column :notifications, :ma_frais_gestion_mutualises_local
    remove_column :sous_contrat_notifications, :ma_frais_gestion_mutualises_local
    remove_column :echeancier_periodes, :depenses_frais_gestion_mut_local
  end
end
