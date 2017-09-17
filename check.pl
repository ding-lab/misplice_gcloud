use strict;


#7a27b3da-4786-4903-8e83-8a2ab8b0d299	TCGA-KO-8408-01A-11R-2315-07	3405fefa-29da-429f-9cac-01e07abcfedc	gs://5aa919de-0aa0-43ec-9ec3-288481102b6d/tcga/KICH/RNA/RNA-Seq/UNC-LCCC/ILLUMINA/UNCID_1703788.3405fefa-29da-429f-9cac-01e07abcfedc.sorted_genome_alignments.bam	6578335719

open(my $RNA,'<',$ARGV[0]) or die "INPUT RNA not found!";
my $datadirectory=$ARGV[1];

while (<$RNA>){
	chomp;
	my @a = split(/\t/,$_);
	my $sample = $a[1];
	my $ogbam = $a[3];
	my @baminfo = split(/\//,$ogbam);
	my $bam = pop @baminfo;
	my $fullbam = $datadirectory."/".$bam;
	pop @baminfo;
	pop @baminfo;
	pop @baminfo;
	pop @baminfo;
	
	my $cancer = pop @baminfo;
	#Check header of bam file
	my $cmd = "miniconda3/bin/samtools view -H ".$fullbam."|head -n2|tail -n1";	
	my $type = `$cmd`;
	chomp $type;
	my @chrinfo = split(/\t/,$type);
	my $chr = $chrinfo[1];
	$chr =~ m/SN\:(.*)/;
	my $cancerlower = lc($cancer);
	print "$sample\t$cancerlower\t$fullbam\t$1\n";
	
}



