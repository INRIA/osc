#!/bin/env ruby
# encoding: utf-8
#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
module DepensesHelper

  def iterate_compute_subtotals(depense)
    ['montant_engage', 'cout_mensuel', 'cout_periode'].each { |m|
      subtotal_var = "@subtotal_#{m}s"
      if instance_variable_defined? subtotal_var
        instance_variable_set(subtotal_var, instance_variable_get(subtotal_var) + depense.send(m.to_sym))
      end
    }

    @subtotal_montant_factures += depense.montant_factures(@type_montant,@current_date_start,@current_date_end)
    @subtotal_montant_paye += depense.montant(@current_date_start,@current_date_end,"sommes_engagees",@type_montant)
  end

end
