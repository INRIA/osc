class CreateGroupRights < ActiveRecord::Migration
  def self.up
    create_table :group_rights, :force => true do |t|
      t.column :group_id,         :integer, :null => false
      t.column :role_id,          :integer, :null => false
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end
  end

  def self.down
    drop_table :group_rights
  end
end
