#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class TodoitemsController < ApplicationController
  
  def update_positions
    st = 'sortable_list_undone_'+params[:todolist_id].to_s
    params[st].each_with_index do |id, position|
      Todoitem.update_all "position ="+position.to_s, "id = "+id.to_s
    end
    render :nothing => true
  end
  
  def undone
    todoitem = Todoitem.find(params[:id])
    todoitem.done = false
    todoitem.save
    @todolist =  todoitem.todolist
    respond_to do |format|
      format.js { 
                  render :update do |page|
                    page.replace_html 'list_items_done_'+@todolist.id.to_s, :partial => 'list_items_done'
                    page.replace_html 'list_items_undone_'+@todolist.id.to_s, :partial => 'list_items_undone'
                    page.visual_effect :highlight, 'todoitem_content_'+todoitem.id.to_s
                  end
                }
    end
  end
  
  def done
    todoitem = Todoitem.find(params[:id])
    todoitem.done = true
    todoitem.save
    @todolist =  todoitem.todolist
    respond_to do |format|
      format.js { 
                  render :update do |page|
                    page.replace_html 'list_items_undone_'+@todolist.id.to_s, :partial => 'list_items_undone'
                    page.replace_html 'list_items_done_'+@todolist.id.to_s, :partial => 'list_items_done'
                    page.visual_effect :highlight, 'todo_item_done_'+todoitem.id.to_s
                  end
                }
    end
  end

  # GET /todoitems
  # GET /todoitems.xml
  def index
    @todoitems = Todoitem.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @todoitems.to_xml }
    end
  end

  # GET /todoitems/1
  # GET /todoitems/1.xml
  def show
    @todoitem = Todoitem.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @todoitem.to_xml }
    end
  end

  # GET /todoitems/new
  def new
    @todoitem = Todoitem.new
    @todolist = Todolist.find(params[:todolist_id])
    
  end

  # GET /todoitems/1;edit
  def edit
    @todoitem = Todoitem.find(params[:id])
    @todolist = Todolist.find(params[:todolist_id])
    @contrat = Contrat.find(params[:contrat_id])
  end

  # POST /todoitems
  # POST /todoitems.xml
  def create
    @todoitem = Todoitem.new(clean_date_params(params[:todoitem]))
    @todolist = Todolist.find(params[:todolist_id])
    @todoitem.todolist = @todolist
    @contrat = Contrat.find(params[:contrat_id])
    respond_to do |format|
      if @todoitem.save
        format.html { redirect_to contrat_url(@contrat) }
        format.js { 
          render :update do |page|
            page.replace_html 'list_items_undone_'+@todolist.id.to_s, :partial => 'list_items_undone', :local => @todolist
            page.replace_html 'add_todoitem_'+@todolist.id.to_s, :partial => 'new'
        		page.insert_html 'after', 'todo_container', sortable_element('todo_container',
        												:url => update_positions_contrat_todolist_path(@todolist.contrat, @todolist),
        												:handle => 'draglist',
        												:scroll => 'window',
        												:constraint => "vertical",
        												:overlap => "vertical",
        												:tag => "div"
        											)
        		page.visual_effect :highlight, 'show_todoitem_'+@todoitem.id.to_s
            
          end
        }
        format.xml  { head :created, :location => todoitem_url(@todoitem) }
      else
        format.html { render :action => "new" }
        format.js { 
          render :update do |page|
            page.replace_html 'error_add_todoitem_'+@todolist.id.to_s, "Merci de renseigner l'intitulé de la tâche, le champ est obligatoire."
          end
        }
        format.xml  { render :xml => @todoitem.errors.to_xml }
      end
    end
  end

  # PUT /todoitems/1
  # PUT /todoitems/1.xml
  def update
    @todoitem = Todoitem.find(params[:id])
    if !params[:todoitem]["has_alerte"]
      @todoitem.has_alerte = 0
    end
    respond_to do |format|
      if @todoitem.update_attributes(clean_date_params(params[:todoitem]))
        @todoitem.save
        format.html { redirect_to todoitem_url(@todoitem) }
        
        format.js {
          render :update do |page|
            page.replace_html 'edit_todoitem_'+@todoitem.id.to_s, nil
            page.hide('edit_todoitem_'+@todoitem.id.to_s)
            
            txt = ''
            if @todoitem.has_alerte
							txt = '<span class="date_alerte">Pour le '+french_date(@todoitem.date)+' : </span>'
						end
            
            page.replace_html 'show_todoitem_'+@todoitem.id.to_s, txt+@todoitem.intitule+' <span class="auteur_todo">('+print_small_user_infos(@todoitem.updated_by)+')</span>'
            page.show('show_todoitem_'+@todoitem.id.to_s)
            page.visual_effect :highlight, 'show_todoitem_'+@todoitem.id.to_s
          end
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { 
          render :update do |page|
            page.replace_html 'error_edit_todoitem_'+@todoitem.id.to_s, "Merci de renseigner l'intitulé de la tâche, le champ est obligatoire."
          end
        }
        format.xml  { render :xml => @todoitem.errors.to_xml }
      end
    end
  end
  
  
  
  def ask_delete
    @todoitem = Todoitem.find(params[:id])
    @type = params[:type]
    respond_to do |format|
      format.html
    end
  end
  

  # DELETE /todoitems/1
  # DELETE /todoitems/1.xml
  def destroy
    @todoitem = Todoitem.find(params[:id])
    @todoitem.destroy
    @contrat = Contrat.find(params[:contrat_id])
    @todolist = Todolist.find(params[:todolist_id])

    respond_to do |format|
      format.js {
          render :update do |page|
            if params[:type]=='undone'
              page.call("RedBox.close")
              page.visual_effect :fade, 'todo_item_undone_'+@todoitem.id.to_s, :duration => 0.75
              page.delay(0.75) do
                page.replace_html 'list_items_undone_'+@todoitem.todolist.id.to_s, :partial => 'list_items_undone'
              end
            else
              page.call("RedBox.close")
              page.visual_effect :fade, 'todo_item_done_'+@todoitem.id.to_s, :duration => 0.75
              page.delay(0.75) do
                page.replace_html 'list_items_done_'+@todoitem.todolist.id.to_s, :partial => 'list_items_done'
              end  
            end
          end
     #   if params[:type]=='done'
    #      render :partial => 'list_items_done'
    #    else
     #     render :partial => 'list_items_undone'
    #    end
      }
      format.xml  { head :ok }
    end
  end
end
