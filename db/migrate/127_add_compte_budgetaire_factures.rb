class AddCompteBudgetaireFactures < ActiveRecord::Migration
  def self.up
    add_column :depense_non_ventilee_factures, :compte_budgetaire, :string, :default => ''
    add_column :depense_fonctionnement_factures, :compte_budgetaire, :string, :default => ''
    add_column :depense_equipement_factures, :compte_budgetaire, :string, :default => ''
    add_column :depense_mission_factures, :compte_budgetaire, :string, :default => ''
    add_column :depense_salaire_factures, :compte_budgetaire, :string, :default => ''
    add_column :depense_commun_factures, :compte_budgetaire, :string, :default => ''
  end

  def self.down
    remove_column :depense_non_ventilee_factures, :compte_budgetaire
    remove_column :depense_fonctionnement_factures, :compte_budgetaire
    remove_column :depense_equipement_factures, :compte_budgetaire
    remove_column :depense_mission_factures, :compte_budgetaire
    remove_column :depense_salaire_factures, :compte_budgetaire
    remove_column :depense_commun_factures, :compte_budgetaire
  end
end
