class CreateOrganismeGestionnaireTauxes < ActiveRecord::Migration
  def self.up
    create_table :organisme_gestionnaire_tauxes do |t|
      t.integer :organisme_gestionnaire_id
      t.decimal :taux, :precision => 5, :scale => 4,  :default => 0
      t.string :annee

      t.timestamps
    end
  end

  def self.down
    drop_table :organisme_gestionnaire_tauxes
  end
end
