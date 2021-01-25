#!/bin/bash
# Copyright(c) 2018 Cloudera Inc. 
# Hadoop build script to run within Jenkins

set -o xtrace
export MVN_PARAMS=$MVN_PARAMS

# TODO check is there any diff between BASELINE_BRANCH vs BRANCH
# TODO check branch exists
#TODO check exit code of build_hadoop_sls.sh calls

GIT_BRANCH=$BASELINE_BRANCH
git checkout origin/$GIT_BRANCH
echo "***********************************************"
echo "Building Hadoop SLS on branch $GIT_BRANCH..."
echo "***********************************************"
/build_hadoop_sls.sh "baseline_$GIT_BRANCH"

GIT_BRANCH=$BRANCH
git checkout origin/$GIT_BRANCH
echo "***********************************************"
echo "Building Hadoop SLS on branch $GIT_BRANCH..."
echo "***********************************************"
/build_hadoop_sls.sh "$GIT_BRANCH"
