
# input is a set of bam files for a single individual

cp $1 tmp.stats
rest=${@:2}

# input files have number of reads as second column
for f in $rest; do
	paste $f tmp.stats | awk '{if($1==$5){print $1"	"$2"	"($3+$7)}else{exit -1}}' > tmp2.stats
	mv tmp2.stats tmp.stats
done

paste atcounts tmp.stats | awk '{print $1"	"$5-$3"	"$6/($5-$3)"   	"$0}' | cut -f1-9 > `basename $1 .sorted.bam.stats`.sum_stats
rm tmp.stats   
	
