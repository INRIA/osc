function toggle_css_bis(id,style_name){
  var lien_css = document.getElementById("style_bis_css");
  var lien_favicon = document.getElementById("favicon")

  
  if(!lien_css){
    lien_css = document.createElement('link');
    lien_css.href = "/assets/"+style_name+".css";
    lien_css.rel = "stylesheet";
    lien_css.id ="style_bis_css";
    lien_css.type = "text/css";
  }
  if(document.getElementById(id).checked){      
    document.getElementsByTagName("head")[0].appendChild(lien_css);
    lien_favicon.href = "/assets/Inria/favicon.ico";
    setCookie("style",style_name,365)
  }else{
    document.getElementsByTagName("head")[0].removeChild(lien_css);
    lien_favicon.href="/favicon.ico";
    setCookie("style",style_name,-1)
  }
}

function setCookie(c_name,value,exdays)
{
  var exdate=new Date();
  exdate.setDate(exdate.getDate() + exdays);
  var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString())+"; path=/";
  document.cookie=c_name + "=" + c_value;
}

function showIndicator(){
	$('indicator').style.display='';
}
function hideIndicator(){
	$('indicator').style.display='none';
}

Ajax.Responders.register({
	onCreate:function(){
		if($('indicator') && Ajax.activeRequestCount>0)
		showIndicator();
	},
	onComplete:function(){
		if($('indicator'))
		hideIndicator();
	}
});

function notice(){
	$('notice').show().setOpacity(0);
	new Effect.Opacity('notice',{duration:0.25, from: 0, to: .95});
	setTimeout(function() {
	    fadeInfobox('notice');
	}, 4000);
}

function error()
{
	$('error').show().setOpacity(0);;
	new Effect.Opacity('error',{duration:0.25, from: 0, to: .97});
	setTimeout(function() {
      fadeInfobox('error');
  }, 4000);
}

function fadeInfobox(id) {
  new Effect.Opacity(id,{
      duration:0.25,
      from: .95,
      to: 0,
      afterFinish: function(){ $(id).hide(); }});
}


function to_ieme(i){
	if (i == 1){
		return i+"<sup>ère</sup>"
	}else{
		return i+"<sup>ème</sup>"
	}
}
function update_paye_legende(){
	i = 0;
	txt_to_add = "";
	$$('#left h3.paye-title').each(function(e){
		i++;
		e.update(to_ieme(i)+" Paye");
	})
}
function update_aide_navigation_paye(){
	i = 0;
	txt_to_add = "";
	$$('#left h3.paye-title').each(function(e){
		i++;
		txt_to_add += "<li>\n";
		txt_to_add += "  <a href='#depense_salaire_facture_" + e.id.gsub('paye_','') + "'>\n";
		txt_to_add +=    to_ieme(i) + " Paye\n";
		txt_to_add += "	 </a>\n";
		txt_to_add += "</li>\n";
	})
	$('link_to_replace').update(txt_to_add);
}


/**
 *  App
 *  Espace de nom réservé au code de l'application
**/
var App = {};


/**
 *  class App.NavigatorHelper
 *  Classe dédiée à la mise en place d'une aide à la
 * navigation vertical dans une page
**/
App.NavigatorHelper = Class.create({
	/**
	 *  new App.NavigatorHelper()
	**/
	initialize: function()
	{
		$('navigation').observe('click', this.goTo.bindAsEventListener(this));
	},

	goTo: function(event)
	{
		event.stop();
		if (Object.isElement(event.findElement('a'))){
			var anchor = event.findElement('a').href.split('#')[1];
			new Effect.ScrollTo(anchor, {duration:.25});
		}
	}
});

/**
 *  class App.GroupsAndRolesDisplay
 *  Classe dédiée à l'interface d'affichage des groupes
 *  Sur les pages contrat#show et ligne#show
**/
App.GroupsAndRolesDisplay = Class.create({
	initialize: function() {
		$$('#right .toggle-group-members').each(function(l){
			l.observe('click', this._toggle.bindAsEventListener(this))
		}.bind(this))
	},

	_toggle: function(event){
		event.stop();
		var link = event.findElement('a');
		if (link.hasClassName('open')) {
			link.removeClassName('open').update('+');
		} else {
			link.addClassName('open').update('-');
		}
		link.up('div').next('ul').toggle();
	}
});

