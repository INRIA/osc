class Update3 < ActiveRecord::Migration
  def self.up
    add_column :soumissions, "organisme_gestionnaire_id", :integer
    Soumission.reset_column_information
    Soumission.find(:all).each do |s|        
      @organisme = OrganismeGestionnaire.find_by_nom(s.etablissement_gestionnaire)
      if @organisme.nil?
       @organisme = OrganismeGestionnaire.new(:nom => s.etablissement_gestionnaire)
       @organisme.save
       @organisme = OrganismeGestionnaire.find_by_nom(s.etablissement_gestionnaire)
      end
      execute " UPDATE `soumissions` 
                SET `created_at` = '"+s.created_at.to_s(:db)+"',
                `organisme_gestionnaire_id` = "+@organisme.id.to_s+",
                `updated_at` = '"+s.updated_at.to_s(:db)+"' 
                WHERE `id` = "+s.id.to_s
    end
    
    
    add_column :notifications, "organisme_gestionnaire_id", :integer
    Notification.reset_column_information
    Notification.find(:all).each do |s|        
      @organisme = OrganismeGestionnaire.find_by_nom(s.etablissement_gestionnaire)
      if @organisme.nil?
       @organisme = OrganismeGestionnaire.new(:nom => s.etablissement_gestionnaire)
       @organisme.save
       @organisme = OrganismeGestionnaire.find_by_nom(s.etablissement_gestionnaire)
      end
      execute " UPDATE `notifications` 
                SET `created_at` = '"+s.created_at.to_s(:db)+"',
                `organisme_gestionnaire_id` = "+@organisme.id.to_s+",
                `updated_at` = '"+s.updated_at.to_s(:db)+"' 
                WHERE `id` = "+s.id.to_s
    end
  end
  
  def self.down
   remove_column :soumissions, :organisme_gestionnaire_id
   remove_column :notifications, :organisme_gestionnaire_id
  end
end