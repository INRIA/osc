class AddVerrouFonctionnement < ActiveRecord::Migration
  def self.up
    add_column :depense_fonctionnements, :verrou, :string, :default => 'Aucun'
    add_column :depense_fonctionnements, :verrou_listchamps, :text, :default => ''
    add_column :depense_fonctionnement_factures, :verrou, :string, :default => 'Aucun'
    add_column :depense_fonctionnement_factures, :verrou_listchamps, :text, :default => ''
  end

  def self.down
    remove_column :depense_fonctionnements, :verrou
    remove_column :depense_fonctionnements, :verrou_listchamps
    remove_column :depense_fonctionnement_factures, :verrou
    remove_column :depense_fonctionnement_factures, :verrou_listchamps
  end
end
