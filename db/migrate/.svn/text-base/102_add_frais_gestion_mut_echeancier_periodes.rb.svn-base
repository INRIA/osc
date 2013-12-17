class AddFraisGestionMutEcheancierPeriodes < ActiveRecord::Migration
  def self.up
    add_column :echeancier_periodes, :depenses_frais_gestion_mut, :decimal, :precision => 8, :scale =>2, :default => 0.0
  end

  def self.down
    remove_column :echeancier_periodes, :depenses_frais_gestion_mut
  end
end
