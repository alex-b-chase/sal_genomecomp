# sal_genomecomp
comparing different genome assembly platforms for Salinispora

# Overview
data from a MiSeq run on 16 genomes isolated from a 1x1m plot

Compared the [a5 pipeline](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0042304) (optimized for MiSeq data), [SPAdes](https://github.com/ablab/spades), [RAY](https://github.com/sebhtml/ray), [ABySS](https://github.com/bcgsc/abyss), and [Velvet](http://sepsis-omics.github.io/tutorials/modules/velvet/).

Salinispora is a marine sediment bacterium that has ~5.5Mbp genome sizes with 70% GC.

For all assemblers, 8 cores were used and kmer=81. Reads were first QC filtered with BBDuk unless otherwise specified.

```
bbduk.sh in1=$FFILE in2=$RFILE \
out1=$REF.R1.clean.fq out2=$REF.R2.clean.fq \
minlen=25 qtrim=rl trimq=10 ktrim=r k=25 ref=$BBMAPDIR/nextera.fa.gz hdist=1
```

# a5
```
a5_pipeline.pl --threads=$THREAD \
$READBASE/$REF.R1.clean.fq $READBASE/$REF.R2.clean.fq $REF
```

# ABySS
requires some extra formatting for read input
```
repair.sh in1=$REF.R1.clean.fq in2=$REF.R2.clean.fq \
out1=$OUTDIR/$REF.R1.clean.fix.fq out2=$OUTDIR/$REF.R2.clean.fix.fq \
outsingle=singletons.fq

reformat.sh in1=$OUTDIR/$REF.R1.clean.fix.fq in2=$OUTDIR/$REF.R2.clean.fix.fq \
out1=$OUTDIR/$REF.R1.final.fq out2=$OUTDIR/$REF.R2.final.fq addslash

sed 's/ /_/g' $OUTDIR/$REF.R1.final.fq > $OUTDIR/$REF.R1.final.fix.fq
sed 's/ /_/g' $OUTDIR/$REF.R2.final.fq > $OUTDIR/$REF.R2.final.fix.fq

abyss-pe np=$THREAD k=81 name=$REF \
in='CNZ-840.R1.final.fix.fq CNZ-840.R2.final.fix.fq'
```

# RAY
RAY uses its own QC so just need to get raw data in the right format.
```
zcat $FFILE > $READBASE/ray/$REF.R1.fq
zcat $RFILE > $READBASE/ray/$REF.R2.fq

reformat.sh in1=$READBASE/ray/$REF.R1.fq in2=$READBASE/ray/$REF.R2.fq \
out1=$READBASE/ray/$REF.R1.fa out2=$READBASE/ray/$REF.R2.fa

rm -rf $OUTDIR
rm -f $READBASE/ray/$REF.R1.fq
rm -f $READBASE/ray/$REF.R2.fq

cd $READBASE/ray

mpiexec -n $THREAD Ray -k81 \
-p $REF.R1.fa $REF.R2.fa -o $OUTDIR
```

# SPAdes
```
spades.py -k 31,41,51,61,71,81 --careful -t $THREAD \
-1 $REF.R1.clean.fq.gz -2 $REF.R2.clean.fq.gz \
-o $OUTDIR
```

# Velvet
again, there is a built-in part here for QC filtering, just need rawdata.
```
velveth $OUTDIR 81 \
-shortPaired -fastq -separate $FFILE $RFILE 

velvetg $OUTDIR \
-cov_cutoff auto -ins_length 270 -min_contig_lgth 500 -exp_cov auto 
```

