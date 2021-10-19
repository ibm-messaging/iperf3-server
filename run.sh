#!/bin/bash
echo "iperf3 testing: server"
echo ""
echo "Local IP Addresses:"
ip a
echo ""
echo "Running iperf3 server:"
iperf3 -s 