/**
 *  class App.ContratTreeDisplay
 *  Classe dédiée à l'affichage de la structure 2quipe/departement/labo
 *  dans la section de suivi des contrats
**/
App.ContratTreeDisplay = Class.create({
	initialize: function() {
		$$('#right .toggle-tree').first().observe('click', this._toggle.bindAsEventListener(this));
	},

	_toggle: function(event){
		event.stop();
		var link = event.findElement('a');
		if (link.hasClassName('open')) {
			link.removeClassName('open').update('+');
		} else {
			link.addClassName('open').update('-');
		}
		$$("#right .hierarchie .not_in_contrat").each(function(e){
			e.toggle();
		});
	}
});

/**
 *  class App.Echeancier
 *  Classe dédiée à l'interface de gestion des écheanciers.
 *
**/
App.Echeancier = Class.create({
	/**
	 *  new App.Echeancier(maxPeriodsCount)
	 *  - maxPeriodsCount (integer) : Nombre maximal de période authorisées
	 *
	 *	Mise en place du formulaire de gestion des écheanciers.
	**/
	initialize: function(maxPeriodsCount) {
		this.maxPeriodsCount = maxPeriodsCount;
		this.addLink = false;
		if ($$('a.sub_list_add').size() == 1) {
			this.addLink = $$('a.sub_list_add').first();
			// Ajout du listener sur le lien d'ajout d'une période
			this.addLink.observe('click', this._add.bindAsEventListener(this));
		}
		this.updateAddLink();
		this.updateLegends();
	},

	/**
	 *  App.Echeancier#updateAddLink -> undefined
	 *
	 *  Affichage ou non du lien permettant d'ajouter une
	 *  nouvelle période.
	**/
	updateAddLink: function()
	{
		if (this.addLink != false) {
			if ($$('.periode').size() >= this.maxPeriodsCount) {
				this.addLink.hide();
			} else {
				this.addLink.show();
			}
		}
	},

	/**
	 *  App.Echeancier#updateLegends -> undefined
	 *
	 *  Affichage de la legende toute les 2 périodes
	 *  et mise à jour dynamique du numéro de période.
	**/
	updateLegends: function(){
		i = 0;
		$$('.periode').each(function(e){
			i++;
			
			$(e.id+"_txt").update("Période "+i);
		})
		$('echeancier-slider').style.width=(i*190)+'px';
	},

	// Ajout d'une période via un appel Ajax
	_add: function(event){
		event.stop();
		this.addLink.hide();
		var link = event.findElement('a');

		new Ajax.Updater('echeancier_periodes', link.href,{
		  
			asynchronous:true,
			evalScripts:true,
			insertion:Insertion.Bottom,
			onComplete:function(){
				this.updateLegends();
				this.updateAddLink();
			}.bind(this)
		});
	}
});

/**
 *  App.Budget
 *  Espace de nom réservé au code de l'application
 *  de la section de suivi budgetaire
**/
App.Budget = {};

/**
 *  class App.Budget.ToggleJustificationData
 *  Classe dédiée à la mise en place d'un lien permettant d'afficher/masquer
 *  les données de justifactions
**/
App.Budget.ToggleJustificationData = Class.create({
	/**
	 *  new App.Budget.ToggleJustificationData()
	**/
	initialize: function()
	{
		$('toggle-justification').observe('click', this._update.bindAsEventListener(this));
	},

	_update: function(event){
		event.stop();
		Effect.toggle('justification-data', 'slide', {
			duration: .2,
			afterFinish : function(){
				if ($('justification-data').getStyle('display') == "none"){
					$('toggle-justification').update("Afficher les données de justification")
				} else {
					$('toggle-justification').update("Masquer les données de justification")
				}
				new Ajax.Request('/lignes/toggle_show_justification_data_preferences');
			}
		});
	}
});


