class AddN0ContratEtab < ActiveRecord::Migration
  def self.up
    add_column :contrats, :num_contrat_etab, :string, :limit => 25, :null => false
  end

  def self.down
    remove_column :contrats, :num_contrat_etab
  end
end
