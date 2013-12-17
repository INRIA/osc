class UpdateFactures < ActiveRecord::Migration
  def self.up
    change_column :depense_non_ventilee_factures, :montant_htr, :decimal, :precision => 10, :scale =>2, :default => nil
    change_column :depense_fonctionnement_factures, :montant_htr, :decimal, :precision => 10, :scale =>2, :default => nil
    change_column :depense_equipement_factures, :montant_htr, :decimal, :precision => 10, :scale =>2, :default => nil
    change_column :depense_mission_factures, :montant_htr, :decimal, :precision => 10, :scale =>2, :default => nil
    change_column :depense_salaire_factures, :montant_htr, :decimal, :precision => 10, :scale =>2, :default => nil
    change_column :depense_non_ventilee_factures, :cout_ht, :decimal, :precision => 10, :scale =>2, :default => nil
    change_column :depense_fonctionnement_factures, :cout_ht, :decimal, :precision => 10, :scale =>2, :default => nil
    change_column :depense_equipement_factures, :cout_ht, :decimal, :precision => 10, :scale =>2, :default => nil
    change_column :depense_mission_factures, :cout_ht, :decimal, :precision => 10, :scale =>2, :default => nil
    change_column :depense_salaire_factures, :cout, :decimal, :precision => 10, :scale =>2, :default => nil

  end

  def self.down
    change_column :depense_non_ventilee_factures, :montant_htr, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_fonctionnement_factures, :montant_htr, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_equipement_factures, :montant_htr, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_mission_factures, :montant_htr, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_salaire_factures, :montant_htr, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_non_ventilee_factures, :cout_ht, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_fonctionnement_factures, :cout_ht, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_equipement_factures, :cout_ht, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_mission_factures, :cout_ht, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_salaire_factures, :cout, :decimal, :precision => 10, :scale =>2,  :default => 0
  end
end