/**
 *  class App.Budget.LigneMigration
 *  Classe dédiée à la mise en place de la fonctionnalité de modification de la
 *  ligne associées à une dépense ou un crédit
**/
App.Budget.LigneMigration = Class.create({
	/**
	 *  new App.Budget.LigneMigration()
	**/
	initialize: function()
	{
		this.link_id           = "build-migration-form-link";
		this.link_container_id = "build-migration-form-link-container";
		this.form_container_id = "migration-form";
		this.loading_message   = "Chargement en cours ...";
		this.updateRunning = false;

		$(this.link_id).observe('click', this.build.bindAsEventListener(this));
	},

	build: function(event){
		event.stop();
		link = event.findElement('a');
		if (this.updateRunning == false) {
			new Ajax.Updater(this.form_container_id, link.href, {
				method:'get',
				onCreate: function(){
					this.updateRunning = true;
					$(this.link_id).update(this.loading_message);
				}.bind(this),
				onComplete:function(){
					$(this.link_container_id).hide();
					$(this.form_container_id).show();
					this.updateRunning = false;
				}.bind(this)
			});
		}
	}
});


/**
 *  class App.Budget.ListView
 *  Classe dédiée à la mise en place des index des dépenses et versements.
**/
App.Budget.ListView = Class.create({
	/**
	 *  new App.Budget.ListView()
	 *
	 *	Mise en place non obstrusive des fonctionnalités de tris, filtrage,
	 *  affichage ou non des factures via des appels Ajax.
	**/
	initialize: function()
	{
		this.updateRunning = false;  // Utilisé pour éviter un double appel ajax lors de double clic
		this.currentLink   = false;  // Utilisé pour sauvegarder le lien cliqué dans les functions toggle et sortBy

		this.filter_links = $$('#affichage a.filter');
		this.toggle_links = $$('#affichage a.toggle');

		this.filter_links.each(function(link){
			link.observe('click', this.filter.bindAsEventListener(this));
		}.bind(this));

		this.toggle_links.each(function(link){
			link.observe('click', this.toggle.bindAsEventListener(this));
		}.bind(this));


		$('to-update').observe('click', this.sortBy.bindAsEventListener(this));
		$('to-update').observe('click', this.chooseTypeMontant.bindAsEventListener(this));
	},

	filter: function(event)
	{
		event.stop()
		var link = event.findElement('a');
		if (!link.hasClassName('selected')) {
			this.filter_links.invoke('removeClassName', 'selected');
			link.addClassName('selected');
			new Ajax.Updater('to-update', link.href, { method:'get'});
		}
	},

	toggle: function(event)
	{
		event.stop()
		this.currentLink = event.findElement('a');
		if (this.updateRunning == false) {
			new Ajax.Updater('to-update', this.currentLink.href, {
				method:'get',
				onCreate: function(){
					this.updateRunning = true;
				}.bind(this),
				onComplete:function(){
					this.currentLink.toggleClassName('selected');
					this.updateRunning = false;
				}.bind(this)
			});
		}
	},

	sortBy: function(event)
	{
		if (Object.isElement(event.findElement('a'))) {
			this.currentLink = event.findElement('a');
			if (this.currentLink.hasClassName('order-by')) {
				if (this.updateRunning == false) {
					new Ajax.Updater('to-update', this.currentLink.href, {
						method:'get',
						onCreate: function(){
							this.updateRunning = true;
						}.bind(this),
						onComplete:function(){
							this.updateRunning = false;
						}.bind(this)
					});
				}
				event.stop();
			}
		}
	},

	chooseTypeMontant: function(event)
	{
		if (Object.isElement(event.findElement('a'))) {
			this.currentLink = event.findElement('a');
			if (this.currentLink.hasClassName('type_montants')) {
				if (this.updateRunning == false) {
					new Ajax.Updater('to-update', this.currentLink.href, {
						method:'get',
						onCreate: function(){
							this.updateRunning = true;
						}.bind(this),
						onComplete:function(){
							this.updateRunning = false;
						}.bind(this)
					});
				}
				event.stop();
			}
		}
	}

});


