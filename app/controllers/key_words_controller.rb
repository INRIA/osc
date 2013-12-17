#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class KeyWordsController < ApplicationController
  auto_complete_for :key_word, :section
  
  # GET /key_words
  # GET /key_words.xml
  def index
    @key_words = KeyWord.find(:all,
                              :include => [:laboratoire], 
                              :order => "key_words.intitule")

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @key_words.to_xml }
    end
  end
  
  def sort_by
    if params[:classement] == "laboratoire"
      @key_words = KeyWord.find(:all,
                              :include => [:laboratoire], 
                              :order => "laboratoires.nom, key_words.intitule",
                              :conditions => ["intitule like ? ","%#{params[:query]}%" ])
    else
      @key_words = KeyWord.find(:all,
                              :include => [:laboratoire], 
                              :order => "key_words.intitule",
                              :conditions => ["intitule like ? ","%#{params[:query]}%" ])
                              
    end

    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:classement] == "laboratoire"
            page.replace_html  'list', :partial => 'list_by_laboratoire'
          else
            page.replace_html  'list', :partial => 'list'
          end
          page.replace_html 'ajax_result', pluralize(@key_words.size.to_s,"mot clé", "mots clés")
        end
      }  
    end
  end
  

  # GET /key_words/1
  # GET /key_words/1.xml
  def show
    @key_word = KeyWord.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @key_word.to_xml }
    end
  end

  # GET /key_words/new
  def new
    @key_word = KeyWord.new
  end

  # GET /key_words/1;edit
  def edit
    @key_word = KeyWord.find(params[:id])
  end

  # POST /key_words
  # POST /key_words.xml
  def create
    @key_word = KeyWord.new(params[:key_word])

    respond_to do |format|
      if @key_word.save
        flash[:notice] = 'Le mot à bien été créé.'
        format.html { redirect_to key_words_url }
        format.xml  { head :created, :location => key_word_url(@key_word) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @key_word.errors.to_xml }
      end
    end
  end

  # PUT /key_words/1
  # PUT /key_words/1.xml
  def update
    @key_word = KeyWord.find(params[:id])

    respond_to do |format|
      if @key_word.update_attributes(params[:key_word])
        flash[:notice] = 'Le mot clé à bien été mis à jour.'
        format.html { redirect_to key_words_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @key_word.errors.to_xml }
      end
    end
  end

  
  def ask_delete
    @key_word = KeyWord.find(params[:id])
    respond_to do |format|
      format.html
    end
  end


  # DELETE /key_words/1
  # DELETE /key_words/1.xml
  def destroy
    @key_word = KeyWord.find(params[:id])
    @key_word.destroy
    @key_words = KeyWord.find(:all)
    
    respond_to do |format|
      format.html { redirect_to key_words_url }
      format.js {
        render :update do |page|
          page.call("RedBox.close")
          page.visual_effect :fade, 'keyword_'+@key_word.id.to_s, :duration => 0.75
          page.delay(0.75) do
            page.replace_html 'keyword_'+@key_word.id.to_s, ""
            page.replace_html 'ajax_result', pluralize(@key_words.size.to_s,"mot clé", "mots clés")
          end
          
        end
      }
      format.xml  { head :ok }
    end
  end
end
