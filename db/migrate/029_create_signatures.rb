class CreateSignatures < ActiveRecord::Migration
  def self.up
    create_table :signatures do |t|
      t.column :contrat_id, :integer
      t.column :date, :date
      t.column :commentaire, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :signatures
  end
end
