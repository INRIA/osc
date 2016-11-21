#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
require 'digest/sha1'

class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password, :is_admin, :is_contrat_admin, :is_fonc_admin
  # Class attribute accessor for current user
  cattr_accessor :current_user

  has_many                  :memberships, :dependent => :destroy
  has_one                   :user_image
  has_many                  :groups, :through => :memberships
  has_many                  :roles

  # Conf pour le plugin Authorization
  acts_as_authorized_user
  acts_as_authorizable
  # -----

  validates_uniqueness_of   :nom,
                            :scope => :prenom,
                            :message => " le couple nom et prénom est déja référencé",
                            :case_sensitive => false
  validates_presence_of     :login, :email, :nom, :prenom
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_format_of       :email,
                            :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                            :message => ': email doit être valide'
  validates_uniqueness_of   :login, :email, :case_sensitive => false, :message => " Cette valeur est déjà utilisée par un autre utilisateur"

  before_save :encrypt_password
  
  def has_role?( role_name, authorizable_obj = nil )
    if authorizable_obj.nil?
      for role in self.roles
        if role.name == role_name
          return true
        end
      end
    else
      for role in self.roles
        if (role.name == role_name ) && (authorizable_obj.class.to_s == role.authorizable_type) && (authorizable_obj.id == role.authorizable_id)
          return true
        end
        if(role.name == role_name) && (authorizable_obj.class.to_s == 'Contrat') && (role.authorizable_type == 'Projet')
          projet = Projet.find(role.authorizable_id)
          if authorizable_obj.projets.include? projet
            return true
          end
        end
      end
    end
    return false
  end


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    #utile pour developper offline
    #return u
    if u && u.ldap == true
      u && u.authenticated_ldap?(password, login) ? u : nil
    else
      u && u.authenticated?(password) ? u : nil
    end
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def authenticated_ldap?(password, login)
    flag = false

    user = User.find_by_login(login)

    # authentification ldap
    BASES_LDAP.each do |ldap|
      if user.type_ldap == ldap["type"]
        flag = false
        port = ldap["port"]
        host = ldap["host"]
        base = ldap["base"]
	auth = ldap["auth"]
	if auth == 1
	  binddn = ldap["binddn"]
	  bindpw = ldap["bindpw"]
	end

        if port == 389
	  if auth == 0
            conn = Net::LDAP.new(:host=>host, :port=>port)
	  else
            conn = Net::LDAP.new(:host=>host, :port=>port, :base=>base, :auth => {
           		:method => :simple,
           		:username => binddn,
           		:password => bindpw }
	    )
	  end
        else
	  if auth == 0
            conn = Net::LDAP.new(:host=>host, :port=>port, :encryption => :simple_tls)
	  else
            conn = Net::LDAP.new(:host=>host, :port=>port, :encryption => :simple_tls, :base=>base, :auth => {
           		:method => :simple,
           		:username => binddn,
           		:password => bindpw }
	    )
	  end
        end
        begin
          if ldap["type"] == 'ildap INRIA'
             
            if conn.bind_as(:base => base,:filter =>"(inriaLogin=#{login})",:password => password) 
              flag = true
            end
            break
          else
            if conn.bind_as(:base => base,:filter =>"(uid=#{login})",:password => password)
              flag = true
            end
            break
          end
        rescue Errno::ETIMEDOUT
          flag = false
        rescue Net::LDAP::LdapError
          flag = false
        end
      end
    end
    return flag
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(:validate=>false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(:validate=> false)
  end



  def is_admin?
    if self.has_role? "Administrateur"
      return true
    else
      for current_user_group in self.groups
        if current_user_group.has_role? "Administrateur"
          return true
        end
      end
    end
    return false
  end

  def is_contrat_admin?
    if self.has_role? "Administrateur de contrat"
      return true
    else
      for current_user_group in self.groups
        if current_user_group.has_role? "Administrateur de contrat"
          return true
        end
      end
    end
    return false
  end

  def is_fonc_admin?
    if self.has_role? "Administrateur fonctionnel"
      return true
    else
      for current_user_group in self.groups
        if current_user_group.has_role? "Administrateur fonctionnel"
          return true
        end
      end
    end
    return false
  end

  protected
  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    if ldap
      return false
    else
      return false
      #crypted_password.blank? || !password.blank
    end
  end

  def self.find_with_role(contrat_id)
    users_with_role = Hash.new{ |h,k| h[k] = "" }
    users_with_role_from_projet = Hash.new{ |h,k| h[k] = "" }

    users_with_role[:consultation] = User.find(:all, :order => "nom, prenom", :include => :roles,
      :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",contrat_id,"consultation","Contrat"])
    users_with_role[:modification] = User.find(:all, :order => "nom, prenom", :include => :roles,
      :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",contrat_id,"modification","Contrat"])
    users_with_role[:modification_budget] = User.find(:all, :order => "nom, prenom", :include => :roles,
      :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",contrat_id,"modification_budget","Contrat"])
    users_with_role[:admin_contrat] = User.find(:all, :order => "nom, prenom", :include => :roles,
      :conditions => ["roles.name = 'Administrateur de contrat'"])

    projets = SousContrat.find_by_sql("SELECT distinct entite_id FROM sous_contrats WHERE entite_type = 'Projet' AND contrat_id = '"+contrat_id.to_s+"'")
    for projet in projets
      users_with_role_from_projet[:consultation] = User.find(:all, :order => "nom, prenom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"consultation","Projet"])
      users_with_role_from_projet[:modification] = User.find(:all, :order => "nom, prenom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"modification","Projet"])
      users_with_role_from_projet[:modification_budget] = User.find(:all, :order => "nom, prenom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"modification_budget","Projet"])
      users_with_role[:consultation] = users_with_role[:consultation] | users_with_role_from_projet[:consultation]
      users_with_role[:modification] = users_with_role[:modification] | users_with_role_from_projet[:modification]
      users_with_role[:modification_budget] = users_with_role[:modification_budget] | users_with_role_from_projet[:modification_budget]
    end

    return users_with_role
  end


  def self.find_with_role_consultation(contrat_id)
    users_with_role_consulsation = []
    users_with_role_consulsation_from_projet = []
    role_consultation = Role.find(:first,:conditions => ["authorizable_id = ? AND name = ? AND authorizable_type = ?",contrat_id,"consultation","Contrat"])
    users_with_role_consulsation = User.find(:all, :order => "nom, prenom", :joins => " INNER JOIN `roles_users` ON roles_users.user_id = users.id", :conditions => ["roles_users.role_id = ?",role_consultation.id])

    projets = SousContrat.find_by_sql("SELECT distinct entite_id FROM sous_contrats WHERE entite_type = 'Projet' AND contrat_id = '"+contrat_id.to_s+"'")
    for projet in projets
      users_with_role_consulsation_from_projet = User.find(:all, :order => "nom, prenom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"consultation","Projet"])
      users_with_role_consulsation = users_with_role_consulsation | users_with_role_consulsation_from_projet
    end

    return users_with_role_consulsation
  end

  def self.find_with_role_modification(contrat_id)
    users_with_role_modification = []
    users_with_role_modification_from_projet = []
    role_modification = Role.find(:first,:conditions => ["authorizable_id = ? AND name = ? AND authorizable_type = ?",contrat_id,"modification","Contrat"])
    users_with_role_modification = User.find(:all, :order => "nom, prenom", :joins => " INNER JOIN `roles_users` ON roles_users.user_id = users.id", :conditions => ["roles_users.role_id = ?",role_modification.id])

    projets = SousContrat.find_by_sql("SELECT distinct entite_id FROM sous_contrats WHERE entite_type = 'Projet' AND contrat_id = '"+contrat_id.to_s+"'")
    for projet in projets
      users_with_role_modification_from_projet = User.find(:all, :order => "nom, prenom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"modification","Projet"])
      users_with_role_modification = users_with_role_modification | users_with_role_modification_from_projet
    end

    return users_with_role_modification
  end

  def self.find_with_role_modification_budget(contrat_id)
    users_with_role_modification_budget = []
    users_with_role_modification_budget_from_projet = []
    role_modification_budget = Role.find(:first,:conditions => ["authorizable_id = ? AND name = ? AND authorizable_type = ?",contrat_id,"modification_budget","Contrat"])
    users_with_role_modification_budget = User.find(:all, :order => "nom, prenom", :joins => " INNER JOIN `roles_users` ON roles_users.user_id = users.id", :conditions => ["roles_users.role_id = ?",role_modification_budget.id])

    projets = SousContrat.find_by_sql("SELECT distinct entite_id FROM sous_contrats WHERE entite_type = 'Projet' AND contrat_id = '"+contrat_id.to_s+"'")
    for projet in projets
      users_with_role_modification_budget_from_projet = User.find(:all, :order => "nom, prenom", :include => :roles,
        :conditions => ["roles.authorizable_id = ? AND name =? AND authorizable_type = ?",projet.entite_id,"modification_budget","Projet"])
      users_with_role_modification_budget = users_with_role_modification_budget | users_with_role_modification_budget_from_projet
    end

    return users_with_role_modification_budget
  end

  def self.can_edit(contrat_id)
    current_contrat = Contrat.find(contrat_id)
    users_can_edit = []
    users_all = User.find(:all, :order => "nom, prenom")
    for user in users_all
      if current_contrat.is_editable? user
        users_can_edit << user
      end
    end
    return users_can_edit
  end

  def self.can_edit_budget(contrat_id)
    current_contrat = Contrat.find(contrat_id)
    users_can_edit_budget = []
    users_all = User.find(:all, :order => "nom, prenom")
    for user in users_all
      if current_contrat.is_budget_editable? user
        users_can_edit_budget << user
      end
    end
    return users_can_edit_budget
  end

  def self.can_consult(contrat_id)
    current_contrat = Contrat.find(contrat_id)
    users_can_consult = []
    users_all = User.find(:all, :order => "nom, prenom")
    for user in users_all
      if current_contrat.is_consultable? user
        users_can_consult << user
      end
    end
    return users_can_consult
  end

end
