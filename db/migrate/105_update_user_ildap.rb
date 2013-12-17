class UpdateUserIldap < ActiveRecord::Migration
  def self.up
    inria_ldap_users = User.find(:all, :conditions => {:type_ldap => 'ldap.inrialpes.fr' })
    for user in inria_ldap_users do
      user.type_ldap = 'ildap INRIA'
      user.save
    end
  end

  def self.down
    inria_ldap_users = User.find(:all, :conditions => {:type_ldap => 'ildap INRIA' })
    for user in inria_ldap_users do
      user.type_ldap = 'ldap.inrialpes.fr'
      user.save
    end
  end
end
