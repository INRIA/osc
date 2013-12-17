class CreateTodolists < ActiveRecord::Migration
  def self.up
    create_table :todolists do |t|
      t.column :contrat_id, :integer
      t.column :nom, :string
      t.column :position, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :todolists
  end
end
