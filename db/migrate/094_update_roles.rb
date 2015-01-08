#encoding: utf-8 

class UpdateRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :commentaire, :text
    Role.update_all("commentaire = 'Le rôle d''administrateur donne le droit
 de modification sur tous les contrats de la base de données ainsi que le droit
 de création de contrat à l''utilisateur qui le posède. Il permet également de gérer les
 utilisateurs et les groupes.'", "name like 'Administrateur'")
 Role.update_all("commentaire = 'Le rôle d''administrateur de contrat donne
 le droit de création de contrat à l''utilisateur qui le possède ainsi que le droit de
 modification sur tous les contrats qu''il a crée. Il ne permet pas de gérer les
 utilisateurs et les groupes.'","name like 'Administrateur de contrat'")
 Role.update_all("commentaire = 'Le rôle d''administrateur fonctionnel permet
 de gérer les utilisateurs et les groupes. Il ne donne aucun droit sur les contrats.'","name like 'Administrateur fonctionnel'")
  end

  def self.down
    remove_column :roles, :commentaire
  end


end
