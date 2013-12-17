class AddActiveLignes < ActiveRecord::Migration
  def change
    add_column :lignes, :active, :boolean, :default => true
  end
end
