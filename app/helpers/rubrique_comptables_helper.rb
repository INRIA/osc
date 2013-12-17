#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
module RubriqueComptablesHelper

  
  def display_tree_recursive(tree, parent_id)
    ret = "<ul>"
    tree.each do |node|
      if node.parent_id == parent_id
        ret += "<li>"
        ret += "- "+node.intitule
        ret += display_tree_recursive(tree, node.id)
        ret += "</li>"
      end
    end
    ret += "</ul>"
    return ret.html_safe()
  end
  
  def display_tree_recursive_for_rubrique_comptable_with_options(tree, parent_id)
      ret = "<ul class='tree'>\n"
      tree.each do |node|
        if node.parent_id == parent_id
          ret += "<li id='rc_"+node.id.to_s+"' class='"+cycle("even", "odd")+"'>\n"
          ret += "<span class='nom'>"
          ret += node.intitule
          ret += "</span>\n"
          ret += "<span class='options'>"
          ret += link_to 'Editer', edit_rubrique_comptable_path(node) 
          if current_user.is_admin?
						if (RubriqueComptable.find_all_by_parent_id(node.id).size == 0) && (search_all_exact_rubrique_comptable(node.id).size == 0)
              ret += " | "
              ret += link_to_remote_redbox "Supprimer",{ :url => ask_delete_rubrique_comptable_path(node),:method => :get},{ :title => "Supprimer cette rubrique comptable" } 
            end
          end
          ret += "</span>\n"
          ret += "<div style='clear:both;'></div>\n"
          ret += display_tree_recursive_for_rubrique_comptable_with_options(tree, node.id)
          ret += "</li>\n"          
        end
      end
      ret += "</ul>\n"
      return ret.html_safe()
    end
  
  def display_form_edit_tree_recursive_for_rubrique_comptable(f, tree, parent_id, current_id)
	  ret = "  <ul>"
    tree.each do |node|
      if node.parent_id == parent_id
        ret += "<li>"
        if current_id == node.id 
          ret += "<label for='contrat_type_parent_id_"+node.id.to_s+"'><b> ---- "+node.intitule+" ---- </b></label>"
          ret += display_tree_recursive(tree, node.id)
        else
          ret += f.radio_button('parent_id', node.id)
          ret += "<label for='contrat_type_parent_id_"+node.id.to_s+"'>"+node.intitule+"</label>"
          ret += display_form_edit_tree_recursive_for_rubrique_comptable(f, tree, node.id, current_id)
        end
        ret += "</li>"
      end
    end
    ret += "  </ul>"
    return ret.html_safe()
  end
  
  def display_form_tree_recursive_rubrique_comptable(f, tree, parent_id)
	  ret = "  <ul>"
    tree.each do |node|
      if node.parent_id == parent_id
        ret += "<li>"
        ret += f.radio_button('parent_id', node.id)
        ret += "<label for='rubrique_comptable_parent_id_"+node.id.to_s+"'>"+node.intitule+"</label>"
        ret += display_form_tree_recursive_rubrique_comptable(f, tree, node.id)
        ret += "</li>"
      end
    end
    ret += "  </ul>"
    return ret.html_safe()
  end

end
