class AddViewsInfoweb < ActiveRecord::Migration
  def self.up
    execute "create view V_contrats_labo_publiables as
    select distinct l.nom as laboratoire,c.id,c.nom,c.acronyme,c.etat from contrats c, sous_contrats ss, laboratoires l
    where c.id = ss.contrat_id
      and ss.entite_type = 'Laboratoire' and ss.entite_id = l.id
      and c.publicite = true
      and (c.etat = 'notification' or c.etat='cloture')
    union
    select distinct l.nom as laboratoire,c.id,c.nom,c.acronyme,c.etat from contrats c, sous_contrats ss,projets p,
      laboratoire_subscriptions ls, laboratoires l
      where c.id = ss.contrat_id
        and ss.entite_type = 'Projet' and ss.entite_id = p.id
        and p.id = ls.projet_id and ls.laboratoire_id = l.id
        and c.publicite = true
        and (c.etat = 'notification' or c.etat='cloture')
    union
    select distinct l.nom as laboratoire,c.id,c.nom,c.acronyme,c.etat from contrats c, sous_contrats ss,projets p,
     departement_subscriptions ds, departements d, laboratoires l
    where c.id = ss.contrat_id
      and ss.entite_type = 'Projet' and ss.entite_id = p.id
      and p.id = ds.projet_id and ds.departement_id = d.id
      and d.laboratoire_id = l.id
      and c.publicite = true
      and (c.etat = 'notification' or c.etat='cloture')
    order by nom"
    execute "create view V_contrats_tutelle_publiables as
      select distinct t.nom as tutelle,c.id,c.nom,c.acronyme,c.etat from contrats c, sous_contrats ss,projets p,
        tutelle_subscriptions ts, tutelles t
      where c.id = ss.contrat_id
        and ss.entite_type = 'Projet' and ss.entite_id = p.id
        and p.id = ts.projet_id and ts.tutelle_id = t.id
        and (c.etat = 'notification' or c.etat='cloture')
        and c.publicite = true
      order by acronyme"
  end

  def self.down
    execute "drop view V_contrats_labo_publiables"
    execute "drop view V_contrats_tutelle_publiables"
  end
end