/**
 *  class App.Budget.ItemsParPageSlider
 *  Classe dédiée à la mise en place d'un slider permettant
 *  de mettre à jour le nombre d'item remonté par page.
**/
App.Budget.ItemsParPageSlider = Class.create({
	/**
	 *  new App.Budget.ItemsParPageSlider(items_per_page)
	 *  - items_per_page (integer) : Nombre maximal de période authorisées
	 *
	 *	Mise en place du slider. Un appel Ajax est effectué au relachement du slider
	 *  permettant de mettre à jour la liste d'items remontés.
	**/
	initialize: function(items_per_page)
	{
		this.items_per_page = items_per_page;

		new Control.Slider('handle','track',
			{
				range : $R(5,100),
				values: [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100],
				sliderValue: this.items_per_page,
			    onSlide: function(v){
					$('nb').update(parseInt(v));
				},
			    onChange: function(v){
					new Ajax.Updater('to-update', '?', {
						parameters: {
							page: $('page').value,
							items_per_page: parseInt(v)
						},
						method:'get'
					});
				}.bind(this)
			}
		);
	}
});

/**
 *  class App.Budget.TimeSelector
 *  Classe dédiée à la mise en place d'une interface de sélection
 *  de plage de dates à l'aide de la classe scriptaculous Control.Slider.
**/
App.Budget.TimeSelector = Class.create({
	/**
	 *  new App.Budget.TimeSelector(params)
	 *    - params (Hash) : Tableau associatif de paramètres :
	 *    - url (String)               : URL à appeler au relachement des sliders
	 *    - div_id_to_replace (String) : Identifiant de l'élément à remplacer au relachement des sliders
	 *    - slider_date_start (Date)   : Borne inférieure du slider
	 *    - slider_date_end (Date)     : Borne supérieure du slider
	 *    - current_date_start (Date)  : Borne inférieure de la sélection
	 *    - current_date_end (Date)    : Borne supérieure de la sélection
	**/
	initialize: function(params)
	{
		// Récupération des paramètres
		this.url                = params.url;
		this.div_id_to_replace  = params.div_id_to_replace;
		this.slider_date_start  = params.slider_date_start;
		this.slider_date_end    = params.slider_date_end;
		this.current_date_start = params.current_date_start;
		this.current_date_end   = params.current_date_end;

		this.periods = [];
		this._find_periods();

		// Nombre de jours dans l'intervalle du slider
		this.slider_number_of_days = Math.ceil((this.slider_date_end - this.slider_date_start)/ (1000*60*60*24));

		// Définition de l'intervalle du slider
		this.slider_range = $R(0, this.slider_number_of_days, false);

		// Définition des éléments HTML du slider
		this.handles = [$('handle_date_start'), $('handle_date_end')];
		this.track   = "track_date";

		// Instanciation du slider
		this.slider = this.createSlider();

		// Mise en place des contrôles "fins"
		$('remove-day-to-date-start').observe('click', this._removeOneDayToDateStart.bindAsEventListener(this));
		$('add-day-to-date-start').observe('click', this._addOneDayToDateStart.bindAsEventListener(this));
		$('remove-day-to-date-end').observe('click', this._removeOneDayToDateEnd.bindAsEventListener(this));
		$('add-day-to-date-end').observe('click', this._addOneDayToDateEnd.bindAsEventListener(this));
	},

	/**
	 *  App.Budget.TimeSelector#createSlider -> Control.Slider
	 *	Mise en place du slider
	**/
	createSlider: function()
	{
		return (
			new Control.Slider(this.handles, this.track,
				{
					range:this.slider_range,
					step:1,
					restricted:true,
					sliderValue: [this._getFirstSliderValue(), this._getSecondSliderValue()],

					onSlide:function(v)
					{
						this._updateDisplayedDates(v[0], v[1]);
						this._updateSelectedLink(v[0], v[1]);

					}.bind(this),

					onChange:function(v)
					{
						this._updateDisplayedDates(v[0], v[1]);
						this._updateSelectedLink(v[0], v[1]);

						new Ajax.Updater(this.div_id_to_replace, this.url,
							{
					  			parameters: {
									date_start:this._sliderValueToYYYY_MM_DD(v[0]),
									date_end:this._sliderValueToYYYY_MM_DD(v[1]),
									with_detail:'0'
								},
								method:'get'
							}
						);

					}.bind(this)
				}
			)
		);
	},

	// Récupération de la position du 1er slider
	_getFirstSliderValue: function()
	{
		return Math.ceil( (this.current_date_start.getTime() - this.slider_date_start.getTime()) / (1000*60*60*24) );
	},

	// Récupération de la position du 2ème slider
	_getSecondSliderValue: function()
	{
		return Math.ceil( (this.current_date_end.getTime() - this.slider_date_start.getTime()) / (1000*60*60*24) );
	},

	// Conversion d'un date js en un position
	_dateToSliderValue: function(date)
	{
		return Math.ceil( (date.getTime() - this.slider_date_start.getTime()) / (1000*60*60*24) );
	},

	// Conversion d'une position en date js
	_sliderValueToDate: function(value)
	{
		return parseInt(value).days().since(this.slider_date_start).toDate();
	},

	// Conversion d'une position en date dd/mm/yyyy
	_sliderValueToDDMMYYYY: function(value)
	{
		var date = this._sliderValueToDate(value);
		return this._dateToDDMMYYY(date);
	},

	// Conversion d'une position en date yyyy-mm-dd
	_sliderValueToYYYY_MM_DD: function(value)
	{
		var date = this._sliderValueToDate(value);
		return date.getFullYear()+'-'+(date.getMonth()+1).toPaddedString(2)+"-"+date.getDate().toPaddedString(2);
	},

	// Conversion d'une date js en date dd/mm/yyyy
	_dateToDDMMYYY: function(date)
	{
		return date.getDate().toPaddedString(2)+"/"+(date.getMonth()+1).toPaddedString(2)+"/"+date.getFullYear()
	},

	// Décalage de + un jour pour le 1er slider
	_addOneDayToDateStart: function(event)
	{
		event.stop();
		if (this.slider.values[0] < this.slider_number_of_days) {
			this.slider.setValue(this.slider.values[0] + 1, 0);
		}
	},

	// Décalage de - un jour pour le 1er slider
	_removeOneDayToDateStart: function(event)
	{
		event.stop();
		if (this.slider.values[0] > 0) {
			this.slider.setValue(this.slider.values[0] - 1, 0);
		}
	},

	// Décalage de + un jour pour le 2ème slider
	_addOneDayToDateEnd: function(event)
	{
		event.stop();
		if (this.slider.values[1] < this.slider_number_of_days) {
			this.slider.setValue(this.slider.values[1] + 1, 1);
		}
	},

	// Décalage de - un jour pour le 2ème slider
	_removeOneDayToDateEnd: function(event)
	{
		event.stop();
		if (this.slider.values[1] > 0) {
			this.slider.setValue(this.slider.values[1] - 1, 1);
		}
	},

	// Mise à jour des classes CSS selected
	_updateSelectedLink: function(v1, v2)
	{

		// Initialisation des classes CSS
		$$("#right .time-selection-links-container a").invoke("removeClassName", "selected");

		// Lien de sélection "Toutes"
		if ((v1 == 0) && (v2 == this.slider_number_of_days)){
			$('select-all-year').addClassName('selected');
		}

		// Liens de sélection par année
		var year_start = this.slider_date_start.getFullYear();
		var year_end = this.slider_date_end.getFullYear();
		$R(year_start, year_end).each(function(y) {
			if (y == this.slider_date_start.getFullYear()) {
				start = this.slider_date_start;
			} else {
				start = new Date(y, 0, 1);
			}
			if (y == this.slider_date_end.getFullYear()) {
				end = this.slider_date_end;
			} else {
				end = new Date(y, 11, 31);
			}
			if ( (this._sliderValueToDDMMYYYY(v1) == this._dateToDDMMYYY(start)) &&
			     (this._sliderValueToDDMMYYYY(v2) == this._dateToDDMMYYY(end)) ) {
				$('select-year-' + y).addClassName('selected');
			}
		}.bind(this));

		// Liens de sélection par période de l'échéancier
		this.periods.each(function(period, i){
			if ( (this._sliderValueToYYYY_MM_DD(v1) == period[0]) &&
			     (this._sliderValueToYYYY_MM_DD(v2) == period[1]) ) {
					$('period-'+i).addClassName('selected');
			}
		}.bind(this));
	},

	// Mise à jours des dates affichées
	_updateDisplayedDates: function(v1, v2)
	{
		$('date_start').update(this._sliderValueToDDMMYYYY(v1));
		$('date_end').update(this._sliderValueToDDMMYYYY(v2));
	},

	// Collecte les périodes de l'écheancier à travers le DOM
	_find_periods: function()
	{
		$$("#right .time-selection-links-container .periods-list a").each(function(link){
			var params = link.href.toQueryParams();
			this.periods.push([params.date_start, params.date_end]);
		}.bind(this));
	}
});

