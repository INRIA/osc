#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
class PaginationLinkRenderer  < WillPaginate::ActionView::LinkRenderer

  def link(text, target, attributes ={})
    attributes["OnClick"]="updateResult("+target.to_s+"); return false;"
    super
  end
end

