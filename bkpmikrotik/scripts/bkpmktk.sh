# Variables
#SHELL=/bin/sh
#PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/bkpmikrotik/scripts:/bkpmikrotik:/bkpmikrotik/keys
_nowfull=$(date +"%d-%m-%Y|%H:%M")
_nowlite=$(date +"%d-%m-%Y")
_key=/bkpmikrotik/keys/id_rsa
_user="bkp-procom"
_passwd=$(date +%s | sha256sum | base64 | head -c 32)
_resetpasswd="/user set password="$_passwd" "$_user""
#_folder="/files/${MIKROTIK}/$_nowlite/"
# User utilizado para ingresar a mikrotik

# Functions

start_backup()
{
        _backup="/system backup save password=recoverme name="\""["${MIKROTIK}"]"$_nowlite".backup"\"""
        _frsc=["${MIKROTIK}"]"$_nowlite".rsc
        _rsc="/export compact file="\""["${MIKROTIK}"]"$_nowlite".rsc"\"""
        _folder="/files/${MIKROTIK}/$_nowlite/"
        _fbackup=["${MIKROTIK}"]"$_nowlite".backup
        echo "Parece que si responde, vamos a comenzar!"
        echo "####  ${MIKROTIK}  #############  $_nowfull  ########### START ############"
        echo "->  waiting 5 secconds to start"
        sleep 5
        #echo "->  knocking ports en ${MIKROTIK}"
        #knock ${MIKROTIK} 50123:tcp 30123:tcp 40123:tcp
        echo "->  iniciando backups para ${MIKROTIK}"
        echo "->  creando carpeta destino $_folder"
        mkdir -p $_folder
        echo "->  aceptando certifiados de ${MIKROTIK}"
        ssh -l $_user -i $_key -oStrictHostKeyChecking=no ${MIKROTIK} /
        echo "->  crando backups en mikrotik ${MIKROTIK}"
        ssh -o ConnectTimeout=30 -l $_user -i $_key ${MIKROTIK} $_rsc
        ssh -o ConnectTimeout=30 -l $_user -i $_key ${MIKROTIK} $_backup
        echo "->  copiando los backups a $_folder"
        scp -i $_key $_user@${MIKROTIK}:/$_frsc $_folder
        scp -i $_key $_user@${MIKROTIK}:/$_fbackup $_folder
        echo "->  borrando los backups ya copiados en mikrotik ${MIKROTIK}"
        ssh -l $_user -i $_key ${MIKROTIK} /file remove "\""$_frsc"\""
        ssh -l $_user -i $_key ${MIKROTIK} /file remove "\""$_fbackup"\""
        echo "->  proceso completo!"
        echo "->  cambiando passwd de user $_user en ${MIKROTIK}"
        ssh -l $_user -i $_key ${MIKROTIK} $_resetpasswd
        echo "####  ${MIKROTIK}  #############  $_nowfull  ###########  END  ############"
        echo ""
        echo ""
        echo ""
}
while read MIKROTIK
  do
        echo "-> Intentando ver si ${MIKROTIK} responde al SSH"
    knock ${MIKROTIK} 50123:tcp 30123:tcp 40123:tcp;
    ssh -n -q -l $_user -i $_key -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes ${MIKROTIK} exit
      if
        [ $? = 255 ]; then
        echo "XXXXXXXXXX"
        echo "XXXXXXXXXX"
        echo "XXXXXXXXXX no puedo acceder a ${MIKROTIK}"
        echo "XXXXXXXXXX"
        echo "XXXXXXXXXX"
        echo " ${MIKROTIK} " >> /files/logs/errores-$_nowlite
        echo ""
        echo ""
        echo ""
      else
       start_backup < /dev/null
      fi
  done < /bkpmikrotik/destinos/mikrotik