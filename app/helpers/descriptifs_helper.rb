#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
module DescriptifsHelper

  def list_descriptif(descriptifs)
    descriptifs.each do |descriptif|  
	   p = descriptif.id;
      if descriptif == descriptifs.first
	     class_add = " first"
	   else
	     class_add = ""
	   end
	   txt += "<div class='small_infos_actions "+cycle("even", "odd")+" "+class_add+"'>"
	   txt += "		<div class='infos'>"
		 txt += "		<div class='name'>"
		 txt +=  "langue" #descriptif.langue.nom_lague
		 txt += "</div>"
     txt += "	  <div class='description'>"+descriptif.descriptif+"</div>"
		 txt += "</div>"
		 txt += "<div class='actions'>"
     txt += link_to_remote_redbox "",
 		    {	:url => ask_delete_descriptif_path(sous_contrat), :method => :get},
 				{	:class => "delete",
 					:title => "Supprimer le descriptif" }
		 txt +="</div>"
		 txt +="<div style='clear:both;'></div>"
		 txt +="</div>"
	 end
	 return txt
 end
end
