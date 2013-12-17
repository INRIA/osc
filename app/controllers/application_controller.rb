#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Initialise le système d'authentification pour toute l'application
  include AuthenticatedSystem
  #model :user
  require_dependency 'user'
  before_filter :set_session_key
  before_filter :login_from_cookie
  before_filter :set_cookies
  before_filter :login_required, :except => [:login, :logout]
  before_filter :set_current_user_in_model

  # Pick a unique cookie name to distinguish our session data from others'
  
  def set_session_key
    session[:session_key] = '_osc_session_id'
  end

  
  
  def set_cookies
    if cookies[:bilan].nil?
      cookies[:bilan] = 'sommes_engagees'
    end
    if cookies[:show_justification_data].nil?
      cookies[:show_justification_data] = 'no'
    end
    @user_preferences_show_justifacation_data = cookies[:show_justification_data]
  end

  def is_my_research_in_session?
    if session[:acronym].blank? and session[:noContrat].blank? and session[:team].blank? and session[:labo].blank? and (session[:selection].blank? or session[:selection] == 'default')
      @my_research = false
    else
      @my_research = true
    end
  end

  def set_my_research_in_session(my_search_criteria=nil)
    if my_search_criteria.nil?
      session[:acronym] = session[:noContrat] = session[:team] = session[:labo] = session[:selection] = nil
      return true
    else
      unless !my_search_criteria.is_a?(Hash)
        session[:acronym] = (my_search_criteria[:acronym].blank? ? nil : my_search_criteria[:acronym] )
        session[:noContrat] = (my_search_criteria[:noContrat].blank? ? nil : my_search_criteria[:noContrat] )
        session[:team] = (my_search_criteria[:team].blank? ? nil : my_search_criteria[:team] )
        session[:labo] = (my_search_criteria[:labo].blank? ? nil : my_search_criteria[:labo] )
        session[:selection] = (my_search_criteria[:selection].blank? ? nil : my_search_criteria[:selection] )
        return true
      else
        return false
      end
    end
  end

  def my_research_in_session
    my_criteria = Hash.new
    my_criteria[:acronym] = session[:acronym]
    my_criteria[:noContrat] = session[:noContrat]
    my_criteria[:team] = session[:team]
    my_criteria[:labo] = session[:labo]
    my_criteria[:selection] = session[:selection]
    return my_criteria
  end

  def is_my_ligne_research_in_session?
    if session[:nom_ligne].blank? and session[:selection_ligne].blank? and session[:projet].blank?
      @my_research = false
    else
      @my_research = true
    end
  end

  def set_my_ligne_research_in_session(my_search_criteria=nil)
    if my_search_criteria.nil?
      session[:nom_ligne] = session[:selection_ligne] = session[:projet] = session[:filtre_projet] = nil
      return true
    else
      unless !my_search_criteria.is_a?(Hash)
        session[:nom_ligne] = (my_search_criteria[:nom_ligne].blank? ? nil : my_search_criteria[:nom_ligne])
        session[:projet] = (my_search_criteria[:projet].blank? ? nil : my_search_criteria[:projet])
        session[:filtre_projet] = (my_search_criteria[:filtre_projet].blank? ? nil : my_search_criteria[:filtre_projet])
        session[:selection_ligne] = (my_search_criteria[:selection_ligne].blank? ? nil : my_search_criteria[:selection_ligne])
        return true
      else
        return false
      end
    end
  end

  def my_ligne_research_in_session
    my_criteria = Hash.new
    my_criteria[:nom_ligne] = session[:nom_ligne]
    my_criteria[:projet] = session[:projet]
    my_criteria[:filtre_projet] = session[:filtre_projet]
    my_criteria[:selection_ligne] = session[:selection_ligne]
    return my_criteria
  end

  def setup_type_montant(is_inria = false)
    if !params['type_montant'].nil?
      @type_montant = params['type_montant']
      cookies[:montant] = params['type_montant']
    elsif !cookies[:montant].nil?
      @type_montant = cookies[:montant]
    elsif is_inria
      @type_montant = 'htr'
      cookies[:montant] = @type_montant
    else
      @type_montant = 'ht'
      cookies[:montant] = @type_montant
    end
  end

  def setup_items_per_page
    if !params['items_per_page'].nil?
       @items_per_page = params['items_per_page']
       cookies[:depenses_items_per_page] = @items_per_page
    else
      if !cookies[:depenses_items_per_page].nil?
        @items_per_page = cookies[:depenses_items_per_page]
      else
        @items_per_page = 20
      end
    end
  end

  def setup_order_by(*args)
    options = args.extract_options!

    if !params['order_by'].nil?
      @order_by_field =  params['order_by']
      cookies[options[:name] + '_order_by_field'] = @order_by_field
      if params['page'].nil?
        if cookies[options[:name] + '_order_by_direction'] == 'desc'
          cookies[options[:name] + '_order_by_direction'] = @order_by_direction = 'asc'
        else
          cookies[options[:name] + '_order_by_direction'] = @order_by_direction = 'desc'
        end
      else
        if cookies[options[:name] + '_order_by_direction'] == 'desc'
          @order_by_direction = 'desc'
        else
          @order_by_direction = 'asc'
        end
      end

    else
      if !cookies[options[:name] + '_order_by_field'].nil? && !cookies[options[:name] + '_order_by_direction'].nil?
        @order_by_field     = cookies[options[:name] + '_order_by_field']
        @order_by_direction = cookies[options[:name] + '_order_by_direction']
      else
        @order_by_field     = options[:default_field]
        @order_by_direction = options[:default_direction]
      end
    end

    # FIXME: needs to be removed when depenses don't use it anymore (see depense_equipements)
    if @order_by_field == 'montant_factures' # 'montant_factures' is not a model attr !
      @order_by = nil
    else
      @order_by = @order_by_field + " " + @order_by_direction
    end
  end

  def setup_all_lignes_filter
    unless params['contrat_clos'].nil?
      filter = params['contrat_clos']
      cookies[:contrat_clos] = filter
    else
      unless cookies[:contrat_clos].nil?
        filter = cookies[:contrat_clos]
      else
        filter = 'no'
      end
    end
    @show_contrat_clos = filter
    
    unless params['show_factures'].nil?
      filter = params['show_factures']
      cookies[:show_factures] = filter
    else
      unless cookies[:show_factures].nil?
        filter = cookies[:show_factures]
      else
        filter = 'no'
      end
    end
    @show_factures = filter
    
    unless params['type_depense'].nil?
      filter = params['type_depense']
      cookies[:type_depense] = filter
    else
      unless cookies[:type_depense].nil?
        filter = cookies[:type_depense]
      else
        filter = 'depenses_all'
      end
    end
    @type_depense= filter
  end
  
  def set_contrats_consultables
     @ids_consultables = session[:ids_consultables]
  end

  def set_contrats_editables
    @ids_editables = session[:ids_editables]
  end

  def set_contrats_budget_editables
    @ids_budget_editables = session[:ids_budget_editables]
  end

  def set_lignes_consultables
     @ids_lignes_consultables = session[:ids_lignes_consultables]
  end

  def set_lignes_editables
    @ids_lignes_editables = session[:ids_lignes_editables]
  end
  
  def set_mes_equipes
    @ids_mes_equipes = session[:ids_mes_equipes]
  end

  def search_all_exact_references(ref)
    sql = "SELECT reference FROM `depense_fonctionnements`  WHERE reference like ?
           union ALL
           SELECT reference FROM `depense_equipements`  WHERE reference like ?
           union ALL
           SELECT reference FROM `depense_missions`  WHERE reference like ?
           union ALL
           SELECT reference FROM `depense_non_ventilees`  WHERE reference like ?"
    result = DepenseEquipement.find_by_sql([sql,ref,ref,ref,ref])
  end

  def rescue_action_in_public(e)
    case e
      when ::ActionController::RoutingError, ::ActionController::UnknownController, ::ActiveRecord::RecordNotFound
      render :file => "#{RAILS_ROOT}/public/404.html",
             :status => '404 Not Found'
      else
        super
    end
  end

  def local_request?
    false
  end

  # Set the current user in User
  def set_current_user_in_model
    User.current_user = current_user
  end
 
 # Formatage des dates pour l'export csv
  def date_to_csv(value)
    return value.strftime("%d/%m/%Y")
  end

  # Formatage des booleen pour l'export en csv
  def boolean_to_csv(value)
    if value
      return "oui"
    else
      return "non"
    end
  end
  
  def clean_date_params(params)
    #modification pour prendre en compte les date_select sous rails 3.2
    params_clean = {}
    if params
      params.each do |key,value|
        if key.to_s.include? "(3i)"
          attribut_name= key.to_s.gsub("(3i)","")
          begin
            date = Date.civil(params[attribut_name + '(1i)'].to_i, params[attribut_name + '(2i)'].to_i, params[attribut_name + '(3i)'].to_i)
            params_clean[attribut_name]=date
          rescue
            params_clean[attribut_name]=nil
          end
        elsif !(key.to_s.include? "(2i)") and !(key.to_s.include? "(1i)")
          params_clean[key]=value
        end
      end
    end
    return params_clean
  end
  
  #chargement des droits en session pour gagner du temps sur chaque page !
  def compute_rights_in_session
    session[:ids_consultables] = Contrat.find_all_consultable(current_user)
    session[:ids_editables] = Contrat.find_all_editable(current_user)
    session[:ids_budget_editables] = Contrat.find_all_budget_editable(current_user)
    session[:ids_lignes_consultables] = Ligne.find_all_consultable(current_user)
    session[:ids_lignes_editables] = Ligne.find_all_editable(current_user)
    session[:ids_mes_equipes] = Projet.find_all_team_for(current_user)
  end
  
  protect_from_forgery
end
