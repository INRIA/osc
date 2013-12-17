class AddGepibudDepensesFactures < ActiveRecord::Migration
  def self.up
    add_column :depense_non_ventilee_factures, :montant_htr, :decimal, :precision => 10, :scale =>2,  :default => 0
    add_column :depense_fonctionnement_factures, :montant_htr, :decimal, :precision => 10, :scale =>2,  :default => 0
    add_column :depense_equipement_factures, :montant_htr, :decimal, :precision => 10, :scale =>2,  :default => 0
    add_column :depense_mission_factures, :montant_htr, :decimal, :precision => 10, :scale =>2,  :default => 0
    add_column :depense_salaire_factures, :montant_htr, :decimal, :precision => 10, :scale =>2,  :default => 0

  end

  def self.down
    remove_column :depense_non_ventilee_factures, :montant_htr
    remove_column :depense_fonctionnement_factures, :montant_htr
    remove_column :depense_equipement_factures, :montant_htr
    remove_column :depense_mission_factures, :montant_htr
    remove_column :depense_salaire_factures, :montant_htr
  end
end
