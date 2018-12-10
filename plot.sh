
# Usage: plot.sh <filename> <avg coverage>

# OUTPUT="set term pngcairo dashed size 1280,1024"
# SUF=png

# OUTPUT="set term pdf"
# SUF=pdf

# Nicer output than PDF, use epstopdf after
OUTPUT="set term postscript eps"
SUF=eps

# Lookup-table of coverages
covlookup(){
grep $1 << EOF
Pacific_females 1.1
Atlantic_male 0.28
Pacific_male 1.20
Antarctic 0.98
EOF
}

coverage(){
   covlookup $1 | cut -f2 -d ' '
}

cov_by_length(){
echo "generating cov by length for $1 ($SUF)"

n=$1
f=$n.sum_stats
cov=$(coverage $1)
# cat xy.list | while read c; do grep "$c	" "$f"; done | awk '{if($2>1e4)print}' > tmp.xy
paste "$f" classes.tab | grep Long | grep XY > tmp.xy
paste "$f" classes.tab | grep Marker > tmp.marker
paste "$f" classes.tab | grep Long | grep SC > tmp.sc

gnuplot << EOF
$OUTPUT
set out "$n.$SUF"
# set title "$n"
set xlabel "scaffold length"
set ylabel "reads/length"
set xrange [0:1e7]
set yrange [-0.1*$cov:3*$cov]

set arrow from 0,$cov/2 to 1e7,$cov/2 nohead lc rgb "black" lt 3
set arrow from 0,$cov to 1e7,$cov nohead lc rgb "black" lt 1
set arrow from 0,$cov*2 to 1e7,$cov*2 nohead lc rgb "black" lt 3


plot "$f" using 2:3 ti "" pt 1 ps 0.5, \
  $cov ti "" lc 0, \
  "tmp.xy" using 2:3 ti "" lc rgb "blue" pt 1 ps 0.8, \
  "tmp.marker" using 2:3:(\$2*0+95000) ti "" with circles lw 1.5 lt 1 lc rgb "green", \
  "tmp.sc" using 2:3:(\$2*0+95000) ti "" with circles lt 1 lw 1.5 lc rgb "orange"
EOF
}



cov_vs_cov(){
echo "generating cov by cov for $1 vs $2 ($SUF)"

f1=$1.sum_stats
f2=$2.sum_stats

paste $f1 $f2 classes.tab | awk '{if($2>1e3)print}' > tmp.all
grep Long tmp.all > tmp.long
grep XY tmp.long > tmp.xy
grep SC tmp.long > tmp.sc
grep Marker tmp.long > tmp.marker

cov1=$(coverage $1)
cov2=$(coverage $2)

gnuplot << EOF
$OUTPUT
set out "$1.vs.$2.$SUF"
# set title "Coverage, $1 vs $2"
set xlabel "$1"
set ylabel "$2"
set xrange [-0.1*$cov1:3*$cov1]
set yrange [-0.1*$cov2:3*$cov2]

set arrow from $cov1,-0.1*$cov2 to $cov1,3*$cov2 nohead lc rgb "black" lt 1
set arrow from $cov1/2,-0.1*$cov2 to $cov1/2,3*$cov2 nohead lc rgb "black" lt 3

set arrow from -0.1*$cov1,$cov2 to 3*$cov1,$cov2 nohead lc rgb "black" lt 1
set arrow from -0.1*$cov1,$cov2/2 to 3*$cov1,$cov2/2 nohead lc rgb "black" lt 3

plot \
  "tmp.all"    using 3:12 ti ""       pt 1 ps 0.5 lc rgb "gray", \
  "tmp.long"   using 3:12 ti ""       pt 1 ps 0.5 lc rgb "red", \
  "tmp.xy"     using 3:12 ti ""       pt 1 ps 0.5 lc rgb "blue", \
  "tmp.sc"     using 3:12:(\$3*0+$cov1/40) ti ""       with circles lw 1.5 lt 1 lc rgb "orange", \
  "tmp.marker" using 3:12:(\$3*0+$cov1/40) ti ""       with circles lw 1.5 lt 1 lc rgb "green"

EOF

# todo: add lines indicating expected coverage
}

cov_by_length Pacific_females
cov_by_length Atlantic_male
cov_by_length Pacific_male
cov_by_length Antarctic

cov_vs_cov Pacific_male Pacific_females
cov_vs_cov Pacific_male Atlantic_male 
cov_vs_cov Pacific_male Antarctic 
cov_vs_cov Atlantic_male Pacific_females

cov_vs_cov Atlantic_male Antarctic
cov_vs_cov Pacific_females Antarctic
