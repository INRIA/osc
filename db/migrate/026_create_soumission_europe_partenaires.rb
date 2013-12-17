class CreateSoumissionEuropePartenaires < ActiveRecord::Migration
  def self.up
    create_table :soumission_europe_partenaires do |t|
      t.column :soumission_id, :integer
      t.column :nom, :string
      t.column :etablissement_gestionnaire, :string
      t.column :ville, :string
      t.column :pays, :string
      t.column :localisation, :string, :default => 'europe'
    end
  end

  def self.down
    drop_table :soumission_europe_partenaires
  end
end
