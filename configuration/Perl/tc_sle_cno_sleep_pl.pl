use strict;

my $time = 0;
my $exit_status = 1;

while ( $time < 2 ) {
    sleep(1);
	$time++;
}

print $exit_status;

exit;