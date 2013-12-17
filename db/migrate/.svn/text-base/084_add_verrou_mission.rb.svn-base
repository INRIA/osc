class AddVerrouMission < ActiveRecord::Migration
  def self.up
    add_column :depense_missions, :verrou, :string, :default => 'Aucun'
    add_column :depense_missions, :verrou_listchamps, :text, :default => ''
    add_column :depense_mission_factures, :verrou, :string, :default => 'Aucun'
    add_column :depense_mission_factures, :verrou_listchamps, :text, :default => ''
  end

  def self.down
    remove_column :depense_missions, :verrou
    remove_column :depense_missions, :verrou_listchamps
    remove_column :depense_mission_factures, :verrou
    remove_column :depense_mission_factures, :verrou_listchamps
  end
end
