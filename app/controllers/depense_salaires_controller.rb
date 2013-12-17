#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DepenseSalairesController < DepensesController
  include UIEnhancements::SubList
  helper :SubList

  sub_list 'DepenseSalaireFactures', 'depense_salaire' do |new_depense_salaire_facture|
  end

  before_filter :set_lignes_editables, :set_lignes_consultables
  before_filter :is_my_ligne_research_in_session?

  def search_people_from_ose
    osePeople = OseApi.new(OSE_URL, OSE_PORT, OSE_API_GET_DOSSIER_PATH, OSE_API_KEY)
    reponse = osePeople.find_by_nom params[:query]
    if !reponse['has_answers']
      reponse = osePeople.find_by_prenom params[:query]
      if !reponse['has_answers']
        reponse = osePeople.find_by_projet_service params[:query]
      end
    end
    @query           = params[:query]
    @query_type      = reponse['query_type']
    @response_status = reponse['status']
    @people = nil
    if @response_status == 'ok'
      @people = reponse['answers'] if reponse['has_answers']
    else
      @api_error_message = reponse['api_message']
    end

    respond_to do |format|
       format.js {
         render :partial => 'ose_results'
      }
    end
  end
  
  def search_people_from_gef
    @ligne = Ligne.find(params[:ligne][:id])
    @contratAgentsResult = ReferentielContratAgent.find(:all,:conditions=>["si_origine = ? and agent_si_id= ? and num_contrat_etab= ?","INRIA", params[:gef][:agent],@ligne.contrat.num_contrat_etab])
    @cout_mensuel = params[:cout_mensuel]
    if !(@cout_mensuel  =~ /^[-+]?[0-9]*\.?[0-9]+$/)
      @cout_mensuel=0
    end
    for contrat_agent in @contratAgentsResult
      agent = ReferentielAgent.find(:first,:conditions=>["si_origine = ? and si_id=?","INRIA",contrat_agent['agent_si_id']])
      contrat_agent['nom']=agent.nom
      contrat_agent['prenom']=agent.prenom
    end
    respond_to do |format|
       format.js {
         render :partial => 'gef_results'
      }
    end
  end

  def create_salaires_from_gef
    @ligne = Ligne.find(params[:ligne_id])
    contrat_agent=ReferentielContratAgent.find(params[:contrat_agent_id])
    #determination du nombre d'annees
    date_fin = contrat_agent.date_fin.to_date
    date_debut = contrat_agent.date_debut.to_date
    nb_salaires = date_fin.year - date_debut.year + 1
    add_notice = ""
    success = false
    exist = DepenseSalaire.find(:all,:conditions => ["ligne_id = ? and agent = ? and date_debut <= ? and date_fin >= ?",@ligne.id,contrat_agent.agent_si_id,date_fin,date_debut])
    if exist.size > 0
      add_notice = '<br/> <red>Attention : un salaire existe d&eacute;j&agrave; pour cet agent sur une partie de la p&eacute;riode !</red>'    
    end
    for i in 1..nb_salaires do
      annee_courrante = date_debut.year+i-1
      depense_salaire = DepenseSalaire.new
      depense_salaire.ligne_id=@ligne.id
      depense_salaire.statut = contrat_agent.statut
      depense_salaire.agent = contrat_agent.agent_si_id 
      depense_salaire.pourcentage = contrat_agent.pourcentage
      depense_salaire.agent_si_origine='INRIA'
      depense_salaire.type_contrat = 'CDD'
      depense_salaire.structure = contrat_agent.code_structure
      depense_salaire.cout_mensuel = params[:cout_mensuel]
       
      if i==1
        depense_salaire.date_debut = date_debut
      else
        depense_salaire.date_debut=(annee_courrante.to_s+"-01-01").to_date
      end
       
      if i == nb_salaires
        depense_salaire.date_fin = date_fin
      else
        depense_salaire.date_fin = (annee_courrante.to_s+"-12-31").to_date
      end
     
      depense_salaire.nb_mois = depense_salaire.compute_nb_mois
      depense_salaire.cout_periode = depense_salaire.nb_mois * depense_salaire.cout_mensuel
      
      exist = DepenseSalaire.find(:all,:conditions => ["agent = ? and date_debut = ? and date_fin = ? and ligne_id = ?",depense_salaire.agent,depense_salaire.date_debut,depense_salaire.date_fin,depense_salaire.ligne_id])
      if exist.size >0
        add_notice = '<br/> <red>Attention : un salaire existe d&eacute;j&agrave; pour cet agent sur une partie de la p&eacute;riode !</red>'    
      else
        success = true
        success &&= depense_salaire.save
    
        # Pour une mise a� jour correcte de date_min et date_max
        depense_salaire.update_dates_min_max
        depense_salaire.save  
      end  
    end   

    if success
      if(nb_salaires >1)
        flash[:notice] = ('Les depenses en salaire ont bien &eacute;t&eacute; cr&eacute;&eacute;es.'+add_notice).html_safe()   
      else
        flash[:notice] = ('La depense en salaire a bien &eacute;t&eacute; cr&eacute;&eacute;e.'+add_notice).html_safe()
      end
    elsif add_notice
      flash[:error] = ("La depense en salaire existe d&eacute;j&agrave;, rien n'a &eacute;t&eacute; cr&eacute;&eacute;!").html_safe()
    else
      flash[:error] = ('Un incident est survenu lors de la cr&eacute;ation des salaires').html_safe()
    end   
    redirect_to(ligne_depense_salaires_path(@ligne))
  end
  # GET /depense_salaires
  # GET /depense_salaires.xml
  def index
    setup_order_by :name => 'salaire', :default_field => 'date_debut', :default_direction => 'desc'
    setup_depenses_filter
    setup_items_per_page
    setup_depenses_dates_salaires
    setup_depenses_facture
    setup_type_montant(@ligne.contrat.come_from_inria?)

    depenses = @ligne.depense_salaires.all(:conditions => @filter_condition + @date_condition)
    @depense_salaires = sort_and_paginate_depenses(depenses)
    setup_depenses_totals(depenses, DepenseSalaire)

    @colspan_totals = 5 # override default
    respond_to do |format|
      format.html {
        if !@ligne.contrat.is_consultable? current_user
            flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'accéder à la ligne "+@ligne.nom+".").html_safe()
            redirect_to lignes_path
        end
      }
      format.js {
        render :partial => 'list.html.erb'
      }
      format.xml  { render :xml => @depense_salaires }
      format.csv { render :text => export_csv(depenses,'salaire') }
    end
  end

  # GET /depense_salaires/1
  # GET /depense_salaires/1.xml
  def show
    @ligne = Ligne.find(params[:ligne_id])
    @depense_salaire = DepenseSalaire.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @depense_salaire }
    end
  end

  def select_referentiel_agent
   
    @referentielAgentResult = ReferentielAgent.find(:all,:conditions=>["si_origine = ?","#{params[:depense_salaire_agent_si_origine]}"],:order => 'nom, prenom')
    @referentielAgentCollection= @referentielAgentResult.collect{ |p| [p.nom+" "+p.prenom+" ("+p.si_id+")", p.si_id ]}

    respond_to do |format|
      format.js { 
                  render :update do |page|
                     if params[:depense_salaire_agent_si_origine] != ''
                       page.replace_html 'referentiel_agent_filter', :partial=>'referentiel_agent_filter'
                       page.replace_html 'referentiel_agent_select', :partial=>'referentiel_agent_select'                       
                       page.replace_html 'agent_text_field', ""
                     else
                       page.replace_html 'referentiel_agent_filter', ""
                       page.replace_html 'referentiel_agent_select', ""
                       page.replace_html 'agent_text_field', :partial=>'agent_text_field'
                     end
                  end
                }
    end  
  end  
  
  def filter_referentiel_agent
    @referentielAgentResult = ReferentielAgent.find(:all,:conditions=>["si_origine = ? and nom like ?","#{params[:depense_salaire][:agent_si_origine]}","%#{params[:agent_filter]}%"],:order => 'nom, prenom')
    @referentielAgentCollection= @referentielAgentResult.collect{ |p| [p.nom+" "+p.prenom+" ("+p.si_id+")", p.si_id ]}
    respond_to do |format|
      format.js { 
                   render :update do |page|
                     if params[:depense_salaire_agent_si_origine] != ''
                       page.replace_html 'referentiel_agent_select', :partial=>'referentiel_agent_select'                       
                       page.replace_html 'agent_text_field', ""
                     else
                       page.replace_html 'referentiel_agent_select', ""
                       page.replace_html 'agent_text_field', :partial=>'agent_text_field'
                     end
                  end
                }
    end    
  end
  
  def gef_filter_referentiel_agent
    @ligne = Ligne.find(params[:ligne][:id])
    req = ["SELECT * FROM referentiel_agents ra
            INNER JOIN referentiel_contrat_agents rca on rca.agent_si_id = ra.si_id
            WHERE ra.si_origine='INRIA' AND rca.num_contrat_etab = ? 
            AND ra.nom like ? order by nom,prenom", @ligne.contrat.num_contrat_etab,"%#{params[:gef_agent_filter]}%"]
    @inriaReferentielAgentResult = ReferentielAgent.find_by_sql(req)
  
   # @inriaReferentielAgentResult = ReferentielAgent.find(:all,:conditions=>["si_origine = ? and nom like ?","INRIA","%#{params[:gef_agent_filter]}%"],:order => 'nom, prenom')
    @inriaReferentielAgentCollection= @inriaReferentielAgentResult.collect{ |p| [p.nom+" "+p.prenom+" ("+p.si_id+")", p.si_id ]}
    @inriaReferentielAgentCollection.uniq!
    respond_to do |format|
      format.js { 
                   render :update do |page|
                     page.replace_html 'gef_agent_select', :partial=>'gef_agent_select'
                  end
                }
    end   
  end
  
  # GET /depense_salaires/new
  # GET /depense_salaires/new.xml
  def new
    @ligne = Ligne.find(params[:ligne_id])
    @depense_salaire = DepenseSalaire.new
    @non_modifiables = @depense_salaire.get_non_modifiables
    
    req = ["SELECT * FROM referentiel_agents ra
            INNER JOIN referentiel_contrat_agents rca on rca.agent_si_id = ra.si_id
            WHERE ra.si_origine='INRIA' AND rca.num_contrat_etab = ? order by nom,prenom", @ligne.contrat.num_contrat_etab]
    @inriaReferentielAgentResult = ReferentielAgent.find_by_sql(req)
    
    if @inriaReferentielAgentResult.size > 0
      @inriaReferentielAgentCollection= @inriaReferentielAgentResult.collect{ |p| [p.nom+" "+p.prenom+" ("+p.si_id+")", p.si_id ]}  
      @inriaReferentielAgentCollection.uniq!
    end
    if @ligne.contrat.come_from_inria?
      @referentielAgentResult = ReferentielAgent.find(:all,:conditions=>["si_origine = 'INRIA'"],:order => 'nom, prenom')
      if @referentielAgentResult.size >0
        @referentiel_selected = true
        @referentielAgentCollection= @referentielAgentResult.collect{ |p| [p.nom+" "+p.prenom+" ("+p.si_id+")", p.si_id ]}  
        @depense_salaire.agent_si_origine='INRIA'
      end
    else
      @referentiel_selected = false
    end
    @selected_agent = ""
    
    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de salaire pour la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_salaires_path(@ligne)
    end
  end

  # GET /depense_salaires/1/edit
  def edit
    @ligne = Ligne.find(params[:ligne_id])
    @depense_salaire = DepenseSalaire.find(params[:id])
    @non_modifiables = @depense_salaire.get_non_modifiables
    @selected_agent = @depense_salaire.agent
    @referentiel_selected = false
    
    if @depense_salaire.agent_from_referentiel?
      @referentielAgentResult = ReferentielAgent.find(:all,:conditions=>["si_origine = ?",@depense_salaire.agent_si_origine],:order => 'nom, prenom')
      @referentiel_selected = true
      @referentielAgentCollection= @referentielAgentResult.collect{ |p| [p.nom+" "+p.prenom+" ("+p.si_id+")", p.si_id ]}  
    end
    
    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas d'éditer les salaires de la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_salaire_path(@ligne, @depense_salaire)
    end
  end

  # POST /depense_equipements/1/duplicate
  def duplicate
    @ligne = Ligne.find(params[:ligne_id])
    @depense_salaire = DepenseSalaire.find(params[:id])
    @new_depense_salaire = @depense_salaire.dup
    @new_depense_salaire.agent = "*"
    @new_depense_salaire.verrou = 'Aucun'
    @new_depense_salaire.verrou_listchamps = nil
    @new_depense_salaire.commande_solde= false
    @new_depense_salaire.verif = 0
    if !@ligne.contrat.is_budget_editable? current_user
      flash[:error] = ("Vos droits dans l'application ne vous permettent pas de créer de dépense en salaire sur la ligne "+@ligne.nom+".").html_safe()
      redirect_to ligne_depense_salaire_path(@ligne)
    end
    @new_depense_salaire.save
    flash[:notice] = ('La dépense a bien été dupliquée.').html_safe()
    respond_to do |format|
      format.html { redirect_to edit_ligne_depense_salaire_path(@ligne, @new_depense_salaire) }
    end
  end

  # POST /depense_salaires
  # POST /depense_salaires.xml
  def create
    params[:depense_salaire] = clean_date_params(params[:depense_salaire])
    @ligne = Ligne.find(params[:ligne_id])
    success = true

    req = ["SELECT * FROM referentiel_agents ra
            INNER JOIN referentiel_contrat_agents rca on rca.agent_si_id = ra.si_id
            WHERE ra.si_origine='INRIA' AND rca.num_contrat_etab = ? order by nom,prenom", @ligne.contrat.num_contrat_etab]
    @inriaReferentielAgentResult = ReferentielAgent.find_by_sql(req)
    
    if @inriaReferentielAgentResult.size > 0
      @inriaReferentielAgentCollection= @inriaReferentielAgentResult.collect{ |p| [p.nom+" "+p.prenom+" ("+p.si_id+")", p.si_id ]}  
      @inriaReferentielAgentCollection.uniq!
    end


    if params[:depense_salaire][:cout_periode].blank?
      params[:depense_salaire][:cout_periode] = params[:depense_salaire][:nb_mois].to_f * params[:depense_salaire][:cout_mensuel].to_f
    end
 
    @depense_salaire = DepenseSalaire.new(params[:depense_salaire])
    @depense_salaire.ligne = @ligne
    @non_modifiables = @depense_salaire.get_non_modifiables
         
    if (params[:depense_salaire][:agent_si_origine]) and (params[:depense_salaire][:agent_si_origine]!="")
      selected_agent_query = ReferentielAgent.find(:first,:conditions =>["si_id = ? and si_origine = ? ", params[:depense_salaire][:agent], params[:depense_salaire][:agent_si_origine]])    
      
      @referentielAgentResult = ReferentielAgent.find(:all,:conditions=>["si_origine = 'INRIA'"],:order => 'nom, prenom')
      if @referentielAgentResult.size >0
        @referentiel_selected = true
        @referentielAgentCollection= @referentielAgentResult.collect{ |p| [p.nom+" "+p.prenom+" ("+p.si_id+")", p.si_id ]}  
      end
      if !selected_agent_query
          flash[:error] = ("L'agent choisi n'existe pas dans le r&eacute;f&eacute;rentiel s&eacute;lectionn&eacute;").html_safe()
          success = false
          @depense_salaire.agent_si_origine=""
      end
    end
     
    if success
      success &&= initialize_depense_salaire_factures
      success &&= @depense_salaire.save
    
      # Pour une mise à jour correcte de date_min et date_max
      @depense_salaire.update_dates_min_max
      #calcul automatique du nb de mois ?
      if params[:depense_salaire][:nb_mois].blank?
        @depense_salaire.nb_mois = @depense_salaire.compute_nb_mois
      end
      if params[:depense_salaire][:cout_periode].blank?
        @depense_salaire.cout_periode = @depense_salaire.nb_mois.to_f * @depense_salaire.cout_mensuel.to_f
      end
      @depense_salaire.save
    end
    
    respond_to do |format|
      if success
        flash[:notice] = ('La feuille de salaire a bien été créée.').html_safe()
        format.html { redirect_to ligne_depense_salaire_path(@ligne, @depense_salaire) }
      else
        prepare_depense_salaire_factures
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /depense_salaires/1
  # PUT /depense_salaires/1.xml
  def update
    params[:depense_salaire] = clean_date_params(params[:depense_salaire])
    @ligne = Ligne.find(params[:ligne_id])
    @depense_salaire = DepenseSalaire.find(params[:id])
    @non_modifiables = @depense_salaire.get_non_modifiables
    
    success = true
       
    if (params[:depense_salaire][:agent_si_origine]) and (params[:depense_salaire][:agent_si_origine]!="")
      selected_agent_query = ReferentielAgent.find(:first,:conditions =>["si_id = ? and si_origine = ? ", params[:depense_salaire][:agent], params[:depense_salaire][:agent_si_origine]])    
      if !selected_agent_query
          flash[:error] = ("L'agent choisi n'existe pas dans le r&eacute;f&eacute;rentiel s&eacute;lectionn&eacute;").html_safe()
          success = false
          @depense_salaire.agent_si_origine=""
      end
    end
    
    if success
      @depense_salaire.update_attributes(params[:depense_salaire])
    
      success &&= initialize_depense_salaire_factures
      success &&= @depense_salaire.save
      
    end
    
    @selected_agent = @depense_salaire.nom_agent
    @referentiel_selected = false
    
    if @depense_salaire.agent_from_referentiel?
      @referentielAgentResult = ReferentielAgent.find(:all,:conditions=>["si_origine = ?",@depense_salaire.agent_si_origine],:order => 'nom, prenom')
      @referentiel_selected = true
      @referentielAgentCollection= @referentielAgentResult.collect{ |p| [p.prenom+" "+p.nom+" ("+p.si_id+")", p.si_id ]}  
    end
    
    respond_to do |format|
      @ligne =  @depense_salaire.ligne
      
      if success
        # Pour une mise à jour correcte de date_min et date_max
        @depense_salaire.update_dates_min_max
        if (params[:ajuster_montant])
          @depense_salaire.cout_periode = @depense_salaire.montant_factures('ttc')
        end
        #calcul automatique du nb de mois ?
        if params[:depense_salaire][:nb_mois].blank?
          @depense_salaire.nb_mois = @depense_salaire.compute_nb_mois
        end
        if params[:depense_salaire][:cout_periode].blank?
          @depense_salaire.cout_periode = @depense_salaire.nb_mois.to_f * @depense_salaire.cout_mensuel.to_f
        end
        @depense_salaire.verif = false
        @depense_salaire.save
        unless !flash[:error].blank?
          flash[:notice] = ('La feuille de salaire a bien &eacute;t&eacute; mise à jour.').html_safe()
          @depense_salaire.depense_salaire_factures.each {|paye|
            if !paye.date_mandatement.nil? && paye.date_mandatement > @ligne.date_fin
              flash[:error] = ("La feuille de salaire a bien &eacute;t&eacute; mise à jour, mais <span>ATTENTION,</span> une date de paye est > à la date de fin du contrat.").html_safe()
              break
            end
          }
        end
        format.html { redirect_to ligne_depense_salaire_path(@ligne, @depense_salaire) }
      else
        prepare_depense_salaire_factures
        format.html { render :action => "edit" }
      end
    end
  end

  def build_migration_form
    @depense_salaire = DepenseSalaire.find(params[:id])
    dotation_contrat_type_ids = ContratType.find_all_dotation_type_id
    req = "Select lignes.id,lignes.nom from lignes 
                         inner join sous_contrats on sous_contrats.id = lignes.sous_contrat_id
                         inner join contrats on contrats.id = sous_contrats.contrat_id
                         inner join notifications on notifications.contrat_id = contrats.id
                         where notifications.contrat_type_id not IN (?) and lignes.id IN (?) ORDER BY nom" 
    @available_lignes = Ligne.find_by_sql([req,dotation_contrat_type_ids, @ids_lignes_editables]).collect { |p| [ p.nom, p.id ] }
    respond_to do |format|
      format.js {
        render :partial => "migration_form"
      }
    end
  end

  def ask_delete
    @ligne = Ligne.find(params[:ligne_id])
    @depense_salaire = DepenseSalaire.find(params[:id])
    respond_to do |format|
      format.html
    end
  end


  # DELETE /depense_salaires/1
  # DELETE /depense_salaires/1.xml
  def destroy
    @ligne = Ligne.find(params[:ligne_id])
    @depense_salaire = DepenseSalaire.find(params[:id])
    @depense_salaire.destroy

    respond_to do |format|
      format.html { redirect_to(ligne_depense_salaires_path(@ligne)) }
      format.xml  { head :ok }
    end
  end

end
