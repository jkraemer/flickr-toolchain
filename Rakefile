require "bundler"
Bundler.setup

require 'rake/testtask'

desc 'Test the library.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

gemspec = eval(File.read("flickr-tools.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["flickr-tools.gemspec"] do
  system "gem build flickr-tools.gemspec"
  system "gem install flickr-tools-#{FlickrTools::VERSION}.gem"
end
