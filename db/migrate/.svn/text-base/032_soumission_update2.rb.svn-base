class SoumissionUpdate2 < ActiveRecord::Migration
  def self.up
    change_column :soumissions, :thematiques, :string
    remove_column :soumissions, :date_debut_prevue
    remove_column :soumissions, :date_fin_prevue
    add_column :soumissions, "md_couts_indirects", :decimal, :precision => 8, :scale =>2, :default =>0
    add_column :soumissions, "pd_equivalent_temps_plein", :decimal, :precision => 4, :scale =>2, :default =>0
  end

  def self.down
    change_column :soumissions, :thematiques, :text
    add_column :soumissions, "date_debut_prevue", :date
    add_column :soumissions, "date_fin_prevue", :date
    remove_column :soumissions, :md_couts_indirects
    remove_column :soumissions, :pd_equivalent_temps_plein
  end
end