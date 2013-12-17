class CreateReferentielAgents < ActiveRecord::Migration
  def self.up
    create_table :referentiel_agents do |t|
      t.string :si_id
      t.string :si_origine
      t.string :nom
      t.string :prenom
      t.integer :dedoublonnage
    end
  end

  def self.down
    drop_table :referentiel_agents
  end
end
