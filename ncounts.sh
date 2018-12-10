
tr '\n' ' ' | tr '>' '\n' | tail -n +2 | while read name seq; do 
  echo "$name	$(echo $seq | grep -o '[Nn]' | wc -l)"
done
