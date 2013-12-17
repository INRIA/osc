class CreateTodoitems < ActiveRecord::Migration
  def self.up
    create_table :todoitems do |t|
      t.column :todolist_id, :integer
      t.column :intitule, :text
      t.column :position, :integer
      t.column :done, :boolean, :default => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :todoitems
  end
end
