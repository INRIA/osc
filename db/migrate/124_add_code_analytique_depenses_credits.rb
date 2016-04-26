class AddCodeAnalytiqueDepensesCredits < ActiveRecord::Migration
  def self.up
    add_column :depense_non_ventilees, :code_analytique, :string
    add_column :depense_fonctionnements, :code_analytique, :string
    add_column :depense_equipements, :code_analytique, :string
    add_column :depense_missions, :code_analytique, :string
    add_column :depense_salaires, :code_analytique, :string
    add_column :depense_communs, :code_analytique, :string
    add_column :versements, :code_analytique, :string
  end

  def self.down
    remove_column :depense_non_ventilees, :code_analytique
    remove_column :depense_fonctionnements, :code_analytique
    remove_column :depense_equipements, :code_analytique
    remove_column :depense_missions, :code_analytique
    remove_column :depense_salaires, :code_analytique
    remove_column :depense_communs, :code_analytique
    remove_column :versements, :code_analytique
  end
end
