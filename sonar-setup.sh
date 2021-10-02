#!/bin/bash
cp /etc/sysctl.conf /root/sysctl.conf_backup
cat <<EOT>> /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
EOT

cp /etc/security/limits.conf /root/sec_limit.conf_backup
cat <<EOT>> /etc/security/limits.conf

sonarqube   -   nofile   65536
sonarqube   -   nproc    4096
EOT

sudo apt-get update -y
sudo apt-get install wget unzip -y
sudo apt-get install openjdk-11-jdk -y
sudo apt-get install openjdk-11-jre -y
sudo update-alternatives --config java
java -version

sudo apt update

# Install PostgreSQL:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo apt-get install postgresql postgresql-contrib -y

# sudo /usr/pgsql/bin/postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

sudo echo "postgres:admin123" | chpasswd
runuser -l postgres -c "createuser sonar"
sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED password 'admin123';"
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -i -u postgres psql -c "grant all privileges on DATABASE sonarqube to sonar;"

sudo systemctl restart  postgresql
#systemctl status -l   postgresql
netstat -tulpena | grep postgres

sudo mkdir -p /sonarqube/
cd /sonarqube/
sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.1.44547.zip
sudo apt-get install unzip -y
sudo unzip -o sonarqube-8.9.1.44547.zip -d /opt
sudo mv /opt/sonarqube-8.9.1.44547/ /opt/sonarqube

# Create a group as sonar
sudo groupadd sonar
# Add the user with directory access
sudo useradd -c "User to run - SonarQube" -d /opt/sonarqube/ -g sonar sonar
sudo chown -R sonar:sonar /opt/sonarqube/ 
cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup

cat <<EOT> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube

sonar.web.host=0.0.0.0
sonar.web.port=9000
# sonar.web.javaAdditionalOpts=-server -Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
# sonar.search.javaOpts=-server -Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
# sonar.path.data=/var/sonarqube/data
# sonar.path.temp=/var/sonarqube/temp
EOT

cat <<EOT> /opt/sonarqube/bin/linux-x86-64/sonar.sh
RUN_AS_USER=sonar
EOT

#change into sonar user, press bash to get the command line, cd /opt/sonarqube/bin/linux-x86-64 then ./sonar.sh start

cat <<EOT>> /etc/systemd/system/sonar.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
sudo systemctl enable sonarqube.service
sudo systemctl start sonarqube.service
#systemctl status -l sonarqube.service

apt-get install nginx -y
rm -rf /etc/nginx/sites-enabled/default
rm -rf /etc/nginx/sites-available/default
cat <<EOT>> /etc/nginx/sites-available/sonarqube
server {
    listen      80;
    server_name sonarqube.groophy.in;
    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;
    include /etc/nginx/default.d/*.conf;
    proxy_buffers 16 64k;
    proxy_buffer_size 128k;
    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
              
        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT

ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
systemctl enable nginx.service
#systemctl restart nginx.service
# sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
# sudo firewall-cmd --zone=public --add-port=9000/tcp --permanent
# sudo firewall-cmd --zone=public --add-port=9001/tcp --permanent
# sudo firewall-cmd --zone=public --add-service=http --permanent
# sudo firewall-cmd --zone=public --add-service=https --permanent 
# sudo firewall-cmd --reload
sudo ufw allow 80,9000,9001/tcp
echo "System reboot in 30 sec"
sleep 30
reboot