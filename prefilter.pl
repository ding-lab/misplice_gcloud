#!/usr/bin/perl

use strict;
use warnings;

(my $usage = <<OUT) =~ s/\t+//g;
perl prefilter dir_in info
OUT

die $usage unless @ARGV == 2;

my ($dir_in, $info) = @ARGV;

sub largest_key (\%)
{
        my $in_hash = shift;
        keys %$in_hash;       # reset the each iterator
        my ($large_key, $large_val) = (0, -1);

        while (my ($key, $val) = each %$in_hash)
        {
                if ($val > $large_val)
                {
                        $large_val = $val;
                        $large_key = $key;
                }
        }
	return $large_key;
}

#my $dir = "allmut2";

#foreach my $input (glob("$dir_in/*.v2.filtered.2.detailed.alignment.2"))

foreach my $input (glob("$dir_in/$info"))
{
	print "$input\n";
#	<STDIN>;
	open(IN,"$input") or die;

	open(OUT, ">$input.max") or die;
	
	my %hash;
	my $id;
	while(<IN>)
	{
		chomp;
		if($_ =~m/^TCGA/)
		{
			$id = $_;
		}else
		{
			my @l = split(/\t/,);
			my @number=($l[5]=~m/(\d+)\w/g);
			my $start = $l[3] + $number[0];
			my $end = $start + $number[1];
			my $jd = $start.$end;
			$hash{$id}{$jd}++;
		}
	}
	
	my %mark;
	foreach my $i (keys %hash)
	{
		$mark{$i} = largest_key(%{$hash{$i}});
	}
	
	open(IN, "$input");
	while(<IN>)
	{
		chomp;
		if($_ =~m/^TCGA/)
		{
			$id = $_;
			print OUT "$_\n";
		}else
		{
			my @l = split(/\t/,);
			my @number=($l[5]=~m/(\d+)\w/g);
			my $start = $l[3] + $number[0];
			my $end = $start + $number[1];
			my $jd = $start.$end;
			if($mark{$id} eq $jd)
			{
				print OUT "$_\n";
			}
		}
	}
}
