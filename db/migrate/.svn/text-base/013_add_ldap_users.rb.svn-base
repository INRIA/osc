class AddLdapUsers < ActiveRecord::Migration
  
  def self.up
    # Users : Ajout du champ ldap
    add_column :users, "ldap", :boolean, :default => false
    # Users : Ajout du champ type ldap
    add_column :users, "type_ldap", :string
    # Users : Ajout du champ ldap
    add_column :users, "photose", :string
  end 
  
  def self.down
    remove_column :users, :ldap
    remove_column :users, :type_ldap
    remove_column :users, :photose
  end
end