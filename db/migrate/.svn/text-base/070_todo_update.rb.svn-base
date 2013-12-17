class TodoUpdate < ActiveRecord::Migration
  def self.up
    add_column :todoitems, "has_alerte", :boolean, :default => false
    add_column :todoitems, "date", :date
  end

  def self.down
    remove_column :todoitems, :has_alerte
    remove_column :todoitems, :date
  end
end