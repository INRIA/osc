#osc
===

##Introduction

OSC (acronyme pour Outil de Suivi des Contrats) est une application web open source (écrite en Ruby On Rails) permettant le suivi des Contrats et des Budgets correspondant dans le contexte d'une entité de recherche (EPST, Laboratoire, Université, etc.). Son périmètre est à la croisé des différents métiers (porteur de projet, services administratifs & financiers, assistant(e)s d’équipe, service des ressources humaines, etc.) et est utile aussi bien pour suivre chaque contrat dans le détail, qu’à des fins de pilotage du point de vue d’une équipe ou d’un établissement.
Elle est le fruit de spécifications réalisées par des acteurs métiers et de développements réalisés par le CNRS puis l’INRIA depuis 2006 et continuant à ce jour.
De nombreuses évolutions successives ont été apportées sur le logiciel en fonction de l’évolution des métiers, des besoins utilisateurs et des réglementations.

## Les principales fonctionnalités

OSC est une application web collaborative, ce qui veut dire qu’elle peut être utilisée par n’importe qui depuis n’importe où avec comme seule contrainte le fait de posséder un navigateur et un accès internet. Aucun logiciel client n’est à déployer sur les postes de travail, et les informations modifiées par les uns sont en temps réel accessibles par les autres.
L’application se subdivise en trois principales sections :
* une partie dédiée au suivi des aspects contractuels
* une partie dédiée au suivi budgétaire
* une partie dédiée à l’administration de l’application, de ses utilisateurs et de ses référentiels

L’ensemble des informations présentes dans l’application peuvent être saisies manuellement via l’application directement, ou peuvent être injectées en base de données par des mécanismes de synchronisation depuis d’autres applications du système d’information des établissements. Un mécanisme de verrou existe pour l’ensemble des données permettant d’en empêcher l’édition via les interfaces web de l’application si leur source est externe à l’outil.


###	Des fonctionnalités tournées vers les utilisateurs
L’application permet une utilisation par de multiples acteurs à plusieurs niveaux tout au long de la vie d’un projet, voire d’un établissement.
Pendant la phase d’avant-projet :
* Les chargé(e)s de contrats de recherche 
* Le service juridique
* Le service transfert partenariat et innovation
* Le responsable scientifique
* Les partenaires

Peuvent partager en collaboration des documents et réaliser le montage du projet, en s’appuyant sur des outils commun comme des todo list,  la mise en place d’alertes, etc.

Pendant la durée du projet :
* Les assistant(e)s d’équipe de recherche
* Les assistant(e)s de service
* Les chargé(e)s de contrats de recherche 
* Les chargé(e)s de budget 
* Les gestionnaires financiers 

Veillent à la bonne exécution budgétaire du projet : ouverture des crédits, suivi des dépenses/factures, saisie du prévisionnel, vérification des bilans, suivi de l’éligibilité et de la justification des dépenses, vérification du disponible avant engagement, etc.

*	Le service des ressources humaines peut suivre les recrutements et la bonne imputation des paies

A tout moment :
* les responsables d’équipe de recherche / de services
*	Les chargé(e)s de budget
*	Les gestionnaires financiers
*	Les assistant(e)s d’équipes ou de services

Peuvent suivre le budget par équipe, voir le disponible et prévoir les échéances importantes pour la vie des équipes/services.


Un outil de pilotage :
* La direction des établissements
* l’agence comptable
* Le service transfert partenariat et innovation

Peuvent avoir une vue d’ensemble des contrats en phase de montage,  en cours, clos ou refusés. L’application met à disposition des fonctionnalités simples d’utilisation de construction dynamique de requêtes pour interroger l’ensemble des données à des fins de pilotages, à la fois sur l’activité contractuelle (partenariat, thématiques, types de contrats, etc.) mais aussi sur l’activité financière et budgétaire de leur établissement.

###	Le suivi des contrats
L’application est capable de gérer des contrats attachés à plusieurs structures différentes et de gérer pour chacune de ses associations les moyens accordés, tant humains que financiers, ainsi que les budgets de dépenses associés.
On retrouve comme principales fonctionnalités dans cette partie de l’application :
* Un écran d’accueil récapitulant les tâches à accomplir ainsi que l’activité récente sur les contrats pour lesquels on possède des droits
* Un moteur de recherche multicritères permettant d’accéder facilement au contrat souhaité
* La possibilité de créer des contrats
* Pour chaque contrat :
  * Un tableau de bord synthétisant les informations générales
  * L’enregistrement des différentes étapes du cycle de vie du contrat, contenant chacun un ensemble d’informations associées (détaillées dans la deuxième partie de ce document), contractuelles et financières : 
    * La préparation du contrat
    * La soumission
    * La signature ou le refus
    * La notification
    * La clôture
  * La possibilité de saisir/d’éditer chacune de ces étapes et les informations qui lui sont associées
  * La possibilité de saisir des descriptifs du contrat dans différentes langues exportables via une API pour un affichage sur un site externe
  * L’ensemble des documents sous forme électroniques (scan, etc.) relatifs au contrat de manière à dématérialiser ces documents et à les rendre accessibles à l’ensemble des acteurs
  *	La liste des tâches à effectuer, datées, avec la possibilité de mettre en place des alertes et d’en ajouter
  *	La saisie/visualisation des échéanciers de dépenses, déclinables par structures si plusieurs structures sont impliquées sur un même contrat
  *	Un écran de synthèse budgétaire contenant un résumé des dépenses éligibles à la justification, réalisées et prévisionnelles
  *	La visualisation des personnes ou groupes de personnes ayant des droits dans l’application sur les données du contrat
  *	La possibilité d’extraire au format PDF les informations contenu dans n’importe lequel des écrans précédemment décrit
  *	La possibilité de dupliquer un contrat pour faciliter la saisie de contrats similaires
