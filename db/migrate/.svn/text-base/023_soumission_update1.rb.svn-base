class SoumissionUpdate1 < ActiveRecord::Migration
  def self.up
    # Projets : Ajout du champ date de début
    add_column :soumissions, "thematiques", :text
    add_column :soumissions, "md_type_montant", :text
    add_column :soumissions, "md_fonctionnement", :decimal, :precision => 8, :scale =>2, :default =>0
    add_column :soumissions, "md_equipement", :decimal, :precision => 8, :scale =>2, :default =>0
    add_column :soumissions, "md_salaire", :decimal, :precision => 8, :scale =>2, :default =>0
    add_column :soumissions, "md_mission", :decimal, :precision => 8, :scale =>2, :default =>0
    add_column :soumissions, "md_allocation", :integer, :default => 0
    add_column :soumissions, "md_total", :decimal, :precision => 8, :scale =>2, :default =>0
    add_column :soumissions, "pd_doctorant", :decimal, :precision => 4, :scale =>0, :default =>0
    add_column :soumissions, "pd_post_doc", :decimal, :precision => 4, :scale =>0, :default =>0
    add_column :soumissions, "pd_ingenieur", :decimal, :precision => 4, :scale =>0, :default =>0
    add_column :soumissions, "pd_autre", :decimal, :precision => 4, :scale =>0, :default =>0
  end

  def self.down
    remove_column :soumissions, :thematiques
    remove_column :soumissions, :md_type_montant
    remove_column :soumissions, :md_fonctionnement
    remove_column :soumissions, :md_equipement
    remove_column :soumissions, :md_salaire
    remove_column :soumissions, :md_mission
    remove_column :soumissions, :md_allocation
    remove_column :soumissions, :md_total
    remove_column :soumissions, :pd_doctorant
    remove_column :soumissions, :pd_post_doc
    remove_column :soumissions, :pd_ingenieur
    remove_column :soumissions, :pd_autre    
  end
end
