class AddVerrouProjet < ActiveRecord::Migration
  def self.up
    add_column :projets, :verrou, :string, :default => 'Aucun'
    add_column :projets, :verrou_listchamps, :text, :default => ''
  end

  def self.down
    remove_column :projets, :verrou
    remove_column :projets, :verrou_listchamps
  end
end
