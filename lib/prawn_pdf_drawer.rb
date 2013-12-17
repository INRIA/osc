#!/bin/env ruby
# encoding: utf-8

class PrawnPdfDrawer < Prawn::Document
  def initialize(object,request)
    
    @request = request
    @black = "000000"
    @grey = "808080"
    @white = "FFFFFF"
    @table_shade1 = "DBDBDB"
    @table_shade2 = "FFFFFF"
    super(:top_margin=> 90)
    @table_cell1_width = 45*(bounds.right-bounds.left)/100
    @table_cell2_width = 55*(bounds.right-bounds.left)/100
    @table_cell3_width = (bounds.right-bounds.left)/3
    @table_cell4_width = (bounds.right-bounds.left)/4
    @table_cell5_width = (bounds.right-bounds.left)/5
    font "Times-Roman"
    case object.class.name
    when 'Contrat'
      draw_contrat(object)
    when 'Soumission'
      draw_soumission(object)
    when 'Notification'
      draw_notification(object)
    when 'Cloture'
      draw_cloture(object)
    when 'Signature'
      draw_signature(object)
    when 'Refu'
      draw_refu(object)
    end
    
    init_footer
    add_page_number
  end
  
  # Affiche un titre de niveau 1
  def h1(txt)
    fill_color @black
    stroke_color @grey
    move_down 10
    text txt, :size => 16
    dash(1, :space => 1, :phase => 0)
    stroke_horizontal_rule
    move_down 5   
  end

  # Affiche un titre de niveau 2
  def h2(text)
    move_down 5
    fill_color @black
    text text, :size => 12
    move_down 5
  end
  
  def classic_tab(data)
    table(data,:row_colors => [@table_shade1,@table_shade2],
           :cell_style=>{:borders=>[],:size => 9,:padding => [2, 5, 2, 5]},
           :column_widths => [@table_cell1_width,@table_cell2_width])  
  end
  
  # Affiche les infos sur la soumission
  def draw_soumission(object)
    prepare_soumission(object)
    init_header(object.contrat,"Soumission du contrat ")
  end
  
  def draw_signature(object)
    prepare_signature(object)
    init_header(object.contrat,"Signature du contrat ")
  end
  
  def draw_refu(object)
    prepare_refu(object)
    init_header(object.contrat,"Refu du contrat ")
  end
  
  def draw_notification(object)
    prepare_notification(object)
    init_header(object.contrat,"Notification du contrat ")
  end
  
  def draw_cloture(object)
    prepare_cloture(object)
    init_header(object.contrat,"Clôture du contrat ")
  end
  
  # Affiche les infos sur le contrat
  def draw_contrat(object)
    @contrat = object
    text @contrat.acronyme, :align => :center, :size => 46
    move_down 15
    fill_color @grey
    text @contrat.nom, :align => :center, :size => 14
    fill_color @black
    if @contrat.num_contrat_etab and @contrat.num_contrat_etab != ''
      move_down 5
      text "N° "+@contrat.num_contrat_etab, :align => :center, :size => 14
    end
    move_down 15
    stroke_color @grey
    stroke_horizontal_rule
    move_down 5
    txt = ""
    for sous_contrat in @contrat.sous_contrats
      txt += sous_contrat.entite.nom+"     "
    end
    text txt, :align => :center,:size => 20
    move_down 5
    stroke_horizontal_rule
    move_down 45
    txt = "Etat du contrat : "
    txt += "Soumission" if !@contrat.soumission.nil?
    txt += "Soumission non créée" if @contrat.soumission.nil?
    txt += " > Signature" if !@contrat.signature.nil?
    txt += " > Refus" if !@contrat.refu.nil?
    txt += " > Notification" if !@contrat.notification.nil?
    txt += " > Clôture" if !@contrat.cloture.nil?
    text txt, :size => 16, :align => :left
    
    h1("Dates importantes")
    data = []
    if !@contrat.soumission.nil?
      data << ["Dépot de la soumission", @contrat.soumission.date_depot.strftime("%d/%m/%Y")]
    else
      data << ["Pas d'information", " " ]          
    end
    if !@contrat.signature.nil? 
      data << ["Signature", @contrat.signature.date.strftime("%d/%m/%Y")  ]
    end
    if !@contrat.refu.nil?
      data << [ "Refus",  @contrat.refu.date.strftime("%d/%m/%Y")]
    end
    if !@contrat.notification.nil?
      data << ["Notification", @contrat.notification.date_notification.strftime("%d/%m/%Y") ]
      data << ["Début du contrat",  @contrat.notification.date_debut.strftime("%d/%m/%Y")]
      data <<  ["Fin du contrat",  @contrat.notification.date_fin.strftime("%d/%m/%Y")] 
      data << ["Durée",  @contrat.notification.nombre_mois.to_s+" mois" ]
    elsif !@contrat.soumission.nil?
      data <<  ["Durée",  @contrat.soumission.nombre_mois.to_s+" mois" ]
    end
    if !@contrat.cloture.nil?
      data << ["Fin des dépenses",  @contrat.cloture.date_fin_depenses.strftime("%d/%m/%Y")]
    end
    table(data,:row_colors => [@table_shade1,@table_shade2],
               :cell_style=>{:borders=>[],:size => 9},
               :column_widths => [@table_cell1_width,@table_cell2_width])
               
    h1("Porteur & coordinateur")    
    data = []
    if !@contrat.notification.nil?
      data << ["Porteur",  @contrat.notification.porteur] 
      data << ["Coordinateur", @contrat.notification.coordinateur] 
    elsif !@contrat.soumission.nil?
      data << ["Porteur", @contrat.soumission.porteur] 
      data << ["Coordinateur", @contrat.soumission.coordinateur ]
    else
      data << ["Pas d'information", " "] 
    end
    table(data,:row_colors => [@table_shade1,@table_shade2],
               :cell_style=>{:borders=>[],:size => 9},
               :column_widths => [@table_cell1_width,@table_cell2_width])

    h1 "Affichage public"
    if @contrat.publicite
       text "Oui", :size => 9, :align => :left
    else
       text "Non", :size => 9, :align => :left
    end

    if !@contrat.descriptifs.empty?
      h1 "Descriptifs"
      @contrat.descriptifs.each_with_index { |e, i|
           text e.descriptif, :size => 9, :align => :left
           text " ", :size => 15, :align => :center
      }
    end
    
    if !@contrat.soumission.nil?
      start_new_page
      titre("Soumission du contrat") 
      prepare_soumission(@contrat.soumission)
    end
    if !@contrat.signature.nil?
      start_new_page 
      titre("Signature du contrat")
      prepare_signature(@contrat.signature)
    end
    
    if !@contrat.refu.nil?
      start_new_page 
      titre("Refus du contrat")
      prepare_refu(@contrat.refu)
    end
    
    if !@contrat.notification.nil?
      start_new_page
      titre("Notification du contrat")
      prepare_notification(@contrat.notification)
    end
    
    if !@contrat.cloture.nil?
      start_new_page
      titre("Clôture du contrat")
      prepare_cloture(@contrat.cloture)
    end
    
    init_header(@contrat)
  end
  
  # Prépare l'affichage du bloc porteur et coordinateur commun aux soumission et notification
  # obj == 'soumission' || 'notification'
  def prepare_porteur(obj)
    h1 "Porteur et coordinateur"
    data = [
      ["Porteur",  obj.porteur],
      ["Etablissement de rattachement du porteur",  obj.etablissement_rattachement_porteur],
      ["Coordinateur",  obj.coordinateur],
      ["Etablissement gestionnaire du coordinateur",  obj.etablissement_gestionnaire_du_coordinateur]
    ]
    classic_tab(data)
  end
  
   # Prépare l'affichage du bloc mots clés et thématiques commun aux soumission et notification
  # obj == 'soumission' || 'notification'
  def prepare_key_words(obj)
    h1 "Mots clés et thématiques"
    
    if obj.key_words.size == 0
      text "Aucun mots clés spécifiés", :size => 9
    else
      data = [["Laboratoire","Section","Intitulé du mot clé"]]
      table(data,:cell_style=>{:borders=>[],:size => 8,:text_color =>@grey,:padding => [2, 5, 2, 5],:font_style => :bold},
                 :column_widths => [@table_cell3_width,@table_cell3_width,@table_cell3_width])
      data = []
      for key_word in obj.key_words.find(:all, :include => [:laboratoire], :order => "laboratoires.nom, key_words.section, key_words.intitule")
        data <<  [key_word.laboratoire.nom.to_s,key_word.section.to_s,key_word.intitule.to_s]
      end
      table(data,:row_colors => [@table_shade1,@table_shade2],
                 :cell_style=>{:borders=>[],:size => 9,:padding => [2, 5, 2, 5]},
                 :column_widths => [@table_cell3_width,@table_cell3_width,@table_cell3_width])
    end
    
    move_down 20
    
  
    data = []
    data <<  ["Mots clés libres",  obj.mots_cles_libres]
    data <<  ["Thématiques",  obj.thematiques]
    data <<  ["Pôles de compétivites",  obj.poles_competivites]
    classic_tab(data)
  end
  
  # Prépare l'affichage du bloc partenaire en France commun aux soumission et notification
  # obj == 'soumission' || 'notification'
  def prepare_partenaires_france(obj)
    h2 "Partenaires en France"
    if obj.size == 0
      text "Aucun partenaire en France", :size => 9
    else
      data = [["Nom","Laboratoire","Etablissement gestionnaire","Ville"]]
      table(data,:cell_style=>{:borders=>[],:size => 8,:text_color =>@grey,:padding => [2, 5, 2, 5],:font_style => :bold},
                 :column_widths => [@table_cell4_width,@table_cell4_width,@table_cell4_width,@table_cell4_width])
      data = []
      obj.each_with_index { |e, i| 
        data <<  [e.nom,  e.laboratoire,  e.etablissement_gestionnaire,  e.ville]
      }
      table(data,:row_colors => [@table_shade1,@table_shade2],
                 :cell_style=>{:borders=>[],:size => 9,:padding => [2, 5, 2, 5]},
                 :column_widths => [@table_cell4_width,@table_cell4_width,@table_cell4_width,@table_cell4_width])
    end
  end
  
  # Prépare l'affichage du bloc partenaire en Europe commun aux soumission et notification
  # obj == 'soumission' || 'notification'
  def prepare_partenaires_europe(obj)
    h2 "Partenaires en Europe"
    if obj.size == 0  
      text "Aucun partenaire en Europe", :size => 9
    else
      data = [["Nom","Etablissement gestionnaire","Ville","Pays"]]
      table(data,:cell_style=>{:borders=>[],:size => 8,:text_color =>@grey,:padding => [2, 5, 2, 5],:font_style => :bold},
                 :column_widths => [@table_cell4_width,@table_cell4_width,@table_cell4_width,@table_cell4_width])
 
      data = []
      obj.each_with_index { |e, i| 
        data <<  [e.nom,  e.etablissement_gestionnaire,  e.ville,  e.pays ]
      }
      table(data,:row_colors => [@table_shade1,@table_shade2],
                 :cell_style=>{:borders=>[],:size => 9,:padding => [2, 5, 2, 5]},
                 :column_widths => [@table_cell4_width,@table_cell4_width,@table_cell4_width,@table_cell4_width])

    end
  end
  
  
  # Prépare l'affichage du bloc partenaire hors France commun aux soumission et notification
  # obj == 'soumission' || 'notification'
  def prepare_partenaires(obj)
    h2 "Partenaires hors Europe"
    if obj.size == 0    
      text "Aucun partenaire hors Europe", :size => 9
    else
      data = [["Nom","Etablissement gestionnaire","Ville","Pays"]]
      table(data,:cell_style=>{:borders=>[],:size => 8,:text_color =>@grey,:padding => [2, 5, 2, 5],:font_style => :bold},
                 :column_widths => [@table_cell4_width,@table_cell4_width,@table_cell4_width,@table_cell4_width])
 
      data = []
      obj.each_with_index { |e, i| 
        data <<  [e.nom,  e.etablissement_gestionnaire,  e.ville,  e.pays ]
      }
      table(data,:row_colors => [@table_shade1,@table_shade2],
                 :cell_style=>{:borders=>[],:size => 9,:padding => [2, 5, 2, 5]},
                 :column_widths => [@table_cell4_width,@table_cell4_width,@table_cell4_width,@table_cell4_width])

    end
  end
  
  def prepare_personnel_implique(obj, obj2)
    h1 "Personnel impliqué"
    if obj.size == 0   
      text "Aucun personnel impliqué", :size => 9
    else
      data = [["Nom","Prénom","Statut","Tutelle","%"]]
      table(data,:cell_style=>{:borders=>[],:size => 8,:text_color =>@grey,:padding => [2, 5, 2, 5],:font_style => :bold},
                 :column_widths => [@table_cell5_width,@table_cell5_width,@table_cell5_width,@table_cell5_width,@table_cell5_width])

      data = []
      obj.each_with_index { |e, i| 
        data <<  [e.nom,  e.prenom,  e.statut,  e.tutelle,  e.pourcentage]
      }
      table(data,:row_colors => [@table_shade1,@table_shade2],
                 :cell_style=>{:borders=>[],:size => 9,:padding => [2, 5, 2, 5]},
                 :column_widths => [@table_cell5_width,@table_cell5_width,@table_cell5_width,@table_cell5_width,@table_cell5_width])

    end
    move_down 10
    text "Equivalent temps plein : "+obj2.to_s
    
  end
  
  def prepare_soumission(soumission)
    h1 "Informations générales"  
    data = [
      ["Type de contrat",  soumission.contrat_type.nom],
      ["Date de dépot",  soumission.date_depot.strftime("%d/%m/%Y")],
      ["Nombre de mois",  soumission.nombre_mois],
      ["Etablissement gestionnaire", soumission.organisme_gestionnaire.nom],
      ["Organisme financeur",  soumission.organisme_financeur]
    ]
    classic_tab(data)
    
    prepare_porteur(soumission)
    prepare_key_words(soumission)
    h1 "Partenaires"
    prepare_partenaires_france(soumission.soumission_france_partenaires)
    prepare_partenaires_europe(soumission.soumission_europe_partenaires)
    prepare_partenaires(soumission.soumission_partenaires)

    h1 "Moyens demandés"
    data = [
      ["Les montants sont",  soumission.md_type_montant],
      ["Fonctionnement", soumission.md_fonctionnement.to_s+" EUR"],
      ["Equipement",  soumission.md_equipement.to_s+" EUR"],
      ["Salaire",  soumission.md_salaire.to_s+" EUR"],
      ["Mission",  soumission.md_mission.to_s+" EUR"],
      ["Non Ventilé",  soumission.md_non_ventile.to_s+" EUR"],
      ["Frais de gestion déductibles",  soumission.md_couts_indirects.to_s+" EUR"],
      ["Allocation",  soumission.md_allocation.to_s+" Mois"],
      ["Total", soumission.md_total.to_s+" EUR"],
      ["Taux de subvention",  soumission.taux_subvention],
      ["Total subvention",  soumission.total_subvention.to_s+" EUR"]
    ]
    classic_tab(data)
    
    prepare_personnel_implique(soumission.soumission_personnels, soumission.pd_equivalent_temps_plein)
    
    h1 "Personnel demandé"
    data = [
      ["Doctorant",  soumission.pd_doctorant.to_s+" hommes-mois"],
      ["Post-doc",  soumission.pd_post_doc.to_s+" hommes-mois"],
      ["Ingénieur",  soumission.pd_ingenieur.to_s+" hommes-mois"],
      ["Autre",  soumission.pd_autre.to_s+" hommes-mois"]     
    ]
    classic_tab(data)
    

    move_down 10
    text "Equivalent temps plein : "+soumission.equivalent_temps_plein_personnel.to_s  
  end
  
  def prepare_signature(signature)    
    data = [
      ["Date de la signature", signature.date.strftime("%d/%m/%Y")],
      ["Commentaire",  signature.commentaire]
    ]
    classic_tab(data)
  end
  
  def prepare_refu(refu)     
    data = [ ["Date de la signature",  refu.date.strftime("%d/%m/%Y")] ]
    if refu.liste_attente
      data <<  ["Est sur une liste d'attente ?",  "Oui"]
    else
      data <<  ["Est sur une liste d'attente ?",  "Non"]
    end
    if refu.labelise
      data <<  ["Est labellisé ?",  "Oui"]
    else
      data <<  ["Est labellisé ?",  "Non"]
    end
    data <<  ["Commentaire",  refu.commentaire]
    classic_tab(data)
  end
  
  def prepare_notification(notification)
    sous_contrats_size = notification.contrat.sous_contrats.size
    contrat = notification.contrat
    h1 "Informations générales"
    
    data = [
       ["Type de contrat",  notification.contrat_type.nom],
       ["Date de notification",  notification.date_notification.strftime("%d/%m/%Y")],
       ["Date de début",  notification.date_debut.strftime("%d/%m/%Y")],
       ["Date de fin",  notification.date_fin.strftime("%d/%m/%Y")],
       ["Nombre de mois",  notification.nombre_mois],
       ["Etablissement gestionnaire",  notification.organisme_gestionnaire.nom],
       ["Organisme financeur",  notification.organisme_financeur],
       ["Organisme payeur",  notification.organisme_payeur],
       ["N° de ligne budgétaire",  notification.numero_ligne_budgetaire],
       ["N° de contrat",  notification.numero_contrat]       
    ]
    if notification.a_justifier
      data <<  ["Le contrat est-il à justifier ?",  "Oui"]        
    else
      data <<  ["Le contrat est-il à justifier ?", "Non" ]       
    end
    classic_tab(data)

    prepare_porteur(notification)
    
    h1 "Site Web"   
    data = [
      ["URL",  notification.url]      
    ]
    classic_tab(data)

      
    prepare_key_words(notification)

    h1 "Partenaires"
    prepare_partenaires_france(notification.notification_france_partenaires)
    prepare_partenaires_europe(notification.notification_europe_partenaires)
    prepare_partenaires(notification.notification_partenaires)
    
    h1 "Moyens accordés"
    if sous_contrats_size > 1
      data = []    
      nb_infos_par_lignes = 3
      number_of_tables = ((1+sous_contrats_size).to_f/nb_infos_par_lignes).ceil
      first_current_sous_contrat_number_of_table = 0
      for current_table_number in 1..number_of_tables do
        data_line = []
        data_line << "" 
        number_of_sous_contrat_in_table = (sous_contrats_size) - (first_current_sous_contrat_number_of_table)
        if current_table_number == 1 and number_of_sous_contrat_in_table > (nb_infos_par_lignes-1) 
          number_of_sous_contrat_in_table = (nb_infos_par_lignes-1) 
        elsif number_of_sous_contrat_in_table > nb_infos_par_lignes
          number_of_sous_contrat_in_table = nb_infos_par_lignes
        end
        number_of_sous_contrat_in_table = number_of_sous_contrat_in_table -1
        if(current_table_number == 1)
          data_line << contrat.long_acronyme
        end
        for i in 0..number_of_sous_contrat_in_table do
          data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].entite.nom 
        end
        data << data_line
        data_line = []
        #Fonctionnement
        data_line << "Fonctionnement (EUR)"
        if(current_table_number == 1)
          data_line << notification.ma_fonctionnement
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.ma_fonctionnement
          end
        end
        data << data_line
        data_line = []
        #Equipement
        data_line << "Equipement (EUR)"
        if(current_table_number == 1)
          data_line << notification.ma_equipement
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.ma_equipement
          end
        end
        data << data_line
        data_line = []
        #Salaire
        data_line << "Salaire (EUR)"
        if(current_table_number == 1)
          data_line << notification.ma_salaire
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.ma_salaire
          end
        end
        data << data_line
        data_line = []
        #Mission
        data_line << "Mission (EUR)"
        if(current_table_number == 1)
          data_line << notification.ma_mission
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.ma_mission
          end
        end
        data << data_line
        data_line = []
        #Non ventilé
        data_line << "Non ventilé (EUR)"
        if(current_table_number == 1)
          data_line << notification.ma_non_ventile
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.ma_non_ventile
          end
        end
        data << data_line
        data_line = []
        #Frais de gestion déductibles
        data_line << "Frais de gestion déductibles (EUR)"
        if(current_table_number == 1)
          data_line << notification.ma_couts_indirects
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.ma_couts_indirects
          end
        end
        data << data_line
        data_line = []
        #Frais de gestion mutualisés locaux
        data_line << "Frais de gestion mutualisés locaux ou non justifiés (EUR)"
        if(current_table_number == 1)
          data_line << notification.ma_frais_gestion_mutualises_local
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.ma_frais_gestion_mutualises_local
          end
        end
        data << data_line
        data_line = []
        #Frais de gestion mutualisés nationaux
        data_line << "Frais de gestion mutualisés nationaux (EUR)"
        if(current_table_number == 1)
          data_line << notification.ma_frais_gestion_mutualises
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.ma_frais_gestion_mutualises
          end
        end
        data << data_line
        data_line = []
        #Allocation
        data_line << "Allocation (mois)"
        if(current_table_number == 1)
          data_line << notification.ma_allocation
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.ma_allocation
          end
        end
        #Total
        data << data_line
        data_line = []
        data_line << "Total (EUR)"
        if(current_table_number == 1)
          data_line << notification.ma_total
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.ma_total
          end
        end
        data << data_line
        if(current_table_number ==1)
          first_current_sous_contrat_number_of_table = first_current_sous_contrat_number_of_table +(nb_infos_par_lignes-1)
        else 
          first_current_sous_contrat_number_of_table = first_current_sous_contrat_number_of_table +nb_infos_par_lignes
        end 
        data << [" "]
    
      end   
      
      table(data,:row_colors => [@table_shade1,@table_shade2],
                 :cell_style=>{:borders=>[],:size => 9,:padding => [2, 5, 2, 5]},
                 :column_widths => [@table_cell4_width,@table_cell4_width,@table_cell4_width,@table_cell4_width])

     
    else  
      data = [
        ["Fonctionnement (EUR)",  notification.ma_fonctionnement],
        ["Equipement (EUR)",  notification.ma_equipement],
        ["Salaire (EUR)",  notification.ma_salaire],
        ["Mission (EUR)",  notification.ma_mission],
        ["Non ventilé (EUR)",  notification.ma_non_ventile],
        ["Frais de gestion déductibles (EUR)",  notification.ma_couts_indirects],
        ["Frais de gestion mutualisés locaux ou non justifiés (EUR)",  notification.ma_frais_gestion_mutualises_local],
        ["Frais de gestion mutualisés nationaux (EUR)",  notification.ma_frais_gestion_mutualises],
        ["Allocation (mois)",  notification.ma_allocation],
        ["Total (EUR)",  notification.ma_total]
      ]
      classic_tab(data)     
    end
    
    h1 "Personnel accordé"
    if notification.contrat.sous_contrats.size > 1
      data = []    
      nb_infos_par_lignes = 4
      number_of_tables = ((1+sous_contrats_size).to_f/nb_infos_par_lignes).ceil
      first_current_sous_contrat_number_of_table = 0
      for current_table_number in 1..number_of_tables do
        data_line = []
        data_line << "" 
        number_of_sous_contrat_in_table = (sous_contrats_size) - (first_current_sous_contrat_number_of_table)
        if current_table_number == 1 and number_of_sous_contrat_in_table > (nb_infos_par_lignes-1) 
          number_of_sous_contrat_in_table = (nb_infos_par_lignes-1) 
        elsif number_of_sous_contrat_in_table > nb_infos_par_lignes
          number_of_sous_contrat_in_table = nb_infos_par_lignes
        end
        number_of_sous_contrat_in_table = number_of_sous_contrat_in_table -1
        if(current_table_number == 1)
          data_line << contrat.long_acronyme
        end
        for i in 0..number_of_sous_contrat_in_table do
          data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].entite.nom 
        end
        data << data_line
        data_line = []
        #Doctorant 
        data_line << "Doctorant (hommes-mois)"
        if(current_table_number == 1)
          data_line << notification.pa_doctorant
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.pa_doctorant
          end
        end
        data << data_line
        data_line = []     
        #Post-doc 
        data_line << "Post-doc (hommes-mois)"
        if(current_table_number == 1)
          data_line << notification.pa_post_doc
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.pa_post_doc
          end
        end
        data << data_line
        data_line = []
        #Ingénieur
        data_line << "Ingénieur (hommes-mois)"
        if(current_table_number == 1)
          data_line << notification.pa_ingenieur
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.pa_ingenieur
          end
        end
        data << data_line
        data_line = [] 
        #Autre
        data_line << "Autre (hommes-mois)"
        if(current_table_number == 1)
          data_line << notification.pa_autre
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.pa_autre
          end
        end
        data << data_line
        data_line = []      
        #Equivalent temps plein
        data_line << "Equivalent temps plein"
        if(current_table_number == 1)
          data_line << notification.pa_equivalent_temps_plein
        end
        for i in 0..number_of_sous_contrat_in_table do
          if contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.nil?
            data_line << 0
          else
            data_line << contrat.sous_contrats[first_current_sous_contrat_number_of_table+i].sous_contrat_notification.pa_equivalent_temps_plein
          end
        end
        data << data_line
        if(current_table_number ==1)
          first_current_sous_contrat_number_of_table = first_current_sous_contrat_number_of_table +(nb_infos_par_lignes-1)
        else 
          first_current_sous_contrat_number_of_table = first_current_sous_contrat_number_of_table +nb_infos_par_lignes
        end 
        
        data << []
        data << [" "," ", " ", " ", " "]
      end  
      table(data,:row_colors => [@table_shade1,@table_shade2],
                 :cell_style=>{:borders=>[],:size => 9,:padding => [2, 5, 2, 5]},
                 :column_widths => [@table_cell5_width,@table_cell5_width,@table_cell5_width,@table_cell5_width,@table_cell5_width])
 
    else        
      data = [
        ["Doctorant",  notification.pa_doctorant.to_s+" hommes-mois"],
        ["Post-doc",  notification.pa_post_doc.to_s+" hommes-mois"],
        ["Ingénieur",  notification.pa_ingenieur.to_s+" hommes-mois"],
        ["Autre",  notification.pa_autre.to_s+" hommes-mois"]
      ]
      classic_tab(data)
      move_down 5
      text "Equivalent temps plein : "+notification.pa_equivalent_temps_plein.to_s
    end
    
    prepare_personnel_implique(notification.notification_personnels, notification.equivalent_temps_plein_personnel)   
  end
      
  def prepare_cloture(cloture)     
    data = [
      ["Date de fin des dépense",  cloture.date_fin_depenses.strftime("%d/%m/%Y")],
      ["Commentaire",  cloture.commentaires]
    ]
    classic_tab(data)
  end
    
  # Affiche un en-tete sur toutes les pages sauf la premiere
  def init_header(contrat,title='')
    
    repeat(:all,:dynamic => true) do
      if page_number != 1 or title != ''
        fill_color @black
        fill_rectangle [bounds.left,bounds.top + 70], (bounds.right-bounds.left),40
        fill_color @white
        draw_text title.to_s+contrat.acronyme, :size => 16, :at => [10,bounds.top+50]
        draw_text contrat.nom, :size => 10, :at => [10,bounds.top+38]
      end
    end 
  end
    
  
  def titre(title)
    fill_color @grey
    fill_rectangle [bounds.left,bounds.top + 30], (bounds.right-bounds.left),20
    fill_color @white
    draw_text title, :size => 14, :at => [10,bounds.top + 15]
    fill_color @black
    
  end
  
  # Affiche un pied de page sur toutes les pages
  def init_footer
    #Footer
    t = "Outil de Suivi des Contrats - "+"#{@request.protocol}#{@request.host_with_port}"+" - "
    date  = Time.now
    t += "PDF généré le "+date.strftime("%d/%m/%Y à %H:%M:%S")
    fill_color @grey 
    repeat(:all) do
      stroke_color @grey
      stroke_horizontal_line bounds.left,bounds.right, :at => bounds.bottom - 10
      bounding_box([bounds.left, bounds.bottom - 15], :width=> 400, :height => 20) do 
        text t, :size => 8
      end 
    end
    fill_color @black
    stroke_color @black
  end

  # Affiche le numero de page sur toutes les pages
  def add_page_number
    string = "<page> sur <total>"
    options = { :at => [bounds.right - 150, 0],
                :width => 150,
                :align => :right }
    number_pages string, options   
  end

end

