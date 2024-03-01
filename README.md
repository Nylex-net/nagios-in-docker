# Nagios in Docker

## Installing Nagios from Dockerfile for Nylex.net

I originally made use of the image [jasonrivers/nagios](https://hub.docker.com/r/jasonrivers/nagios) from Docker Hub.
But I eventually switched to using a Ubuntu image and borrowed Nylex.net's installation shell file to more customize and setup Nagios manually.
I've pushed my custom image to Docker Hub as [nylexdotnet/nagios-svr](https://hub.docker.com/r/nylexdotnet/nagios-svr).
The intention is to make it easy for Nylex.net employees to pull and run with very little instructions. Just pull and run:

1. Pull image from Docker Hub:

    - `docker pull nylexdotnet/nagios-svr`

2. Run container with the following parameters:

    - `docker run --hostname Nagios-SVR -p 0.0.0.0:80:80 nylexdotnet/nagios-svr`
