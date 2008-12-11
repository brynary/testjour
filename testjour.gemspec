# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{testjour}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bryan Helmkamp"]
  s.date = %q{2008-12-11}
  s.default_executable = %q{testjour}
  s.description = %q{Distributed test running with autodiscovery via Bonjour (for Cucumber first)}
  s.email = %q{bryan@brynary.com}
  s.executables = ["testjour"]
  s.files = ["History.txt", "MIT-LICENSE.txt", "README.rdoc", "Rakefile", "bin/testjour", "lib/testjour", "lib/testjour/bonjour.rb", "lib/testjour/cli.rb", "lib/testjour/colorer.rb", "lib/testjour/commands", "lib/testjour/commands/base_command.rb", "lib/testjour/commands/help.rb", "lib/testjour/commands/list.rb", "lib/testjour/commands/local_run.rb", "lib/testjour/commands/run.rb", "lib/testjour/commands/slave_run.rb", "lib/testjour/commands/slave_start.rb", "lib/testjour/commands/slave_stop.rb", "lib/testjour/commands/slave_warm.rb", "lib/testjour/commands/version.rb", "lib/testjour/commands/warm.rb", "lib/testjour/commands.rb", "lib/testjour/cucumber_extensions", "lib/testjour/cucumber_extensions/drb_formatter.rb", "lib/testjour/cucumber_extensions/queueing_executor.rb", "lib/testjour/mysql.rb", "lib/testjour/pid_file.rb", "lib/testjour/progressbar.rb", "lib/testjour/queue_server.rb", "lib/testjour/rsync.rb", "lib/testjour/run_command.rb", "lib/testjour/slave_server.rb", "lib/testjour.rb", "vendor/authprogs"]
  s.homepage = %q{http://github.com/brynary/testjour}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Distributed test running with autodiscovery via Bonjour (for Cucumber first)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<systemu>, [">= 1.2.0"])
      s.add_runtime_dependency(%q<dnssd>, [">= 0.6.0"])
    else
      s.add_dependency(%q<systemu>, [">= 1.2.0"])
      s.add_dependency(%q<dnssd>, [">= 0.6.0"])
    end
  else
    s.add_dependency(%q<systemu>, [">= 1.2.0"])
    s.add_dependency(%q<dnssd>, [">= 0.6.0"])
  end
end
