#!/bin/bash
# Copyright(c) 2018 Cloudera Inc. 
# Hadoop build script to run within Jenkins

set -o xtrace
set -e

BUILDS_DIR="/builds"
SLS_BASH_SCRIPT_PATH="cdh/testing/tests/SLS/bin/"
SLS_PYTHON_SCRIPT_PATH="cdh/testing/tests/SLS/python/"

if [ -z "$WORKLOAD_TYPES" ]; then
    echo "WORKLOAD_TYPES should not be empty!"
    exit 1
fi

if [ -z "$SLS_BUILD_NUMBER" ]; then
    ls -dt $BUILDS_DIR/sls*/ | head -n 2
    dirs=($(ls -dt $BUILDS_DIR/sls*/ | head -n 2))
    if [[ ${dirs[0]} =~ .*baseline.* ]] ; then 
        BASELINE_SLS_DIR=${dirs[0]};
        SLS_DIR=${dirs[1]};
    fi
    if [[ ${dirs[1]} =~ .*baseline.* ]] ; then 
        BASELINE_SLS_DIR=${dirs[1]};
        SLS_DIR=${dirs[0]}
    fi
else
    dirs=($(ls -dt $BUILDS_DIR/sls*_build${SLS_BUILD_NUMBER}*/))
    if [[ ${dirs[0]} =~ .*baseline.* ]] ; then 
        BASELINE_SLS_DIR=${dirs[0]};
        SLS_DIR=${dirs[1]};
    fi
    if [[ ${dirs[1]} =~ .*baseline.* ]] ; then 
        BASELINE_SLS_DIR=${dirs[1]};
        SLS_DIR=${dirs[0]}
    fi
fi

if [ ! -d "$BASELINE_SLS_DIR" ]; then
    echo "Baseline SLS directory was not found for build number: $SLS_BUILD_NUMBER"
    echo "Listing $BUILDS_DIR"
    ls -la $BUILDS_DIR
fi

if [ ! -d "$SLS_DIR" ]; then
    echo "SLS directory was not found for build number: $SLS_BUILD_NUMBER"
    echo "Listing $BUILDS_DIR"
    ls -la $BUILDS_DIR
fi


pushd $SLS_PYTHON_SCRIPT_PATH
echo "Generating SLS input files..."
for i in $(echo $WORKLOAD_TYPES | sed "s/,/ /g")
do
    python generate_config.py --dirs . --workload $i
done


pushd $SLS_BASH_SCRIPT_PATH
#TODO fill
DIRECTORY_OF_TESTS=""

#TODO fill
HADOOP_DIST_DIR=""

exit 1
#./run_test_set.sh  $DIRECTORY_OF_TESTS $SCHEDULER_TYPE $HADOOP_DIST_DIR $NUMBER_OF_RUNS