#!/bin/bash
echo "Iperf3 Testing: server"
echo "Local IP Addresses"
ip a
echo "Running iperf3 server"
iperf3 -s 
