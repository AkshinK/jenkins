#!/bin/bash
# Copyright Cloudera Inc. 2018
# Script to build up a Jenkins master

service firewalld stop

# Reference: https://github.com/jenkinsci/docker
if ! which docker
then
  curl https://get.docker.com | bash
  service docker start
fi
chown root:1000 /var/run/docker.sock

#Docker service restart is required, because sometimes docker containers does not have internet connection.
#See: https://stackoverflow.com/questions/20430371/my-docker-container-has-no-internet
service docker restart
docker build ./ -t hadoop/jenkins

id -u uploader &>/dev/null;user_exists=$(echo $?)
if [ "$user_exists" -ne "0" ]; then
    useradd -m uploader
    mkdir /home/uploader/.ssh
    touch /home/uploader/.ssh/authorized_keys
fi

docker kill nginx 2>/dev/null
sleep 1

BUILDS_DIR="/builds"
if [ ! -d ${BUILDS_DIR} ]
then
  mkdir ${BUILDS_DIR}
fi
chmod -R go+rwX ${BUILDS_DIR}
docker run -d -p 80:80 --name nginx --rm -v ${BUILDS_DIR}:/usr/share/nginx/html/builds:ro nginx

docker kill jenkins 2>/dev/null
sleep 1
if [ ! -d ${BUILDS_DIR} ]
then
    mkdir /hadoop
    mkdir /hadoop-sls-build
    mkdir /sls-runner
fi


chown 1000:1000 /hadoop
chown 1000:1000 /hadoop-sls-build
chown 1000:1000 /sls-runner

chmod ug+rwx /hadoop
chmod ug+rwx /hadoop-sls-build
chmod ug+rwx /sls-runner

docker run -d -p 8080:8080 -p 5005:5005 \
-h `hostname` --name jenkins \
-v ${BUILDS_DIR}:${BUILDS_DIR}:rw \
-v /var/run/docker.sock:/var/run/docker.sock:rw \
-v /usr/bin/docker:/usr/bin/docker:ro \
-v /hadoop:/var/jenkins_home/workspace/hadoop:rw \
-v /hadoop-sls-build:/var/jenkins_home/workspace/hadoop-sls-build:rw \
-v /sls-runner:/var/jenkins_home/workspace/sls-runner:rw \
--rm hadoop/jenkins:latest

#Add rights to user jenkins on file /var/run/docker.sock to avoid errors like below:
#Example: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post http://%2Fvar%2Frun%2Fdocker.sock/v1.37/images/create?fromImage=docker-registry.infra.cloudera.com%2Fhadoopbuild&tag=984717fc8a46048675b4c07b479e3b38: dial unix /var/run/docker.sock: connect: permission denied
docker exec -u 0 -it jenkins bash -c 'chmod 777 /var/run/docker.sock'

#In case of host machine has different UID for user 'jenkins' than the user has in the docker container, we need to update the owner of jenkins workspace directories to the jenkins user of the container.
docker exec -u 0 -it jenkins bash -c 'chown jenkins:jenkins /var/jenkins_home/workspace/hadoop'
docker exec -u 0 -it jenkins bash -c 'chown jenkins:jenkins /var/jenkins_home/workspace/hadoop-sls-build'
docker exec -u 0 -it jenkins bash -c 'chown jenkins:jenkins /var/jenkins_home/workspace/sls-runner'

printf "Waiting for startup\n"