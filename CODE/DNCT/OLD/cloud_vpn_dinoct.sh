#!/bin/bash

echo "Cloud_Vpn"
echo ""
read -p "ENTER Google OTP For 'Dinoct': " gotp
echo "$gotp"
username="hari.dinoct"
password="kFl3#BVdGKy#VPN$gotp"
echo $username > .auth.key
echo $password >> .auth.key
echo "Connecting to Cloud VPN Server.... "
sleep 3
sudo openvpn --config /home/hari/Chrome-os/Vpn/cloud.ovpn --auth-user-pass .auth.key 

