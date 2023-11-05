# docker-Sneaklardooon

[![Build and Publish Docker Image](https://github.com/Aterfax/docker-Sneaklardooon/actions/workflows/build-docker.yml/badge.svg)](https://github.com/Aterfax/docker-Sneaklardooon/actions/workflows/build-docker.yml)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/aterfax/sneaklardooon/latest)
![Docker Pulls](https://img.shields.io/docker/pulls/aterfax/sneaklardooon)

This repo contains the source files and configuration needed to create the Sneaklardooon Docker container. The Sneaklardooon Docker container is an amalgamation of several pieces of software typically used to record, monitor and display information about running DCS World servers via the Tacview server plugin.

This Docker container is largely making use of the existing Sneaker ``config.json`` configuration file to elect the servers of interest, Docker bind mounts to supply config or save relevant files and exposes each web service over its own port.

Specifically, this docker wrappers the following software:

- **[Lardoon](https://github.com/team-limakilo/lardoon):**
  Lardoon is a web repository that offers a user-friendly interface for listing, searching, and downloading ACMI files. It's primarily designed to work in conjunction with TacView and Jambon to automate the recording and importing of server-side TacView recordings.

- **[Jambon](https://github.com/team-limakilo/jambon):**
  Jambon is a compact utility created for processing large Tacview (ACMI) files. It provides command-line tools for searching objects within Tacview, determining object lifespan, trimming tacviews to specific time frames, and filtering out objects.

- **[Sneaker](https://github.com/Special-K-s-Flightsim-Bots/sneaker):**
  Sneaker is a browser-based radar and GCI simulation tool developed for use alongside Tacview and DCS: World. Users access a simulated radar scope that displays air, sea, and optionally land targets along with speed, altitude, and type information. Additionally, Sneaker offers specific functionalities tailored for GCI (Ground-Control Intercept) purposes.

## Table of Contents

- [Quickstart](#Quickstart)
- [Configuration](#Configuration)
- [FAQ](#FAQ)
- [Troubleshooting](#Troubleshooting)
- [Contributing](#Contributing)
- [License](#License)

## Quickstart

### Prerequisites

* You are running a platform which supports Docker and you have Docker installed on your system. i.e. a Linux machine or cloud VM. You can download it from [here](https://www.docker.com/get-started).
* You have enough storage space to store the saved Tacview ACMI files.
* The servers you are intending to monitor already have the Tacview server plugin installed and running.
* You understand how and when to open ports and setup port forwarding to your running Sneaklardooon service through your router, firewall, machine (and possibly reverse proxy) where this is required.
* You are already relatively familiar with configuring and running the Lardoon, Jambon and Sneaker services.

### Using the DockerHub provided image and Docker Compose file

Please have a look in the [docker-compose/Sneaklardooon-only](docker-compose/Sneaklardooon-only) folder:

* Make amendments to the ``docker-compose.yml`` file  as needed, taking care with the volume binds ensuring the chosen locations have sufficient storage.
* Make amendments to the ``config/config.json`` file, adding your DCS World servers in the same format.
* Copy  ``.env.example `` to ``.env`` and amend as required. If you want to validate the correct settings are applied you can run ``docker compose config`` to display what Docker will use.
* To start the container, ensure you are in the [docker-compose/Sneaklardooon-only](docker-compose/Sneaklardooon-only) directory and then run the command ``docker compose up -d && docker logs -f sneaklardooon``.
* Check the shown logs look ok and navigate to the chosen host server's ports in your web browser. e.g. if on your local machine, http://localhost:3883/ and http://localhost:7788

Eventually a Docker Compose example using a reverse proxy such as SWAG may be created, with example configuration for hosting each service via HTTPS over a specific domain name and/or using subdirectories/subdomains but this is presently out of scope.


## Configuration

This section details the possible environment variables which can be set, their purpose and their defaults. You probably won't need to change anything away from defaults!

If you do make any changes to defaults, please review the implementation of the use of these variables within the ``run`` files held within each s6-init service directory:  [docker_src\s6-src\s6-services](docker_src\s6-src\s6-services).

If setting these variables away from defaults, be aware you are changing ports and paths *within* the container and container services. e.g. changing `SNEAKER_PORT` changes the port the Sneaker Web service is binding inside the container, thus you will need to adjust the container port specified within the ``.env`` file too.

### Variable Name: `CONFIG_FILE_NAME`
- **Purpose:** This variable refers to the Sneaker configuration file name.
- **Default Value:** "config.json"

### Variable Name: `SNEAKER_BIND_IP`
- **Purpose:** Refers to the IP to which the Sneaker web service is bound.
- **Default Value:** "0.0.0.0"

### Variable Name: `SNEAKER_PORT`
- **Purpose:** Represents the port used for the Sneaker web service.
- **Default Value:** "7788"

### Variable Name: `SNEAKER_TIMEOUT`
- **Purpose:** Specifies the timeout duration between liveness checks for the Sneaker web service.
- **Default Value:** "30"

### Variable Name: `TACVIEW_FOLDER`
- **Purpose:** The path of the directory which you want tacview files to be stored in.
- **Default Value:** "/tacview"

### Variable Name: `JAMBON_TIMEOUT`
- **Purpose:** Denotes the timeout duration between checks that Jambon recordings are occuring for each server.
- **Default Value:** "10"

### Variable Name: `LARDOON_DB_NAME`
- **Purpose:** Refers to the filename of the Lardoon database.
- **Default Value:** "lardoon.db"

### Variable Name: `LARDOON_BIND_IP`
- **Purpose:** Represents the IP to which the Lardoon web service is bound.
- **Default Value:** "0.0.0.0"

### Variable Name: `LARDOON_PORT`
- **Purpose:** Indicates the port used for Lardoon web service.
- **Default Value:** "3883"

### Variable Name: `LARDOON_WEB_TIMEOUT`
- **Purpose:** Specifies the timeout duration between liveness checks for the Lardoon web service.
- **Default Value:** "30"

### Variable Name: `LARDOON_DAEMON_WAIT_TIME_PERIOD`
- **Purpose:** Specifies the timeout duration between attempted imports of Tacview ACMI files for the Lardoon daemon.
- **Default Value:** "30"

### Variable Name: `DEBUG`
- **Purpose:** Turn on additional logging (debug output).
- **Default Value:** "0"

## FAQ

### Which user am I within the container?

As with most linuxserver.io images, in this container you will run things as the ``abc`` user. Note that the ``abc`` user's UID and GID will be those you specified within the ``docker-compose.yml`` file.

### How do I change the ports or pass through more ports from the container?

To change the ports passed through or add more, you need to edit the ports section in the ``.env `` file you use or directly in the ``docker-compose.yml`` file. The ports section defines the mapping between the ports on the host machine and the ports inside the container.

The syntax for the ports section is:

        ports:
        - <host_port>:<container_port>

Once you have edited the ports section, you need to rebuild and restart the containers using the ``docker-compose up -d`` command.

Keep in mind when changing the port or passing through new ports:

- If you are changing the host ports for the services being provided, you also need to update the firewall rules on your host machine / firewalls to allow traffic on the changed / new port as well as amending any port forwarding rules as needed.

- Changing the ports for the Docker container in the ``docker-compose.yml`` file will not change the ports of any running service internal to the container! To change internal service ports you would need to do so via the environment variables and match them correctly with the ``docker-compose.yml`` and Docker ``ports:`` syntax.

## Troubleshooting

If you encounter issues, please check the Github discussions to see if someone else has already resolved your issue or 
please start a thread.

If you have a problem or feature request and you know this related directly to the code implemented by this repo please file an issue detailing the nature of the problem or feature and any steps for implementation within a pull request.

## Contributing

If you'd like to contribute to this project, follow these steps:

* Fork the repository.
* Create a new branch for your feature: git checkout -b feature-name.
* Make your changes and commit them e.g. : git commit -m "Add feature".
* Push to the branch: git push origin feature-name.
* Create a pull request explaining your changes.

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

In short: The MIT License allows you to freely use, modify, and distribute the software, provided that the original license and copyright notice are included in all copies or substantial portions of the software.
