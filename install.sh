#!/data/data/com.termux/files/usr/bin/bash

green='\033[0;32m'
red='\033[0;31m'
blue='\033[0;34m'
bold='\033[1m'
reset='\033[0m'

for pkg in iputils-ping curl; do
    if ! command -v ${pkg%%-*} >/dev/null 2>&1; then
        echo -e "${blue}Installing ${pkg}...${reset}"
        pkg install -y $pkg
    fi
done

ip_to_int() {
    local IFS=.
    read -r i1 i2 i3 i4 <<< "$1"
    echo $(( (i1 << 24) + (i2 << 16) + (i3 << 8) + i4 ))
}

int_to_ip() {
    local ip=$1
    echo "$(( (ip >> 24) & 255 )).$(( (ip >> 16) & 255 )).$(( (ip >> 8) & 255 )).$(( ip & 255 ))"
}

start_ip="104.103.72.0"
end_ip="104.103.111.255"
start_int=$(ip_to_int "$start_ip")
end_int=$(ip_to_int "$end_ip")
range_size=$((end_int - start_int))

echo -e "${bold}Searching for live IPv4 addresses...${reset}"
live_ips=()
attempts=0

while [ "${#live_ips[@]}" -lt 2 ]; do
    rand_offset=$((RANDOM % range_size))
    ip=$(int_to_ip $((start_int + rand_offset)))
    ((attempts++))
    if ping -c 1 -W 1 $ip >/dev/null 2>&1; then
        echo -e "${green}[✔] $ip is alive.${reset}"
        live_ips+=("$ip")
    else
        echo -e "${red}[✘] $ip is unreachable.${reset}"
    fi
    [ $attempts -ge 100 ] && break
done

echo -e "\n${bold}Found ${#live_ips[@]} live IP(s):${reset}"
for ip in "${live_ips[@]}"; do
    echo -e "${green}🔹 $ip${reset}"
done

echo -e "\n${blue}Done.${reset}"
