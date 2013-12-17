#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
module AllLignesHelper

  def display_millesime(depense)
    if depense.millesime
      millesime = depense.millesime.year
    else
      depense_table_name = depense.class.table_name
      facture_table_name = depense_table_name.chop+'_factures'
      # FIXME: we take the first associated facture instead of finding the good
      # one...
      millesime = depense.send(facture_table_name.to_sym)[0].millesime.year
    end
    "(#{millesime})"
  end

end
