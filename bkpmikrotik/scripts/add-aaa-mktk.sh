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
        echo "#####################################################################################"
		echo "copiando certificado"
                scp /bkpmikrotik/aaa.clientes/${MIKROTIK}.crt  $_key $_user@${MIKROTIK}:/
		echo "copiando llave privada"
                scp /bkpmikrotik/aaa.clientes/${MIKROTIK}.key  $_key $_user@${MIKROTIK}:/
		echo "importando certificado y llave"
                ssh -l $_user -i $_key ${MIKROTIK} /certificate import file-name=${MIKROTIK}.crt passphrase="a"
                ssh -l $_user -i $_key ${MIKROTIK} /certificate import file-name=${MIKROTIK}.key passphrase="a"
		echo "configurando ovpn"
                ssh -l $_user -i $_key ${MIKROTIK} /interface ovpn-client add  connect-to=nxfilter01.procomisp.com.ar port=1794 mode=ip certificate=${MIKROTIK}.crt_0 auth=sha1 cipher=aes256 user=${MIKROTIK} comment=AAA.procom
		echo "creando perfiles lvl1 y lvl2"
                ssh -l $_user -i $_key ${MIKROTIK} /user group add name=procom-lvl2 policy=local,telnet,ssh,ftp,reboot,read,write,test,winbox,password,web,sniff,sensitive,api,romon
                ssh -l $_user -i $_key ${MIKROTIK} /user group add name=procom-lvl1 policy=local,telnet,ssh,read,test,winbox,web,sniff
		echo "configurando radius"
                ssh -l $_user -i $_key ${MIKROTIK} /user aaa set use-radius=yes
                ssh -l $_user -i $_key ${MIKROTIK} /radius add service=login address=172.30.155.100 secret=procom

}
while read MIKROTIK
  do
     start_backup < /dev/null
  done < /bkpmikrotik/destinos/mikrotik.aaa
