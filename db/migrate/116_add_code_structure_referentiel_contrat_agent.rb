class AddCodeStructureReferentielContratAgent < ActiveRecord::Migration
  def self.up
    add_column :referentiel_contrat_agents, :code_structure, :string
  end

  def self.down
    remove_column :referentiel_contrat_agents, :code_structure
  end
end
