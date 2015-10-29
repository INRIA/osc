class AddEtablissementContrat < ActiveRecord::Migration
  def self.up
    # Ajout du champ etablissement à la table des contrats
    add_column :contrats, :etablissement_id, :integer
    add_column :contrats, :etablissement_type, :string
    
    add_index :contrats, [:etablissement_id, :etablissement_type]
  end

  def self.down
    remove_column :contrats, :etablissement_id
    remove_column :contrats, :etablissement_type
    
    remove_index :contrats, [:etablissement_id, :etablissement_type]
  end
end