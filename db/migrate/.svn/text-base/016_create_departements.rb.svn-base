class CreateDepartements < ActiveRecord::Migration
  def self.up
    create_table :departements do |t|
      t.column :nom, :string
      t.column :description, :text
      t.column :laboratoire_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :departements
  end
end
