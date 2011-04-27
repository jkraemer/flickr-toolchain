require File.expand_path("../lib/flickr-tools/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "flickr-tools"
  s.version     = FlickrTools::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jens Kraemer"]
  s.email       = ["jk@jkraemer.net"]
  s.homepage    = "http://github.com/carlhuda/newgem"
  s.summary     = "flickr utitlity library"
  s.description = "You're definitely going to want to replace a lot of this"

  s.required_rubygems_version = ">= 1.3.6"

  # lol - required for validation
  s.rubyforge_project         = "newgem"

  # If you have other dependencies, add them here
  s.add_dependency "rubyzip"
  s.add_dependency 'xml-magic'
  s.add_dependency 'tomk32-flickr_fu', '>=0.3.4'
  s.add_dependency 'iptc', '>= 0.0.2'

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md", "doc/*"]
  s.require_path = 'lib'

  # If you need an executable, add it here
  s.executables = ["flickr-tools"]

  # If you have C extensions, uncomment this line
  # s.extensions = "ext/extconf.rb"
end