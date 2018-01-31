# list all ssh hosts from ssh config
# reference: https://ben.lobaugh.net/blog/203195/quickly-list-all-hosts-in-your-ssh-config
alias sshls="grep -w -i "Host" ~/.ssh/config | sed 's/Host//'"
