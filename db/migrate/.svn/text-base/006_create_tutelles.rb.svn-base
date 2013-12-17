class CreateTutelles < ActiveRecord::Migration
  def self.up
    create_table :tutelles do |t|
      t.column :nom, :string
      t.column :description, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :tutelles
  end
end
