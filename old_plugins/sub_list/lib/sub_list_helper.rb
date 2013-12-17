# ROR SubList Plugin
# Luke Galea - galeal@ideaforge.org
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# (2013) Modified by Benjamin Ninassi for rails 3.2 compatibility
module SubListHelper  
  def sub_list_add_link( model = 'Note', label = image_tag( 'add.png' ) )
    model = model.to_s.tableize.singularize
    models = model.pluralize
    
    link_to_remote( label, {:update => models, 
                           :position => :bottom, 
                           :complete => visual_effect( :appear, models, :duration => 0.05 ), 
                           :url => { :action => "add_#{model}" }},
                           {:class => "sub_list_add"}
     )
  end
  
  def sub_list_content( model = 'Note', parent = 'incomplete', options = '' )
    model = model.to_s.tableize.singularize
    models = model.pluralize
    content = render :partial => model, :locals => { :options => options } ,:collection => eval("@#{parent}.#{models}")
    "<div id=\"#{models}\"> #{content} </div>".html_safe()
  end
  
  def sub_list_content_without_div( model = 'Note', parent = 'incomplete' )
    model = model.to_s.tableize.singularize
    models = model.pluralize
    
    render :partial => model, :collection => eval("@#{parent}.#{models}")
  end
  
  def sub_list_remove_link( item, model = 'Note', label = image_tag( 'delete.png' ) )
    model = model.to_s.tableize.singularize
    models = model.pluralize
    
  #  link_to_remote( label,{ :update => "#{model}_#{item.id}",
  #                          :before => visual_effect( :DropOut, "#{model}_#{item.id}" , :duration => 0.5 ), 
  #                          :confirm => 'La suppression est permanente. Etes-vous certain de vouloir supprimer ce information ?', 
  #                          :url => { :action => "remove_#{model}", :id => item }
  #                          },
  #                          {:class => "sub_list_delete"})
    
     link_to_remote_redbox( label, {	:url => { :action => "ask_delete_#{model}", :id => item.id }}, 
                        				   {	:class => "sub_list_delete"})
                            
  end  
  
  def sub_list_accept_to_remove_link( model)
	  link_to_remote( "Oui",{ 
	   											  :complete => "RedBox.close();",
                            :url => { :action => "remove_"+model, :id => params[:id] }
                          })
                          # :update => model+"_"+params[:id].to_s,
                          #  :before => visual_effect( :DropOut, model+"_"+params[:id].to_s , :duration => 0.25 ), 
	                        
  end
  
  
end