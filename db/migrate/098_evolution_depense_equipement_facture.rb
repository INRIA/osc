class EvolutionDepenseEquipementFacture < ActiveRecord::Migration
  def self.up
    add_column :depense_equipement_factures, "amortissement", :string, :default => "100%"
    add_column :depense_equipement_factures, "duree_amortissement", :integer
    add_column :depense_equipement_factures, "date_amortissement_debut", :date
    add_column :depense_equipement_factures, "date_amortissement_fin", :date
    add_column :depense_equipement_factures, "taux_amortissement", :decimal, :precision => 3, :scale => 2, :default => 0
    add_column :depense_equipement_factures, "montant_justifiable_htr", :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :depense_equipement_factures, "amortissement_is_in_auto_mode", :boolean, :default => true
  end

  def self.down
    remove_column :depense_equipement_factures, :amortissement
    remove_column :depense_equipement_factures, :duree_amortissement
    remove_column :depense_equipement_factures, :date_amortissement_debut
    remove_column :depense_equipement_factures, :date_amortissement_fin
    remove_column :depense_equipement_factures, :taux_amortissement
    remove_column :depense_equipement_factures, :montant_justifiable_htr
    remove_column :depense_equipement_factures, :amortissement_is_in_auto_mode
  end
end
