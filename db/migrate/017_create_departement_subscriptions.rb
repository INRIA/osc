class CreateDepartementSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :departement_subscriptions do |t|
      t.column :projet_id, :integer
      t.column :departement_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :departement_subscriptions
  end
end
