class CreateContratTypes < ActiveRecord::Migration
  def self.up
    create_table :contrat_types do |t|
      t.column :parent_id, :integer
      t.column :nom, :string
    end
  end

  def self.down
    drop_table :contrat_types
  end
end
