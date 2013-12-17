class AddRefAgentsDepensesSalaire < ActiveRecord::Migration
  def self.up
    add_column :depense_salaires, :agent_si_origine, :string, :default => ""
  end

  def self.down
    remove_column :depense_salaires, :agent_si_origine
  end
end
