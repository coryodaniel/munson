require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do
  at_exit { sh "codeclimate-test-reporter" }
end

task :default => :spec
