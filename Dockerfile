FROM tomcat:7.0.64-jre7

WORKDIR /home

COPY target/*.war /usr/local/tomcat/webapps/

