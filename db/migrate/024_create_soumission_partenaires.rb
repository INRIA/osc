class CreateSoumissionPartenaires < ActiveRecord::Migration
  def self.up
    create_table :soumission_partenaires do |t|
      t.column :soumission_id, :integer
      t.column :nom, :string
      t.column :etablissement_gestionnaire, :string
      t.column :ville, :string
      t.column :pays, :string
      t.column :localisation, :string, :default => 'autre'
    end
  end

  def self.down
    drop_table :soumission_partenaires
  end
end
