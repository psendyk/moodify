begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |t, task_args|
    t.rspec_opts = "--profile"
  end

  task default: :spec
rescue LoadError
  # no rspec available
end
