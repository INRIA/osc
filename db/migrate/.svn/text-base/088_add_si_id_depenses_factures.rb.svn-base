class AddSiIdDepensesFactures < ActiveRecord::Migration
  def self.up
    add_column :depense_non_ventilees, :si_id, :string
    add_column :depense_fonctionnements, :si_id, :string
    add_column :depense_equipements, :si_id, :string
    add_column :depense_missions, :si_id, :string
    add_column :depense_salaires, :si_id, :string
    add_column :depense_non_ventilee_factures, :si_id, :string
    add_column :depense_fonctionnement_factures, :si_id, :string
    add_column :depense_equipement_factures, :si_id, :string
    add_column :depense_mission_factures, :si_id, :string
    add_column :depense_salaire_factures, :si_id, :string
  end

  def self.down
    remove_column :depense_non_ventilees, :si_id
    remove_column :depense_fonctionnements, :si_id
    remove_column :depense_equipements, :si_id
    remove_column :depense_missions, :si_id
    remove_column :depense_salaires, :si_id
    remove_column :depense_non_ventilee_factures, :si_id
    remove_column :depense_fonctionnement_factures, :si_id
    remove_column :depense_equipement_factures, :si_id
    remove_column :depense_mission_factures, :si_id
    remove_column :depense_salaire_factures, :si_id
  end
end
