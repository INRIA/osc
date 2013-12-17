#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
module NotificationsHelper
  
  def my_notification_error_messages_for notification
    txt =""
    if notification && !notification.errors.empty?
  	  txt = "<div class='errorExplanation' id='errorExplanation'>"
  	  txt += "<h2>"+notification.errors.size.to_s+" erreur(s) de saisie empêche(nt) l'enregistrement de la notification du contrat</h2>"
      txt += "<ul>"
      notification.errors.each do |attr, msg| 
  	    if attr.to_s =="notification_partenaires" 
  			  txt += "<li><strong>Partenaires hors Europe</strong> : le champ <strong>nom</strong> est un champ obligatoire, merci de le renseigner</li>"
  		  elsif attr.to_s =="notification_europe_partenaires"
  			  txt += "<li><strong>Partenaires en Europe</strong> : le champ <strong>nom</strong> est un champ obligatoire, merci de le renseigner</li>"
  		  elsif attr.to_s =="notification_france_partenaires" 
  			  txt += "<li><strong>Partenaires en France</strong> : le champ <strong>nom</strong> est un champ obligatoire, merci de le renseigner</li>"
  		  elsif attr.to_s =="notification_personnels" 
  			  txt += "<li><strong>Personnel impliqué</strong> : tous les champs sont obligatoires, merci de les renseigner</li>"
  		  elsif attr.to_s =="avenants" 
  			  txt += "<li><strong>Avenant</strong> : tous les champs sont obligatoires et les dates doivent être valides, merci de les renseigner</li>"
  		  else 
  			  txt += "<li>"+msg+"</li>"
  		  end
      end
      txt += "</ul>"
      txt += "</div>"
    end
    return txt.html_safe()
  end
  
  
   def display_contrat_type(element)
     ret = ""
     if !element.parent.nil?
      ret += display_contrat_type(element.parent)+" > "
      ret += element.nom 
     else
      ret += element.nom
     end
     ret.html_safe()
   end
  
  
end