/**
 *  class App.Budget.EquipmentFactureForm
 *  Classe dédiée à la mise en place du formulaire de dépense en equipement
**/
App.Budget.EquipmentFactureForm = Class.create({
	/**
	 *  new App.Budget.EquipmentFactureForm()
	**/
	initialize: function(id)
	{
		this.id = id;

		this._setupDisplay();
		new Form.Element.Observer('depense_equipement_facture_' + this.id + '_amortissement_100', .1, this._update.bind(this));
		new Form.Element.Observer('depense_equipement_facture_' + this.id + '_amortissement_is_in_auto_mode', .1, this._updateCalculationSection.bind(this));
	},

	_setupDisplay: function()
	{
		this._update();
		this._updateCalculationSection();
	},

	_update: function()
	{
		if ($('depense_equipement_facture_' + this.id + '_amortissement_100').checked) {
			$('amortissement-sub-form-' + this.id).hide();
			$('tab-' + this.id).removeClassName('selected');
		}
		else {
			$('amortissement-sub-form-' + this.id).show();
			$('tab-' + this.id).addClassName('selected');
		}
	},

	_updateCalculationSection: function()
	{
		if ($('depense_equipement_facture_' + this.id + '_amortissement_is_in_auto_mode').checked) {
			$('auto-mode-true-' + this.id).show();
			$('auto-mode-false-' + this.id).hide();
		}
		else {
			$('auto-mode-true-' + this.id).hide();
			$('auto-mode-false-' + this.id).show();
		}
	}
});

