class CreateKeyWordsNotifications < ActiveRecord::Migration
  def self.up
    create_table :key_words_notifications do |t|
      t.column :key_word_id, :integer
      t.column :notification_id, :integer
    end
  end

  def self.down
    drop_table :key_words_notifications
  end
end
