#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Notifier < ActionMailer::Base
    default :from => "Support OSC <"+EMAIL_SUPPORT+">",
            :reply_to => EMAIL_SUPPORT,
            :content_type => "text/html"
            

    # Envoi d'email à l'utilisateur pour lequel un rôle à été ajouté sur un contrat
    def send_mail_for_add_roles(type_droit, contrat, user, current_user)
      @user = user
      @contrat = contrat
      @type_droit = type_droit
      @current_user = current_user
      @recipients   = user.email
      @subject      = "Ajout de droits dans OSC"
      @sent_on      = Time.now
      mail(:to => @recipients, :subject => @subject,:date =>@sent_on)
    end
    
    # Envoi d'email à l'utilisateur pour lequel on vient de créer un compte local
    # Envoi du login et mot de passe
    def send_mail_for_add_local_user(user, password)
      @user = user
      @password = password
      @recipients   = user.email      
      @subject      = "Votre login et mot de passe pour l'outil de suivi des contrats"
      @sent_on      = Time.now
      mail(:to => @recipients, :subject => @subject,:date =>@sent_on)
    end
    
    #Envoi d'email aux administrateurs fonctionnel lors de l'ajout d'un utilisateur dans un groupe
    def send_mail_for_add_user_in_group(user, group)
      @user = user
      @group = group
      users_found = User.find(:all)
      @recipients = Array.new
      for user_found in users_found do
        if user_found.is_fonc_admin?
          @recipients.push(user_found.email)
        end
      end
      @subject      = "Ajout d'un utilisateur dans un groupe"
      @sent_on      = Time.now
      mail(:to => @recipients, :subject => @subject,:date =>@sent_on)
    end
    
    #Envoi d'email aux administrateurs fonctionnel lors de la suppresion d'un utilisateur dans un groupe
    def send_mail_for_del_user_in_group(user, group)
      @user = user
      @group = group
      users_found = User.find(:all)
      @recipients = Array.new
      for user_found in users_found do
        if user_found.is_fonc_admin?
          @recipients.push(user_found.email)
        end
      end
      @sent_on      = Time.now
      @subject      = "Suppression d'un utilisateur dans un groupe"
      mail(:to => @recipients, :subject => @subject,:date =>@sent_on)
    end
    
end