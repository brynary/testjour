#!/usr/bin/perl
#
# authprogs, Copyright 2003, Brian Hatch.
#
# Released under the GPL.  See the file
# COPYING for more information.
# 
# This program is intended to be called from an authorized_keys
# file, i.e. triggered by use of specific SSH identities.
#
# It will check the original command (saved in $SSH_ORIGINAL_COMMAND
# environment variable by sshd) and see if it is on the 'approved'
# list.
#
# Allowed commands are stored in ~/.ssh/authprogs.conf
# The format of this file is as follows:
#
#   [ ALL ]
#   	command0 arg arg arg
#
#   [ ip.ad.dr.01  ip.ad.dr.02 ]
#       command1 arg arg arg
#
#   [ ip.ad.dr.03 ]
#       command2 arg arg arg
#       command3 arg arg 
#
# There is no regexp or shell metacharacter support.  If
# you want to allow 'ls /dir1' and 'ls /dir2' you need to
# explicitly create those two rules.  Putting "ls /dir[12]"
# in the authprogs.conf file will *not* work.
#
# NOTE: Some versions of Bash do not export the (already exported)
# SSH_CLIENT environment variable.  You can get around this by adding
#   export SSH_CLIENT=${SSH_CLIENT}
# or something similar in your ~/.bashrc, /etc/profile, etc.
#   http://mail.gnu.org/archive/html/bug-bash/2002-01/msg00096.html 
#
# Changes:
#  2003-10-27: fixed exit status, noted by Brad Fritz.
#  2003-10-27: added blank SSH_ORIGINAL_COMMAND debug log message


use strict;
use subs qw(bail log); 
use POSIX qw(strftime);
use File::Basename;
use FileHandle;

# DEBUGLEVEL values:
#   0 - log nothing
#   1 - log errors
#   2 - log failed commands
#   3 - log successful commands
#   4 - log debugging info
my $DEBUGLEVEL = 4;

# Salt to taste.  /dev/null might be a likely
# place if you don't want any logging.
my $LOGFILE = "$ENV{HOME}/.ssh/authprogs.log";

# Configfile - location of the host/commands allowed.
my $CONFIGFILE = "$ENV{HOME}/.ssh/authprogs.conf";

# $CLIENT_COMMAND is the string the client sends us.
#
# Unfortunately, the actual spacing is lost.  IE
# ("some string" and "some" "string" are not differentiable.)
my ($CLIENT_COMMAND) = $ENV{SSH_ORIGINAL_COMMAND};

# strip quotes - we'll explain later on.
$CLIENT_COMMAND =~ s/['"]//g;

# Set CLIENT_IP to just the ip addr, sans port numbers.
my ($CLIENT_IP) = $ENV{SSH_CLIENT} =~ /^(\S+)/;


# Open log in append mode.  Note that the use of '>>'
# means you better be doing it somewhere that is only
# writeable by you, lest you have a symlink/etc attack.
# Since we default to ~/.ssh, this should not be a problem.

if ( $DEBUGLEVEL ) {
	open LOG, ">>$LOGFILE" or bail "Can't open $LOGFILE\n";
	LOG->autoflush(1);
}

if ( ! $ENV{SSH_ORIGINAL_COMMAND} ) {
	log(4, "SSH_ORIGINAL_COMMAND not set - either the client ".
		"didn't send one, or your shell is removing it from ".
		"the environment.");
}


# Ok, let's scan the authprogs.conf file
open CONFIGFILE, $CONFIGFILE or bail "Config '$CONFIGFILE' not readable!";

# Note: we do not verify that the configuration file is owned by
# this user.  Some might argue that we should.  (A quick stat
# compared to $< would do the trick.)  However some installations
# relax the requirement that the .ssh dir is owned by the user
# s.t. it can be owned by root and only modifyable in that way to
# keep even the user from making changes.  We should trust the
# administrator's SSH setup (StrictModes) and not bother checking
# the ownership/perms of configfile.

my $VALID_COMMAND=0;	# flag: is this command appopriate for this host?

READ_CONF: while (<CONFIGFILE>) {
	chomp;

	# Skip blanks and comments.
	if ( /^\s*#/ ) { next }
	if ( /^\s*$/ ) { next }
	
	# Are we the beginning of a new set of
	# clients?
	if ( /^\[/ ) {
		
		# Snag the IP address(es) in question.
		
		/^ \[    ( [^\]]+ )   \] /x;
		$_ = $1;

		if ( /^\s*ALL\s*$/ ) {	 	# If wildcard selected
			$_ = $CLIENT_IP;
		}

		my @clients = split;

		log 4, "Found new clients line for @clients\n";

		# This would be a great place to add
		# ip <=> name mapping so we can have it work
		# on hostnames rather than just IP addresses.
		# If so, better make sure that forward and
		# reverse lookups match -- an attacker in
		# control of his network can easily set a PTR
		# record, so don't rely on it alone.
		
		unless ( grep /^$CLIENT_IP$/, @clients ) {

			log 4, "Client IP does not match this list.\n";
			
			$VALID_COMMAND=0;

			# Nope, not relevant - go to next
			# host definition list.
			while (<CONFIGFILE>) {
				last if /^\[/;
			}

			# Never found another host definition.  Bail.
			redo READ_CONF;
		}
		$VALID_COMMAND=1;
		log 4, "Client matches this list.\n";

		next;
	}
	
	# We must be a potential command
	if ( ! $VALID_COMMAND ) {
		bail "Parsing error at line $. of $CONFIGFILE\n";
	}


        my $allowed_command = $_;
	$allowed_command =~ s/\s+$//;	# strip trailing slashes
	$allowed_command =~ s/^\s+//;	# strip leading slashes

	# We've now got the command as we'd run it through 'system'.
	#
	# Problem: SSH sticks the command in $SSH_ORIGINAL_COMMAND
	#          but doesn't retain the argument breaks.
	#
	# Solution: Let's guess by stripping double and single quotes
	#           from both the client and the config file.  If those
	#           versions match, we'll assume the client was right.

	my $allowed_command_sans_quotes = $allowed_command;
	$allowed_command_sans_quotes =~ s/["']//g;

	log 4, "Comparing allowed command and client's command:\n";
	log 4, " Allowed: $allowed_command_sans_quotes\n";
	log 4, " Client:  $CLIENT_COMMAND\n";

	if ( $allowed_command_sans_quotes eq $CLIENT_COMMAND ) {
		log 3, "Running [$allowed_command] from $ENV{SSH_CLIENT}\n";

		# System is a bad thing to use on untrusted input.
		# But $allowed_command comes from the user on the SSH
		# server, from his authprogs.conf file.  So we can trust
		# it as much as we trust him, since it's running as that
		# user.

		system $allowed_command;
		exit $? >> 8;
	}
		
}

# The remote end wants to run something they're not allowed to run.
# Log it, and chastize them.

log 2, "Denying request '$ENV{SSH_ORIGINAL_COMMAND}' from $ENV{SSH_CLIENT}\n";
print STDERR "You're not allowed to run '$ENV{SSH_ORIGINAL_COMMAND}'\n";
exit 1;


sub bail {
	# print log message (w/ guarenteed newline)
	if (@_) {
		$_ = join '', @_;
		chomp $_;
		log 1, "$_\n";
	}

	close LOG if $DEBUGLEVEL;
	exit 1
}

sub log {
	my ($level,@list) = @_;
	return if $DEBUGLEVEL < $level;

	my $timestamp = strftime "%Y/%m/%d %H:%M:%S", localtime;
	my $progname = basename $0;
	grep { s/^/$timestamp $progname\[$$\]: / } @list;
	print LOG @list;
}
