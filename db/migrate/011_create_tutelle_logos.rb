class CreateTutelleLogos < ActiveRecord::Migration
  def self.up
    create_table :tutelle_logos do |t|
      t.column :tutelle_id, :integer
      t.column :logo, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :tutelle_logos
  end
end
