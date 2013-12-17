class UpdateDepenses < ActiveRecord::Migration
  def self.up
    change_column :depense_equipements, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => nil
    change_column :depense_fonctionnements, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => nil
    change_column :depense_missions, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => nil
    change_column :depense_non_ventilees, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => nil
    change_column :depense_salaires, :cout_periode, :decimal, :precision => 10, :scale =>2,  :default => nil
 

  end

  def self.down
    change_column :depense_equipements, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_fonctionnements, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_missions, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_non_ventilees, :montant_engage, :decimal, :precision => 10, :scale =>2,  :default => 0
    change_column :depense_salaires, :cout_periode, :decimal, :precision => 10, :scale =>2,  :default => 0
     
  end
end
