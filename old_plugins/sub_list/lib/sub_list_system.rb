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
require 'action_pack'

module UIEnhancements
  class Engine < Rails::Engine
    initializer "UIEnhancements" do
      require 'sub_list_helper'
    end
    config.autoload_paths << File.expand_path("..", __FILE__)
  end 
  module SubList
  
	  def self.included(mod)
	    mod.extend(ClassMethods)
	  end
	  
	  module ClassMethods
	   def sub_list( model = 'Note', parent = 'incomplete' )
	     instance_eval do
            model = model.to_s.tableize.singularize
            model_class = model.to_s.camelize.constantize
            models = model.pluralize
            define_method("initialize_#{models}") do
              success = true
              parent_obj = eval "@#{parent}"
              model_list = parent_obj.send( models )
              return success if params[model].nil?
              
              params[model].sort.each do |id, values|
                obj = send( "find_#{model}", id )
                if obj.nil?
                  
                  # obj = model_class.new( values )
                  # obj.send( "#{parent}=", parent_obj )
                  
                  #modification pour prendre en compte les dates sous rails 3.2
                  values2 = {}
                  values.each do |key,value|
                    if key.to_s.include? "(3i)"
                      attribut_name= key.to_s.gsub("(3i)","")
                      begin
                        date = Date.civil(values[attribut_name + '(1i)'].to_i, values[attribut_name + '(2i)'].to_i, values[attribut_name + '(3i)'].to_i)
                      rescue
                        date = ""
                      end 
                      values2[attribut_name]=date
                    elsif !(key.to_s.include? "(2i)") and !(key.to_s.include? "(1i)")
                      values2[key]=value
                    end
                  end
                  obj = model_list.build( values2 )
                  
                #  model_list << obj
                else
                  obj = model_list.select { |item| item == obj }.first
                  
                  #modification pour prendre en compte les dates sous rails 3.2
                  values2 = {}
                  values.each do |key,value|
                    if key.to_s.include? "(3i)"
                      attribut_name= key.to_s.gsub("(3i)","")
                      begin
                        date = Date.civil(values[attribut_name + '(1i)'].to_i, values[attribut_name + '(2i)'].to_i, values[attribut_name + '(3i)'].to_i)
                      rescue
                        date = ""
                      end
                      values2[attribut_name]=date
                    elsif !(key.to_s.include? "(2i)") and !(key.to_s.include? "(1i)")
                      values2[key]=value
                    end
                  end
                  success = obj.update_attributes( values2 )
                end
              end
              #model_list.select { |item| item.id.nil? }.each { |null_item| null_item.id = Time.now.to_i }
              
              success
            end
            
            define_method("prepare_#{models}") do
              (eval "@#{parent}").send( models ).select { |item| item.id.nil? }.each { |null_item| null_item.id = Time.now.to_f.to_s.gsub(".", '') }
            #  (eval "@#{parent}").send( models ).select { |item| item.id.nil? }.each { |null_item| null_item.id = Time.now.to_i }
            end
            
            define_method "add_#{model}" do
              new_obj = model_class.new()
              new_obj.id = Time.now.to_f.to_s.gsub(".", '') #this won't actually be used as the id
             # new_obj.id = Time.now.to_i #this won't actually be used as the id
              
              yield new_obj #opportunity to setup the new item              
              render :partial => model+'.html.erb', :locals => { model.to_sym => new_obj }
            end
            
            define_method "remove_#{model}" do
              obj = send( "find_#{model}", params[:id] )
              
              if ! obj.nil?
                obj.destroy #This is not a new note but an old one..actually delete it
              end
              
             # render :text => ''
              render :update do |page|
                page.visual_effect :Fade, model+"_"+params[:id].to_s, :duration => 0.6
                page.delay(0.6) do
                 page.replace_html  model+"_"+params[:id].to_s, ""
                 if model == "echeancier_periode"
                   page.remove model+"_"+params[:id].to_s
                   page << "echeancier.updateAddLink();"
                   page << "echeancier.updateLegends();"
                 end
                 if model == "depense_salaire_facture"
                   page.remove model+"_"+params[:id].to_s
                   page << "update_paye_legende();"
                   page << "update_aide_navigation_paye();"
                 end
               end
               page.hide "indicator"
              end
            end
            
            define_method "ask_delete_#{model}"  do
              obj = send( "find_#{model}", params[:id] )
              render :partial => "ask_delete_#{model}", :locals => { model.to_sym => obj }
            end
            
            define_method "find_#{model}" do | id |
              begin
                return model_class.find( id )
              rescue ActiveRecord::RecordNotFound
                return nil
              end
            end
            
            protected "find_#{model}"      	      
            #protected "update_or_create_#{models}"
            
          end #end of instance_eval
        end #end of sublist	 function 
	  end #end of module Classmethods
	  
  end #end of sublist module
end #end of ui enhanacements module