FROM jenkins/jenkins:lts
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
USER root
RUN apt update;apt install -y wget build-essential nano autoconf automake libtool zlib1g-dev pkg-config libssl-dev curl make gcc g++ unzip openssl git libssl-dev openjdk-8-jdk cmake
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
RUN POPD=$PWD;mkdir /opt/protoc;cd /opt/protoc;wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz;tar -xf protobuf-2.5.0.tar.gz;cd $WORKSPACE/protobuf-2.5.0;./configure;make;find .;cd $POPD
RUN POPD=$PWD;mkdir /opt/mvn;cd /opt/mvn;wget http://www-us.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz;tar -xf apache-maven-3.3.9-bin.tar.gz;chmod -R o+r /opt/mvn/apache-maven-3.3.9;cd $POPD
COPY casc.yaml /var/jenkins_home/casc.yaml
USER jenkins
ADD hadoop_jenkins.sh /
ADD jenkins_hadoopbuild_command.sh /
ADD sls /
ADD hadoop.groovy /