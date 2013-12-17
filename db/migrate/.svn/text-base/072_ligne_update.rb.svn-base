class LigneUpdate < ActiveRecord::Migration
  def self.up
    remove_column :lignes, "budgetable_type"
    rename_column :lignes, "budgetable_id", "sous_contrat_id"
  end

  def self.down
  end
end