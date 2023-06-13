#!/bin/bash

info () {
    lgreen='\e[92m'
    nc='\033[0m'
    printf "${lgreen}[Info] ${@}${nc}\n"
}

error () {
    lgreen='\033[0;31m'
    nc='\033[0m'
    printf "${lgreen}[Error] ${@}${nc}\n"
}

#=======================================

GIT_REPO=/srv/TEAMinternational_Learning

install_unzip_wget () {
    apt install unzip wget    &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "install_unzip_wget complete"
    else
        tail -n20 $log_path/tmp.log
        error "install_unzip_wget failed"
    exit 1
fi
}

install_default_jdk () {
    apt install openjdk-8-jre-headless   &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "nstall_default_jdk complete"
    else
        tail -n20 $log_path/tmp.log
        error "nstall_default_jdk failed"
    exit 1
fi
}

add_user () {
    useradd -m -U -d /opt/tomcat -s /bin/false tomcat   &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "add_user complete"
    else
        tail -n20 $log_path/tmp.log
        error "add_user failed"
    exit 1
fi
}

get_tomcat () {
    cd /tmp
    wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.20/bin/apache-tomcat-8.0.20.zip  &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "get_tomcat complete"
    else
        tail -n20 $log_path/tmp.log
        error "get_tomcat failed"
    exit 1
fi
}

unzip_tomcat () {
    unzip apache-tomcat-8.0.20.zip      &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "unzip_tomcat complete"
    else
        tail -n20 $log_path/tmp.log
        error "unzip_tomcat failed"
    exit 1
fi
}

move_tomcat () {
    mkdir -p /opt/tomcat
    mv  apache-tomcat-8.0.20  /opt/tomcat/    &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "move_tomcat complete"
    else
        tail -n20 $log_path/tmp.log
        error "move_tomcat failed"
    exit 1
fi
}

create_a_symbolic_link () {
    ln -s /opt/tomcat/apache-tomcat-8.0.20 /opt/tomcat/latest   &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "create_a_symbolic_link complete"
    else
        tail -n20 $log_path/tmp.log
        error "create_a_symbolic_link failed"
    exit 1
fi
}

add_owner () {
    chown -R tomcat: /opt/tomcat      &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "add_owner complete"
    else
        tail -n20 $log_path/tmp.log
        error "add_owner failed"
    exit 1
fi
}

add_permission () {
    sudo sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'    &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "add_permission complete"
    else
        tail -n20 $log_path/tmp.log
        error "add_permission failed"
    exit 1
fi
}

add_service () {
    cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat 8.0.20 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"

Environment="CATALINA_BASE=/opt/tomcat/latest"
Environment="CATALINA_HOME=/opt/tomcat/latest"
Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/latest/bin/startup.sh
ExecStop=/opt/tomcat/latest/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF
if [ $? -eq 0 ];
    then
        info "add_service complete"
    else
        tail -n20 $log_path/tmp.log
        error "add_service failed"
    exit 1
fi
}

replace_server_xml () {
    \cp -r $GIT_REPO/tomcat/server.xml /opt/tomcat/apache-tomcat-8.0.20/conf/   &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "replace_server_xml complete"
    else
        tail -n20 $log_path/tmp.log
        error "replace_server_xml failed"
    exit 1
fi
}

daemon_reload () {
    systemctl daemon-reload     &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "add_service complete"
    else
        tail -n20 $log_path/tmp.log
        error "add_service failed"
    exit 1
fi
}

enable_tomcat () {
    systemctl enable tomcat     &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "enable_tomcat complete"
    else
        tail -n20 $log_path/tmp.log
        error "enable_tomcat failed"
    exit 1
fi
}

allow_8080 () {
    ufw allow 8080    &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "allow_8080 complete"
    else
        tail -n20 $log_path/tmp.log
        error "allow_8080 failed"
    exit 1
fi
}

start_tomcat () {
    systemctl start tomcat    &> $log_path/tmp.log
if [ $? -eq 0 ];
    then
        info "start_tomcat complete"vim
    else
        tail -n20 $log_path/tmp.log
        error "start_tomcat failed"
    exit 1
fi
}

main () {
install_unzip_wget

install_default_jdk

add_user

get_tomcat

unzip_tomcat

move_tomcat

create_a_symbolic_link

add_owner

add_permission

add_service

replace_server_xml

daemon_reload

enable_tomcat

allow_8080

start_tomcat

}

main
