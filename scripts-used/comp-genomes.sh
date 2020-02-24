#!/bin/bash

BASE=/Volumes/Bennett_BACKUP/Research/jensen-metabolites/fiji_sal-microscale/genome_comp

cd $BASE


# curate the genomes by filtering and renaming to finalize genomes
# from the output of genome assemblers, I named the genomes by strainID.assembler.fasta
for fas in *.fasta
do
	genome=$(echo $fas | cut -f1 -d'.')
	method=$(echo $fas | cut -f2 -d'.')

	# remove contigs with less than 500bp across all assembled genomes
	removesmalls.py -i $fas -l 500 -o $genome.$method.fix.fasta > /dev/null 2>&1

	# calculate some genomic stats
	n50_calc.py $genome.$method.fix.fasta > /dev/null 2>&1

	rm -f $genome.$method.fix_rejected.fasta
	rm -f $genome.$method.fix.fasta

	echo "done with ${genome}"

done


# combine all the genomic stats together
rm -rf $BASE/total.genome.stats.txt
cat *_n50.txt | awk '!seen[$0]++' > $BASE/total.genome.stats.txt
rm *_n50.txt

### OPTIONAL
# can run a pairwise ANI to see if any assemblers are totally off - would guess not, so didn't run
#ani-aai-matrix.sh -m ani -i .fix.fasta -t 8

