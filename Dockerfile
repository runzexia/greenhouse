FROM java:openjdk-6

WORKDIR /home

COPY target/*.jar /home

ENTRYPOINT java -jar *.jar