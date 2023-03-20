#!/usr/bin/env perl

use strict;
use Getopt::Long;
use Excel::Writer::XLSX;
use JSON::Parse 'read_json';

my $usage = qq{
perl my_script.pl
  Getting help:
    [--help]

  Input:
    [--infile filename]
		The name of the file to read. 

  Ouput:    
    [--outfile filename]
        The name of the output file. By default the output is the
        standard output
};

my $outfile = undef;
my $infile = undef;

my $help;

GetOptions(
    "help" => \$help,
    "infile=s" => \$infile,
    "outfile=s" => \$outfile);

# Print Help and exit
if ($help) {
    print $usage;
    exit(0);
}

if ($outfile) {
    open(STDOUT, ">$outfile") or die("Cannot open $outfile");
}

#die "Must specify an outfile (--outfile)" unless (defined $outfile);

# Initiate the XLS workbook
my $workbook = Excel::Writer::XLSX->new($outfile);

my @files = glob( "*.json" );

foreach my $file (@files) {

	my $row = 0;

	my $json = read_json($file);
	
	# Parse data from hash
	my $sample = %$json{"sample"};
	my @s = (split "_", $sample);
	my $sample_name = join("_", @s[2...$#s]) ;
	printf STDERR $sample_name . "\n";
	my $calls = %$json{"calls"};
	my $pipeline_version = %$json{"pipeline_version"};
	my $date = %$json{"date"};

	# Add a new sheet
        my $worksheet = $workbook->add_worksheet(substr($sample_name,0,25));

	my @header = () ;


	#printf $sample . "\n";

	my @genes = (sort keys %$calls) ;

	my @data = ();

	foreach my $gene (@genes) {
		my @elements = ( $gene );

		#printf "\t" . $gene . "\n";

		my $gdata = %${calls}{$gene};
		@header = ("Gene");

		foreach my $tool (sort keys %$gdata) {
			push(@header,$tool);
			my $c = %$calls{$gene}->{$tool};
			if ( (scalar @$c) > 0) {
				push(@elements, join(",",@$c)) ; 
			} else {
				push(@elements, "");
			}
		}

		push(@data,\@elements);

	}

	write_xlsx($worksheet,$row,@header) ;

	foreach my $d (@data) {
		$row += 1;
		write_xlsx($worksheet,$row,$d) ;

	}
}

sub write_xlsx{
    my ($worksheet, $tem_row, @ele) = @_;
    for(my $i = 0; $i < @ele; ++$i){
        $worksheet->write( $tem_row, $i, $ele[$i]);
    }
}
