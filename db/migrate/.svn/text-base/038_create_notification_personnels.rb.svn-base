class CreateNotificationPersonnels < ActiveRecord::Migration
  def self.up
    create_table :notification_personnels do |t|
      t.column :notification_id, :integer
      t.column :nom, :string
      t.column :prenom, :string
      t.column :statut, :string
      t.column :tutelle, :string
      t.column :pourcentage, :integer, :limit => 3, :precision => 3, :scale => 0
    end
  end

  def self.down
    drop_table :notification_personnels
  end
end
