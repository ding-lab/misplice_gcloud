
### Song Cao ####

### get supporting reads for novel junctions due to somatic mutation ### 

### Oct 25, 2016###

## last updated: Jan 16, 2017 ###

#!/usr/bin/perl

use strict;
use warnings;
(my $usage = <<OUT) =~ s/\t+//g;
perl filter_fp_ns.pl f_in f_out
OUT

die $usage unless @ARGV == 3;
my ($f_in, $f_out, $script_dir) = @ARGV;

#my $f_bam_list="/gscuser/scao/data_source/rnaseq/bam_path_02_10_2017.tsv"; 
#my $f_bam_list="/gscuser/scao/data_source/rnaseq/bam_path_03_04_2017.tsv";
my $f_bam_list = $script_dir."/resource/bampath.txt";
my $f_e75= $script_dir."/resource/E75_bed.tsv";
#my $f_e75="/gscuser/scao/gc2524/dinglab/bed_maker/E75_bed.tsv";

##0-based##

my %bampath=();
my %bampathchr=();
my %known_junc=();
my %known_junc_s=(); 

open(OUT,">$f_out");

my $f_out2=$f_out.".detailed.alignment.run2"; 
open(OUT2,">$f_out2"); 

foreach my $l (`cat $f_e75`) 
	{
		my $ltr=$l; 
		chomp($ltr); 
		my @temp=split("\t",$ltr); 
		my @temp2=split(":",$temp[3]); 		

		if($temp2[3]=~/^i/) { 
		#print $temp[0],"\t",$temp[1],"\t",$temp[2],"\n"; 
		#<STDIN>;
		$known_junc{$temp[0]}{$temp[1]}{$temp[2]}=1; 
		$known_junc_s{$temp[0]}{$temp[1]}=1;
        $known_junc_s{$temp[0]}{$temp[2]}=1;
			}

	}

foreach my $l (`cat $f_bam_list`) 
	{
		my $ltr=$l; 
		chomp($ltr); 
	 	my @temp=split(" ",$ltr); 
		#print $temp[2],"\t",$temp[4],"\n";	
		my $sn=substr($temp[0],0,12); 
		#if($temp[4]=~/chr/) { $bampathchr{$sn}=$temp[2]; }
		if($temp[3]=~/chr/) { $bampathchr{$sn}=$temp[2]; }
		else { $bampath{$sn}=$temp[2]; }
	}

foreach my $l (`cat $f_in`)
	{
		my $ltr=$l; chomp($ltr); 
		my @temp=split("\t",$ltr);
		# sample list 104 ###
		#my $slist=$temp[104];
		my $slist=$temp[14];
		my @tempn=split(/\,/,$slist);
		my $ns=scalar @tempn; 

		for(my $i=0;$i<$ns;$i++)
		{		

		my $sn=$tempn[$i]; 
		#print $sn,"\n";
		#<STDIN>; 	
		my $chr=$temp[1]; 
		my $pos=$temp[2];
		my $ref=$temp[7];
		my $var=$temp[9]; 
        my $dellen=0;
        if($var eq "-") { $dellen=length($ref); }
		#print $chr,"\t",$pos,"\n";
		my $chr_pos; 
		my $bam="NULL";
		my $chr_bk=$chr; 
		my $pos_bk=$pos; 

		###104###

		if(defined $bampathchr{$sn} && (-e $bampathchr{$sn}))
		{
			my $left_pos=$pos-20; 
			my $right_pos=$pos+20; 
			$chr_pos="chr".$chr.":".$left_pos."-".$right_pos;
			$bam=$bampathchr{$sn};
			#print $bam,"\n";
		}
 
		if(defined $bampath{$sn} && (-e $bampath{$sn}))
        {
            my $left_pos=$pos-20;
            my $right_pos=$pos+20;
            $chr_pos=$chr.":".$left_pos."-".$right_pos;
			$bam=$bampath{$sn};
			#print $bam,"\n";
        } 
			
		if($bam ne "NULL" && (-e $bam)) 
		{
			#print $bam,"\n";
			my $com=`miniconda3/bin/samtools view $bam \"$chr_pos\"`;
			#print $com; 
			my @temp=split("\n",$com); 
			my %count_read=();
			foreach my $t (@temp)
			{
				my @temp2=split("\t",$t);
				#print $t,"\n"; 
				if($temp2[5]=~/^(\d+)M(\d+)N(\d+)M$/)
				{

					#print $temp2[5],"\n";
					my $chr=$temp2[2]; 
					my $start_pos=$temp2[3];
					my $id=$temp2[0]; 
					my $flag=$temp2[1];
					my $r1;
					my $r2; 
					my $rid=$id; 
					my $x=$start_pos+$1-1;
                    my $y=$start_pos+$1+$2-2;
					my $mapq=$temp2[4];
					if($id=~/\/2$/ || ($flag & 0x80)) { $rid=$id; $rid=~s/\/2$//g; $rid.="\/2";  }
					if($id=~/\/1$/ || ($flag & 0x40)) { $rid=$id; $rid=~s/\/1$//g; $rid.="\/1"; } 
					#my $x=$start_pos+$1-1; 
					#my $y=$start_pos+$1+$2-2; 
					#print $t,"\n";	
					#print $rid,"\n";
					#<STDIN>;
					#print $start_pos,"\n";
					#print $1,"\n";
					#print $2,"\n";
					#print $t,"\n";
					#print $x,"\t",$y,"\t",$mapq,"\n";
					#<STDIN>;			
					if($chr=~/^chr/) { $chr=$chr; }
                    else { $chr="chr".$chr; }
					#print $chr,"\t",$x,"\t",$y,"\t",$temp2[6],"\n";
					#<STDIN>;
					#if(!defined $known_junc{$chr}{$x}{$y} && ($temp2[6] eq "=") && ($mapq>=20 && $mapq!=255) && (($x>=$pos-20 && $x<=$pos+20) || ($y>=$pos-20 && $y<=$pos+20)))						
                    if(!defined $known_junc{$chr}{$x}{$y} && (!($y-$x+1==$dellen)) && ($temp2[6] eq "=") && ($mapq>=20 && $mapq!=255) && (($x>=$pos-20 && $x<=$pos+20 && (!defined $known_junc_s{$chr}{$x})) || ($y>=$pos-20 && $y<=$pos+20 && (!defined $known_junc_s{$chr}{$y}))))
					{ 
				      	#print $t,"\n";  
                    	#print $rid,"\n";
                    	#print $start_pos,"\n";
                    	#print $1,"\n";
                    	#print $2,"\n"; 
						#print $chr,"\n";
						#print $x,"\t",$y,"\n";
						#<STDIN>;	
						$count_read{$rid}=$t; 
					}	
				}		
			}
		
			my $n_key=keys %count_read;

			if($n_key>=1) 
			{
			 my $ltr=$l;
			 chomp($ltr); 
			 print OUT $sn,"\t",$n_key,"\n";  
			 print OUT2 $sn,"\t",$chr_bk,"\t",$pos_bk,"\t",$ref,"\t",$var,"\n";
			 foreach my $rr (sort keys %count_read)
				{
					print OUT2 $count_read{$rr},"\n";
				}
			}
			else { print OUT $sn,"\t","0","\n"; }
		}	
		
	}
}

close OUT;
close OUT2; 
