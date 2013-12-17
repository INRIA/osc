class CreateDepenseEquipements < ActiveRecord::Migration
  def self.up
    create_table :depense_equipements do |t|
      t.integer :ligne_id
      t.string :fournisseur
      t.text :intitule
      t.string :reference
      t.date :date_commande
      t.date :date_min
      t.date :date_max
      t.decimal :montant_engage
      t.boolean :commande_solde
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :depense_equipements
  end
end
