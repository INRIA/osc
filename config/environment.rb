#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
require "net-ldap"
#pour les exports csv
require 'csv'
# Load the rails application
require File.expand_path('../application', __FILE__)
# require 'osc.conf.rb'
require File.dirname(__FILE__) + "/../config/osc.conf.rb" 

require 'will_paginate/view_helpers'
require 'will_paginate/array'

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  '<span class="fieldWithErrors">'.html_safe << html_tag << '</span>'.html_safe
end


# ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :sendmail
# ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.sendmail_settings = {
  :location       => '/usr/sbin/sendmail',
  #:arguments      => '-i -t -f '+EMAIL_SUPPORT #pour activer l'envoi de mail (prod)
  :arguments      => '-bv '+EMAIL_SUPPORT #pour desactiver l'envoi de mails (dev)
}

ValidatesDateTime.us_date_format = true

# Initialize the rails application
OscNew::Application.initialize!

