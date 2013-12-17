class AddMillesimeDepensesFactures < ActiveRecord::Migration
  def self.up
    add_column :depense_equipements, :millesime, :date, :default => nil
    add_column :depense_fonctionnements, :millesime, :date, :default => nil
    add_column :depense_missions, :millesime, :date, :default => nil
    add_column :depense_equipement_factures, :millesime, :date, :default => nil
    add_column :depense_fonctionnement_factures, :millesime, :date, :default => nil
    add_column :depense_mission_factures, :millesime, :date, :default => nil
  end

  def self.down
    remove_column :depense_equipements, :millesime
    remove_column :depense_fonctionnements, :millesime
    remove_column :depense_missions, :millesime
    remove_column :depense_equipement_factures, :millesime
    remove_column :depense_fonctionnement_factures, :millesime
    remove_column :depense_mission_factures, :millesime
  end
end
