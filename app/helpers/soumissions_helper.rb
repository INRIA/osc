#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
module SoumissionsHelper
  
  def my_soumission_error_messages_for soumission
    txt = ""    
    if soumission && !soumission.errors.empty?
  	  txt = "<div class='errorExplanation' id='errorExplanation'>"
  	  txt += "<h2>"+@soumission.errors.size.to_s+" erreur(s) de saisie empêche(nt) l'enregistrement de la soumission du contrat</h2>"
      txt += "<ul>"
      soumission.errors.each do |attr, msg| 
  		  if attr.to_s =="soumission_partenaires" 
  			  txt += "<li><strong>Partenaires hors Europe</strong> : le champ <strong>nom</strong> est un champ obligatoire, merci de le renseigner</li>"
  		  elsif attr.to_s =="soumission_europe_partenaires"
  			  txt += "<li><strong>Partenaires en Europe</strong> : le champ <strong>nom</strong> est un champ obligatoire, merci de le renseigner</li>"
  		  elsif attr.to_s =="soumission_france_partenaires" 
  			  txt += "<li><strong>Partenaires en France</strong> : le champ <strong>nom</strong> est un champ obligatoire, merci de le renseigner</li>"
  		  elsif attr.to_s =="soumission_personnels" 
  			  txt += "<li><strong>Personnel impliqué</strong> : tous les champs sont obligatoires, merci de les renseigner</li>"
  		  else 
  			  txt += "<li>"+msg+"</li>"
  		  end
      end
      txt += "</ul>"
      txt += "</div>"
    end
    return txt.html_safe()
  end

end
