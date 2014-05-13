Overview
--------
Quick and easy setup of Microsoft SQL Server 2000 Desktop Engine on Windows XP VM in the VirtualBox on Mac OS X.

It also installs Microsoft SQL Server Management Studio Express.

Host-only adapter is configured on the VM (one is also set up in the VirtualBox if none with IP 192.168.56.1 is found).

Two snapshots are taken - before and after configuration of DB on the VM. This could be useful if for some reason there is an error during setup.

It uses Windows XP image from http://www.modern.ie/ that is valid for max 90 days.

Password for Windows user account ```IEUser``` is ```Passw0rd!```.


Usage
-----
Clone repository and execute ```mssqlvm.sh``` or simply execute
```curl -s https://raw.github.com/twr/mssqlvm/master/mssqlvm.sh | bash```

Few ```VBoxManage: error: Querying directory existence "/Documents and Settings/IEUser/Desktop" failed: VERR_NOT_FOUND.``` error messages are expected during installation - it's a way of checking if guestcontrol is enabled yet.

First startup of VM in gui will be full screen. When this happens press Cmd+F to go out.

If something goes wrong with setting up SQL Server DB, there should be ```mssql-setup.bat``` on the desktop in the VM, that can be rerun manually.


Useful keyboard shortcuts
-------------------------
CTRL is used rather than Cmd to copy/paste, e.g. CTRL+C, CTRL+V

Cmd + click on the touch pad is a right mouse click


Database details
----------------
If everything goes ok, it should be possible to connect to db on the vm from host using:

 * IP: 192.168.56.101,
 * port: 1433,
 * user: sa,
 * password: devadmin


Dependencies
------------
* [7-zip](http://sourceforge.net/projects/sevenzip/files/7-Zip/9.22/7z922.exe/download)
* [curl](http://curl.haxx.se/gknw.net/7.29.0/dist-w32/curl-7.29.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32.zip)
* [ievms](https://github.com/xdissent/ievms) - used to create base VM


Acknowledgements
----------------
[ievms](https://github.com/xdissent/ievms) - takes care of setting up a VM
