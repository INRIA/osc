class DeleteIdForKeyWords < ActiveRecord::Migration
  def self.up
    remove_column :key_words_notifications, :id
    remove_column :key_words_soumissions, :id
  end

  def self.down
    add_column :key_words_notifications, "id", :integer
    add_column :key_words_soumissions, "id", :integer
  end
end
