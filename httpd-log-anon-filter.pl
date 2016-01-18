#!/usr/bin/perl
use strict;
use warnings;

use Digest::MD5 qw(md5);

my $logfile = shift @ARGV || die  'no output file given';

open my $log_fh, '>>', $logfile or die "can't open `$logfile': $!\n";
$log_fh->autoflush(); # better remove this on high-bandwidth sites

# get random MD5 salt
# this will give a new salt on every invocation, meaning that the
# hashes are 'new' after logrotate's daily 'apache reload'
my $salt = chr(rand(256)) . chr(rand(256)) . chr(rand(256)) . chr(rand(256));

while (my $line = <STDIN>) {
    my ($ip, $rest) = split /\s+/, $line, 2;

    # convert salt plus hostname field contents to md5 hash
    my $md5 = md5( $salt . $ip );
    
    if ($ip =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {
	# host field looks like IPv4:
	# convert first 4 bytes of md5 hash to an IPv4 address
	$ip = join( '.', unpack( 'C4', $md5));
    }
    else {
	# host field contains IPv6, resolved hostname or any other junk:
	# convert complete md5 hash to an IPv6 address
	$ip = join( ':', unpack( '(H4)8', $md5));

	# TODO:
	# generate documentation addresses? 2001:db8::/32
	# generate discard addresses? 0100::/64
    }
    print $log_fh "$ip $rest";
}

close $log_fh or die "can't close `$logfile': $!\n";
