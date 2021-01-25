#!/bin/bash
set -o xtrace
cd /hadoop;
groupadd -g 1000 jenkins
useradd -d /hadoop -u 1000 -g 1000 jenkins
echo export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 >> /etc/profile
echo export PATH=$JAVA_HOME/bin:/opt/cmake/bin:/opt/protobuf/bin:$PATH >>/etc/profile
echo export CPLUS_INCLUDE_PATH=/opt/protobuf/include >>/etc/profile
echo export C_INCLUDE_PATH=/opt/protobuf/include >>/etc/profile
echo export LIBRARY_PATH=/opt/protobuf/lib >>/etc/profile
echo export LD_LIBRARY_PATH=/opt/protobuf/lib >>/etc/profile
echo export PROTOBUF_LIBRARY >>/etc/profile
echo export PROTOBUF_INCLUDE_DIR >>/etc/profile 

cat /etc/profile
chown -R 1000:1000 .
# chown -R jenkins:jenkins /root/
chown -R 1000:1000 /root/
# chmod 777 1000:1000 /root/.config
# chmod 777 1000:1000 /root/.npm
# echo "fazil"
# chown -R jenkins:jenkins /root/.config
# chown -R 1000:1000 /root/.config
if [ -f /opt/mvn/apache-maven-3.3.9/bin/mvn ]
then
  /opt/maven/bin/mvn --version;
  sudo -u jenkins -g jenkins bash --login -c "/opt/maven/bin/mvn $MVN_PARAMS"
else
  mvn --version;
  sudo -u jenkins -g jenkins bash --login -c "mvn $MVN_PARAMS"
fi
chown -R 1000:1000 .