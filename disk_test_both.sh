#!/bin/bash

#SLEEP=0

NAME=$(basename $0)

function usage {
  echo "USAGE: $NAME [ -p | -P <INPUT_FILE> ] [ -n <OUTPUT_FILE> ]"
  echo "	If neither -p nor -P is specified, the test will just run."
  echo "	-p will run the test, save output to file, and plot the current run with gnuplot."
  echo "	-P <INPUT_FILE> will not run test, but will plot the specified INPUT_FILE."
  echo "	-n <OUTPUT_FILE> will save output into a file named <OUTPUT_FILE> in the current directory."
  exit 1
}

while getopts "pP:n:" opt; do
  case $opt in
    p) PLOT_IT="true"
       ;;
    P) PLOT_IT="true"
       PLOT_FILE="$OPTARG"
       ;;
    n) DATA_FILE="$OPTARG"
       ;;
    *) usage
       ;;
  esac
done

shift $((OPTIND-1))

if [ $# -ne 0 ]
then
  usage
fi

# If $DATA_FILE is not set by getopts, set a default.
if [ -z "$DATA_FILE" ]
then
  DATA_FILE=/tmp/disk_test_both.$$
fi

# Plot results on a graph.
function plot_it {

  if [ -z "$PLOT_FILE" ]
  then
    PLOT_FILE="$DATA_FILE"
  fi

  echo Plotting $PLOT_FILE...
  echo "
set grid
set title 'Disk performance and number of files per directory'
set xlabel 'Number of Files'
set ylabel 'Seconds'
set datafile separator ','
plot \"$PLOT_FILE\" u 1:2 w lp t 'flat', \"$PLOT_FILE\" u 1:3 w lp t 'hierarchical'
" | gnuplot
}


# If PLOT_FILE is specified then just plot the graph.
if [ -n "$PLOT_FILE" ]
then
  plot_it
  exit $?
fi

# This may not work right, haven't really checked, but feel it's suspect.
function die {
  echo "ERROR: $1"
  exit 1
}

# Run the test for all files in same dir.
function flat_test {
  START=1
  END=$1

  mkdir $END || die "Failed to create dir $END!"


  cd $END || die "Failed to cd to $END!"
  seq 1 $END | xargs touch
  cd - > /dev/null

}

# Create a directory and put 1000 files in it.
function hier_worker {
  START=1
  END=1000
  DIR=$1

  mkdir $DIR || die "Failed to create dir $DIR!"

  cd $DIR || die "Failed to cd to $DIR!"
  seq $START $END | xargs touch
  cd - > /dev/null

}

# Run the right number of hier_workers to get the desired number of files.
function hier_test {

  COUNT=$1

  # For every 1000 requested, run heir_worker 1 time and increment $PASS.
  PASS=1
  PASSES=$(expr $COUNT / 1000)

  while [ $PASS -le $PASSES ]
  do
    hier_worker $PASS
    PASS=$(expr $PASS + 1)
  done


}

# Run and time both types of test.
function time_tests {
  COUNT=$1
  
  # Seems like a good before test.
  sync;sync;sync;sync;sync
  sleep 5

  # Do flat test.
  FLAT=`(time -p flat_test $COUNT) 2>&1 | awk '/real/ {print $NF}'`
  rm -r $COUNT

  # Seems like a good idea before test.
  sync;sync;sync;sync;sync
  sleep 5

  # Do hierarchical test.
  HIER=$( (time -p hier_test $COUNT) 2>&1 | awk '/real/ {print $NF}')
  rm -r  [0-9]*

  # Results.
  echo "$COUNT,$FLAT,$HIER" | tee -a $DATA_FILE
}

mkdir disk_test || die "Failed to create dir disk_test!"
cd disk_test || die "Failed to cd to disk_test!"

echo "number_of_files,flat,hierarchical" | tee $DATA_FILE

time_tests 1000
time_tests 2000
time_tests 3000
time_tests 4000
time_tests 5000
time_tests 6000
time_tests 7000
time_tests 8000
time_tests 9000
time_tests 10000
time_tests 12500
time_tests 15000
time_tests 17500
time_tests 20000
time_tests 30000
time_tests 40000
time_tests 50000
time_tests 75000
time_tests 100000

cd ..
rmdir disk_test

echo "DATA_FILE is stored at $DATA_FILE"

if [ "$PLOT_IT" == "true" ]
then
  plot_it
fi


