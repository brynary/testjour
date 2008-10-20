=== Testjour

* http://github.com/brynary/testjour

=== Description

Distributed test running with autodiscovery via Bonjour (for Cucumber first)

=== Synopsis

On machines to be used as Testjour slaves:

    $ mkdir testjour-working-dir
    $ testjour slave:start

    
On your development machine, verify it can see the testjour slave:

    $ testjour list
    
    Testjour servers:

        bhelmkamp    available    bryans-computer.local.:62434
        
Now run your tests:
    
    $ testjour run features

Note: This only really makes sense if you use more than one slave. Otherwise
it's slower than just running them locally.

=== Install

To install the latest release (once there is a release):

    $ sudo gem install testjour
    
For now, just pull down the code from the GitHub repo:
    
    $ git clone git://github.com/brynary/testjour.git
    $ cd testjour
    $ rake gem
    $ rake install_gem

=== Authors

- Maintained by Bryan Helmkamp (http://brynary.com/)