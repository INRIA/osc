#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class ContratFilesController < ApplicationController
  before_filter :is_my_research_in_session?
  
  
  def sort_by
    params[:classement] ||= "date"
    session[:doc_classement]= params[:classement]
    @contrat = Contrat.find(params[:contrat_id])
    @contrat_files = @contrat.contrat_files
    if params[:classement] != "date"      
      @contrat_files = @contrat_files.sort_by{ |file| file['file'].downcase}
    end
    respond_to do |format|
      format.js {
        if params[:classement] == "date"
          render :update do |page|
            page.replace_html  'list_files', :partial => 'list_files'
          end
        else
          render :update do |page|
            page.replace_html  'list_files', :partial => 'list_files_by_AZ'
          end
        end
      }
    end
  end
  
  
  # GET /contrat_files
  def index
    session[:doc_classement] ||= "date"
    @contrat = Contrat.find(params[:contrat_id])
    @contrat_files = @contrat.contrat_files
    if session[:doc_classement] != "date"      
      @contrat_files = @contrat_files.sort_by{ |file| file['file'].downcase}
    end
  end

  # GET /contrat_files/1
  def show
    @contrat_file = ContratFile.find(params[:id])
  end

  # GET /contrat_files/new
  def new
    @contrat_file = ContratFile.new
  end

  # GET /contrat_files/1;edit
  def edit
    @contrat_file = ContratFile.find(params[:id])
  end

  def edit_description
    @contrat_file = ContratFile.find(params[:id])
    respond_to do |format|
        format.html { render :partial => "edit_description" }
    end    
  end
  
  def update_description
    @contrat_file = ContratFile.find(params[:id])
    respond_to do |format|
      if @contrat_file.update_attributes(params[:contrat_file])
        format.js { 
          render :update do |page|
            page.replace_html 'file_description_'+@contrat_file.id.to_s, (link_to  :name => @contrat_file.description,
                                                                                    :url => edit_description_contrat_contrat_file_path(@contrat_file.contrat, @contrat_file),
                                                                                    :method => :get,
                                                                                    :title => "Editer la description du fichier",
                                                                         	          :update => 'edit_description_'+@contrat_file.id.to_s
                                                                         	       )
            page.visual_effect :highlight, 'file_description_'+@contrat_file.id.to_s
            page.hide 'edit_description_'+@contrat_file.id.to_s
            page.show 'file_description_'+@contrat_file.id.to_s
          end
          }
      else
        format.js { 
          render :update do |page|
           page.replace_html 'error_edit_file_'+@contrat_file.id.to_s, "Le champ description est obligatoire merci de le remplir."
          end
          }
      end
    end
  end

  # POST /contrat_files
  def create
    @contrat = Contrat.find(params[:contrat_id])    
    @contrat_file = ContratFile.new(params[:contrat_file])
    @contrat_file.contrat = @contrat
  
    if @contrat_file.save
      flash[:notice] = 'Le document à bien été ajouté au contrat '+@contrat.acronyme
      redirect_to contrat_contrat_files_path(@contrat)
    else
      flash[:warning] = @contrat_file.errors.full_messages.join("<br />") 
      redirect_to contrat_contrat_files_url(@contrat)
    end
  end


  def ask_delete
    @contrat_file = ContratFile.find(params[:id])
  end

  # DELETE /contrat_files/1
  def destroy
    @contrats = Contrat.find(:all, :order => "acronyme")
    
    @contrat_file = ContratFile.find(params[:id])
    @contrat_file.destroy

    respond_to do |format|
      format.js {
        @contrat = Contrat.find(params[:contrat_id])    
        @contrat_files = @contrat.contrat_files
        render :update do |page|
          page.call("RedBox.close")
          page.visual_effect :fade, 'file_'+@contrat_file.id.to_s, :duration => 0.75
          page.delay(0.75) do
            page.replace_html  'list_files', :partial => 'list_files'
          end
          if @contrat.contrat_files.empty?
            page.visual_effect :Appear, 'init_file', :duration => 0.5
            page.visual_effect :Fade, 'options_affichage', :duration => 0.5
          end        
        end
      }
    end
  end
end
