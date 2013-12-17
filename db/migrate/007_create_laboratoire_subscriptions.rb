class CreateLaboratoireSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :laboratoire_subscriptions do |t|
      t.column :projet_id, :integer
      t.column :laboratoire_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :laboratoire_subscriptions
  end
end
