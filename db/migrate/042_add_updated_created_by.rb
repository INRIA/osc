class AddUpdatedCreatedBy < ActiveRecord::Migration
  def self.up
    # Ajout des champs created_by et updated_by à la table soumissions
    add_column :soumissions, "created_by", :integer
    add_column :soumissions, "updated_by", :integer
    
    # Idem pour le table signature
    add_column :signatures, "created_by", :integer
    add_column :signatures, "updated_by", :integer
     
    # Idem pour le table refus
    add_column :refus, "created_by", :integer
    add_column :refus, "updated_by", :integer

    # Idem pour le table notifications
    add_column :notifications, "created_by", :integer
    add_column :notifications, "updated_by", :integer

    # Idem pour le table todoitems
    add_column :todoitems, "created_by", :integer
    add_column :todoitems, "updated_by", :integer    
    
    
    # Idem pour le table contrat
    add_column :contrats, "created_by", :integer
    add_column :contrats, "updated_by", :integer    
    
    # Idem pour le table contrat_file
    add_column :contrat_files, "created_by", :integer
    add_column :contrat_files, "updated_by", :integer
    
  end

  def self.down
    remove_column :soumissions, :created_by
    remove_column :soumissions, :updated_by
    remove_column :signatures, :created_by
    remove_column :signatures, :updated_by    
    remove_column :refus, :created_by
    remove_column :refus, :updated_by    
    remove_column :notifications, :created_by
    remove_column :notifications, :updated_by
    remove_column :todoitems, :created_by
    remove_column :todoitems, :updated_by 
    remove_column :contrats, :created_by
    remove_column :contrats, :updated_by
    remove_column :contrat_files, :created_by
    remove_column :contrat_files, :updated_by
  end
end
