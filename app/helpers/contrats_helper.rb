#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
module ContratsHelper

  def list_association(sous_contrats, type)
    txt = "<h2>Associations à des <strong>"+type+"</strong></h2>"
    if sous_contrats.size == 0
      txt += "<p class='comment'>Aucune association directe à un "+type+" n'est enregistrée.</p>"
    end
    for sous_contrat in sous_contrats
      if sous_contrat == sous_contrats.first
        class_add = " first"
      else
        class_add = ""
      end
      txt += "<div class='small_infos_actions "+cycle("even", "odd")+" "+class_add+"'>"
      txt += "          <div class='infos'>"
      txt += "          <div class='name'>"
      txt +=  sous_contrat.entite.nom
      txt += "</div>"
      txt += "    <div class='description'>"+truncate(sous_contrat.entite.description, :length => 80, :ommission => "...")+"</div>"
      txt += "</div>"
      txt += "<div class='actions'>"
      if sous_contrat.verrou != 'SI INRIA'
        txt += link_to_remote_redbox "",
        {       :url => ask_delete_sous_contrat_path(sous_contrat), :method => :get},
        {       :class => "delete",
          :title => "Supprimer le contrat" }
      end
      txt +="</div>"
      txt +="<div style='clear:both;'></div>"
      txt +="</div>"
    end
    return txt.html_safe()
  end
end


class UserPaginationLinkRenderer  < WillPaginate::ActionView::LinkRenderer

  def link(text, target, attributes ={})
    attributes["OnClick"]="updateUserResult("+target.to_s+"); return false;"
    super
  end
end

class GroupPaginationLinkRenderer  < WillPaginate::ActionView::LinkRenderer

  def link(text, target, attributes ={})
    attributes["OnClick"]="updateGroupResult("+target.to_s+"); return false;"
    super
  end
end