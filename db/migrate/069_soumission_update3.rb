class SoumissionUpdate3 < ActiveRecord::Migration
  def self.up
    add_column :soumissions, "md_non_ventile", :decimal, :precision => 8, :scale =>2, :default =>0
  end

  def self.down
    remove_column :soumissions, :md_non_ventile
  end
end