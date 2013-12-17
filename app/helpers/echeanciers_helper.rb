#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
module EcheanciersHelper

  def find_css_class(solde)
    if solde < 0
      "error" 
    else
       ""
    end
  end

  def my_echeancier_error_messages_for(object = @object)
    if object && !object.errors.empty?
      content_tag("div",
        content_tag('h2',
          "Des erreurs de saisie empêche l'enregistrement de l'échéancier" 
        ) +
        content_tag("p", "Il y a des problème avec les champs suivants :") + error_list_for(object),
          :id => 'errorExplanation'
      )
    else
      ''
    end
  end

   def error_list_for(object, depth = 1, max_depth = 2)
     association_names = object.class.reflect_on_all_associations.map(&:name)
     association_errors, attribute_errors = object.errors.partition { |name, _| association_names.include?(name.to_sym) }
     messages = []
     attribute_errors.sort.each do |attr, errors|
       errors.each_line do |msg|
         if attr == "base" 
           messages << msg
         else
           messages << "#{msg}"
         end
       end
     end
     
     # Validation adds the same error again on the base object
     # for each invalid associated object. Uniq boils these down to one.
     association_errors.sort.uniq.each do |assoc, errors|
       errors.each_line do |msg|
         if depth < max_depth
           associated_objects = Array(object.send(assoc))
           if associated_objects.empty?
             messages << "#{assoc.humanize}<ul><li>#{msg}</li></ul>" 
           else
             associated_objects.each_with_index do |associated_object, i|
               unless associated_object.errors.empty?
                 messages << "Période #{i + 1}" + error_list_for(associated_object, depth + 1)
               end
             end
           end
         else
           messages << "#{assoc.humanize} #{msg}" 
         end
       end
     end
     message_global = ""
     for m in messages do
       message_global +=content_tag("li",m.html_safe())
     end
     content_tag("ul", 
       message_global.html_safe()
     )
   end


end
