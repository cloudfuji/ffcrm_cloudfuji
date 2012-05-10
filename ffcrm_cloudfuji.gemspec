# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'fat_free_crm/cloudfuji/version'

Gem::Specification.new do |s|
  s.name = 'ffcrm_cloudfuji'
  s.authors = ['Sean Grove', 'Nathan Broadbent']
  s.email = 's@cloudfuji.com'
  s.homepage = 'http://cloudfuji.com'
  s.summary = 'Fat Free CRM - Cloudfuji Integration'
  s.description = 'Integrates Fat Free CRM with the Cloudfuji hosting platform.'
  s.files = `git ls-files`.split("\n")
  s.version = FatFreeCRM::Cloudfuji::VERSION

  s.add_dependency 'cloudfuji'
  s.add_dependency 'authlogic_cloudfuji', '~> 0.9'

end
