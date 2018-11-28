class AddCodeProjetDepenses < ActiveRecord::Migration
  def self.up
    add_column :depense_non_ventilees, :code_projet, :string, :default => ''
    add_column :depense_fonctionnements, :code_projet, :string, :default => ''
    add_column :depense_equipements, :code_projet, :string, :default => ''
    add_column :depense_missions, :code_projet, :string, :default => ''
    add_column :depense_salaires, :code_projet, :string, :default => ''
    add_column :depense_communs, :code_projet, :string, :default => ''
  end

  def self.down
    remove_column :depense_non_ventilees, :code_projet
    remove_column :depense_fonctionnements, :code_projet
    remove_column :depense_equipements, :code_projet
    remove_column :depense_missions, :code_projet
    remove_column :depense_salaires, :code_projet
    remove_column :depense_communs, :code_projet
  end
end
