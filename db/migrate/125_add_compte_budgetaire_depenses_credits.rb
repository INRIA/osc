class AddCompteBudgetaireDepensesCredits < ActiveRecord::Migration
  def self.up
    add_column :depense_non_ventilees, :compte_budgetaire, :string, :default => ''
    add_column :depense_fonctionnements, :compte_budgetaire, :string, :default => ''
    add_column :depense_equipements, :compte_budgetaire, :string, :default => ''
    add_column :depense_missions, :compte_budgetaire, :string, :default => ''
    add_column :depense_salaires, :compte_budgetaire, :string, :default => ''
    add_column :depense_communs, :compte_budgetaire, :string, :default => ''
    add_column :versements, :compte_budgetaire, :string, :default => ''
  end

  def self.down
    remove_column :depense_non_ventilees, :compte_budgetaire
    remove_column :depense_fonctionnements, :compte_budgetaire
    remove_column :depense_equipements, :compte_budgetaire
    remove_column :depense_missions, :compte_budgetaire
    remove_column :depense_salaires, :compte_budgetaire
    remove_column :depense_communs, :compte_budgetaire
    remove_column :versements, :compte_budgetaire
  end
end
