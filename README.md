# Minecraft Server 
The following project was made to set up and host a crossplay server between Bedrock and Java editions of minecraft using docker and a few other services. This tutorial aims to make setting up a server as simple as possible. 

## Docker Installation
To use this project








docker build -t min-server:latest .
docker run -p 25565:25565/tcp -p 25565:25565/udp --name min-server min-server:latest