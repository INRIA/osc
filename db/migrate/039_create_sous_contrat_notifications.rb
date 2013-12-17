class CreateSousContratNotifications < ActiveRecord::Migration
  def self.up
    create_table :sous_contrat_notifications do |t|
      t.column :sous_contrat_id, :integer
      t.column :notification_id, :integer
      t.column :ma_fonctionnement, :decimal,  :default => 0.0
      t.column :ma_equipement, :decimal,  :default => 0.0
      t.column :ma_salaire, :decimal,  :default => 0.0
      t.column :ma_mission, :decimal,  :default => 0.0
      t.column :ma_non_ventile, :decimal,  :default => 0.0
      t.column :ma_couts_indirects, :decimal,  :default => 0.0
      t.column :ma_allocation, :string,    :default => "0"
      t.column :ma_total, :decimal,  :default => 0.0
      t.column :pa_doctorant, :decimal,  :precision => 4, :scale =>0,  :default => 0
      t.column :pa_post_doc, :decimal,  :precision => 4, :scale =>0,  :default => 0
      t.column :pa_ingenieur, :decimal,  :precision => 4, :scale =>0,  :default => 0
      t.column :pa_autre, :decimal,  :precision => 4, :scale =>0,  :default => 0
      t.column :pa_equivalent_temps_plein, :decimal,  :precision => 5, :scale =>2,  :default => 0.0
    end
  end

  def self.down
    drop_table :sous_contrat_notifications
  end
end
