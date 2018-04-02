+++
title = 'User guide for R servers of the GISciecne group at FSU Jena'
author = 'Patrick Schratz'
date = '2018-01-20'
+++

[NEWS](http://www.geoinf.uni-jena.de/~bi28yuv/r_server/Changelog.txt)

Acknowledgements:
Thanks to Sven Kralisch and Benjamin Ludwig who helped me a lot!

<!--ts-->
<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [1. Introduction](#1-introduction)
- [2. Data and scripts](#2-data-and-scripts)
- [3. Geospatial libraries](#3-geospatial-libraries)
- [4. Accessing the servers](#4-accessing-the-servers)
	- [4.1 Accessing the folders](#41-accessing-the-folders)
		- [4.1.1 Windows](#411-windows)
			- [4.1.1.1 Scripts](#4111-scripts)
			- [4.1.1.2 Data](#4112-data)
		- [4.1.2 Linux & Mac](#412-linux-mac)
			- [4.1.2.1 Scripts](#4121-scripts)
			- [4.1.2.2 Data](#4122-data)
	- [4.2 Command-line access](#42-command-line-access)
		- [4.2.1 Windows](#421-windows)
		- [4.2.2 Linux & Mac](#422-linux-mac)
- [5. RStudio Server Pro](#5-rstudio-server-pro)
- [6. Executing long running/parallel processing jobs](#6-executing-long-runningparallel-processing-jobs)
		- [6.1 How to do it right](#61-how-to-do-it-right)
	- [6.2 Killing processes](#62-killing-processes)
- [7. Appendix: Admin notes (German)](#7-appendix-admin-notes-german)
	- [7.1 Installation of R with Intel-mkl support](#71-installation-of-r-with-intel-mkl-support)
	- [7.2 Remote file editing over ssh](#72-remote-file-editing-over-ssh)
	- [7.3 `/data` folder](#73-data-folder)
	- [7.4 `home` folders](#74-home-folders)
	- [7.5 Installierte Bibliotheken (alle server)](#75-installierte-bibliotheken-alle-server)
		- [7.5.1 mccoy only (rstudio server)](#751-mccoy-only-rstudio-server)
		- [7.5.2 kirk, scotty, spock only](#752-kirk-scotty-spock-only)

<!-- /TOC -->

<!-- Added by: pjs, at: 2018-04-02T22:33+02:00 -->

<!--te-->

# 1. Introduction

There are currently four servers set up tailored towards `R` processing:

* MCCOY (mccoy.geogr.uni-jena.de; 141.35.159.150)
* KIRK (kirk.geogr.uni-jena.de; 141.35.159.147)
* SCOTTY (scotty.geogr.uni-jena.de; 141.35.159.149)
* SPOCK (spock.geogr.uni-jena.de; 141.35.159.148)

All are curretnly running on a Debian 9 “stretch” operating system.
All servers have the same hardware (48 cores, 193 GB RAM) with each AMD core running on 2,1 GHz.
Your user accounts will work for all four servers.

All servers share the same `home` folder (using an `nfs` mount with `mccoy` as the base).
This means you can log in on any server and access a shared folder structure.
All changes you do will instantly be reflected across all servers.

# 2. Data and scripts

Please store all your data in the `/data` directory and everything else (scripts, figures, documents) in your `/home/<yourusername>` directory on MCCOY.
The mounted `/data` directory is a (windows) file-server (41 TB) with a lot more space than MCCOY (2 TB).
See below for a detailed guide how to connect to LOSSA (where you should store your data) and MCCOY (where all your scripts should be placed) to access both your data and scripts.

**DO NOT PUT DATA INTO `/home`!
I will move it to `/data` without any prior notice.**
**This will most likely break your scripts.
Don't say I did not warn you :)**

**Note:** A *personal recommendation* of mine is to split your data directory into `raw` and `mod` to have a clear cut between read-only raw data and modified data by you.

# 3. Geospatial libraries

The servers can be used for any geo-related processing but are set up with a focus on `R` processing.
System libraries will be updated once a week.

A list of important geo-related libraries:

* `GDAL`
* `GEOS`
* `SAGA`
* `GRASS7`
* `TAUDEM` (compiled from source, v5.3.8)

# 4. Accessing the servers

Accessing servers is two fold:

1. Mount the servers to your local machine to move and access files.

2. Log in via shell using your favourite terminal application to communicate to the server via the command line.

## 4.1 Accessing the folders

### 4.1.1 Windows

#### 4.1.1.1 Scripts

Please use [WinSCP](https://winscp.net/eng/index.php).
Enter `mccoy.geogr.uni-jena.de` with the `sftp` protocol and your username + password from the server.
You only need to connect to MCCOY as your `/home` directory is shared across all servers.

#### 4.1.1.2 Data

As said before, all data is stored on LOSSA.
LOSSA is a Windows server which is mounted to MCCOY, KIRK, SCOTTY and SPOCK under `/data`.
To access your files, you can connect to the server via Windows Explorer by doing the following:

1. Right-click on "Network" -> Map network drive
2. In "Folder" enter `\\lossa.ads.uni-jena.de\data\data_mccoy_kirk_scotty`
3. Check "Connect using different credentials"
4. Username: `FSUJENA\<URZ_ID>`
5. Password: `<Your URZ_ID password>`

To successfully connect to the Windows servers from outside the university, you need to use a VPN.
See section on "RStudio Server Pro" for more information.

### 4.1.2 Linux & Mac

#### 4.1.2.1 Scripts

I use entries in `/etc/fstab` which mount MCCOY into my file-manager using `sshfs`.

On (Arch) Linux (fuse > v3.0), I have an entry in `/etc/fstab` that looks as follows:

```bash
patrick@141.35.159.150:/      /mnt/mccoy      fuse.sshfs
  nonempty,reconnect,idmap=user,transform_symlinks,identityFile=~/.ssh/id_rsa,allow_other,cache=yes,
  kernel_cache,compression=no,default_permissions,uid=1000,gid=100,umask=0,_netdev,
  x-systemd.after=network-online.target   0 00
```

On any Ubuntu derivate it would be as follows (fuse v2.9)

```bash
sshfs#patrick@141.35.159.150:/        /mnt/mccoy          fuse
  nonempty,reconnect,idmap=user,transform_symlinks,identityFile=~/.ssh/id_rsa,allow_other,cache=yes,
  kernel_cache,compression=no,default_permissions,uid=1000,gid=100,umask=0,_netdev,
  x-systemd.after=network-online.target   0 0
```

#### 4.1.2.2 Data

To connect to Windows servers in our environment, you can use a similar entry in `/etc/fstab`:

```bash
//141.35.159.70/home_geoinf /mnt/geoinf cifs credentials=/etc/.smbcredentials.txt,uid=1000,
  file_mode=0775,dir_mode=0775,gid=100,sec=ntlm,vers=1.0,dom=ads.uni-jena.de,forcegid,
  _netdev,x-systemd.after=network-online.target 0 0
```

Note: To get the `cifs` mounts working, you need to provide a text file with your username and password.
In this example I use `/etc/.smbcredentials.txt` which contains:

```
username: <URZ_ID>
password: <URZ_ID password>
```

## 4.2 Command-line access

### 4.2.1 Windows

On Windows the easiest option is probably to use [MobaXterm](https://mobaxterm.mobatek.net/).

Go to `Session >> SSH` and enter the following:

* Remote Host: `mccoy.geogr.uni-jena.de`
* Username: <your username> (not your URZ, your MCCOY username. Usually your first name, e.g. "patrick".)

Then answer 'yes' if you are asked whether your password should be saved.
You can open multiple tabs in [MobaXterm](https://mobaxterm.mobatek.net/) and re-use your just created session.
You can also create splitted view by using the `split` button from the toolbar.
This way, one session can always show what's going on on the server using `htop` and the other can be used for your commands.

### 4.2.2 Linux & Mac

I prefer password-less logins via `ssh` by storing an authentication file which identifies you as a user so you do not have to type in your password every time you log in.

If you have never set a keygen pair at your local machine, please do so by calling `ssh-keygen -t rsa`.

If you already have a file named `id_rsa.pub` in your `~/.ssh` folder at your local machine, skip this step!
Otherwise it will override your existing one and may invalidate previous ssh connections you set up.
You now have a `id_rsa.pub` file in a (hidden!) folder named `.ssh` within `/home` (at your local machine).
Now you need to copy this file (`id_rsa.pub`) to the server so that you can be identified:

```
cat .ssh/id_rsa.pub | ssh username@mccoy.geogr.uni-jena.de 'cat >> .ssh/authorized_keys'
```

Every time you log in via command line now, you will not be prompted for your password.

You can further simplify the login process.
Instead of having to type `ssh <user>@mccoy.geogr.uni-jena` you can store all of this information in your `.ssh/config` file:

```bash
Host mccoy
    user <username>
    Hostname mccoy.geogr.uni-jena.de
    IdentityFile /path/to/.ssh/id_rsa
```

This can be done for all four servers.

**Personal recommendation:** Set up profiles in your terminal application that automatically send the log in command once you open the profile.
You can further save arrangements of multiple profiles if your terminal application supports that.
If you restore the arrangement, all your profiles will be loaded.
This is extremely useful to log in to all servers with multiple windows with just one click.

# 5. RStudio Server Pro

We have a license for `RStudio Server Pro` which runs on `MCCOY`.
`RStudio Server Pro` enables you to work in your familiar `RStudio` environment while all processing is executed on the server and not on your local machine.
This enables you to do other stuff at your local machine while the server is busy processing.
No crashing because of lack of RAM or limited number of cores.

To log in, simply connect to `mccoy.geogr.uni-jena.de:8787` in your browser and log in using your username and password.

All packages you install will also be used across all other servers as your personal library is by default stored within your `/home` directory.

**Note:** While the command line and WinSCP login should work without a [VPN](https://www.uni-jena.de/Universit%C3%A4t/Einrichtungen/URZ/Dienste/Datennetz/Netzzugang/VPN_Zugang/VPN+_+FSU+Jena.html) if you are not in the rooms of our chair, you need to use it if you want to use RStudio Server from outside.
Please log in to the VPN using

```
<URZ_username>@vlan630.uni-jena.de
```

where “URZ_username” is your university username (not the one you use on the server!).
This identifies you as a temporary member of our group and gives you the remote access rights for the RStudio Server port.

# 6. Executing long running/parallel processing jobs

While these kind of processing can also be done in `RStudio Server`, I recommend to start long running jobs via the command line.
Sometimes, jobs get killed/stuck by some interference in `RStudio Server`, especially if you use parallelization.
From my personal experience, this can happen when you execute a particular script and work in a different one within the same `RStudio Server` session.
Also it may happen that you restart the wrong R session by accident or loose the connection to the server.
All this does not happen often but if your script crashes after several days, please do not say that I did not warn you :-)

Video with some usage instructions: https://www.rstudio.com/resources/videos/rstudio-server-pro-1-1-new-features/

### 6.1 How to do it right

1. To ensure that your script is not tackled by any interference, please start it using `nohup`.
This command ensures that no permanent connection is required between the source which started the script and the server.
All settings will be stored on the server and you can close the connection, shut down your machine and the script will still continue running.
All output which would have been printed to the console will be written to a file called `nohup.out` in the directory from which you started the job.
2. If you use parallelization first make sure that nobody else is currently doing heavy processing on the server.
Check by using `htop` that the server is "free enough" for your processing.
That means, please checke the available RAM and that enough cores are idle in case you want to do parallel processing.
If you see all cores working, simply start your script on one of the other servers (`MCCOY`, `KIRK`, `SCOTTY`, `SPOCK`).
There will most likely be at least one server that is not fully loaded.
3. Next, ‘nice’ the priority of your heavy processing jobs.
This makes it possible that other small jobs will still work because they have a higher priority by default (default = 0).
What happens in detail is that if a higher priority job is started by a user (e.g. copying of files) it gets prioritised over the long running jobs.
Doing so, other users will not suffer from delays doing their normal work by the heavy processing.
I always ‘nice’  my processes to a value of `19` (lowest possible = 20).
4. R scripts can be started using `Rscript`. Be aware that `Rscript` [does not load the `methods` package](https://stackoverflow.com/questions/19680462/rscript-does-not-load-methods-package-r-does-why-and-what-are-the-consequen)!
5. A full example could look as follows: `nohup nice -19 Rscript /path/to/script.R`
6. If you forgot to ‘nice’ your processes during starting, you can renice them afterwards using `renice -19 -u <yourusername>`.
However, note that this will ‘renice’ all processes of your user account including `RStudio Server` instances and other stuff.
7. Assuming you want to start multiple `nohup` jobs on different servers, you need to specify a custom output file for `nohup`.
Otherwise, all processes will write to the same file (`nohup.out`) at the same time.
You can do so by appending `> nohup_kirk.out&`  at the end of your command.
Of course you can change the name to your desires.
The full example would then look like

```
nohup nice -19 Rscript /path/to/script.R > nohup_kirk.out&
```

## 6.2 Killing processes

**Single process:**
Type `htop`, select the process and press "Kill".

**Multiple/all processes:**
`killall -u <username>`

# 7. Appendix: Admin notes (German)

## 7.1 Installation of R with Intel-mkl support

Massive speedup, see [this benchmarking comparison](http://pacha.hk/2017-12-02_why_is_r_slow.html).
**Note: We have AMD cores so the speedup of the `intel-mkl` library does not apply for our servers.
Going with `libopenblas` which has a similar speedup and is detected automatically.**


First, install `intel-mkl`:

```bash
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB

sudo sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list'

sudo apt-get install intel-mkl-64bit-2018.1-038 # the package name is version dependend

sudo apt-get build-dep r-base # install R deps
```

Afterwards, install R from source with `intel-mkl`:

```bash
wget https://cran.r-project.org/src/base/R-3/R-3.4.3.tar.gz
tar xzvf R-3.4.3.tar.gz
rm R-3.4.3.tar.gz
cd R-3.4.3

source /opt/intel/mkl/bin/mklvars.sh intel64

MKL="-L/opt/intel/mkl/lib/intel64 -Wl,--no-as-needed -lmkl_gf_lp64 -Wl,--start-group -lmkl_gnu_thread  -lmkl_core  -Wl,--end-group -fopenmp  -ldl -lpthread -lm"

export LD_LIBRARY_PATH=/opt/intel/mkl/lib/intel64:$PATH
./configure --with-blas="$MKL" --with-lapack --enable-shared --enable-R-shlib
make
sudo make install
```

**Note:** This was not working with `clusterssh`.
Apparently the `configure` and `make` calls interfered with each other.
Running them on each server sequetnially worked fine.

## 7.2 Remote file editing over ssh

Is supported via [rsub](https://github.com/henrikpersson/rsub)/[rmate](https://github.com/aurora/rmate).
When `.ssh/config` is correctly set, one is logged in via ssh using remote port forwarding and has an editor that supports this (e.g. Atom, SublimeText3), simply calling `rsub/rmate <file.txt>` opens the file locally in SublimeText3.

## 7.3 `/data` folder

`/data` wird von `lossa.ads.uni-jena/data/data_mccoy_scotty_kirk`  (windows) mittels `cifs` zu `mccoy.geogr.uni-jena/data`, `scotty.geogr.uni-jena/data` und `kirk.geogr.uni-jena/data`(Debian) gemounted.

Da es wohl Netzwerk bedingte Zeitprobleme beim mounten gibt, wird `/data` nachträglich über `sudo mount -a` in `/etc/rc.local` gemounted.

Zugriff auf `/data` wird über Gruppe “data_users” geregelt mit Eintrag “gid=10000” in `/etc/fstab`.

Dieser Ansatz führt zu Berechtigungsproblemen wenn man versucht mit `WinSCP` auf den `/data` Ordner zuzugreifen.
Das liegt vermutlich daran, dass der `cifs` mount immer von einem user ausgeführt wird (momentan "patrick") und alle anderen Personen nur über die Gruppe Zugriff haben.
Alle Ordner gehören jedoch Nutzer "patrick", was `WinSCP` nicht gefällt.
Daher wird momentan empfohlen die Verbindungen zu LOSSA über den Windows Explorer herzustellen.
In Zukunft wäre es sinnvoll auch einen Linux Daten Server zu haben, damit dieser dann mit `nfs` gemounted werden kann und diese Probleme hoffentlich verschwinden.

## 7.4 `home` folders

MCCOY dient als '`nfs` share für `SCOTTY`,`KIRK` und `SPOCK` für `/home` mit der Ziel directory `/home`.
Die ursprüngliche `/home` directory von `SCOTTY`,`KIRK` und `SPOCK` ist nach `/home_local` verschoben.

## 7.5 Installierte Bibliotheken (alle server)

* 18/08/2017

  * apt-transport-https
  * dirmngr
  * r-base
  * libgdal-dev
  * libssl-dev
  * libudunits2-dev
  * portmap
  * ufw
  * psmisc
  * libv8-3.14-dev
  * git
  * saga
  * grass
  * qgis
  * cifs-utils
  * samba
  * gvfs
  * pwgen

* 22/08/2017
  * members

* 25/07/2017
  * libprotobuf-dev
  * protobuf-compiler

* 04/09/2017
  * parallel

* 08/09/2017
  * default-jre
  * default-jdk

* 11/09/2017
  * python-pip
  * python3-pip

* 13/09/20017
  * libgsl-dev
  * mkdocs
  * libjs-mathjax
  * python-markdown

* 15/09/2017
  * screen

* 19/09/2017
  * docker

* 02/11/2017
  * net-tools

* 03/11/2017
  * curl
  * autoconf
  * autoconf-archive
  * autogen
  * automake
  * libmnl-dev

* 16/11/2017
  * fftw-dev
  * libfftw3-dev

* 08/12/2017
  * libopenmpi-dev
  * cmake

* 11/12/2017
  * libgconf-2-4

* 18/12/2017
  * ccache

* 02/02/2018
  * libcairo2-dev

### 7.5.1 mccoy only (rstudio server)

* gdebi-core
* libssl1.0.0_1.0.1
* nfs-kernel-server
* nfs-server

### 7.5.2 kirk, scotty, spock only

* nfs-common
