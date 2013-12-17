#!/bin/env ruby
# encoding: utf-8

#depreciation en ruby 1.9.3 de iconv remplace par string#encode : cette classe a ete faite pour pas avoir a changer tout le code. 
class Iconv 
  def initialize(encoding1,encoding2)
    @encoding = encoding1
  end
  
  def iconv(string)    
    return string.encode(@encoding, :invalid => :replace, :undef => :replace, :replace => "?")
  end
end

