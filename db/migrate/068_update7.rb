class Update7 < ActiveRecord::Migration
  def self.up
    change_column :depense_equipement_factures, :cout_ht, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_equipement_factures, :cout_ttc, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_equipement_factures, :cout_projet, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_equipements, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => 0
    
    change_column :depense_fonctionnement_factures, :cout_ht, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_fonctionnement_factures, :cout_ttc, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_fonctionnements, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => 0
    
    change_column :depense_mission_factures, :cout_ht, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_mission_factures, :cout_ttc, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_mission_factures, :cout_projet, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_missions, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => 0
    
    change_column :depense_non_ventilee_factures, :cout_ht, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_non_ventilee_factures, :cout_ttc, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_non_ventilees, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => 0
    
    change_column :depense_salaire_factures, :cout, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_salaires, :cout_mensuel, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_salaires, :cout_periode, :decimal, :precision => 10, :scale =>2,  :default => 0
    
    change_column :versements, :montant, :decimal, :precision => 10, :scale =>2,  :default => 0
  end
  
  def self.down
    change_column :depense_equipement_factures, :cout_ht, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_equipement_factures, :cout_ttc, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_equipement_factures, :cout_projet, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_equipements, :montant_engage, :decimal, :precision => 10, :scale =>0,  :default => 0
    
    change_column :depense_fonctionnement_factures, :cout_ht, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_fonctionnement_factures, :cout_ttc, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_fonctionnements, :montant_engage, :decimal, :precision => 10, :scale =>0,  :default => 0
    
    change_column :depense_mission_factures, :cout_ht, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_mission_factures, :cout_ttc, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_mission_factures, :cout_projet, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_missions, :montant_engage, :decimal, :precision => 10, :scale =>0,  :default => 0
    
    change_column :depense_non_ventilee_factures, :cout_ht, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_non_ventilee_factures, :cout_ttc, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_non_ventilees, :montant_engage, :decimal, :precision => 10, :scale =>0,  :default => 0
    
    change_column :depense_salaire_factures, :cout, :decimal, :precision => 9, :scale =>3,  :default => 0
    change_column :depense_salaires, :cout_mensuel, :decimal, :precision => 10, :scale =>0,  :default => 0
    change_column :depense_salaires, :cout_periode, :decimal, :precision => 10, :scale =>0,  :default => 0
    
    change_column :versements, :montant, :decimal, :precision => 10, :scale =>0,  :default => 0
  end
end