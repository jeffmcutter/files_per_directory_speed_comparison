#!/bin/bash

DATAFILE=/tmp/disk_test_hierarchy.$$

function die {
  echo "ERROR: $1"
  exit 1
}
  
function worker {
  START=1
  END=1000
  DIR=$1

  mkdir $DIR || die "Failed to create dir $DIR!"

  cd $DIR || die "Failed to cd to $DIR!"
  seq $START $END | xargs touch
  cd - > /dev/null

}

function run_test {

  COUNT=$1

  # For every 1000 requested, run worker 1 time and increment $PASS.
  PASS=1
  PASSES=$(expr $COUNT / 1000)

  while [ $PASS -le $PASSES ]
  do
    worker $PASS
    PASS=$(expr $PASS + 1)
  done


}

function time_test {
  COUNT=$1
  CREATE=$( (time -p run_test $COUNT ) 2>&1 | awk '/real/ {print $NF}')
  echo "$COUNT,$CREATE" | tee -a $DATAFILE
  rm -r  [0-9]*
}

mkdir disk_test || die "Failed to create dir disk_test!"
cd disk_test || die "Failed to cd to disk_test!"

echo "number_of_files,time_to_create" | tee $DATAFILE

time_test 1000
time_test 2000
time_test 3000
time_test 4000
time_test 5000
time_test 6000
time_test 7000
time_test 8000
time_test 9000
time_test 10000
time_test 12500
time_test 15000
time_test 17500
time_test 20000
time_test 30000
time_test 40000
time_test 50000
time_test 75000
time_test 100000

cd ..
rmdir disk_test

echo Plotting $DATAFILE...
echo "
set grid
set title 'Disk performance and number of files per directory'
set xlabel 'Number of Files'
set ylabel 'Seconds'
set yrange [0:700]
set datafile separator ','
plot \"$DATAFILE\" u 1:2 w lp t 'time_to_create'
" | gnuplot

#plot \"$DATAFILE\" u 1:2 w lp t 'time_to_create', \"$DATAFILE\" u 1:3 w lp t 'time_to_list', \"$DATAFILE\" u 1:4 w lp t 'time_to_remove'

echo "DATAFILE is stored at $DATAFILE"


