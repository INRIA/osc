class AddVerrouEquipement < ActiveRecord::Migration
  def self.up
    add_column :depense_equipements, :verrou, :string, :default => 'Aucun'
    add_column :depense_equipements, :verrou_listchamps, :text, :default => ''
    add_column :depense_equipement_factures, :verrou, :string, :default => 'Aucun'
    add_column :depense_equipement_factures, :verrou_listchamps, :text, :default => ''
  end

  def self.down
    remove_column :depense_equipements, :verrou
    remove_column :depense_equipements, :verrou_listchamps
    remove_column :depense_equipement_factures, :verrou
    remove_column :depense_equipement_factures, :verrou_listchamps
  end
end
