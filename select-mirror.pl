use strict;
use warnings FATAL => 'all';

use Net::Ping;
use Parallel::ForkManager;
use URI;
use Time::HiRes;

my $MAX_PROCESSES = 10;

my $pm = Parallel::ForkManager->new(10);

# read hosts from file
my @hosts;
do {
	open my $fh, '<', 'mirrors.txt' or die "cannot open file $!";
	while (<$fh>) {
		chomp;
		$_ eq '' and next;
		my $host = URI->new($_)->host;
		push @hosts, $host;
	}
};

PM_START:
foreach my $host (@hosts) {
	# fork.
	my ($ret, $duration, $ip);
	my $pid = $pm->start and next PM_START;
	my $p = Net::Ping->new('tcp');
	$p->hires;
	($ret, $duration, $ip) = $p->ping($host, 2) // 'no output';
	$p->close;
	printf "host %s time %s\n", $host, $duration;
	$pm->finish;
}
