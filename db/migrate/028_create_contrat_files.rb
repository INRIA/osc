class CreateContratFiles < ActiveRecord::Migration
  def self.up
    create_table :contrat_files do |t|
      t.column :contrat_id, :integer
      t.column :file, :string
      t.column :description, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :contrat_files
  end
end
