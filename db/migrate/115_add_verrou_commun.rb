class AddVerrouCommun < ActiveRecord::Migration
  def self.up
    add_column :depense_communs, :verrou, :string, :default => 'Aucun'
    add_column :depense_communs, :verrou_listchamps, :text, :default => ''
    add_column :depense_commun_factures, :verrou, :string, :default => 'Aucun'
    add_column :depense_commun_factures, :verrou_listchamps, :text, :default => ''
  end

  def self.down
    remove_column :depense_communs, :verrou
    remove_column :depense_communs, :verrou_listchamps
    remove_column :depense_commun_factures, :verrou
    remove_column :depense_commun_factures, :verrou_listchamps
  end
end
