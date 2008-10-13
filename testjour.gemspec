Gem::Specification.new do |s|
  s.name = %q{testjour}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bryan Helmkamp"]
  s.date = %q{2008-10-12}
  s.default_executable = %q{testjour}
  s.email = ["bryan@brynary.com"]
  s.executables = ["testjour"]
  s.extra_rdoc_files = ["History.txt", "MIT-LICENSE.txt", "Manifest.txt", "README.txt", "TODO.txt"]
  s.files = ["History.txt", "MIT-LICENSE.txt", "Manifest.txt", "README.txt", "Rakefile", "TODO.txt", "bin/testjour", "lib/testjour.rb", "lib/testjour/bonjour.rb", "lib/testjour/cli.rb", "lib/testjour/colorer.rb", "lib/testjour/commands.rb", "lib/testjour/commands/base_command.rb", "lib/testjour/commands/help.rb", "lib/testjour/commands/list.rb", "lib/testjour/commands/run.rb", "lib/testjour/commands/slave_run.rb", "lib/testjour/commands/slave_start.rb", "lib/testjour/commands/slave_stop.rb", "lib/testjour/commands/version.rb", "lib/testjour/cucumber_extensions/drb_formatter.rb", "lib/testjour/cucumber_extensions/queueing_executor.rb", "lib/testjour/mysql.rb", "lib/testjour/pid_file.rb", "lib/testjour/queue_server.rb", "lib/testjour/rsync.rb", "lib/testjour/slave_server.rb", "testjour.gemspec"]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{testjour}
  s.rubygems_version = %q{1.2.0}
  s.summary = nil

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
