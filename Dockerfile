# © Copyright IBM Corporation 2021
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# FROM ubuntu:22.04  
# FROM quay.io/stmassey/ubuntu
# FROM registry.access.redhat.com/ubi9/ubi-minimal:latest
FROM registry.access.redhat.com/ubi9/ubi:latest

LABEL maintainer "Sam Massey <smassey@uk.ibm.com>"

# RUN dnf install openssl wget ca-certificates gzip tar bash bc ca-certificates coreutils curl file findutils gawk grep passwd procps sed util-linux procps iputils vim iproute iperf3 \
RUN dnf install -y wget bc file procps procps iputils vim\
  # Update and clean
  && dnf update; dnf clean all \
  # Add group and user 
  && groupadd --system --gid 800 mqm \
  && useradd --system --uid 800 --gid mqm mqperf \
  && mkdir -p /home/mqperf/iperf3 \
  && chown -R mqperf /home/mqperf/iperf3 \
  # Update the command prompt 
  && echo "export PS1='iperf3-server:\u@\h:\w\$ '" >> /home/mqperf/.bashrc \
  && echo "cd ~/iperf3" >> /home/mqperf/.bashrc

COPY run.sh /home/mqperf/iperf3/
COPY libiperf.so.0 /usr/local/lib
COPY iperf3 /home/mqperf/iperf3
USER mqperf
WORKDIR /home/mqperf/iperf3
EXPOSE 5201

ENTRYPOINT ["./run.sh"]
