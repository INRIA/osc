class AddFraisGestionMut < ActiveRecord::Migration
  def self.up
    add_column :notifications, :ma_frais_gestion_mutualises, :decimal, :precision => 10, :scale => 2, :default => 0.0
    add_column :sous_contrat_notifications, :ma_frais_gestion_mutualises, :decimal, :precision => 10, :scale => 2, :default => 0.0
  end

  def self.down
    remove_column :notifications, :ma_frais_gestion_mutualises
    remove_column :sous_contrat_notifications, :ma_frais_gestion_mutualises
  end
end
