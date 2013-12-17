class CreateVersements < ActiveRecord::Migration
  def self.up
    create_table :versements do |t|
      t.integer :ligne_id
      t.date :date_effet
      t.string :reference
      t.decimal :montant
      t.string :ventilation
      t.string :origine
      t.text :commentaire
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :versements
  end
end
