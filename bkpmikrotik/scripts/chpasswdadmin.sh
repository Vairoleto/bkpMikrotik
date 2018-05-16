# Variables
#SHELL=/bin/sh 
#PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/bkpmikrotik/scripts:/bkpmikrotik:/bkpmikrotik/keys
_nowfull=$(date +"%d-%m-%Y|%H:%M")
_nowlite=$(date +"%d-%m-%Y")
_key=/bkpmikrotik/keys/id_rsa
_user="bkp-procom"
_passwd=$(date +%s | sha256sum | base64 | head -c 32)
_resetpasswd="/user set password="$_passwd" "$_user""

# Functions

start_backup()
{
	 _folder="/files/${MIKROTIK}/$_nowlite/"
        # User utilizado para ingresar a mikrotik
        _frsc=["${MIKROTIK}"]"$_nowlite".rsc
        _fbackup=["${MIKROTIK}"]"$_nowlite".backup
        _rsc="/export compact file="\""["${MIKROTIK}"]"$_nowlite".rsc"\"""
        _backup="/system backup save password= name="\""["${MIKROTIK}"]"$_nowlite".backup"\"""
        echo "#####################################################################################"
        echo "->  cambiando passwd de admin para ${MIKROTIK}"
        ssh -l $_user -i $_key ${MIKROTIK} /user set admin password=FiFTb9YlqnYjB1iN1lR7
}
while read MIKROTIK
  do
     start_backup < /dev/null
  done < /bkpmikrotik/destinos/mikrotik.chpasswd
