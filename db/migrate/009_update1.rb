class Update1 < ActiveRecord::Migration
  def self.up
    # Projets : Ajout du champ date de début
    add_column :projets, "date_debut", :date
    # Projets : Ajout du champ date de fin
    add_column :projets, "date_fin", :date
    # Projets : Ajout d'un logo
    add_column :projets, "logo",  :string
    # Laboratoire : Ajout d'un logo
    add_column :laboratoires, "logo", :string
    #Tutelle : Ajout d'un logo
    add_column :tutelles, "logo", :string
  end 
  def self.down
    remove_column :projets, :date_debut
    remove_column :projets, :date_fin
    remove_column :projets, :logo
    remove_column :laboratoires, :logo
    remove_column :tutelles, :logo
  end
end
