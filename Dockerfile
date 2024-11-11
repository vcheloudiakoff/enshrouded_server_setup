# Utilise une image de base Ubuntu
FROM ubuntu:24.04

# Variables d'environnement pour SteamCMD
ENV STEAMCMDDIR="/usr/games"
ENV SERVERDIR="/home/enshrouded/enshroudedserver"

# Définir DEBIAN_FRONTEND pour éviter les questions interactives
ENV DEBIAN_FRONTEND=noninteractive

# Met à jour le système et installe les dépendances
RUN apt update && \
    apt upgrade -y && \
    apt install -y software-properties-common lsb-release wget ufw cabextract winbind screen xvfb && \
    dpkg --add-architecture i386 && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources && \
    apt update && \
    apt install -y --install-recommends winehq-staging && \
    apt install -y software-properties-common && \
    add-apt-repository multiverse && \
    apt update && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt install -y steamcmd && \
    apt clean

# Création de l'utilisateur enshrouded
RUN useradd -m enshrouded

# Change le contexte utilisateur pour installer le serveur
USER enshrouded
WORKDIR /home/enshrouded

# Télécharge et installe le serveur de jeu avec SteamCMD
RUN $STEAMCMDDIR/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir $SERVERDIR +login anonymous +app_update 2278520 +quit

# Ajoute le fichier de configuration du serveur (remplacez avec votre propre fichier JSON si vous avez des configs personnalisées)
COPY enshrouded_server.json $SERVERDIR/enshrouded_server.json

# Expose les ports nécessaires
EXPOSE 15636/tcp
EXPOSE 15637/tcp

# Exécute le serveur de jeu
ENTRYPOINT ["wine64", "/home/enshrouded/enshroudedserver/enshrouded_server.exe"]

# Réinitialise DEBIAN_FRONTEND
ENV DEBIAN_FRONTEND=dialog