/**
 *  class App.Budget.SalaireForm
 *  Classe dédiée à la mise en place du formulaire de dépense en salaire
**/
App.Budget.SalaireForm = Class.create({
	/**
	 *  new App.Budget.SalaireForm()
	**/
	initialize: function()
	{
		this._update();
		new Form.Element.Observer('depense_salaire_type_personnel_contractuel', .1, this._update.bind(this));
		new Form.Element.Observer('depense_salaire_type_personnel_unknown', .1, this._update.bind(this));

		if (Object.isElement($('people_from_ose'))) {
			$('people_from_ose').observe('click', this._populate_form_with_ose_data.bindAsEventListener(this));
		}
	},

	_update: function(){

		if ($('depense_salaire_type_personnel_contractuel').checked) {
			$('tab-contractuel').addClassName('selected');
			$('tab-titulaire').removeClassName('selected');
			$$('.for-contractuel').invoke('show');
			$$('.for-titulaire').invoke('hide');
			$('type_personnel_sub_form').show();
		}

		if ($('depense_salaire_type_personnel_titulaire').checked) {
			$('tab-contractuel').removeClassName('selected');
			$('tab-titulaire').addClassName('selected');
			$$('.for-contractuel').invoke('hide');
			$$('.for-titulaire').invoke('show');
			$('type_personnel_sub_form').show();
		}

		if ($('depense_salaire_type_personnel_unknown').checked) {
			$('tab-contractuel').removeClassName('selected');
			$('tab-titulaire').removeClassName('selected');
			$('type_personnel_sub_form').hide();
		}
	},

	_populate_form_with_ose_data: function(event)
	{
		if (Object.isElement(event.findElement('a'))) {
			event.stop();

			var link = event.findElement('a');

			$('depense_salaire_agent').value  = link.down('.prenom').innerHTML + " " + link.down('.nom').innerHTML;
			$('depense_salaire_statut').value = link.down('.statut').innerHTML;

			var date_start = link.down('.date_start').innerHTML.strip().split('/');
			$('depense_salaire_date_debut-dd').value = parseInt(date_start[0]);
			$('depense_salaire_date_debut-mm').value = parseInt(date_start[1]);
			$('depense_salaire_date_debut').value    = parseInt(date_start[2]);

			var date_end = link.down('.date_end').innerHTML.strip().split('/');
			$('depense_salaire_date_fin-dd').value = parseInt(date_end[0]);
			$('depense_salaire_date_fin-mm').value = parseInt(date_end[1]);
			$('depense_salaire_date_fin').value    = parseInt(date_end[2]);
		}
	}
});

