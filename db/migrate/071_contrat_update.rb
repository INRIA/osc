class ContratUpdate < ActiveRecord::Migration
  def self.up
    add_column :contrats, "etat", :string, :default => 'init'
    
    Contrat.reset_column_information
    Contrat.find(:all).each do |c|
      if !c.cloture.nil?
        etat = "cloture"
      elsif !c.notification.nil?
        etat = "notification"
      elsif !c.signature.nil?
        etat = "signature"
      elsif !c.refu.nil?
        etat = "refus"
      elsif !c.soumission.nil?
        etat = "soumission"
      else
        etat = "init"
      end
      execute " UPDATE `contrats` 
                SET `created_at` = '"+c.created_at.to_s(:db)+"',
                `etat` = '"+etat+"',
                `updated_at` = '"+c.updated_at.to_s(:db)+"' 
                WHERE `id` = "+c.id.to_s
      
    end
  end

  def self.down
    remove_column :contrats, :etat
  end
end