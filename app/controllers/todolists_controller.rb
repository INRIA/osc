#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class TodolistsController < ApplicationController
  before_filter :is_my_research_in_session?
  
  def update_positions
    st = 'todo_container'
    params[st].each_with_index do |id, position|
      Todolist.update_all "position ="+position.to_s, "id = "+id.to_s
    end
    render :nothing => true
  end
  
  # GET /todolists
  # GET /todolists.xml
  def index
    @contrats = Contrat.find(:all, :order => "acronyme")
    
    @contrat = Contrat.find(params[:contrat_id])
    @todolists = @contrat.todolists

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @todolists.to_xml }
    end
  end

  # GET /todolists/1
  # GET /todolists/1.xml
  def show
    @todolist = Todolist.find(params[:id])
    @contrat = Contrat.find(params[:contrat_id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @todolist.to_xml }
    end
  end

  # GET /todolists/new
  def new
      @contrat = Contrat.find(params[:contrat_id])
      @todolists = @contrat.todolists
  end

  # GET /todolists/1;edit
  def edit
    @todolist = Todolist.find(params[:id])
    @contrat = Contrat.find(params[:contrat_id])
  end

  # POST /todolists
  # POST /todolists.xml
  def create
    @todolist = Todolist.new(params[:todolist])
    @contrat = Contrat.find(params[:contrat_id])
    @todolist.contrat = @contrat

    respond_to do |format|
      if @todolist.save
        format.html { redirect_to contrat_url(@contrat) }
        format.js { 
          render :update do |page|
            page.insert_html 'bottom', 'todo_container', :partial => 'list'
            page.hide 'new_todolist'
            page.show 'link_to_add'
            page.show 'add_todoitem_'+@todolist.id.to_s
            page.hide 'link_to_add_todoitem_'+@todolist.id.to_s
            page.replace_html 'add_todoitem_'+@todolist.id.to_s, :partial => 'todoitems/new'
            if @contrat.todolists.size > 1
              first = Todolist.find(:first, :conditions => ["contrat_id = ?", @contrat.id])
              page.show 'todolist_drag_'+first.id.to_s            
            end
            if @contrat.todolists.size == 1
              page.visual_effect :Fade, 'init_todo', :duration => 0.5
              page.visual_effect :Appear, 'options_affichage', :duration => 0.5
            end
        		page.insert_html 'after', 'todo_container', sortable_element('todo_container',
        												:url => update_positions_contrat_todolist_path(@todolist.contrat, @todolist),
        												:handle => 'draglist',
        												:scroll => 'window',
        												:constraint => "vertical",
        												:overlap => "vertical",
        												:tag => "div"
        											)
          end
        }
        format.xml  { head :created, :location => todolist_url(@contrat, @todolist) }
      else
        format.html { render :action => "new" }
        format.js { 
          render :update do |page|
            page.replace_html 'error_new_todolist', "Merci de renseigner l'intitulé de la To-Do List, le champ est obligatoire."
          end
        }
        format.xml  { render :xml => @todolist.errors.to_xml }
      end
    end
  end

  # PUT /todolists/1
  # PUT /todolists/1.xml
  def update
    @todolist = Todolist.find(params[:id])
    @contrat = Contrat.find(params[:contrat_id])

    respond_to do |format|
      if @todolist.update_attributes(params[:todolist])
        format.html {
          # redirect_to todolist_url(@todolist) 
          redirect_to contrat_url(@contrat)
          }
          format.js {
            render :update do |page|
              page.replace_html 'edit_todolist_'+@todolist.id.to_s, ""
              page.replace_html 'show_todolist_'+@todolist.id.to_s,  :partial => 'show'
              page.show('show_todolist_'+@todolist.id.to_s)
          		page.insert_html 'after', 'todo_container', sortable_element('todo_container',
          												:url => update_positions_contrat_todolist_path(@todolist.contrat, @todolist),
          												:handle => 'draglist',
          												:scroll => 'window',
          												:constraint => "vertical",
          												:overlap => "vertical",
          												:tag => "div"
          											)
            end
          }
        format.xml  { head :ok }
      else
        format.html {
          flash[:error] = 'Pas de mise à jour, une to-do list doit avoir obligatoirement un nom'
          redirect_to contrat_url(@contrat)
        }
        format.js { 
          render :update do |page|
            page.replace_html 'error_edit_todolist_'+@todolist.id.to_s, "Merci de renseigner l'intitulé de la To-Do List, le champ est obligatoire."
          end
        }
        format.xml  { render :xml => @todolist.errors.to_xml }
      end
    end
  end
  
  
  def ask_delete
    @todolist = Todolist.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  

  # DELETE /todolists/1
  # DELETE /todolists/1.xml
  def destroy
    @todolist = Todolist.find(params[:id])
    @contrat = Contrat.find(params[:contrat_id])
    @todolist.destroy

    respond_to do |format|
      format.js { 
        render :update do |page|
          page.call("RedBox.close")
          page.visual_effect :fade, 'todolist_box_'+@todolist.id.to_s, :duration => 0.75
          page.delay(0.75) do
            page.remove 'todolist_box_'+@todolist.id.to_s
          end
          if @contrat.todolists.size == 0
            page.visual_effect :Appear, 'init_todo', :duration => 0.5
            page.visual_effect :Fade, 'options_affichage', :duration => 0.5
          end
          
          if @contrat.todolists.size == 1
            first = Todolist.find(:first, :conditions => ["contrat_id = ?", @contrat.id])
            page.hide 'todolist_drag_'+first.id.to_s
          end
    
        end
      }
      format.xml  { head :ok }
    end
  end
end
