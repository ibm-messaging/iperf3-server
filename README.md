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

You can check the logs to see which ip addresses are available to connect to the iperf3 server. Select one of those and pass it to the client as an envvar:

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

The easiest way to launch the iperf3-server in an OCP environment is to create a new workspace and add the server project as a new application:
```
oc new-project iperf
oc new-app stmassey/iperf3-server
```
This will create the required Kube artefacts (deployments, services, pods). You can check the available interfaces either by examining the pod logs:
```
oc logs pod/iperf3-server-6997546b96-p2p57
iperf3 testing: server

Local IP Addresses:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if1689: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default
    link/ether 0a:58:0a:82:04:c8 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.130.4.200/23 brd 10.130.5.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::b4d9:67ff:fe72:914c/64 scope link
       valid_lft forever preferred_lft forever

Running iperf3 server:
```

You can then launch the iperf-client as a job file [here](https://github.com/ibm-messaging/iperf3-client/blob/main/iperf-client-job.yaml), by default it uses the svc address (iperf3-server), but this can be overridden by setting the envvar IPERF3_HOSTNAME to the desired IP address:
```
oc create -f iperf-client-job.yaml
oc logs job.batch/iperf3-client
iperf3 testing: client
Running against host: 10.130.4.200
Connecting to host 10.130.4.200, port 5201
[  5] local 10.129.3.182 port 50766 connected to 10.130.4.200 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   109 MBytes   915 Mbits/sec    5    397 KBytes
[  5]   1.00-2.00   sec   108 MBytes   910 Mbits/sec    0    511 KBytes
[  5]   2.00-3.00   sec   107 MBytes   901 Mbits/sec    6    609 KBytes
[  5]   3.00-4.00   sec   108 MBytes   910 Mbits/sec    0    730 KBytes
[  5]   4.00-5.00   sec   108 MBytes   906 Mbits/sec    0    821 KBytes
[  5]   5.00-6.00   sec   108 MBytes   904 Mbits/sec    0    821 KBytes
[  5]   6.00-7.00   sec   109 MBytes   911 Mbits/sec    0    821 KBytes
[  5]   7.00-8.00   sec   109 MBytes   911 Mbits/sec    0    821 KBytes
[  5]   8.00-9.00   sec   108 MBytes   903 Mbits/sec    1    821 KBytes
[  5]   9.00-10.00  sec   109 MBytes   911 Mbits/sec    0    821 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  1.06 GBytes   908 Mbits/sec   12             sender
[  5]   0.00-10.04  sec  1.06 GBytes   903 Mbits/sec                  receiver

iperf Done.
```
