class AddGepibudDepenses < ActiveRecord::Migration
  def self.up
    add_column :depense_non_ventilees, :tache, :string, :default => ''
    add_column :depense_fonctionnements, :tache, :string, :default => ''
    add_column :depense_equipements, :tache, :string, :default => ''
    add_column :depense_missions, :tache, :string, :default => ''
    add_column :depense_salaires, :tache, :string, :default => ''
    add_column :depense_non_ventilees, :montant_paye, :decimal, :precision => 10, :scale =>2,  :default => 0
    add_column :depense_fonctionnements, :montant_paye, :decimal, :precision => 10, :scale =>2,  :default => 0
    add_column :depense_equipements, :montant_paye, :decimal, :precision => 10, :scale =>2,  :default => 0
    add_column :depense_missions, :montant_paye, :decimal, :precision => 10, :scale =>2,  :default => 0
    add_column :depense_salaires, :montant_paye, :decimal, :precision => 10, :scale =>2,  :default => 0
    add_column :depense_non_ventilees, :destination_budgetaire, :string, :default => ''
    add_column :depense_fonctionnements, :destination_budgetaire, :string, :default => ''
    add_column :depense_equipements, :destination_budgetaire, :string, :default => ''
    add_column :depense_missions, :destination_budgetaire, :string, :default => ''
    add_column :depense_salaires, :destination_budgetaire, :string, :default => ''
    add_column :depense_non_ventilees, :eligible, :boolean,  :default => false
    add_column :depense_fonctionnements, :eligible, :boolean,  :default => false
    add_column :depense_equipements, :eligible, :boolean,  :default => false
    add_column :depense_missions, :eligible, :boolean,  :default => false
    add_column :depense_salaires, :eligible, :boolean,  :default => false
    add_column :depense_non_ventilees, :type_activite, :string, :default => ''
    add_column :depense_fonctionnements, :type_activite, :string, :default => ''
    add_column :depense_equipements, :type_activite, :string, :default => ''
    add_column :depense_missions, :type_activite, :string, :default => ''
    add_column :depense_salaires, :type_activite, :string, :default => ''

  end

  def self.down
    remove_column :depense_non_ventilees, :tache
    remove_column :depense_fonctionnements, :tache
    remove_column :depense_equipements, :tache
    remove_column :depense_missions, :tache
    remove_column :depense_salaires, :tache
    remove_column :depense_non_ventilees, :montant_paye
    remove_column :depense_fonctionnements, :montant_paye
    remove_column :depense_equipements, :montant_paye
    remove_column :depense_missions, :montant_paye
    remove_column :depense_salaires, :montant_paye
    remove_column :depense_non_ventilees, :destination_budgetaire
    remove_column :depense_fonctionnements, :destination_budgetaire
    remove_column :depense_equipements, :destination_budgetaire
    remove_column :depense_missions, :destination_budgetaire
    remove_column :depense_salaires, :destination_budgetaire
    remove_column :depense_non_ventilees, :eligible
    remove_column :depense_fonctionnements, :eligible
    remove_column :depense_equipements, :eligible
    remove_column :depense_missions, :eligible
    remove_column :depense_salaires, :eligible
    remove_column :depense_non_ventilees, :type_activite
    remove_column :depense_fonctionnements, :type_activite
    remove_column :depense_equipements, :type_activite
    remove_column :depense_missions, :type_activite
    remove_column :depense_salaires, :type_activite
  end
end
