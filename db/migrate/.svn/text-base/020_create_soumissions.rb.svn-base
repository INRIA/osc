class CreateSoumissions < ActiveRecord::Migration
  def self.up
    create_table :soumissions do |t|
      t.column :contrat_id, :integer
      t.column :acronyme, :string
      t.column :contrat_type_id, :integer
      t.column :date_depot, :date
      t.column :date_debut_prevue, :date
      t.column :nombre_mois, :integer
      t.column :date_fin_prevue, :date
      t.column :etablissement_gestionnaire, :string
      t.column :organisme_financeur, :string
      t.column :mots_cles_libres, :text
      t.column :poles_competivites, :text
      t.column :porteur, :string
      t.column :etablissement_rattachement_porteur, :string
      t.column :est_porteur, :boolean
      t.column :coordinateur, :string
      t.column :etablissement_gestionnaire_du_coordinateur, :string
      t.column :taux_subvention, :decimal, :precision => 3, :scale => 2, :default => 1.0
      t.column :total_subvention, :decimal, :precision => 8, :scale =>2, :default => 0
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :soumissions
  end
end
