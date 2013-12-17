class CreateEcheanciers < ActiveRecord::Migration
  def self.up
    create_table :echeanciers do |t|
      t.column :echeanciable_id, :integer
      t.column :echeanciable_type, :string
      t.column :global_depenses_frais_gestion, :decimal
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :created_by, :integer
      t.column :updated_by, :integer
    end
  end

  def self.down
    drop_table :echeanciers
  end
end
