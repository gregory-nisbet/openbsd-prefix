#!/usr/bin/env perl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;

my @hosts = qw[google.com yahoo.com cnn.com wikipedia.org];

# get the average time of a particular host
# from ping
sub average_time {
    my $urls_ref = shift;
    # test the round trip time of a url
    # and parse the average speed
    # does not handle missing values very well
    my $speed = sub { 
	my $url = shift;
	return
	     qq(ping -c 3 "$url" | tail -n 1 |).
       	     q(sed 's/^.*= //;s/ ms//' |) .
             q(awk -F '/' 'END {print $2}');
    };
    # populate url reference
    my $url_ref = {};
    for my $key (@$urls_ref) {
	my $command = $speed->($key);
	my $value = `$command`;
	chomp($value);
        $url_ref->{$key} = $value || 'INF';
    }
    return $url_ref;
}

print Dumper(average_time([@hosts]));

