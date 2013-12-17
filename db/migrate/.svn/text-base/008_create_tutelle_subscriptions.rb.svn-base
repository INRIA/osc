class CreateTutelleSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :tutelle_subscriptions do |t|
      t.column :projet_id, :integer
      t.column :tutelle_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :tutelle_subscriptions
  end
end
