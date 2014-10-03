#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi

# <b>Auteurs</b> : Benjamin Ninassi & Jean-Marie Vallet
#
# Les methodes de cet helper sont accessibles par toutes les vues de l'application

module ApplicationHelper

  KOCTET = 1024.0
  MEGABYTE = 1024.0 * 1024.0
  
  def to_filesize filesize
    if filesize < 1024.0
      f = filesize.to_s
      unit = "octets"
    end
    
    if filesize > 1023.0
      f = (filesize / KOCTET).to_s
      unit = "Ko"
      
    end
    
    if filesize > 104858.0
      f = (filesize / MEGABYTE).to_s 
      unit = "Mo"
    end
    return number_to_currency(f, :unit => unit, :precision => 1)
  end

  def print_user_infos(id)
    if  User.find_by_id(id)
      user = User.find(id)
    end
    if !user.nil?
      user.prenom+" "+user.nom
    else
      "???"
    end
  end
  
  def print_small_user_infos(id)
    if  User.find_by_id(id)
      user = User.find(id)
    end
    if !user.nil?
      if user.nom == "SI INRIA" && user.prenom == "."
        "SI INRIA".html_safe()
      else
        (user.nom + " " + user.prenom[0..0] + ".").html_safe()
      end
    else
      "&oslash;".html_safe()
    end
  end

  # Customisation de la méthode number_to_currency pour la langue française
  def my_number_to_currency(number, options = {})
    options   = options.stringify_keys
    precision = options["precision"] || 2
    unit      = options["unit"] || "&euro;"
    separator = precision > 0 ? options["separator"] || "." : ""
    delimiter = options["delimiter"] || " "
    if number.nil?
      number = 0
    end
    begin
      number_to_currency(number, :precision => precision,:locale => :fr, :separator => separator)
    rescue
      number
    end
  end

  # Retourne un date dans le format francais : Jour/Mois/Annee Heure:Minute:Seconde
  def french_datetime(datetime)
    datetime.strftime("%d/%m/%Y à %H:%M:%S") unless datetime.nil? 
  end
  
  # Retourne un date dans le format francais : Jour/Mois/Annee
  def french_datetime_with_word(datetime)
    mois = ["Janvier", "Fevrier", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
    if !datetime.nil?
      datetimetemp = relative_date(datetime)
      if datetimetemp == "Aujourd'hui"
        datetimetemp
      elsif datetimetemp == "Hier"
        datetimetemp
      else
       datetimetemp = datetime.strftime("%d").to_i.to_s+" "+mois[datetime.strftime("%m").to_i-1]+" "+datetime.strftime("%Y")
      end
      return datetimetemp
    end 
  end
  
  
  # Retourne un date dans le format francais : Heure:Minute
  def french_datetime_in_day(datetime)
    datetime.strftime("%H:%M") unless datetime.nil? 
  end
  
  # Retourne un date dans le format francais : Jour/Mois/Annee
  def french_day_datetime(datetime)
    datetime.strftime("%d/%m/%Y") unless datetime.nil? 
  end

  
  # Retourne une date formatee (Jour/Mois/annee) ou "Date infinie" lorsque la date en entree vaut 31/12/2099
  def french_date(date)
    if date.strftime("%d/%m/%Y") == "31/12/2099"
      return "Date infinie"
    else
      date.strftime("%d/%m/%Y")
    end
  end
  
  def to_ddmmyyyy(date)
    date.strftime("%d/%m/%Y")
  end
  
  # Retourne une date formatee (Jour/Mois/annee) ou "Date infinie" lorsque la date en entree vaut 31/12/2099
  def french_small_date(date)
      date.strftime("%d/%m/%y")
  end
  
  # Prend objet ayant les attributs created_at et updated_at
  # et retourne une div masquee, avec les informations de date de creation et de derniere modification
  def show_dates(obj)
    txt = "<div id='more' style='display:none;'>"
    txt += "Date de création: <strong>"+french_datetime(obj.created_at)+"</strong><br/>"
    txt += "Date de dernière modification : <strong>"+french_datetime(obj.updated_at)+"</strong><br/>"
    txt += "</div>"   	
    return sprintf(txt).html_safe()
  end
  
  def to_ieme(i)
    if i == 1
      return ("1<sup>er</sup>").html_safe()
    else
      return (i.to_s+"<sup>ème</sup>").html_safe()
    end
  end

  def get_file_img_src(extname)
    case extname
    when ".pdf"
    	img = asset_path "mine_types/pdf.png"
    when ".doc"
    	img = asset_path "mine_types/Word.png"
    when ".xls"
    	img = asset_path "mine_types/xls.png"
    when ".xlsx"
      img = asset_path "mine_types/xls.png"
    when ".ppt"
    	img = asset_path "mine_types/PowerPoint.png"	
    when ".zip"
    	img = asset_path "mine_types/zip.png"
    when ".tar"
    	img = asset_path "mine_types/tar.png"
    when ".gz"
    	img = asset_path "mine_types/gz.png"
    when ".gz2"
    	img = asset_path "mine_types/gz2.png"
    when ".png"
    	img = asset_path "mine_types/png.png"
    when ".jpg"
    	img = asset_path "mine_types/jpg.png"
    when ".jpeg"
    	img = asset_path "mine_types/jpeg.png" 
    else
    	img = asset_path "mine_types/default.png"
    end
    return img
  end

  # Retourne la photo de taille 76x76 associee a un groupe
  def show_groups_image
    return image_tag 'group_show.png', :alt => 'Groupe'
  end

  # Retourne la photo de taille 76x76 associee a un utilisateur
  def show_user_image(user)
    if user.user_image.nil?
      if user.photose.to_s == '' or user.photose.nil?
        return image_tag 'null.jpg', :alt => 'image introuvable'
      else
        return ("<img alt='photo' src='"+user.photose+"' />").html_safe()
      end
    else
      image_tag url_for_file_column(user.user_image, "image")
    end
  end

  # Retourne la photo de taille 38x38 associee a un utilisateur
  def show_user_image_small(user)
    if user.user_image.nil?
      if user.photose.nil? or !File.exist? user.photose
        return image_tag 'null.jpg', :alt => 'image introuvable'
      else
        return ("<img alt='photo' src='"+user.photose+"' />").html_safe()
      end
    else
      image_tag url_for_file_column(user.user_image, "image", "small")
    end
  end

  # Retourne la photo de taille 76x76 associee a une tutelle
  def show_tutelle_logo(tutelle_logo)
    if tutelle_logo.nil?
      return image_tag 'logo_null.jpg', :alt => 'image introuvable'
    else
      image_tag url_for_file_column(tutelle_logo, "logo")
    end
  end
  
  # Retourne la photo de taille 38x38 associee a une tutelle
  def show_tutelle_logo_small(tutelle_logo)
    if tutelle_logo.nil?
      return image_tag 'logo_null.jpg', :alt => 'image introuvable'
    else
      image_tag url_for_file_column(tutelle_logo, "logo", "small")
    end
  end
  
  def display_contrat_type(element)
    ret = ""
    if !element.parent.nil?
     ret += display_contrat_type(element.parent)+" > "
     ret += element.nom 
    else
     ret += element.nom
    end
    ret
  end
  

  def options_for_contrat_types(categories)
    ret = []
    for category in categories
      if category.parent_id == 0
        ret << [category.nom, category.id]
        ret += options_for_sub_contrat_types(category)
      end
    end
    ret
  end

  def options_for_sub_contrat_types(category, level='')
    ret = []
    if category.children.size > 0
      level += '. . . '
      category.children.each do |subcat|
        ret << [ level + ' '+subcat.nom, subcat.id]
        if subcat.children.size > 0
          ret += options_for_sub_contrat_types(subcat, level)
        end
      end
    end
    ret
  end

  def options_for_rubrique_comptables(categories)
    ret = []
    for category in categories
      if category.parent_id == 0
        ret << [category.intitule, category.id]
        ret += options_for_sub_rubrique_comptables(category)
      end
    end
    ret
  end

  def options_for_sub_rubrique_comptables(category, level='')
    ret = []
    if category.children.size > 0
      level += '. . . '
      category.children.each do |subcat|
        ret << [ level + ' '+subcat.intitule, subcat.id]
        if subcat.children.size > 0
          ret += options_for_sub_rubrique_comptables(subcat, level)
        end
      end
    end
    ret
  end



  def is_in_admin_menu?
    if controller.class.to_s == "ContratsController" ||
      controller.class.to_s == "SousContratsController" ||
      controller.class.to_s == "SoumissionsController"
      return false
    else
      return true
    end
  end

  def search_all_exact_rubrique_comptable(id)
    sql = "SELECT rubrique_comptable_id FROM `depense_fonctionnement_factures`  WHERE rubrique_comptable_id like ?
           union ALL
           SELECT rubrique_comptable_id FROM `depense_equipement_factures`  WHERE rubrique_comptable_id like ?
           union ALL
           SELECT rubrique_comptable_id FROM `depense_mission_factures`  WHERE rubrique_comptable_id like ?
           union ALL
           SELECT rubrique_comptable_id FROM `depense_non_ventilee_factures`  WHERE rubrique_comptable_id like ?"
    result = DepenseEquipementFacture.find_by_sql([sql,id,id,id,id])
  end
  
  def error_messages_for(object)
    txt=""
    if object && !object.errors.empty?
      txt = "<div class='errorExplanation' id='errorExplanation'>"
      txt += "<h2>"+object.errors.size.to_s+" erreur(s) de saisie empêche(nt) l'enregistrement</h2>"
      txt += "<ul>"
      object.errors.each do |attr, msg| 
        txt += "<li>Le champ "+attr.to_s.humanize+ " " + msg+"</li>"
      end
      txt += "</ul>"
      txt += "</div>"
    end
    return txt.html_safe()
  end
  
  def error_messages_content_nested_resources_for(nested_collection, object_name)
    if object_name == "organisme_gestionnaire"
      txt = "Définition du taux par année pour le calcul du coût projet"
    else
      txt = "Facture"
    end
    content  = ""
    if nested_collection
      for nested in nested_collection
        if !nested.errors.empty?
          content += "<li>"+txt+"<ul>"
          for msg in nested.errors.full_messages
            content += "<li>Le champ "+msg+"</li>"
          end
          content += "</ul></li>"
        end
      end
    end
    return content.html_safe()
  end
  
  def error_messages_nested_resources_for(object)
    object_name = object.class.to_s
    case object_name
      when "DepenseCommun"         then nested_objects = object.depense_commun_factures
      when "DepenseFonctionnement" then nested_objects = object.depense_fonctionnement_factures
      when "DepenseEquipement"     then nested_objects = object.depense_equipement_factures
      when "DepenseMission"        then nested_objects = object.depense_mission_factures
      when "DepenseSalaire"        then nested_objects = object.depense_salaire_factures
      when "DepenseNonVentilee"   then nested_objects = object.depense_non_ventilee_factures
      when "Organisme_gestionnaire" then nested_objects = object.organisme_gestionnaire_tauxes
    end
    nb_errors = 0
    count_nested_error_case = 0
    if nested_objects 
      for nested in nested_objects
        if nested.errors.size > 0
          count_nested_error_case += 1
          nb_errors += nested.errors.size
        end
      end
    end
    
    txt=""
    unless (object.errors.empty? && nb_errors == 0)
      txt = "<div class='errorExplanation' id='errorExplanation'>"
      txt += "<h2>"+"#{pluralize(object.errors.count+nb_errors-count_nested_error_case, "erreurs")} empêche(nt) ce formulaire d'être sauvegardé</h2>"
      txt += "<p>Veuillez vérifier les informations et apporter les modifications aux champs suivants :</p>"
      txt += "<ul>"
      object.errors.each do |attr, msg| 
        if (msg != ("Taux par année est invalide")) and (!attr.to_s.humanize.include? "factures")
          txt += "<li>Le champ "+attr.to_s.humanize+ " " + msg+"</li>"
        end
      end

      txt +=error_messages_content_nested_resources_for(nested_objects, object_name)
      txt += "</ul>"
      txt += "</div>"
    end
    return txt.html_safe()
  end
      
end
