#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
module EtatHelper
  
  def display_tree_recursive(tree, parent_id)
    ret = "<ul>"
    tree.each do |node|
      if node.parent_id == parent_id
        ret += "<li>"
        ret += node.nom
        count = Notification.find(:all, :conditions => [ "contrat_type_id in (?)", node.id]).size
        ret += " ("+count.to_s+")"
        ret += display_tree_recursive(tree, node.id)
        ret += "</li>"
      end
    end
    ret += "</ul>"
  end
  
  def my_check_box(id, intitule, css_class = "")
    if @params[id] == '1'
      bool = "checked = checked"
    else
      bool = ""
    end
    ret = "<p class='"+css_class+"'>"
    ret += "<input id='"+id+"' class='checkbox' type='checkbox' value='1' name='"+id+"' "+bool+" />"
		ret += "<label for='"+id+"'>"+intitule+"</label>"
		ret += "</p>"
  end

  
  def my_th(value)
    section = value[:intitule].split(' : ')[0]
    intitule = value[:intitule].sub(' - ', '<hr />').sub('Soumission : ', '').sub('Signature : ', '').sub('Refus : ', '').sub('Notification : ', '').sub('Clôture : ', '')
	  return "<th class='"+section+"'>"+intitule+"</th>"
  end
  
  def show_boolean(value)
    if value
      return "oui"
    else
      return "non"
    end
  end

end