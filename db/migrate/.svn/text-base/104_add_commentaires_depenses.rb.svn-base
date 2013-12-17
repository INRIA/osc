class AddCommentairesDepenses < ActiveRecord::Migration
  def self.up
    add_column :depense_fonctionnements, :commentaire, :text,:default => ""   
    add_column :depense_equipements, :commentaire, :text,:default => "" 
    add_column :depense_missions, :commentaire, :text,:default => "" 
    add_column :depense_salaires, :commentaire, :text,:default => "" 
    add_column :depense_non_ventilees, :commentaire, :text,:default => "" 
  end

  def self.down  
    remove_column :depense_fonctionnements, :commentaire
    remove_column :depense_equipements, :commentaire
    remove_column :depense_missions, :commentaire
    remove_column :depense_salaires, :commentaire
    remove_column :depense_non_ventilees, :commentaire
  end
end
