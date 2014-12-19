#!/bin/bash

DATAFILE=/tmp/disk_test_flat.$$
#SLEEP=0

function die {
  echo "ERROR: $1"
  exit 1
}
  
function run_test {
  START=1
  END=$1

  mkdir $END || die "Failed to create dir $END!"


  cd $END || die "Failed to cd to $END!"
  CREATE=`(time -p seq 1 $END | xargs touch) 2>&1 | awk '/real/ {print $NF}'`
  cd - > /dev/null

  #sleep $SLEEP
  #LIST=`(time -p ls -l | wc -l > /dev/null 2>&1) 2>&1 | awk '/real/ {print $NF}'`


  #sleep $SLEEP
  #REMOVE=`(time -p find $END | xargs rm) 2>&1 | awk '/real/ {print $NF}'`

  rm -r $END

  #echo "$END,$CREATE,$LIST,$REMOVE" | tee -a $DATAFILE
  echo "$END,$CREATE" | tee -a $DATAFILE

}

mkdir disk_test || die "Failed to create dir disk_test!"
cd disk_test || die "Failed to cd to disk_test!"

echo "number_of_files,time_to_create" | tee $DATAFILE

#n=1000
#inc=1000
#while [ $n -le 25000 ]
#do
#  run_test $n
#  (( n = $n + $inc ))
#done

run_test 1000
run_test 2000
run_test 3000
run_test 4000
run_test 5000
run_test 6000
run_test 7000
run_test 8000
run_test 9000
run_test 10000
run_test 12500
run_test 15000
run_test 17500
run_test 20000
run_test 30000
run_test 40000
run_test 50000
run_test 75000
run_test 100000

cd ..
rm -r disk_test


echo Plotting $DATAFILE...
echo "
set grid
set title 'Disk performance and number of files per directory'
set xlabel 'Number of Files'
set ylabel 'Seconds'
set datafile separator ','
plot \"$DATAFILE\" u 1:2 w lp t 'time_to_create'
" | gnuplot

#plot \"$DATAFILE\" u 1:2 w lp t 'time_to_create', \"$DATAFILE\" u 1:3 w lp t 'time_to_list', \"$DATAFILE\" u 1:4 w lp t 'time_to_remove'

echo "DATAFILE is stored at $DATAFILE"


