FROM openjdk:19

RUN curl https://launcher.mojang.com/v1/objects/125e5adf40c659fd3bce3e66e67a16bb49ecc1b9/server.jar -O
WORKDIR data
CMD echo 'eula=true' > eula.txt && java -jar ../server.jar nogui
