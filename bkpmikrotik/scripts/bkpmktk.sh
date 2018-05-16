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
        _backup="/system backup save password=enigma28 name="\""["${MIKROTIK}"]"$_nowlite".backup"\"""
        echo "#####################################################################################"
        echo "->  iniciando backups para ${MIKROTIK}"
        echo "->  creando carpeta destino $_folder"
        mkdir -p $_folder
        echo "->  aceptando certifiados de ${MIKROTIK}"
        ssh -l $_user -i $_key -oStrictHostKeyChecking=no ${MIKROTIK} /
        echo "->  crando backups en mikrotik ${MIKROTIK}"
        ssh -l $_user -i $_key ${MIKROTIK} $_rsc
        ssh -l $_user -i $_key ${MIKROTIK} $_backup
        echo "->  copiando los backups a $_folder"
        scp -i $_key $_user@${MIKROTIK}:/$_frsc $_folder
        scp -i $_key $_user@${MIKROTIK}:/$_fbackup $_folder
        echo "->  borrando los backups ya copiados en mikrotik ${MIKROTIK}"
        ssh -l $_user -i $_key ${MIKROTIK} /file remove "\""$_frsc"\""
        ssh -l $_user -i $_key ${MIKROTIK} /file remove "\""$_fbackup"\""
        echo "->  proceso completo!"
        echo "->  cambiando passwd de user $_user en ${MIKROTIK}"
        ssh -l $_user -i $_key ${MIKROTIK} $_resetpasswd
}
while read MIKROTIK
  do
     start_backup < /dev/null
  done < /bkpmikrotik/destinos/mikrotik
