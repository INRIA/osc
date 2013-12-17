class CreateClotures < ActiveRecord::Migration
  def self.up
    create_table :clotures do |t|
      t.column :contrat_id, :integer
      t.column :date_fin_depenses, :date
      t.column :commentaires, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :created_by, :integer
      t.column :updated_by, :integer
    end
  end

  def self.down
    drop_table :clotures
  end
end
