class CreateDepenseDuCommun < ActiveRecord::Migration
  def self.up
    create_table :depense_communs do |t|
      t.integer :ligne_id, :null => false
      t.integer :budgetaire_reference_id, :null => false
      t.string :reference
      t.string :fournisseur
      t.text :intitule, :null => false
      t.date :date_commande
      t.date :date_min
      t.date :date_max
      t.decimal :montant_engage, :precision => 10, :scale =>2,  :default => 0
      t.boolean :commande_solde
      t.string :tache
      t.boolean :eligible, :default => false
      t.string :type_activite
      t.boolean :prestation_service, :default => false
      t.string :commentaire
      t.integer :created_by
      t.integer :updated_by
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :depense_communs, :ligne_id

    create_table :depense_commun_factures do |t|
      t.integer :depense_commun_id, :null => false
      t.integer :rubrique_comptable_id, :null => false
      t.date :date, :null => :false
      t.string :numero_facture, :limit => 20
      t.decimal :cout_ht,  :precision => 10, :scale =>2,  :default => 0
      t.string :taux_tva, :limit => 10, :null => false
      t.decimal :cout_ttc,  :precision => 10, :scale =>2,  :default => 0
      t.string :justifiable, :limit => 25
      t.text :commentaire
      t.string :numero_mandat, :limit => 20
      t.date :date_mandatement
      t.integer :created_by
      t.integer :updated_by
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :depense_commun_factures, :depense_commun_id
    add_index :depense_commun_factures, :rubrique_comptable_id

    create_table :budgetaire_references do |t|
      t.string :code, :limit => 10, :null => false
      t.string :intitule, :null => false
    end
  end

  def self.down
    drop_table :depense_communs
    drop_table :depense_commun_factures
    drop_table :budgetaire_references
  end
end
