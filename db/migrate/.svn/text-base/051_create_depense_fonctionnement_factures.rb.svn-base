class CreateDepenseFonctionnementFactures < ActiveRecord::Migration
  def self.up
    create_table :depense_fonctionnement_factures do |t|
      t.integer :depense_fonctionnement_id
      t.date :date
      t.string :numero_facture
      t.decimal :cout_ht,  :precision => 9, :scale =>3,  :default => 0
      t.string :taux_tva
      t.decimal :cout_ttc,  :precision => 9, :scale =>3,  :default => 0
      t.string :justifiable
      t.text :commentaire
      t.integer :rubrique_comptable_id
      t.string :numero_mandat
      t.date :date_mandatement
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :depense_fonctionnement_factures
  end
end
