class AddVerrouVersement < ActiveRecord::Migration
  def self.up
    add_column :versements, :verrou, :string, :default => 'Aucun'
  end

  def self.down
    remove_column :versements, :verrou
  end
end
