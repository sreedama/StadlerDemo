use strict;

my $pdf_file = 'C:/splm/install_dir_temp/CNO_ValidationFramework/back-up_not-in-GIT-yet/Faked_Dispatcher_Repository/' . $ARGV[0] . '.pdf';
my $exit_status = 0;

if ( -e $pdf_file ) {
	$exit_status = 1;
}

print $exit_status;

exit;