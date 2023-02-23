# frozen_string_literal: true

require_relative('lib/taxonomer/version')

Gem::Specification.new do |spec|
  spec.name         = 'taxonomer'
  spec.version      = TaxonomerVer::VERSION
  spec.authors      = ['Toni Nurminen']
  spec.email        = ['toni.nurminen@gmail.com']
  spec.summary      = 'Obfuscates taxonomic species and strain names in given strings'
  spec.description  = 'This gem can be used to augment machine learning text examples with new taxonomic names and strain names.'
  spec.license      = 'MIT'
  spec.homepage     = 'https://github.com/tznurmin/taxonomer'
  spec.platform     = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.0'
  spec.files = Dir['README.md', 'LICENSE', 'CHANGELOG.md', 'lib/**/*.rb', 'data/**/*.txt', 'data/**/LICENSE',
                   'taxonomer.gemspec', 'Gemfile']

  spec.add_development_dependency 'rubocop', '~> 1.45'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
