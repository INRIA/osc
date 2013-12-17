class UpToMilliard < ActiveRecord::Migration
  def self.up
    # Table echeanciers
    change_column :echeanciers, :global_depenses_frais_gestion, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    
    # Table echeancier_periodes
    change_column :echeancier_periodes, :credit, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_non_ventile, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_fonctionnement, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_equipement, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_salaires, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_missions, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_couts_indirects, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_frais_gestion, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_frais_gestion_mut, :decimal, :precision => 12, :scale =>2, :default => 0.0
 
    # Table notifications
    change_column :notifications, :ma_fonctionnement, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_equipement, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_salaire, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_mission, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_non_ventile, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_couts_indirects, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_total, :decimal, :precision => 12, :scale =>2,  :default => 0.0    
    change_column :notifications, :ma_frais_gestion_mutualises, :decimal, :precision => 12, :scale => 2, :default => 0.0
    
    # Table sous_contrat_notifications
    change_column :sous_contrat_notifications, :ma_fonctionnement, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_equipement, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_salaire, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_mission, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_non_ventile, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_couts_indirects, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_total, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_frais_gestion_mutualises, :decimal, :precision => 12, :scale => 2, :default => 0.0
    
    # Table soumissions
    change_column :soumissions, :total_subvention, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_fonctionnement, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_equipement, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_salaire, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_mission, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_total, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_couts_indirects, :decimal, :precision => 12, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_non_ventile, :decimal, :precision => 12, :scale =>2,  :default => 0.0

  end

  def self.down
    # Table echeanciers
    change_column :echeanciers, :global_depenses_frais_gestion, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    
    # Table echeancier_periodes
    change_column :echeancier_periodes, :credit, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_non_ventile, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_fonctionnement, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_equipement, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_salaires, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_missions, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_couts_indirects, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_frais_gestion, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :echeancier_periodes, :depenses_frais_gestion_mut, :decimal, :precision => 10, :scale =>2, :default => 0.0

    # Table notifications
    change_column :notifications, :ma_fonctionnement, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_equipement, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_salaire, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_mission, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_non_ventile, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_couts_indirects, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :notifications, :ma_total, :decimal, :precision => 10, :scale =>2,  :default => 0.0    
    change_column :notifications, :ma_frais_gestion_mutualises, :decimal, :precision => 10, :scale => 2, :default => 0.0
    
    # Table sous_contrat_notifications
    change_column :sous_contrat_notifications, :ma_fonctionnement, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_equipement, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_salaire, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_mission, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_non_ventile, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_couts_indirects, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_total, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :sous_contrat_notifications, :ma_frais_gestion_mutualises, :decimal, :precision => 10, :scale => 2, :default => 0.0
    
    # Table soumissions
    change_column :soumissions, :total_subvention, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_fonctionnement, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_equipement, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_salaire, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_mission, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_total, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_couts_indirects, :decimal, :precision => 10, :scale =>2,  :default => 0.0
    change_column :soumissions, :md_non_ventile, :decimal, :precision => 10, :scale =>2,  :default => 0.0

  end
end
