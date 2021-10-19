# iperf3-server
Configuration to build iperf3 images 

This repo and its associated public image make it easier to run iperf3 networking tests in containerized environments.

The built image is available at:
```
docker pull stmassey/iperf3-server
```

## Use in docker/podman local environments

You can run the client and server on the default docker bridge network (or even one of your own defined networks), but its more likely you will want to run it on the host network
to check network performance between different servers

```
docker run -itd --net="host" stmassey/iperf3-server
```

You can check the logs to see which ipaddresses are available to connect to the iperf3 server. Select one of those and pass it to the client as an envvar:

```
docker run -it --net="host" --env IPERF3_HOSTNAME=<hostname> stmassey/iperf3-client
iperf3 testing: client
Running against host: <hostname>
Connecting to host <hostname>, port 5201
[  5] local *.*.*.* port 12904 connected to *.*.*.* port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  2.55 GBytes  21.9 Gbits/sec    0    895 KBytes
[  5]   1.00-2.00   sec  2.32 GBytes  19.9 Gbits/sec    0    895 KBytes
[  5]   2.00-3.00   sec  2.32 GBytes  19.9 Gbits/sec    0   1.37 MBytes
[  5]   3.00-4.00   sec  2.32 GBytes  19.9 Gbits/sec    0   1.37 MBytes
[  5]   4.00-5.00   sec  2.55 GBytes  21.9 Gbits/sec    0   1.37 MBytes
[  5]   5.00-6.00   sec  2.37 GBytes  20.3 Gbits/sec    0   1.37 MBytes
[  5]   6.00-7.00   sec  2.32 GBytes  19.9 Gbits/sec    0   1.37 MBytes
[  5]   7.00-8.00   sec  2.32 GBytes  19.9 Gbits/sec    0   1.37 MBytes
[  5]   8.00-9.00   sec  2.32 GBytes  19.9 Gbits/sec    0   1.37 MBytes
[  5]   9.00-10.00  sec  2.33 GBytes  20.0 Gbits/sec    0   1.37 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  23.7 GBytes  20.4 Gbits/sec    0             sender
[  5]   0.00-10.04  sec  23.7 GBytes  20.3 Gbits/sec                  receiver
```

If you want to run it on the docker network, then the following commands might be useful:
```
docker run -itd stmassey/iperf3-server
docker run -it --env IPERF3_HOSTNAME=$(docker inspect --format "{{ .NetworkSettings.IPAddress }}" $(docker ps -ql)) stmassey/iperf3-client
```


## Use in Kube/OCP environments
