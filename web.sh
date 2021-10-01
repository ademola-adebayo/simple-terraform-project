yum install wget unzip httpd -y
systemctl start httpd
systemctl enable httpd
wget https://ww.tooplate.com/zip-templates/2117_infinite_loop.zip
unzip -o 2117_infinite_loop/* /var/www/html/
systemctl restart httpd