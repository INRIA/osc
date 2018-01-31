#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie, :only =>  [:index]
  
  def index
  end

  def login
    if logged_in?
      respond_to do |format|
        format.html { redirect_to :controller => '/contrats', :action => "index" }
      end
    else
      return unless request.post?
      self.current_user = User.authenticate(params[:login], params[:password])
      
      if logged_in?
        if params['remember_me'] == "on"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at,:secure=> true, :httponly => true  }
        end
        if params['style_bis'] == "on"
          cookies[:style]= CHOIX_STYLE
        else
          cookies[:style]=nil
        end
        session[:current_user_ldap] = self.current_user.type_ldap
        respond_to do |format|
          format.html { redirect_to :controller => '/contrats', :action => "index" }
          flash[:notice] = "Authentification réussie"
        end
      else
        @login = params[:login]
        text = []
        text.push "Echec de la connexion :"
        if params[:login].blank? && params[:password].blank?
          text.push "Merci de saisir votre login et votre mot de passe." 
        else
          text.push "Merci de saisir votre login." if params[:login].blank?
          text.push "Merci de saisir un mot de passe." if params[:password].blank?
          text.push "Le couple login/mot de passe est incorrect." if !params[:password].blank? && !params[:login].blank?
        end
        flash[:error] = (text.join '<br />').html_safe()
      end
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end
  
end


