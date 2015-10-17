use strict;
use warnings FATAL => 'all';

sub command {
    my $host = shift;
    qq(ping -w 1 -c 2 '$host' |) . 
	q(tail -n 1 |) .
	q(sed 's/^.*= //;s/ ms//' |) .
	q(awk -F '/' 'END {print $2}');
}

sub filehandles {
    my @handles;
    for my $command (@_) {
        open my $fh, '-|', $command or
	    die "cannot open file ($!) associated with $command";
	push @handles, $fh;
    }
    @handles;
}



my @commands = map command($_), qw[google.com cnn.com wikipedia.org];
my @fhs = filehandles(@commands);

