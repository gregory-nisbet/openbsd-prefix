package AsyncGather;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(setup gather_commands);

use strict;
use warnings FATAL => 'all';
use vars qw(@hosts @commands @fhs);

# generate command to get average 
# round trip length to hostname.
# we know in advance that each command only
# emits one line
sub command {
    my $host = shift;
    qq(ping -w 1 -c 5 '$host' |) . 
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

sub setup {
    @hosts = @_;
    @commands = map command($_), @hosts;
    @fhs = filehandles(@commands);
}

sub gather_commands {
    my @out;
    # read line from each of the ping processes sequentially
    for my $fh (@fhs) {
        my $line = scalar <$fh>;
        push @out, $line;
    }
}