App.PeriodHelper = Class.create({

    initialize: function(periodId) {
        this.periodId = periodId;

        this._forAllDateFieldSuffice(function(i){
            $(periodId+'_start'+i).observe(
                'change', this.checkPeriodConsistency.bind(this));
            $(periodId+'_end'+i).observe(
                'change', this.checkPeriodConsistency.bind(this));
        });
    },

    checkPeriodConsistency: function(e){
        var date_start = new Date($(this.periodId+'_start').value,
                                  $(this.periodId+'_start-mm').value,
                                  $(this.periodId+'_start-dd').value);
        var date_end   = new Date($(this.periodId+'_end').value,
                                  $(this.periodId+'_end-mm').value,
                                  $(this.periodId+'_end-dd').value);
        if (date_end < date_start) {
            this._forAllDateFieldSuffice(function(suf){
                depot_period_end_opts = $$('#'+this.periodId+'_end'+suf+' option');
                for (var i=0, len=depot_period_end_opts.length; i<len; ++i) {
                    if (depot_period_end_opts[i].readAttribute('value') == $(this.periodId+'_start'+suf).value) {
                        var opt;
                        if (suf || ($(this.periodId+'_start'+suf).value == $$('#'+this.periodId+'_start option').last().value))
                            opt = i
                        else
                            opt = i+1 // +1 for year
                        depot_period_end_opts[opt].selected = true;
                        break;
                    }
                }
            });
        }
    },

    _forAllDateFieldSuffice: function(cb) {
        var suf = ['', '-mm', '-dd'];
        for (var i=0, len=suf.length; i<len; ++i) cb.call(this, suf[i]);
    }

});

 /**
   *  Piwik   
  **/
  if(location.host == 'osc.inria.fr'){  
    var _paq = _paq || [];
    
    _paq.push([function() {
        var self = this;
        function getOriginalVisitorCookieTimeout() {
          var now = new Date(),
          nowTs = Math.round(now.getTime() / 1000),
          visitorInfo = self.getVisitorInfo();
          var createTs = parseInt(visitorInfo[2]);
          var cookieTimeout = 33696000; // 13 mois en secondes
          var originalTimeout = createTs + cookieTimeout - nowTs;
          return originalTimeout;
        }
        this.setVisitorCookieTimeout( getOriginalVisitorCookieTimeout() );
      }]);
    
    _paq.push(['trackPageView']);
    _paq.push(['enableLinkTracking']);
    (function() {
      var u="//piwik.inria.fr/";
      _paq.push(['setTrackerUrl', u+'piwik.php']);
      _paq.push(['setSiteId', 8]);
      var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
      g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
    })();
  }
