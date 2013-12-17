#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
# Utile pour la selection d'un contrat dans le menu déroulant

class RedirectionsController < ApplicationController
  before_filter :set_lignes_editables, :set_lignes_consultables
  before_filter :set_contrats_editables, :set_contrats_consultables
  
  def show_menu_ligne
    @previous_controller  = params[:previous_controller]
    @previous_action      = params[:previous_action]
    @previous_ligne_id    = params[:previous_ligne_id]
    
    @ids_lignes_viewables = @ids_lignes_consultables+@ids_lignes_editables
    
    @all_lignes = Ligne.find(:all, :include => [:sous_contrat], :conditions => ["id in (?)", @ids_lignes_viewables])
    @lignes = []
    for ligne in @all_lignes
        @lignes << ['nom' => ligne.nom, 'id' => ligne.id]
    end
    @lignes.sort!{|a,b| a[0]['nom'].downcase <=> b[0]['nom'].downcase}

    render :action => "show_menu_ligne.js.erb", :layout => false
  end
  
  
  
  def show_menu_contrat
    @previous_controller  = params[:previous_controller]
    @previous_action      = params[:previous_action]
    @previous_contrat_id    = params[:previous_contrat_id]
    
    @ids_viewables = @ids_consultables+@ids_editables
    
    all_contrats = Contrat.find(:all)
    consultable_contrats = []
    for contrat in all_contrats
      if ( @ids_viewables.include? contrat.id)
        consultable_contrats << ['nom' => contrat.long_acronyme, 'id' => contrat.id]
      end
    end
    consultable_contrats.sort!{|a,b| a[0]['nom'].downcase <=> b[0]['nom'].downcase}
    
    @contrats = []
    
    for contrat in consultable_contrats
      path = ''
  	  case @previous_controller.to_s
  		  when 'Contrats'
  			  path = contrat_path(contrat[0]['id'])
  			  
  		  when 'ContratFiles'
  			  path = contrat_contrat_files_path(contrat[0]['id'])
  		  
  		  when 'Todolists'
  			  path = contrat_todolists_path(contrat[0]['id'])
  		  
  		  when 'Soumissions'
  			  current_contrat = Contrat.find_by_id(contrat[0]['id'])
  			  soumission = current_contrat.soumission
  			  if ['edit','update'].include? @previous_action.to_s	
  				  if (!soumission.nil?) && ( @ids_viewables.include? current_contrat.id )
  					  path = edit_contrat_soumission_path(contrat[0]['id'], soumission.id)
  				  end
  			  end
  			  if ['new','create'].include? @previous_action.to_s	
  				  if (soumission.nil?) && ( @ids_viewables.include? current_contrat.id )
  					  path = new_contrat_soumission_path(contrat[0]['id'])
  				  end
  			  end
  			  if ['show'].include? @previous_action.to_s	
  				  if !soumission.nil?
  					  path = contrat_soumission_path(contrat[0]['id'], soumission.id)
  				  end
  			  end
  			  
  			when 'Notifications'
  			  current_contrat = Contrat.find_by_id(contrat[0]['id'])
  			  notification    = current_contrat.notification
  			  signature       = current_contrat.signature
  			  if ['edit','update'].include? @previous_action.to_s	
  				  if (!notification.nil?) && ( @ids_viewables.include? current_contrat.id )
  					  path = edit_contrat_notification_path(contrat[0]['id'], notification.id)
  				  end
  			  end
  			  if ['new','create'].include? @previous_action.to_s	
  				  if (notification.nil?) && (!signature.nil?) && ( @ids_viewables.include? current_contrat.id )
  					  path = new_contrat_notification_path(contrat[0]['id'])
  				  end
  			  end
  			  if ['show'].include? @previous_action.to_s	
  				  if !notification.nil?
  					  path = contrat_notification_path(contrat[0]['id'], notification.id)
  				  end
  			  end
  			  
  			when 'Clotures'
  			  current_contrat = Contrat.find_by_id(contrat[0]['id'])
  			  notification    = current_contrat.notification
  			  cloture       = current_contrat.cloture
  			  if ['edit','update'].include? @previous_action.to_s	
  				  if (!cloture.nil?) && ( @ids_viewables.include? current_contrat.id )
  					  path = edit_contrat_cloture_path(contrat[0]['id'], cloture.id)
  				  end
  			  end
  			  if ['new','create'].include? @previous_action.to_s	
  				  if (cloture.nil?) && (!notification.nil?) && ( @ids_viewables.include? current_contrat.id )
  					  path = new_contrat_cloture_path(contrat[0]['id'])
  				  end
  			  end
  			  if ['show'].include? @previous_action.to_s
  				  if !cloture.nil?
  					  path = contrat_cloture_path(contrat[0]['id'], cloture.id)
  				  end
  			  end
  		  
  		  when 'Refus'
  			  current_contrat = Contrat.find_by_id(contrat[0]['id'])
  			  soumission  = current_contrat.soumission
  			  refu        = current_contrat.refu
  			  signature   = current_contrat.signature
  			  if ['edit','update'].include? @previous_action.to_s	
  				  if (!refu.nil?) && ( @ids_viewables.include? current_contrat.id )
  					  path = edit_contrat_refu_path(contrat[0]['id'], refu.id)
  				  end
  			  end
  			  if ['new','create'].include? @previous_action.to_s	
  				  if (refu.nil?) && (signature.nil?) && (!soumission.nil?) && ( @ids_viewables.include? current_contrat.id )
  					  path = new_contrat_refu_path(contrat[0]['id'])
  				  end
  			  end
  			  if ['show'].include? @previous_action.to_s	
  				  if !refu.nil?
  					  path = contrat_refu_path(contrat[0]['id'], refu.id)
  				  end
  			  end
  			  
  			  when 'Signatures'
    			  current_contrat = Contrat.find_by_id(contrat[0]['id'])
    			  soumission  = current_contrat.soumission
    			  refu        = current_contrat.refu
    			  signature   = current_contrat.signature
    			  if ['edit','update'].include? @previous_action.to_s	
    				  if (!signature.nil?) && ( @ids_viewables.include? current_contrat.id )
    					  path = edit_contrat_signature_path(contrat[0]['id'], signature.id)
    				  end
    			  end
    			  if ['new','create'].include? @previous_action.to_s	
    				  if (refu.nil?) && (signature.nil?) && (!soumission.nil?) && ( @ids_viewables.include? current_contrat.id )
    					  path = new_contrat_signature_path(contrat[0]['id'])
    				  end
    			  end
    			  if ['show'].include? @previous_action.to_s	
    				  if !signature.nil?
    					  path = contrat_signature_path(contrat[0]['id'], signature.id)
    				  end
    			  end
  		  
  		  else
  			  path = ''
  		  end
  		  
  		  if path != ''
  		    @contrats << ['nom' => contrat[0]['nom'], 'id' => contrat[0]['id'], 'path' => path]
  			end
      end
    
    render :action => "show_menu_contrat.js.erb", :layout => false
  end
  
  
  
  def create
     case params[:redirection]
       when 'change_projet'
         redirect_to contrat_path(params[:contrat][:id])
       else
         raise ArgumentError
     end
   end
  
end
