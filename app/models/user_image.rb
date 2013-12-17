#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class UserImage < ActiveRecord::Base
  belongs_to :user
  file_column :image,
              :magick => {
                :geometry => "76x76", :crop => "1:1",
                :versions => { "medium" => "400x400",
                                "small" => "38x38"}
              }
  validates_presence_of :image
  
  attr_accessible :image_temp, :image
  
end