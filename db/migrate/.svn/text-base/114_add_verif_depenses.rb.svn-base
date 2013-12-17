class AddVerifDepenses < ActiveRecord::Migration
  def self.up
    add_column :depense_fonctionnements, :verif, :bool, :default => false
    add_column :depense_equipements, :verif, :bool, :default => false
    add_column :depense_missions, :verif, :bool, :default => false
    add_column :depense_salaires, :verif, :bool, :default => false
    add_column :depense_non_ventilees, :verif, :bool, :default => false
    add_column :depense_communs, :verif, :bool, :default => false
    
  end

  def self.down
    remove_column :depense_fonctionnements, :verif
    remove_column :depense_equipements, :verif
    remove_column :depense_missions, :verif
    remove_column :depense_salaires, :verif
    remove_column :depense_non_ventilees, :verif
    remove_column :depense_communs, :verif
  end
end
