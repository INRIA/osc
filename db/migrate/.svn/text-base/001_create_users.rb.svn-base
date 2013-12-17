class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :nom, :string
      t.column :prenom, :string
      t.column :email, :string
      t.column :image, :string
      t.column :commentaire, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :users
  end
end
