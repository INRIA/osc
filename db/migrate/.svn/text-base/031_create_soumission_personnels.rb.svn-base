class CreateSoumissionPersonnels < ActiveRecord::Migration
  def self.up
    create_table :soumission_personnels do |t|
      t.column :soumission_id, :integer
      t.column :nom, :string
      t.column :prenom, :string
      t.column :statut, :string
      t.column :tutelle, :string
      t.column :pourcentage, :decimal, :precision => 3, :scale =>0
    end
  end

  def self.down
    drop_table :soumission_personnels
  end
end
