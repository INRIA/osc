#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class Todolist < ActiveRecord::Base
  belongs_to :contrat
  acts_as_list  
  has_many :todoitems, :order => "position",  :dependent => :destroy
  validates_presence_of :nom, :message => "can't be blank"
  
  attr_accessible :nom
  
  def get_items_undone
    items_undone = Array.new
    for item in self.todoitems
      if !item.done
        items_undone << item
      end
    end
    return items_undone
  end
  
  def get_items_done
    items_done = Array.new
    for item in self.todoitems
      if item.done
        items_undone << item
      end
    end
    return items_done
  end
  
end
