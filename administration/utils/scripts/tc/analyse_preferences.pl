#!/usr/bin/perl

###############################################################################
# 
#   analyse_preferences.pl
#
#   This script analyzes a the log file of an ideas import to Teamcenter
#   It extracted the TDM and Teamcenter attributes and writes them to the 
#   output file.
#
#   Parameters:
#   -root_dir       Root directory that will be traversed recursively (looking for XML files)
#   -input_list     File with directories
#
#   Example run:
#   > perl analyse_preferences.pl {-root_dir=<> | -input_list=<>}
#
#=============================================================================#
# 1.0   16. February 2012    G. Langenbacher     initial version
###############################################################################

sub param($);
sub process_dir($);

$|=1;

my $d_root  = param("-root_dir");
my $f_input = param("-input_list");

if ($f_input eq "<undefined>" && $d_root eq "<undefined>")
{
    print ("\nUSAGE:\n  perl analyse_preferences.pl [-root_dir=<>] [-input_list=<>]");
    print ("\n          -root_dir     root directory that will be processed recursively");
    print ("\n          -input_list   file with directory mapping that should be processed");
    exit 0;
}

if (!-e $d_root && !-e $f_input) 
{
    print ("\nERROR: Root directory '$d_root' does not exist!\n") if (!-e "$d_root");
    print ("\nERROR: File '$f_input' does not exist!\n") if (!-e "$f_input");
    exit 0;
}

print "\nINFO: Start Processing...\n";

$separator      = ";";
$value_separator= "|";
$lines_written  = 0;
$output_file    = ($d_root ne "<undefined>") ? "$d_root\\preferences_report.csv" : "preferences_report.csv";

open(OUTPUT,">$output_file") or die "\nERROR: Open output file '$output_file' failed";
print OUTPUT "Name".$separator."Value".$separator."Type".$separator."Is Array".$separator."Is Disabled".$separator."Protection Scope".$separator."Env Preference".$separator."Description".$separator."In File";
close (OUTPUT);

