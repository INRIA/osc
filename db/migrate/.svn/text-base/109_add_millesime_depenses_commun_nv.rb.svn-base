class AddMillesimeDepensesCommunNv < ActiveRecord::Migration
  def self.up
    add_column :depense_communs, :millesime, :date, :default => nil
    add_column :depense_commun_factures, :millesime, :date, :default => nil
    add_column :depense_non_ventilees, :millesime, :date, :default => nil
    add_column :depense_non_ventilee_factures, :millesime, :date, :default => nil
  end

  def self.down
    remove_column :depense_communs, :millesime
    remove_column :depense_commun_factures, :millesime
    remove_column :depense_non_ventilees, :millesime
    remove_column :depense_non_ventilee_factures, :millesime
  end
end
