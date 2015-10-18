package SelectMirror;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(select_mirror);

use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use URI;

# ISSUES
# 1) does not run `ping` in parallel and so it takes a while
# on a vm

# constants
my $HOST = 0;
my $FULL = 1;
my $TIME = 2;

sub get_hosts {
    open(my $fh, '<', 'mirrors.txt');
    my @hosts;
    while (<$fh>) {
        my $u = URI->new($_);
        push @hosts, [$u->host, $_];
    }
    @hosts;
}


# get the average time of a particular host
# from ping
sub average_time {
    my $urls_ref = shift;
    # test the round trip time of a url
    # and parse the average speed
    my $speed = sub { 
	my $url = shift;
	return
	    qq(ping -w 1 -c 2 "$url" |) . 
	    q(tail -n 1 |) .
	    q(sed 's/^.*= //;s/ ms//' |) .
	    q(awk -F '/' 'END {print $2}');
    };
    # this part, right here, should really be parallel
    my @times;
    for my $item (@$urls_ref) {
	my $host = $item->[$HOST];
	$host =~ s/\s+$//;
	my $full = $item->[$FULL];
	$full =~ s/\s+$//;
	my $command = $speed->($host);
	my $value = `$command`;
	# annoying trailing newline in number or INF
	chomp($value);
        push @times, [$host, $full, $value || '+INF'];
    }
    return [@times];
}

sub sort_hosts {
    my $host_ref = shift;
    [sort {
	print Dumper($a);
	print "\n";
	print Dumper($b);
	print "\n";
	$a->[$TIME] <=> $b->[$TIME]
     } @$host_ref];
}

sub select_mirror {
    my @hosts = get_hosts();
    return sort_hosts(average_time([@hosts]));
}