if ($d_root ne "<undefined>")
{
    process_dir($d_root);
}
else
{
    open(LIST,"<$f_input") or die "\nERROR: Open input file '$f_input' failed";
    while (<LIST>)
    {    
        s/[\r\n]+//;   # better cho(m)p
        next if (/^\s*$/);
        next if (/^\#/);
        
        if (-d $_)
        {
            process_dir($_);
        }
        else
        {
            print "WARNING: Directory '".$_."' does not exist!\n";
        }
    }
    close(LIST);
}

unlink($output_file) if !$lines_written;


print "\n################################################################\n";
print "##  S U M M A R Y                                             ##\n";
print "##------------------------------------------------------------##\n";
print "  Preferences written to file [$lines_written]\n";
print "  See file '$output_file'\n" if $lines_written;

print "\nINFO: Process finished!\n";

############################
#  FUNC: param             #
# ------------------------ #
# Get param by name        #
############################
sub param($)
{
	my $string = shift;
	my $ret = "<undefined>";
	foreach $parameter(@ARGV)
	{
		my ($para1, $para2) = split(/=+/, $parameter);
		if ( uc($string) eq uc($para1) )
		{
			$ret = $para2;
		}
	}
	return $ret;
}

############################
#  FUNC: process_dir       #
# ------------------------ #
# Process directory and    #
# search XML files         #
############################
sub process_dir($)
{
    my $current_dir = shift;
    
    opendir(IMD, $current_dir) || die("\nERROR: Cannot open input dir '$current_dir'");
    local @files_list= readdir(IMD);
    closedir(IMD);

    while (my $input_fname = pop(@files_list))
    {
        # skip dummy lines
        next if($input_fname eq "." || $input_fname eq "..");
        
        if (-d "$current_dir\\$input_fname")
        {
            process_dir("$current_dir\\$input_fname");
            next;
        }
        
        if ($input_fname =~ /^.*.xml$/)
        {
            my $found_prefs = 0;
            print "INFO: Processing file '$input_fname'...";
            
            if (-f "$current_dir\\$input_fname" && -e "$current_dir\\$input_fname") 
            {    
                open(OUTPUT,">>$output_file") or die "\nERROR: Open output file '$output_file' failed";
                
                my $pref_name           = "";
                my $pref_value          = "";
                my $pref_type           = "";
                my $pref_array          = "";
                my $pref_disabled       = "";
                my $pref_protectionScope= "";
                my $pref_envEnabled     = "";
                my $preference_record   = ""; 
                my $value_count         = 0;
                my $current_line        = 0;
                
                open(INPUT,"<$current_dir\\$input_fname") or die "\nERROR: Open input file '$current_dir\\$input_fname' failed";
                while (<INPUT>)
                {    
                    s/[\r\n]+//;   # better cho(m)p
                    next if (/^\s*$/);
                    next if (/^\#/);
                    next if (/^\<\?xml.*/); # <?xml...
                    
                    if (!$current_line && !/<preferences version=\"10.0\">/)
                    {
                        # file is not a preference file --> skip file
                        last;
                    }
                    $current_line++;
                    
                    # <preference name="CR_allow_alternate_procedures" type="String" array="false" disabled="false" protectionScope="Site" envEnabled="false">
                    if (($val1, $val2, $val3, $val4, $val5, $val6) = ($_=~ m/.*\<preference name\=\"(.*)\" type\=\"(.*)\" array\=\"(.*)\" disabled\=\"(.*)\" protectionScope\=\"(.*)\" envEnabled\=\"(.*)\"\>/i))
                    { 
                        $pref_name      		= $val1;
                        $pref_type      		= $val2;
                        $pref_array     		= $val3;
                        $pref_disabled  		= $val4;
						$pref_protectionScope	= $val5;
						$pref_envEnabled		= $val6;
                        $value_count    = 0;
						#print "DEBUG: [$val1] found in preferences file\n";
                        next;
                    }
                    
                    # <preference_description>Description text</preference_description>
                    if (($val1) = ($_=~ m/.*\<preference_description\>(.*)\<\/preference_description\>/))
                    { 
                        $pref_description = $val1;
                        $processing_multilinedesc = 0;
                        next;
                    }
                    elsif (($val1) = ($_=~ m/.*\<preference_description\>(.*)/))
                    {
                        $pref_description = $val1;
                        $processing_multilinedesc = 1;
                        next;
                    }
                    
                    # process multi line description
                    if ($processing_multilinedesc)
                    {
                        if (($val1) = ($_=~ m/(.*)\<\/preference_description\>/))
                        { 
                            $pref_description .= $val1;
                            $processing_multilinedesc = 0;
                        }
                        else
                        {
                            $pref_description .= $_;
                        }
                        next;
                    }
                    
                    # <value>Assigned</value>
                    if (($val1) = ($_=~ m/.*\<value\>(.*)\<\/value\>/))
                    { 
                        $pref_value .= ($value_count ? $value_separator : ""). $val1;
                        $value_count++;
                        next;
                    }                    
                    
                    # </preference>
                    if (($val1) = ($_=~ m/.*(\<\/preference\>)/))
                    { 
                        # clean description
                        $pref_description =~ s/\&lt\;/\</g;     # replace &lt; by <
                        $pref_description =~ s/\&gt\;/\>/g;     # replace &gt; by >
                        $pref_description =~ s/\&quot\;/\"/g;   # replace &quot; by "
                        $pref_description =~ s/^\s*//g;         # remove spaces at the beginning
                        $pref_description =~ s/\s*$//g;         # remove spaces at the end
                        $pref_description =~ s/\s{2,}/ /g;      # remove multiple spaces

                        # attach record
                        $preference_record .= "\n$pref_name".$separator."$pref_value".$separator."$pref_type".$separator.uc($pref_array).$separator.uc($pref_disabled).$separator.uc($pref_protectionScope).$separator.uc($pref_envEnabled).$separator."$pref_description".$separator."$current_dir\\$input_fname";
                        
                        # reset variables
                        $pref_name        		= "";
                        $pref_value       		= "";
                        $pref_type        		= "";
                        $pref_array       		= "";
                        $pref_disabled    		= ""; 
                        $pref_protectionScope   = ""; 
                        $pref_envEnabled    	= ""; 
                        $pref_description 		= "";
                        $lines_written++;
                        $found_prefs++;                       
                        next;
                    }                                     
                }
                close(INPUT);

                # print records to file
                if ($preference_record ne "")
                {
                    print OUTPUT "$preference_record";
                }
                close(OUTPUT);
                print " found preferences [$found_prefs]\n";
            }
        }
    }
}