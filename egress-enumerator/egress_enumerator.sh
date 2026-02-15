#!/usr/bin/env bash

function banner() {
    cat <<'EOF'
  ___                    ___                             _
 | __|__ _ _ _ ___ _____| __|_ _ _  _ _ __  ___ _ _ __ _| |_ ___ _ _
 | _|/ _` | '_/ -_|_-<_-< _|| ' \ || | '  \/ -_) '_/ _` |  _/ _ \ '_|
 |___\__, |_| \___/__/__/___|_||_\_,_|_|_|_\___|_| \__,_|\__\___/_|
     |___/

EOF
}

function usage() {
    cat <<EOF
    usage: ${0} [listener iface]

    default listner iface:  tun0
EOF
}

function summary() {
    echo
    echo
    echo "=============== SUMMARY OF PORTS SEEN ==============="
    for port in $(printf "%s\n" "${!PORTS_SEEN[@]}" | sort -n); do
        echo ${port}
    done | column -c 60 -x
    echo "====================================================="
}

trap summary SIGINT

banner

if [ $EUID -ne 0 ]; then
    echo "[!] Must run as root; exiting"
    exit 1
fi

if [[ "${1}" =~ -{1,2}h(elp)? ]]; then
    usage
    exit
fi

if [ $# -gt 1 ]; then
    usage
    exit 1
fi

IFACE=${1:-tun0}
declare -A PORTS_SEEN

if ip a show dev ${IFACE} >/dev/null 2>&1; then 
    IFACE_ADDR=$(ip a show dev ${IFACE} | grep -E '\binet\b' | awk '{print $2}' | awk -F\/ '{print $1}')
else
    echo "[!] ${IFACE}: no such interface; exiting"
    exit 1
fi

# no sudo - should already be root
echo "[*] listening on ${IFACE_ADDR}"
while read -r port; do
    echo ${port}
    PORTS_SEEN["${port}"]=1
done < <(
        tcpdump -U -l -n -i ${IFACE} \
                "dst host ${IFACE_ADDR} and tcp[tcpflags] & (tcp-syn|tcp-ack) == tcp-syn" 2>/dev/null |
            stdbuf -oL grep -Eo '> ([0-9]{1,3}\.){4}[0-9]+' |
            stdbuf -oL awk -F\. '{print $NF}'
)

