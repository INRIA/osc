class CreateRefus < ActiveRecord::Migration
  def self.up
    create_table :refus do |t|
      t.column :contrat_id, :integer
      t.column :date, :date
      t.column :liste_attente, :boolean, :default => false
      t.column :labelise, :boolean, :default => false
      t.column :commentaire, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :refus
  end
end
