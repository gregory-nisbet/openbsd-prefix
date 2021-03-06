use strict;
use warnings FATAL => 'all';

# this is meant to be a test

# generate command to get average 
# round trip length to hostname.
# we know in advance that each command only
# emits one line
sub command {
    my $host = shift;
    qq(ping -c 5 '$host' |) . 
	q(tail -n 1 |) .
	q(sed 's/^.*= //;s/ ms//' |) .
	q(awk -F '/' 'END {print $2}');
}

# launch each ping in its own process and create
# a filehandle that reads from it
sub filehandles {
    my @handles;
    for my $command (@_) {
        open my $fh, '-|', $command or
	    die "cannot open file ($!) associated with $command";
	push @handles, $fh;
    }
    @handles;
}

my @commands = map command($_), qw[google.com cnn.com wikipedia.org microsoft.com walmart.com];
my @fhs = filehandles(@commands);

# read line from each of the ping processes sequentially
for my $fh (@fhs) {
    my $line = scalar <$fh>;
    chomp $line;
    printf "%s\n", $line || '+INF';
}

