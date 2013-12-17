class CreateKeyWords < ActiveRecord::Migration
  def self.up
    create_table :key_words do |t|
      t.column :laboratoire_id, :integer
      t.column :intitule, :string
    end
  end

  def self.down
    drop_table :key_words
  end
end