* Un écran possédant un mécanisme d’extraction de données permettant de construire dynamiquement des requêtes en quelques clics pour extraire un ensemble d’information de la partie contrat, à des fins de pilotage. Les résultats produits par ces requêtes sont exportables sous format tableur (csv).
* Des écrans de pilotage possédant des résultats de requêtes préconfigurées pour visualiser rapidement l’activité contractuelle d’un établissement
 
###	Le suivi des budgets
Pour chaque association d’un contrat signé et notifié avec une structure, il est possible de créer un budget de dépense afin d’effectuer le suivi budgétaire associé au contrat. Ces lignes budgétaires permettent de faire le suivi des dépenses ventilées selon les postes budgétaires suivants :
* Fonctionnement
* Equipement
* Mission
* Salaire
* Non-ventilé
* Dépenses du commun dans le cas de dotations où la ventilation n’est pas nécessaire

On retrouve comme principales fonctionnalités dans cette partie de l’application :
* Un écran d’accueil récapitulant l’activité récente sur les budgets pour lesquels on possède des droits
* Un moteur de recherche multicritères permettant d’accéder facilement au budget souhaité
* On retrouve pour chaque budget :
  * Un tableau de bord synthétisant l’activité récente
  * La visualisation des personnes ou groupes de personnes ayant des droits sur ces données budgétaires
  * Le résumé des aspects financiers contractuels (dates, montants accordés, etc.)
  * Un onglet listant les crédits ouverts sur le contrat
  * Un onglet pour chaque type de dépenses (fonctionnement, équipement, mission, salaire, non-ventilé, dépenses du commun) listant l’ensemble des dépenses correspondantes
  * Le détail de chaque dépense ainsi que des factures qui y sont associées (la liste des principales informations sera détaillée en deuxième partie de ce document)
  * Un écran de bilan permettant d’avoir une vue synthétique du budget récapitulant les moyens accordés, les crédits ouverts, la somme des dépenses, le reste à ouvrir et le reste à engager, par ventilation et de manière global
  * Une sélection temporelle permettant de filtrer les résultats affichés dans tous les écrans précédents par année, par période ou simplement de date à date
  * La possibilité de saisir/d’éditer tout type de données décrites plus haut (crédit, dépense, facture)
  * La possibilité de dupliquer une dépense pour faciliter la saisie de données similaires
* Des écrans d’extraction de données à des fins de pilotage permettent d’effectuer des requêtes sur les données budgétaires (dépenses, crédits, bilans) à l’échelle d’une structure, d’un contrat, d’un laboratoire, d’un établissement, d’une tutelle, etc.
* L’ensemble des données sur la plupart des interfaces web de la partie de suivi du budget sont exportables au format tableur (csv)

###	L’administration
L’application possède une interface web d’administration permettant :
* De gérer les comptes utilisateurs
* De gérer les groupes d’utilisateurs
* De gérer les droits dans l’application, qui peuvent être attribués par utilisateur, par groupe d’utilisateurs, pour un contrat ou pour l’ensemble des contrats rattachés à une structure
* De gérer les valeurs présentes dans les différents référentiels de l’application :
  * Les structures (équipes, départements, laboratoires, tutelles)
  * Les mots clés utilisés pour décrire les contrats
  * Les types de contrats
  * Les établissements gestionnaires
  * Les rubriques comptables
  * Les références budgétaires

##	Les caractéristiques techniques
OSC est une application web compatible avec tous les navigateurs récents.
L’application en elle-même utilise les technologies suivantes :
* Le framework Ruby On rails
* Le langage Ruby 
* Le langage Javascript 
* Un serveur applicatif, le plus couramment Apache
* Le système de gestion de base de données Mysql

L’authentification dans l’application peut se faire au moyen d’un annuaire ldap, voir même de plusieurs annuaires ldap sur une même instance dans le cas où l’utilisation de l’application serait partagée entre plusieurs entités différentes. Elle peut également se faire via la création de comptes locaux à l’application.

La personnalisation de l’identité graphique de l’application est possible via une feuille de style css, de manière à permettre à chaque établissement de faciliter l’intégration de l’application dans son écosystème logiciel.
 
Elle est déjà déployée et utilisée dans différents EPST ou universités, sur des infrastructures linux Ubuntu ou Cent Os.
L’application est Open Source, le dépôt APP a été effectué.

Les données étant stockées dans des tables mysql, il est facile de les injecter dans un système décisionnel à l’aide d’un ETL de type talend par exemple.

## Conclusion
OSC est un outil convivial, ergonomique, collaboratif et complet touchant tous les corps de métiers concernés de près ou de loin par la gestion de contrats et de ressources contractuels. En tant qu’application web open source, il peut s’insérer facilement et à moindre coût qu’une solution propriétaire dans le système d’information d’un établissement, tout en fédérant l’ensemble des acteurs autour d’un même outil.
