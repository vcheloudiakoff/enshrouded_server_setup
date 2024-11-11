# Enshrouded Game Server Setup with Docker

This guide provides step-by-step instructions to build and run the Enshrouded game server using Docker.

## Prerequisites

### Install Docker

#### Update Existing Packages
Make sure your package list is up-to-date:

```bash
sudo apt update
sudo apt upgrade -y
```

#### Install Docker
Run the following commands to install Docker on Ubuntu-based systems:

```bash
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce
```

#### Verify Docker Installation
After installation, verify that Docker is running:

```bash
sudo systemctl status docker
```

You should see Docker listed as active (running).

> **Note:** Docker Compose is typically used to manage multiple containers. In this case, it is not required, as we only need a single container to run the server.

For more information on Docker, visit the [official Docker Installation Guide](https://docs.docker.com/get-docker/).

## Build the Docker Image

### Clone the Repository
Clone this repository to your local machine to access the Dockerfile and configuration files.

```bash
cd enshrouded-server
```

### Build the Docker Image
Use Docker to build the image from the included Dockerfile.

```bash
docker build -t enshrouded_server .
```

This command will create an image named `enshrouded_server` that contains all necessary dependencies and configurations.

## Configure the Server

Edit the `enshrouded_server.json` file if you want to customize the server settings, such as name, `gamePort`, `queryPort`, and other gameplay parameters.

```json
{
  "name": "Server Name",
  "gamePort": 15636,
  "queryPort": 15637,
  "slotCount": 16,
  ...
}
```

## Opening the Required Ports on the Host Machine

To ensure that the server is accessible, open the required ports on your VPS or machine’s firewall outside of Docker. Use the following commands to configure UFW (the Uncomplicated Firewall) on Ubuntu-based systems. (These steps may vary if you’re using another firewall or VPS configuration.)

```bash
sudo ufw allow 15636/tcp
sudo ufw allow 15637/udp
sudo ufw reload
```

Make sure UFW is enabled:

```bash
sudo ufw enable
```

## Run the Server

Start the server using Docker with the required ports:

```bash
docker run -d --name enshrouded_server_container --restart always \
    -p 15636:15636/tcp -p 15637:15637/udp \
    enshrouded_server
```

- `15636/tcp`: Game connection port
- `15637/udp`: Query port for status and discovery

This command will run the server in detached mode, allowing it to restart automatically if stopped.

## Verify the Server

To confirm the server is running correctly, check the logs:

```bash
docker logs -f enshrouded_server_container
```

Look for the following messages in the logs, which confirm that the server is fully initialized and ready:

```
[OnlineProviderSteam] 'Initialize' (up)!
[OnlineProviderSteam] 'JoinOrCreateGame' (up)!
[OnlineProviderSteam] 'SetLobbyData' (up)!
[OnlineProviderSteam] 'JoinLocalPlayers' (up)!
[OnlineProviderSteam] 'ConnectToPeers' (up)!
[OnlineProviderSteam] finished transition from 'Uninitialized' to 'InGame' (current='InGame')!
[Session] 'HostOnline' (up)!
[Session] finished transition from 'Lobby' to 'Host_Online' (current='Host_Online')!
```

If you see these entries, the server is online and ready for players.

## Stopping and Restarting the Server

- **Stop the Server:**

  ```bash
  docker stop enshrouded_server_container
  ```

- **Restart the Server:**

  ```bash
  docker start enshrouded_server_container
  ```

- **Or just:**

  ```bash
  docker restart enshrouded_server_container
  ```

## Troubleshooting

If you encounter any issues, make sure:

- Docker is running and properly configured.
- The ports `15636` (TCP) and `15637` (UDP) are open and accessible on your firewall.
- Check server logs for error messages using `docker logs -f enshrouded_server_container`.
