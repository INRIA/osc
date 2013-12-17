class CreateDepenseSalaires < ActiveRecord::Migration
  def self.up
    create_table :depense_salaires do |t|
      t.integer :ligne_id
      t.string :agent
      t.string :type_contrat
      t.string :statut
      t.date :date_commande
      t.date :date_debut
      t.date :date_fin
      t.date :date_min
      t.date :date_max
      t.integer :nb_mois
      t.decimal :cout_mensuel
      t.decimal :cout_periode
      t.boolean :commande_solde
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :depense_salaires
  end
end
