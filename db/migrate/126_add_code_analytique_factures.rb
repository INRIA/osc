class AddCodeAnalytiqueFactures < ActiveRecord::Migration
  def self.up
    add_column :depense_non_ventilee_factures, :code_analytique, :string, :default => ''
    add_column :depense_fonctionnement_factures, :code_analytique, :string, :default => ''
    add_column :depense_equipement_factures, :code_analytique, :string, :default => ''
    add_column :depense_mission_factures, :code_analytique, :string, :default => ''
    add_column :depense_salaire_factures, :code_analytique, :string, :default => ''
    add_column :depense_commun_factures, :code_analytique, :string, :default => ''
  end

  def self.down
    remove_column :depense_non_ventilee_factures, :code_analytique
    remove_column :depense_fonctionnement_factures, :code_analytique
    remove_column :depense_equipement_factures, :code_analytique
    remove_column :depense_mission_factures, :code_analytique
    remove_column :depense_salaire_factures, :code_analytique
    remove_column :depense_commun_factures, :code_analytique
  end
end
