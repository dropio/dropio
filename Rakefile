require 'spec/rake/spectask'
require 'rake/rdoctask'

### RSpec

task :default => :spec
Spec::Rake::SpecTask.new(:spec)

namespace :spec do
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_opts = %w{ --exclude ^/ --exclude ^spec/ --sort coverage }
  end
  
  namespace :rcov do
    desc "Generate and view RCov report"
    task :view => :rcov do
      coverage_index = File.expand_path(File.join(File.dirname(__FILE__), 'coverage', 'index.html'))
      sh "open file://#{coverage_index}"
    end
  end
end


### RDoc

Rake::RDocTask.new(:rdoc) do |rd|
  rd.rdoc_dir = 'doc'
end

namespace :rdoc do
  desc "Generate and view RDoc documentation"
  task :view => :rdoc do
    doc_index = File.expand_path(File.join(File.dirname(__FILE__), 'doc', 'index.html'))
    sh "open file://#{doc_index}"
  end
end