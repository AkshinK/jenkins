#!/bin/bash
# Copyright(c) 2018 Cloudera Inc. 
# Hadoop build script to run within Jenkins
set -o xtrace
MVN_PARAMS=${MVN_PARAMS:-clean package -Pnative -Pdist -DskipTests}

#Get docker hash from hadoop repo's Dockerfile
DOCKER_HASH=`cat dev-support/docker/Dockerfile | md5sum | head -c 32`
echo "Running command with user: `whoami`"
echo "Docker hash is: $DOCKER_HASH"

echo "Printing env: "
env

HADOOP_BUILD_CONTAINER="hadoopbuild"
DOCKER_REGISTRY="docker-registry.infra.cloudera.com"
JENKINS_COMMAND_SCRIPT="jenkins_hadoopbuild_command.sh"
DOCKER_IMAGE_REF=${DOCKER_REGISTRY}/${HADOOP_BUILD_CONTAINER}:${DOCKER_HASH}
BUILDS_DIR="/builds"

docker pull ${DOCKER_IMAGE_REF}
docker build --tag ${DOCKER_IMAGE_REF} dev-support/docker/
docker push ${DOCKER_IMAGE_REF}

cp /${JENKINS_COMMAND_SCRIPT} $WORKSPACE/${JENKINS_COMMAND_SCRIPT}
chmod a+rx $WORKSPACE/${JENKINS_COMMAND_SCRIPT}
chown 1000:1000 $WORKSPACE/${JENKINS_COMMAND_SCRIPT}

#echo "Listing contents of $WORKSPACE/${JENKINS_COMMAND_SCRIPT}: "
#cat $WORKSPACE/${JENKINS_COMMAND_SCRIPT}

docker kill ${HADOOP_BUILD_CONTAINER}
sleep 1

docker run --name ${HADOOP_BUILD_CONTAINER} --rm -p 5006:5005 -d \
-e MVN_PARAMS="${MVN_PARAMS}" \
-v /hadoop/m2:/root/.m2:rw \
-v ${BUILDS_DIR}:${BUILDS_DIR}:rw \
-v /hadoop:/hadoop:rw ${DOCKER_IMAGE_REF} bash /hadoop/${JENKINS_COMMAND_SCRIPT}

echo -e "Finished '${HADOOP_BUILD_CONTAINER}' docker container\n"

rm -f $WORKSPACE/success
docker logs -f ${HADOOP_BUILD_CONTAINER} | tee >(tail -n 100 | grep 'BUILD SUCCESS' && touch $WORKSPACE/success) | cat
if [ -f $WORKSPACE/success ]
then
  export RESULT=0
else
  export RESULT=1
fi

OUTPUT_PATH=`date +%y%m%d`_$GIT_BRANCH/$BUILD_ID
echo "Output path is: $OUTPUT_PATH"
OUTPUTDIR=`find $WORKSPACE/hadoop-dist/target -name hadoop-*-SNAPSHOT | head -n 1`
if [ -d $OUTPUTDIR ]
then
  pushd $WORKSPACE/hadoop-dist/target
  tar -czf hadoop.tar.gz `basename $OUTPUTDIR`
  popd
  mkdir -p ${BUILDS_DIR}/$OUTPUT_PATH/uncompressed
  mkdir -p ${BUILDS_DIR}/$OUTPUT_PATH/commit
  touch ${BUILDS_DIR}/$OUTPUT_PATH/commit/$GIT_COMMIT
  cp $WORKSPACE/hadoop-dist/target/hadoop.tar.gz ${BUILDS_DIR}/$OUTPUT_PATH
  ls -la ${BUILDS_DIR}/$OUTPUT_PATH
  echo "http://`hostname`${BUILDS_DIR}/$OUTPUT_PATH/hadoop.tar.gz"
else
  echo "Missing $WORKSPACE/hadoop-dist/target/hadoop-*-SNAPSHOT"
fi
exit $RESULT
