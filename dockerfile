FROM debian:latest

#Install supervisor for running command, install procps for killing processes
RUN apt update && apt install supervisor procps -y 

#Install jdk version from .deb, need to have a version installed in same folder as docker path
RUN mkdir /etc/java-debpack
COPY *.deb /etc/java-debpack/jdk.deb
RUN cd /etc/java-debpack && dpkg -i jdk.deb

#Grabs paper server from same folder, sets eula to true
RUN mkdir /etc/server
COPY *.jar /etc/server/paper-server.jar
RUN cd /etc/server/ && echo "eula=true" > eula.txt

#Add plugins to the plugins folder
RUN mkdir /etc/server/plugins
COPY plugins/* /etc/server/plugins

#Runs server and waits for files to be changed to be created, then stops server
RUN cd /etc/server/ && \
  java -jar paper-server.jar nogui & \
  while [ ! -f /etc/server/server.properties ] || \
    [ ! -f /etc/server/plugins/floodgate/key.pem ] || \
    [ ! -f /etc/server/plugins/Geyser-Spigot/config.yml ]; do sleep 1; done && \
  pkill -f "java -jar paper-server.jar"

#Change files for bedrock and java crossplay
RUN cp /etc/server/plugins/floodgate/key.pem /etc/server/plugins/Geyser-Spigot
RUN sed -i 's#clone-remote-port: false#clone-remote-port: true#' /etc/server/plugins/Geyser-Spigot/config.yml

#Expose ports
EXPOSE 25565/tcp
EXPOSE 25565/udp 

#Run the server using supervisord
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["supervisord", "-n"]