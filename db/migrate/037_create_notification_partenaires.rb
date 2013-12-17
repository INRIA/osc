class CreateNotificationPartenaires < ActiveRecord::Migration
  def self.up
    create_table :notification_partenaires do |t|
      t.column :notification_id, :integer
      t.column :nom, :string
      t.column :etablissement_gestionnaire, :string
      t.column :ville, :string
      t.column :pays, :string
      t.column :localisation, :string, :default => 'autre'
    end
  end

  def self.down
    drop_table :notification_partenaires
  end
end
