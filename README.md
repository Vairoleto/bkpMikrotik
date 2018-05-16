# bkpMikrotik

Alpine docker container that runs via crond (every day at 03:00 AM) a script.

The script connects to a each mikrotik defined in the  /bkpmikrotik/destinos/mikrotik file, execute the "backup" and "export" comands, copy those files to /files/$mikrotik and then delete the original files on the mikrotik.

# TODO

make a dockercompose so that we can bring up a dnsmasq container, obligatory as we use names on the mikrotik destination file.
