class AddGepibudProjetCodestructure < ActiveRecord::Migration
  def self.up
    add_column :projets, :code_structure, :string,  :default => ''

  end

  def self.down
    remove_column :projets, :code_structure
  end
end
