class AddSiIdVersements < ActiveRecord::Migration
  def self.up
    add_column :versements, :si_id, :string
  end

  def self.down
    remove_column :versements, :si_id
  end
end
