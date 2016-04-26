class AddCompteBudgetaireDepensesCredits < ActiveRecord::Migration
  def self.up
    add_column :depense_non_ventilees, :compte_budgetaire, :string
    add_column :depense_fonctionnements, :compte_budgetaire, :string
    add_column :depense_equipements, :compte_budgetaire, :string
    add_column :depense_missions, :compte_budgetaire, :string
    add_column :depense_salaires, :compte_budgetaire, :string
    add_column :depense_communs, :compte_budgetaire, :string
    add_column :versement, :compte_budgetaire, :string
  end

  def self.down
    remove_column :depense_non_ventilees, :compte_budgetaire
    remove_column :depense_fonctionnements, :compte_budgetaire
    remove_column :depense_equipements, :compte_budgetaire
    remove_column :depense_missions, :compte_budgetaire
    remove_column :depense_salaires, :compte_budgetaire
    remove_column :depense_communs, :compte_budgetaire
    remove_column :versement, :compte_budgetaire
  end
end
