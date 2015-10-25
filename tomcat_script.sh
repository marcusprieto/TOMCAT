#!/bin/bash

#Tomcat8 no CentOs7 
#Url para verficar a versao -> http://tomcat.apache.org/download-80.cgi
T_VERSION=8.0.24
T2_VERSION=8
INST_DIR=/opt/tomcat
SYSTEMD_DIR=/etc/systemd/system

# Atualiza mirrors localmente
yum update

# Instalando java-openjdk
yum install java-1.7.0-openjdk-devel -y

# Setando o Home do JAVA que instalamos
export JAVA_HOME=/usr/lib/jvm/jre

# Criando o grupo do Tomcat
groupadd tomcat

# Criando usuario do tomcat e chrootando para um diretorio especifico
useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat

# Baixando a versão do Tomcat de acordo com as variaveis setadas acima
wget http://mirror.sdunix.com/apache/tomcat/tomcat-$T2_VERSION/v$T_VERSION/bin/apache-tomcat-$T_VERSION.tar.gz

# Criando diretorio 
mkdir /opt/tomcat

# Extraindo tomcat no diretorio de instalacao
tar xf apache-tomcat-$T_VERSION.tar.gz -C $INST_DIR --strip-components=1

# Mudando as permissoes de arquivos e diretorios

chgrp -R tomcat $INST_DIR/conf
chmod g+rwx $INST_DIR/conf
chmod g+r $INST_DIR/conf/*

chown -R tomcat $INST_DIR/work/ $INST_DIR/temp/ $INST_DIR/logs/

touch $SYSTEMD_DIR/tomcat.service

# Adicionando as linhas no tomcat.service

echo "!#/bin/bash
# Systemd unit file for tomcat
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms256M -Xmx512M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat" > $SYSTEMD_DIR/tomcat.service

# Reload nos scripts e daemons do systemd e reiniciando/habilitando o tomcat
systemctl daemon-reload ; sleep 2 ; systemctl start tomcat.service ; sleep 2 ; systemctl enable tomcat.service 

# Reiniciando o servico do tomcat
systemctl restart tomcat.service

# URLS uteis
#http://server_IP_address:8080
#http://server_IP_address:8080/manager/html
