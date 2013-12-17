class Update2 < ActiveRecord::Migration
  def self.up
    remove_column :soumissions, :acronyme
    add_column :contrats, "acronyme", :string
  end

  def self.down
    add_column :soumissions, "acronyme", :string
    remove_column :contrats, :acronyme
  end
end