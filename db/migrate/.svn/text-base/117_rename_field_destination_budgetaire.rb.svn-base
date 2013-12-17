class RenameFieldDestinationBudgetaire < ActiveRecord::Migration
  def self.up
    rename_column :depense_fonctionnements, :destination_budgetaire, :structure
    rename_column :depense_equipements, :destination_budgetaire, :structure
    rename_column :depense_missions, :destination_budgetaire, :structure
    rename_column :depense_salaires, :destination_budgetaire, :structure
    rename_column :depense_non_ventilees, :destination_budgetaire, :structure
  end
  
  def self.down
    rename_column :depense_fonctionnements, :structure, :destination_budgetaire
    rename_column :depense_equipements, :structure, :destination_budgetaire
    rename_column :depense_missions, :structure, :destination_budgetaire
    rename_column :depense_salaires, :structure, :destination_budgetaire
    rename_column :depense_non_ventilees, :structure, :destination_budgetaire
  end
end