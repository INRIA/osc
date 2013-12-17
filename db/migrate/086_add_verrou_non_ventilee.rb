class AddVerrouNonVentilee < ActiveRecord::Migration
  def self.up
    add_column :depense_non_ventilees, :verrou, :string, :default => 'Aucun'
    add_column :depense_non_ventilees, :verrou_listchamps, :text, :default => ''
    add_column :depense_non_ventilee_factures, :verrou, :string, :default => 'Aucun'
    add_column :depense_non_ventilee_factures, :verrou_listchamps, :text, :default => ''
  end

  def self.down
    remove_column :depense_non_ventilees, :verrou
    remove_column :depense_non_ventilees, :verrou_listchamps
    remove_column :depense_non_ventilee_factures, :verrou
    remove_column :depense_non_ventilee_factures, :verrou_listchamps
  end
end
