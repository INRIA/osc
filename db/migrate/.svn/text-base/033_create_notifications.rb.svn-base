class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.column :contrat_id, :integer
      t.column :contrat_type_id, :integer
      t.column :date_notification,                          :date
      t.column :date_debut,                                 :date
      t.column :nombre_mois,                                :integer
      t.column :date_fin,                                   :date
      
      t.column :etablissement_gestionnaire,                 :string
      t.column :organisme_financeur,                        :string
      t.column :a_justifier,                                :boolean
      t.column :organisme_payeur,                           :string
      t.column :numero_ligne_budgetaire,                    :string
      t.column :numero_contrat,                             :string

      t.column :url,                                        :string


      # Porteur et coordinateur
      t.column :porteur,                                    :string
      t.column :etablissement_rattachement_porteur,         :string
      t.column :est_porteur,                                :boolean
      t.column :coordinateur,                               :string
      t.column :etablissement_gestionnaire_du_coordinateur, :string
      
      # Mot clés et thématiques
      t.column :mots_cles_libres,                           :text
      t.column :thematiques,                                :text
      t.column :poles_competivites,                         :string
      
      # Moyens accordés
      t.column :ma_type_montant,                            :text
      t.column :ma_fonctionnement,                          :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :ma_equipement,                              :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :ma_salaire,                                 :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :ma_mission,                                 :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :ma_non_ventile,                             :decimal, :precision => 8, :scale =>2, :default => 0.0
      t.column :ma_couts_indirects,                         :decimal, :precision => 8, :scale =>2, :default => 0.0      
      t.column :ma_allocation,                              :integer, :precision => 4, :scale =>0, :default => 0
      t.column :ma_total,                                   :decimal, :precision => 8, :scale =>2, :default => 0.0
      
      # Personnel accordé
      t.column :pa_doctorant,                               :decimal, :precision => 4, :scale =>0, :default => 0
      t.column :pa_post_doc,                                :decimal, :precision => 4, :scale =>0, :default => 0
      t.column :pa_ingenieur,                               :decimal, :precision => 4, :scale =>0, :default => 0
      t.column :pa_autre,                                   :decimal, :precision => 4, :scale =>0, :default => 0
      t.column :pa_equivalent_temps_plein,                  :decimal, :precision => 5, :scale =>2, :default => 0.0
      
      t.column :created_at,                                 :datetime
      t.column :updated_at,                                 :datetime
    end
  end

  def self.down
    drop_table :notifications
  end
end
