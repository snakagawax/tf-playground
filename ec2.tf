data "aws_ami" "recent_amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ami" "recent_amazon_linux_2_2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20190612-x86_64-ebs"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}



data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_instance" "webserver" {
  ami                         = data.aws_ami.recent_amazon_linux_2.image_id
  count                       = 0
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.web_instance_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids = [
    aws_security_group.webserver_sg.id,
  ]
  tags = {
    Name = "${var.system}-webserver"
  }
  user_data = <<EOF
#!bin/bash
yum install -y httpd git jq
EOF
}

resource "aws_instance" "jenkins_server" {
  ami                         = data.aws_ami.recent_amazon_linux_2.image_id
  count                       = 0
  instance_type               = "t3.medium"
  iam_instance_profile        = aws_iam_instance_profile.web_instance_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids = [
    aws_security_group.webserver_sg.id,
    aws_security_group.jenkins_sg.id,
  ]
  tags = {
    Name = "${var.system}-jenkins"
  }
  user_data = <<EOF
#!bin/bash
yum update
yum install -y httpd git
yum install java-1.8.0-openjdk-devel.x86_64
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install jenkins
service jenkins start
EOF
}

resource "aws_instance" "wordpress_server" {
  ami                         = data.aws_ami.recent_amazon_linux_2.image_id
  count                       = 0
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.web_instance_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids = [
    aws_security_group.webserver_sg.id,
  ]
  tags = {
    Name = "${var.system}-wordpress"
  }
  user_data = <<EOF
#!bin/bash
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server php72-gd
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
systemctl start mariadb
cat << "EOS" >setup.sql
CREATE USER 'wordpress-user'@'localhost' IDENTIFIED BY 'Passw0rd';
CREATE DATABASE `wordpress-db`;
GRANT ALL PRIVILEGES ON `wordpress-db`.* TO "wordpress-user"@"localhost";
FLUSH PRIVILEGES;
EOS
mysql -u root < setup.sql
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i -e "s/database_name_here/wordpress-db/g" wordpress/wp-config.php
sed -i -e "s/username_here/wordpress-user/g" wordpress/wp-config.php
sed -i -e "s/password_here/Passw0rd/g" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/0_LvNKy/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/%U1NgW_x/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/fgFaQDZQaDQ/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/DPxeo@f/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/Op7kAL%In/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/U1cKu8lD/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/fD]#w-$H/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/t,R)?+I,/" wordpress/wp-config.php
cp -r wordpress/* /var/www/html/
sed -i -z -e "s/AllowOverride None/AllowOverride All/2" /etc/httpd/conf/httpd.conf
chown -R apache /var/www
chgrp -R apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl start httpd
sudo systemctl enable httpd
EOF
}

resource "aws_instance" "wordpress_server-old" {
  ami                         = data.aws_ami.recent_amazon_linux_2_2019.image_id
  count                       = 0
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.web_instance_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids = [
    aws_security_group.webserver_sg.id,
  ]
  tags = {
    Name = "${var.system}-wordpress-old-ami"
  }
  user_data = <<EOF
#!bin/bash
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server php72-gd
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
systemctl start mariadb
cat << "EOS" >setup.sql
CREATE USER 'wordpress-user'@'localhost' IDENTIFIED BY 'Passw0rd';
CREATE DATABASE `wordpress-db`;
GRANT ALL PRIVILEGES ON `wordpress-db`.* TO "wordpress-user"@"localhost";
FLUSH PRIVILEGES;
EOS
mysql -u root < setup.sql
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i -e "s/database_name_here/wordpress-db/g" wordpress/wp-config.php
sed -i -e "s/username_here/wordpress-user/g" wordpress/wp-config.php
sed -i -e "s/password_here/Passw0rd/g" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/0_LvNKy/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/%U1NgW_x/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/fgFaQDZQaDQ/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/DPxeo@f/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/Op7kAL%In/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/U1cKu8lD/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/fD]#w-$H/" wordpress/wp-config.php
sed -i -z -e "s/put your unique phrase here/t,R)?+I,/" wordpress/wp-config.php
cp -r wordpress/* /var/www/html/
sed -i -z -e "s/AllowOverride None/AllowOverride All/2" /etc/httpd/conf/httpd.conf
chown -R apache /var/www
chgrp -R apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl start httpd
sudo systemctl enable httpd
EOF
}

resource "aws_iam_instance_profile" "web_instance_profile" {
  name = "${var.system}-web-role"
  role = aws_iam_role.web_instance_role.name
}

resource "aws_iam_role" "web_instance_role" {
  name               = "${var.system}-web-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.web_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
