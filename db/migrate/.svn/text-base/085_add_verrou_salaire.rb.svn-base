class AddVerrouSalaire < ActiveRecord::Migration
  def self.up
    add_column :depense_salaires, :verrou, :string, :default => 'Aucun'
    add_column :depense_salaires, :verrou_listchamps, :text, :default => ''
    add_column :depense_salaire_factures, :verrou, :string, :default => 'Aucun'
    add_column :depense_salaire_factures, :verrou_listchamps, :text, :default => ''
  end

  def self.down
    remove_column :depense_salaires, :verrou
    remove_column :depense_salaires, :verrou_listchamps
    remove_column :depense_salaire_factures, :verrou
    remove_column :depense_salaire_factures, :verrou_listchamps
  end
end
