class CreateDepenseSalaireFactures < ActiveRecord::Migration
  def self.up
    create_table :depense_salaire_factures do |t|
      t.integer :depense_salaire_id
      t.decimal :cout,  :precision => 9, :scale =>3,  :default => 0
      t.text :commentaire
      t.string :numero_mandat
      t.date :date_mandatement
      t.integer :rubrique_comptable_id
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :depense_salaire_factures
  end
end
