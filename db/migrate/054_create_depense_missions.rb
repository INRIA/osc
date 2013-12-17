class CreateDepenseMissions < ActiveRecord::Migration
  def self.up
    create_table :depense_missions do |t|
      t.integer :ligne_id
      t.string :agent
      t.string :reference
      t.date :date_commande
      t.date :date_depart
      t.date :date_retour
      t.date :date_min
      t.date :date_max
      t.string :lieux
      t.text :intitule
      t.decimal :montant_engage
      t.boolean :commande_solde
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :depense_missions
  end
end
