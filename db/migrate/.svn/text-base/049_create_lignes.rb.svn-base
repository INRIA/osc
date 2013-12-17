class CreateLignes < ActiveRecord::Migration
  def self.up
    create_table :lignes do |t|
      t.integer :budgetable_id
      t.string :budgetable_type
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :lignes
  end
end
