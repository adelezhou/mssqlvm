#!/usr/bin/env bash

set -o nounset
set -o errtrace
set -o errexit
set -o pipefail
username="IEUser"
# Add password due to https://github.com/xdissent/ievms/issues/129#issuecomment-29551990
password="Passw0rd!"

log()  { printf "$*\n" ; return $? ;  }

configure_host_only_nic() {
  log "Configure network adapter"
  
  #IP for the network adapter, guest IP will be set to IP in this network
  ip="192.168.56.1"

  adapter=`VBoxManage list hostonlyifs | awk -v _ip=$ip 'BEGIN { RS = "" } $8==_ip { print $2 }'`
  if [ "$adapter" == "" ];
  then
    result=`VBoxManage hostonlyif create`
    if [[ "$result" =~ .*"successfully created".* ]]
    then
      adapter=`echo $result | grep -o "vboxnet[0-9]*"`
      VBoxManage hostonlyif ipconfig "$adapter" --ip $ip
      echo "created adapter $adapter and set its IP to $ip"
    else
      echo $result
      exit 1
    fi
  else
    echo "found adapter $adapter with IP $ip"
  fi
  
  VBoxManage modifyvm "${vm}" --nic2 hostonly
  VBoxManage modifyvm "${vm}" --hostonlyadapter2 $adapter
}

download_files_to_vm() {
  log "Downloading 7-zip"
  curl -L http://sourceforge.net/projects/sevenzip/files/7-Zip/9.22/7z922.exe/download -o 7z922.exe

  log "Downloading curl"
  curl -L -O http://curl.haxx.se/gknw.net/7.29.0/dist-w32/curl-7.29.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32.zip

  log "Downloading mssql-setup.bat"
  curl -L -O https://raw.github.com/twr/mssqlvm/master/mssql-setup.bat

  log "Starting ${vm}"
  VBoxManage startvm "${vm}" --type headless

  sleep_wait="10"
  guest_loc="/Documents and Settings/IEUser/Desktop"

  log "Waiting for ${vm} to be available for guestcontrol..."
  x="1" ; until [ "${x}" == "0" ]; do
    sleep "${sleep_wait}"
    VBoxManage guestcontrol "${vm}" cp `pwd`"/7z922.exe" "${guest_loc}/7z922.exe" --username ${username} --password ${password} --dryrun && x=$? || x=$?
  done

  sleep "${sleep_wait}"

  log "Copying files to the VM"
  VBoxManage guestcontrol "${vm}" cp `pwd`"/7z922.exe" "${guest_loc}/7z922.exe" --username ${username} --password ${password}
  VBoxManage guestcontrol "${vm}" cp `pwd`"/curl-7.29.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32.zip" "${guest_loc}/curl-7.29.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32.zip" --username ${username} --password ${password}
  VBoxManage guestcontrol "${vm}" cp `pwd`"/mssql-setup.bat" "${guest_loc}/mssql-setup.bat" --username ${username} --password ${password}
}

mssqlvm_home="${HOME}/.mssqlvm"

log "Install WinXP and enable guest control"
curl -s https://raw.github.com/xdissent/ievms/master/ievms.sh | REUSE_XP="yes" IEVMS_VERSIONS="7" INSTALL_PATH="${mssqlvm_home}" bash

# folder has been created by ievms
cd "${mssqlvm_home}"

vm="IE7 - WinXP"

configure_host_only_nic

log "Enable bidirectional clipboard"
VBoxManage modifyvm "${vm}" --clipboard bidirectional

download_files_to_vm

log "Setting up database on the VM (may take a while)"
VBoxManage guestcontrol "${vm}" exec --image "${guest_loc}/mssql-setup.bat" --username ${username} --password ${password} --wait-exit

log "Shutting down VM ${vm}"
VBoxManage guestcontrol "${vm}" exec --image "/WINDOWS/system32/shutdown.exe" --username ${username} --password ${password} --wait-exit -- -s -f -t 0

sleep_wait="10"
log "Waiting for ${vm} to shutdown..."
x="0" ; until [ "${x}" != "0" ]; do
  sleep "${sleep_wait}"
  VBoxManage list runningvms | grep "${vm}" >/dev/null && x=$? || x=$?
done

log "Creating snapshot after installing mssql"
VBoxManage snapshot "${vm}" take clean-mssql --description "clean mssql"
