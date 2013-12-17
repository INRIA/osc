class CreateRubriqueComptables < ActiveRecord::Migration
  def self.up
    create_table :rubrique_comptables do |t|
      t.string :intitule
      t.column "parent_id", :integer
    end
  end

  def self.down
    drop_table :rubrique_comptables
  end
end
