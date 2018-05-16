/bkpmikrotik # more start.sh
#!/bin/sh

# start cron
crond

# generate host keys if not present
# do not detach (-D), log to stderr (-e), passthrough other arguments
[ ! -f /bkpmikrotik/keys/id_rsa ] && ssh-keygen -b 2048 -t rsa -f /bkpmikrotik/keys/id_rsa -q -N "" || exec /usr/sbin/sshd -D -e -h /bkpmikrotik/keys/id_rsa "$@"