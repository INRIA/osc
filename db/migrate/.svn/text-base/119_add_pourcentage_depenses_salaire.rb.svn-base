class AddPourcentageDepensesSalaire < ActiveRecord::Migration
  def self.up
    add_column :depense_salaires, :pourcentage, :decimal, :precision => 10, :scale => 2, :default => '100'
    add_column :referentiel_contrat_agents, :pourcentage, :decimal, :precision => 10, :scale => 2, :default => '100'
  end

  def self.down
    remove_column :depense_salaires, :pourcentage
    remove_column :referentiel_contrat_agents, :pourcentage
  end
end
