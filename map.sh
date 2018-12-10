# Use: parallel -S :,hathor,horus -n 2 map.sh ::: reads/*

G=B_acuto-0.0.scaffold.fa

bwa mem -t 16 $G $1 $2 | samtools view -Sb - > $(basename $1 .fastq | sed -e 's/_R.*//g' -e 's/_[12].*//g').bam
