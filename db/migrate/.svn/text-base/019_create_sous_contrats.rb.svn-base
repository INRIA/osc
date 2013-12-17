class CreateSousContrats < ActiveRecord::Migration
  def self.up
    create_table :sous_contrats do |t|
      t.column :contrat_id, :integer
      t.column :entite_id, :integer
      t.column :entite_type, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :sous_contrats
  end
end
