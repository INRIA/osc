class AddNomLignes < ActiveRecord::Migration
  def self.up
    add_column :lignes, :nom, :string, :null => false 
    lignes = Ligne.find(:all)
    for ligne in lignes do
      current_user_id = ligne.updated_by
      User.current_user = User.find(:first, :conditions =>['id = ?',current_user_id])
      if !User.current_user
        User.current_user = User.find(:first, :conditions => ['nom = ?', 'SI INRIA'])
      end      
      ligne.update_nom
    end
  end

  def self.down
    remove_column :lignes, :nom     
  end
end
