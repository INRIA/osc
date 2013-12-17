class CreateUserImages < ActiveRecord::Migration
  def self.up
    create_table :user_images do |t|
      t.column :user_id, :integer
      t.column :image, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :user_images
  end
end
