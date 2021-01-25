#!/usr/bin/env bash


#Raise ulimits in jenkins container
#docker exec -u 0 -it jenkins bash -c 'echo "fs.file-max = 800000" >> /etc/sysctl.conf; sysctl -p'
#docker exec -u 0 -it jenkins bash -c 'echo "jenkins       hard    nofile          800000" >> /etc/security/limits.conf'
#docker exec -u 0 -it jenkins bash -c 'echo "jenkins       soft    nofile          800000" >> /etc/security/limits.conf'
#docker exec -u 0 -it jenkins bash -c "echo \"Limit of open files (soft): $(ulimit -Sn)\"; echo \"Limit of open files (hard): $(ulimit -Hn)\""

echo "fs.file-max = 800000" >> /etc/sysctl.conf; sysctl -p
echo "jenkins       hard    nofile          800000" >> /etc/security/limits.conf
echo "jenkins       soft    nofile          800000" >> /etc/security/limits.conf
echo "Limit of open files (soft): $(ulimit -Sn)"; echo "Limit of open files (hard): $(ulimit -Hn)"
#restart docker daemon to apply new ulimit
#service docker restart