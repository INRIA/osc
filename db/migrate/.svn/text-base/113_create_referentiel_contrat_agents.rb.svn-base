class CreateReferentielContratAgents < ActiveRecord::Migration
  def self.up
    create_table :referentiel_contrat_agents do |t|
      t.string :agent_si_id
      t.string :si_origine
      t.string :date_debut
      t.string :date_fin
      t.string :libelle_structure
      t.string :num_contrat_etab
      t.string :statut
    end
  end

  def self.down
    drop_table :referentiel_contrat_agents
  end
end
