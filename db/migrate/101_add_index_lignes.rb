class AddIndexLignes < ActiveRecord::Migration
  def self.up
    add_index :lignes, :nom
  end
  
  def self.down
    remove_index :lignes, :nom
  end
end
