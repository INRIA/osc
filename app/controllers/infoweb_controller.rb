#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class InfowebController < ApplicationController
  skip_before_filter :login_required

  before_filter :authorize

  def projets
    text = controlParams
    unless text == "OK"
      headers["Status"]           = "Bad Request"
      render :text => text, :status => '400 Bad Request'
    else
       if !params[:tutelle].nil? 
           @projets = Projet.find_by_sql(["select trim(substring_index(p.nom,': 07RECH',1)) as nom from projets p, tutelles t, tutelle_subscriptions ts
           where p.id = ts.projet_id and  ts.tutelle_id = t.id and t.nom = ? order by p.nom",params[:tutelle].upcase])
       elsif !params[:laboratoire].nil? 
          @projets = Projet.find_by_sql(["select trim(substring_index(p.nom,': 07RECH',1)) as nom from projets p, laboratoires l, laboratoire_subscriptions ls
            where p.id = ls.projet_id and  ls.laboratoire_id = l.id and l.nom = ?
            union select p.nom as nom from projets p, departement_subscriptions ds, departements d, laboratoires l
            where (p.id = ds.projet_id and ds.departement_id=d.id and d.laboratoire_id = l.id and l.nom = ?)
            order by nom", params[:laboratoire].upcase,params[:laboratoire].upcase])
      end
      render :xml => @projets.to_xml
    end
  end
  
  def contrats
   text = controlParams
    unless text == "OK"
      headers["Status"]           = "Bad Request"
      render :text => text, :status => '400 Bad Request'
    else
      # selection sur les paramètres tutelle et laboratoire
       if !params[:tutelle].nil? 
         contrats = Contrat.find_by_sql(["select v.id, v.nom,v.acronyme,v.etat,n.date_debut,n.date_fin,n.url,n.porteur,o.nom as tutelle
            from V_contrats_tutelle_publiables v, notifications n, organisme_gestionnaires o
            where v.tutelle = ? and v.id = n.contrat_id and n.organisme_gestionnaire_id = o.id order by v.nom",params[:tutelle].upcase])
       elsif !params[:laboratoire].nil? 
         contrats = Contrat.find_by_sql(["select v.id, v.nom,v.acronyme,v.etat,n.date_debut,n.date_fin,n.url,n.porteur,o.nom as tutelle
            from V_contrats_labo_publiables v, notifications n, organisme_gestionnaires o
            where v.laboratoire = ? and v.id = n.contrat_id and n.organisme_gestionnaire_id = o.id order by v.nom",params[:laboratoire].upcase])
      end
      @contrats = []
      contrats.each {|cont|
        co = cont.attributes()
        # recherche du type de contrat (arbre complet)
        co["type"] = cont.notification.contrat_type.nom_complet
        # Recherche des descriptifs
        co["descriptifs"] = Descriptif.find(:all, :select => "descriptif,langue_id", :conditions=> ["contrat_id = ?",cont.id])
        # recherche des partenaires
        co["partenaires_europe"] = NotificationEuropePartenaire.find(:all,
          :select => "nom,etablissement_gestionnaire,ville,pays", :conditions => ["notification_id = ?",cont.notification.id])
        co["partenaires_france"] = NotificationFrancePartenaire.find(:all,
           :select => "nom,concat(concat(laboratoire,' '),etablissement_gestionnaire) as etablissement_gestionnaire,ville,pays", :conditions => ["notification_id = ?",cont.notification.id])
        co["partenaires_autre"] = NotificationPartenaire.find(:all,
           :select => "nom,etablissement_gestionnaire,ville,pays", :conditions => ["notification_id = ?",cont.notification.id])
        # Recherche des projets associés
        co["projets"]=[]
       unless params[:laboratoire].nil?
        projets1 = Projet.find(:all,
          :select => "trim(substring_index(projets.nom,': 07RECH',1)) as nom",
          :joins => [:sous_contrats, :laboratoires],
          :conditions => ["sous_contrats.contrat_id = ? and laboratoires.nom = ?",cont.id,params[:laboratoire]])
        projets2 = Projet.find(:all,
          :select => "trim(substring_index(projets.nom,': 07RECH',1)) as nom",
          :joins => [:sous_contrats, :departements, :laboratoires],
          :conditions => ["sous_contrats.contrat_id = ? and laboratoires.nom = ?",cont.id,params[:laboratoire]])
        projets1.each {|pp|
          projet = Hash.new
          projet["nom"] = pp.nom
          co["projets"] << projet
        }
        projets2.each {|pp|
          co["projets"].each {|po|
            if po["nom"] == pp.nom
              loop
            end
          }
          projet = Hash.new
          projet["nom"] = pp.nom
          co["projets"] << projet
        }
       else
        projets = Projet.find(:all,
          :select => "trim(substring_index(projets.nom,': 07RECH',1)) as nom",
          :joins => [:sous_contrats, :tutelles],
          :conditions => ["sous_contrats.contrat_id = ? and tutelles.nom = ?",cont.id,params[:tutelle]])
        projets.each {|pp|
          projet = Hash.new
          projet["nom"] = pp.nom
          co["projets"] << projet
        }
       end
         @contrats << co
      }
      render :xml => @contrats.to_xml
    end
end

def descriptifs
    text = controlParams
    unless text == "OK"
      headers["Status"]           = "Bad Request"
      render :text => text, :status => '400 Bad Request'
    else
      if !params[:tutelle].nil? 
        @descriptifs = Contrat.find_by_sql(["select v.id, d.langue_id,d.descriptif from V_contrats_tutelle_publiables v, descriptifs d
        where v.id = d.contrat_id and v.tutelle=?",params[:tutelle].upcase])
      elsif !params[:laboratoire].nil? 
        @descriptifs = Contrat.find_by_sql(["select v.id, d.langue_id,d.descriptif from V_contrats_labo_publiables v, descriptifs d
        where v.id = d.contrat_id and v.laboratoire=?",params[:laboratoire].upcase])
      end
      render :xml => @descriptifs.to_xml
    end
end

def partenaires
    text = controlParams
    unless text == "OK"
      headers["Status"]           = "Bad Request"
      render :text => text, :status => '400 Bad Request'
    else
      if !params[:tutelle].nil? 
       @partenaires = Contrat.find_by_sql(["select v.id as id_contrat, 'A' as type_partenaire, nt.nom as nom,nt.etablissement_gestionnaire,nt.ville,nt.pays,nt.localisation
              from V_contrats_tutelle_publiables v, notifications n, notification_partenaires nt
              where v.tutelle=? and v.id = n.contrat_id and n.id = nt.notification_id
            union
            select v.id as id_contrat, 'E' as type_partenaire, nt.nom as nom,nt.etablissement_gestionnaire,nt.ville,nt.pays,nt.localisation
              from V_contrats_tutelle_publiables v, notifications n, notification_europe_partenaires nt
              where v.tutelle=? and v.id = n.contrat_id and n.id = nt.notification_id
           union
            select v.id as id_contrat, 'F' as type_partenaire, nt.nom as nom,concat(concat(nt.laboratoire,' '),nt.etablissement_gestionnaire) as etablissement_gestionnaire,nt.ville,nt.pays,nt.localisation
            from V_contrats_tutelle_publiables v, notifications n, notification_france_partenaires nt
            where v.tutelle=? and v.id = n.contrat_id and n.id = nt.notification_id
          order by id_contrat,type_partenaire",params[:tutelle].upcase,params[:tutelle].upcase,params[:tutelle].upcase])
      elsif !params[:laboratoire].nil?
        @partenaires = Contrat.find_by_sql(["select v.id as id_contrat, 'A' as type_partenaire, nt.nom as nom, nt.etablissement_gestionnaire,nt.ville,nt.pays,nt.localisation
              from V_contrats_labo_publiables v, notifications n, notification_partenaires nt
              where v.laboratoire=? and v.id = n.contrat_id and n.id = nt.notification_id
            union
            select v.id as id_contrat, 'E' as type_partenaire, nt.nom as nom,nt.etablissement_gestionnaire,nt.ville,nt.pays,nt.localisation
              from V_contrats_labo_publiables v, notifications n, notification_europe_partenaires nt
              where v.laboratoire=? and v.id = n.contrat_id and n.id = nt.notification_id
           union 
            select v.id as id_contrat, 'F' as type_partenaire, nt.nom as nom,concat(concat(nt.laboratoire,' '),nt.etablissement_gestionnaire) as etablissement_gestionnaire,nt.ville,nt.pays,nt.localisation
            from V_contrats_labo_publiables v, notifications n, notification_france_partenaires nt
            where v.laboratoire=? and v.id = n.contrat_id and n.id = nt.notification_id
          order by id_contrat,type_partenaire",params[:laboratoire].upcase,params[:laboratoire].upcase,params[:laboratoire].upcase])
      end
      render :xml => @partenaires.to_xml
    end
end

def contrat_types_tree
    text = controlParams
    unless text == "OK"
      headers["Status"]           = "Bad Request"
      render :text => text, :status => '400 Bad Request'
    else
      @contrat_types_tree = Contrat.find_by_sql("select id,parent_id,nom from contrat_types where id != #{ID_CONTRAT_DOTATION}")
      render :xml => @contrat_types_tree.to_xml
    end
end

def contrats_projets
  text = controlParams
    unless text == "OK"
      headers["Status"]           = "Bad Request"
      render :text => text, :status => '400 Bad Request'
    else
       if !params[:tutelle].nil?
          @contrats_projets = Contrat.find_by_sql(["select v.id as id_contrat, p.nom
          from V_contrats_tutelle_publiables v, sous_contrats ss, projets p
          where v.tutelle=? and v.id = ss.contrat_id and ss.entite_type='Projet'
            and ss.entite_id = p.id
          order by id_contrat,p.nom",params[:tutelle].upcase])
       elsif !params[:laboratoire].nil?
          @contrats_projets = Contrat.find_by_sql(["select v.id as id_contrat, p.nom
          from V_contrats_labo_publiables v, sous_contrats ss, projets p
          where v.laboratoire=? and v.id = ss.contrat_id and ss.entite_type='Projet'
            and ss.entite_id = p.id
          order by id_contrat,p.nom",params[:laboratoire].upcase])
       end
      render :xml => @contrats_projets.to_xml
    end
end

def lignes
	# Extraction des lignes associées aux contrats (id, nom de la ligne, projet associé)
  text = controlParams
    unless text == "OK"
      headers["Status"]           = "Bad Request"
      render :text => text, :status => '400 Bad Request'
    else
       if !params[:tutelle].nil?
				text = "Nous sommes désolés, l'extraction pour une tutelle n'est actuellement pas implémentée."
				headers["Status"]           = "Bad Request"
				render :text => text, :status => '400 Bad Request'

       elsif !params[:laboratoire].nil?
				 nom_labo = params[:laboratoire].upcase
				 @lignes = Ligne.find_by_sql(["SELECT l.id, l.nom, trim(substring_index(p.nom,': 07RECH',1)) as 'projet', cl.date_fin_depenses as 'datc',
            n.numero_ligne_budgetaire as eotp, n.etablissement_gestionnaire as financeur
						FROM lignes l, sous_contrats ss, projets p, contrats c left outer join clotures cl on c.id = cl.contrat_id, notifications n 
						WHERE l.sous_contrat_id  = ss.id
							AND ss.contrat_id = c.id
              AND c.verrou = 'Aucun'
              AND c.id = n.contrat_id
							AND ss.entite_type = 'Projet'
							AND ss.entite_id = p.id
							AND ss.entite_id IN ( SELECT projet_id from laboratoire_subscriptions lb, laboratoires b
																		where lb.laboratoire_id = b.id AND b.nom=?)
						UNION
						SELECT l.id, l.nom, trim(substring_index(p.nom,': 07RECH',1)) as 'projet', cl.date_fin_depenses as 'datc',
            n.numero_ligne_budgetaire as eotp, n.etablissement_gestionnaire as financeur
						FROM lignes l, sous_contrats ss, projets p, contrats c left outer join clotures cl on c.id = cl.contrat_id, notifications n 
						WHERE l.sous_contrat_id  = ss.id
							AND ss.contrat_id = c.id
              AND c.verrou = 'Aucun'
              AND c.id = n.contrat_id
							AND ss.entite_type = 'Projet'
							AND ss.entite_id = p.id
							AND ss.entite_id IN (SELECT projet_id FROM departement_subscriptions ds, departements d, laboratoires b
									WHERE ds.departement_id = d.id and d.laboratoire_id = b.id and b.nom = ?)
						UNION
						SELECT l.id, l.nom, trim(substring_index(d.nom,': 07RECH',1)) as 'projet', cl.date_fin_depenses as 'datc',
            n.numero_ligne_budgetaire as eotp, n.etablissement_gestionnaire as financeur
						FROM lignes l, sous_contrats ss, contrats c left outer join clotures cl on c.id = cl.contrat_id , departements d, laboratoires b, notifications n 
						WHERE l.sous_contrat_id  = ss.id
							AND ss.contrat_id = c.id
              AND c.verrou = 'Aucun'
              AND c.id = n.contrat_id
              AND ss.entite_type = 'Departement'
							AND ss.entite_id = d.id
							AND d.laboratoire_id = b.id
							AND b.nom=?
						UNION
						SELECT l.id, l.nom, '#{nom_labo}' as 'projet', cl.date_fin_depenses as 'datc', 
            n.numero_ligne_budgetaire as eotp, n.etablissement_gestionnaire as financeur
						FROM lignes l, sous_contrats ss, projets p, contrats c left outer join clotures cl on c.id = cl.contrat_id , laboratoires b, notifications n 
						WHERE l.sous_contrat_id  = ss.id
							AND ss.contrat_id = c.id
              AND c.verrou = 'Aucun'
              AND c.id = n.contrat_id
							AND ss.entite_type = 'Laboratoire'
							AND ss.entite_id = b.id AND b.nom=?;",nom_labo,nom_labo,nom_labo,nom_labo])

				render :xml => @lignes.to_xml
			 end
		end
end

  private
  def authorize
    params[:api_key] == API_KEY ? true : access_non_authorise
  end

  def access_non_authorise
    headers["Status"]           = "Unauthorized"
    headers["WWW-Authenticate"] = %(Basic realm="Web Password")
    render :text => "Could't authenticate you", :status => '401 Unauthorized'
  end

  def controlParams
    text = "OK"
    if params[:laboratoire].nil? && params[:tutelle].nil?
        #repond paramètres obligatoires
        text = "Au moins un paramètre tutelle et/ou laboratoire est obligatoire"
    else
      if !params[:tutelle].nil?
         if !Tutelle.exist?(params[:tutelle])
            # repond tutelle inconnue
            text = "Le paramètre tutelle est inconnu."
         end
      end
      if !params[:laboratoire].nil?
         if !Laboratoire.exist?(params[:laboratoire])
            # repond laboratoire inconnu
            if text == "OK"
              text = "Le paramètre laboratoire est inconnu"
            else
               text += " Le paramètre laboratoire est inconnu"
            end
         end
      end
    end
    return text
  end
end
