class AddDescriptif < ActiveRecord::Migration
  def self.up
    create_table :langues, :options => "auto_increment=1" do |t|
      t.column :langue_id, :string, :limit=>2, :null=>false
      t.column :nom_langue, :string, :limit=>30, :null=>false
    end
    create_table :descriptifs do |t|
      t.column :contrat_id, :integer, :null=>false
      t.column :langue_id, :string, :limit=>2, :null=>false
      t.column :descriptif, :text, :null=>false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_column :contrats, :publicite, :boolean, :default=>1
  end

  def self.down
    drop_table :langues
    drop_table :descriptifs
    remove_column :contrats, :publicite
  end
end
