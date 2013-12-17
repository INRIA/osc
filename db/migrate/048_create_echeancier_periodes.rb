class CreateEcheancierPeriodes < ActiveRecord::Migration
  def self.up
    create_table :echeancier_periodes do |t|
      t.column :echeancier_id, :integer
      t.column :reference_financeur, :string
      t.column :numero_contrat_etablissement_gestionnaire, :string
      t.column :date_debut, :date
      t.column :date_fin, :date
      t.column :credit, :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :depenses_non_ventile, :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :depenses_fonctionnement, :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :depenses_equipement, :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :depenses_salaires, :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :depenses_missions, :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :depenses_couts_indirects, :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :depenses_frais_gestion, :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :allocations, :integer, :precision => 4, :scale =>0, :default => 0
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :created_by, :integer
      t.column :updated_by, :integer
    end
  end

  def self.down
    drop_table :echeancier_periodes
  end
end
