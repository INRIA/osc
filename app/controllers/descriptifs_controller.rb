#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class DescriptifsController < ApplicationController
  before_filter :is_my_research_in_session?
  
  # GET /descriptifs
  # GET /descriptifs.xml
  def index
    #on définie @contrats pour permettre le switch entre contrats
    @contrats = Contrat.find(:all, :order => "acronyme")
    
    @contrat = Contrat.find(params[:contrat_id])
    @descriptifs = @contrat.descriptifs

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @descriptifs.to_xml }
    end
  end

  # GET /descriptifs/new
  def new
      @contrat = Contrat.find(params[:contrat_id])
      @descriptifs = @contrat.descriptifs
  end

  # GET /descriptifs/1;edit
  def edit
    @descriptif = Descriptif.find(params[:id])
    @contrat = Contrat.find(params[:contrat_id])
  end
  
   # POST /descriptifs
  # POST /descriptifs.xml
  def create
    @descriptif = Descriptif.new(params[:descriptif])
    @contrat = Contrat.find(params[:contrat_id])
    @descriptif.contrat = @contrat

    respond_to do |format|
      if @descriptif.save
        format.html { redirect_to contrat_url(@contrat) }
        format.js {
          render :update do |page|
            page.insert_html 'bottom', 'descriptif_container', :partial => 'list'
            page.hide 'new_descriptif'
            page.show 'link_to_add'
            if @contrat.descriptifs.size == 1
              page.visual_effect :Fade, 'init_descriptif', :duration => 0.1
            end
          end
        }
        format.xml  { head :created, :location => descriptif_url(@contrat, @descriptif) }
      else
        format.html { render :action => "new" }
        format.js {
          render :update do |page|
            page.replace_html 'error_new_descriptif', "Vous avez saisi un descriptif vide, ou la langue a déjà été choisie."
          end
        }
        format.xml  { render :xml => @descriptif.errors.to_xml }
      end
    end
  end

   # PUT /descriptifs/1
  # PUT /descriptifs/1.xml
  def update
    @descriptif = Descriptif.find(params[:id])
    @contrat = Contrat.find(params[:contrat_id])

    respond_to do |format|
      if @descriptif.update_attributes(params[:descriptif])
        format.html {
          redirect_to contrat_url(@contrat)
          }
          format.js {
            render :update do |page|
              page.replace_html 'edit_descriptif_'+@descriptif.id.to_s, ""
              page.replace_html 'show_descriptif_'+@descriptif.id.to_s,  :partial => 'show'
              page.show('show_descriptif_'+@descriptif.id.to_s)
            end
          }
        format.xml  { head :ok }
      else
        format.html {
          flash[:error] = 'Erreur lors de la mise à jour du descriptif : descriptif obligatoire ou langue déjà choisie'
          redirect_to contrat_url(@contrat)
        }
        format.js {
          render :update do |page|
            page.replace_html 'error_edit_descriptif_'+@descriptif.id.to_s, "Erreur lors de la mise à jour du descriptif : descriptif obligatoire ou langue déjà choisie"
          end
        }
        format.xml  { render :xml => @descriptif.errors.to_xml }
      end
    end
  end

  def ask_delete
    @descriptif = Descriptif.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # DELETE /descriptifs/1
  # DELETE /descriptifs/1.xml
  def destroy
    @descriptif = Descriptif.find(params[:id])
    @contrat = Contrat.find(params[:contrat_id])
    @descriptif.destroy

    respond_to do |format|
      format.js {
        render :update do |page|
          page.call("RedBox.close")
          page.visual_effect :fade, 'descriptif_box_'+@descriptif.id.to_s, :duration => 0.75
          page.delay(0.75) do
            page.remove 'descriptif_box_'+@descriptif.id.to_s
          end
          if @contrat.descriptifs.size == 0
            page.visual_effect :Appear, 'init_descriptif', :duration => 0.5
           # page.visual_effect :Fade, 'options_affichage', :duration => 0.5
          end

          if @contrat.descriptifs.size == 1
            first = Descriptif.find(:first, :conditions => ["contrat_id = ?", @contrat.id])
            #page.hide 'todolist_drag_'+first.id.to_s
          end

        end
      }
      format.xml  { head :ok }
    end
  end


  # GET /descriptifs/1
  # GET /descriptifs/1.xml
  def show
    @descriptif = descriptif.find(params[:id])
    @contrat = Contrat.find(params[:contrat_id])
    @langue = langue.find(@descriptif.langue_id)
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @descriptif.to_xml }
    end
  end
end
