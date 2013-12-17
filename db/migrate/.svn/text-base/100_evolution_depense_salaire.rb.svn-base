class EvolutionDepenseSalaire < ActiveRecord::Migration
  def self.up
    # Contratuels & Titulaire
    add_column :depense_salaires, "type_personnel", :string, :default => 'unknown'
    # Contratuels & Titulaire
    add_column :depense_salaires, "nb_heures_justifiees", :integer
    # Contratuels & Titulaire
    add_column :depense_salaires, "cout_indirect_unitaire", :decimal, :precision => 8, :scale => 2, :default => 0
    # Contratuels & Titulaire
    add_column :depense_salaires, "somme_salaires_charges", :decimal, :precision => 8, :scale => 2, :default => 0
    # Titulaire
    add_column :depense_salaires, "nb_heures_declarees", :integer
    # Contratuels
    add_column :depense_salaires, "date_debut_prise_en_charge_sur_contrat", :date
    # Contratuels
    add_column :depense_salaires, "date_fin_prise_en_charge_sur_contrat", :date
  end

  def self.down
    remove_column :depense_salaires, :type_personnel
    remove_column :depense_salaires, :nb_heures_justifiees
    remove_column :depense_salaires, :cout_indirect_unitaire
    remove_column :depense_salaires, :somme_salaires_charges
    remove_column :depense_salaires, :nb_heures_declarees
    remove_column :depense_salaires, :date_debut_prise_en_charge_sur_contrat
    remove_column :depense_salaires, :date_fin_prise_en_charge_sur_contrat
  end
end
