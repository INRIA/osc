class CreateSoumissionFrancePartenaires < ActiveRecord::Migration
  def self.up
    create_table :soumission_france_partenaires do |t|
      t.column :soumission_id, :integer
      t.column :nom, :string
      t.column :laboratoire, :string
      t.column :etablissement_gestionnaire, :string
      t.column :ville, :string
      t.column :pays, :string, :default => 'France'
      t.column :localisation, :string, :default => 'france'
    end
  end

  def self.down
    drop_table :soumission_france_partenaires
  end
end
