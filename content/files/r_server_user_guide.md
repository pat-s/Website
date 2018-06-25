+++
title = 'User guide for the R processing servers'
author = 'Patrick Schratz'
date = '2018-04-02'
tags = ['r_server_user_guide']
+++

[NEWS](https://pat-s.github.io/files/changelog)

Acknowledgements:
Thanks to Sven Kralisch and Benjamin Ludwig who helped me a lot!

**Table of Contents**

- [1. Introduction](#1-introduction)
- [2. Data and scripts](#2-data-and-scripts)
- [3. Geospatial libraries](#3-geospatial-libraries)
- [4. Accessing the servers](#4-accessing-the-servers)
  - [4.1 Accessing the folders](#41-accessing-the-folders)
    - [4.1.1 Windows](#411-windows)
      - [4.1.1.1 Scripts](#4111-scripts)
      - [4.1.1.2 Data](#4112-data)
    - [4.1.2 Linux & Mac](#412-linux--mac)
      - [4.1.2.1 Scripts](#4121-scripts)
      - [4.1.2.2 Data](#4122-data)
  - [4.2 Command-line access](#42-command-line-access)
    - [4.2.1 Windows](#421-windows)
    - [4.2.2 Linux & Mac](#422-linux--mac)
- [5. Working with multiple R versions](#5-working-with-multiple-r-versions)
- [6. RStudio Server Pro & Shiny Server](#6-rstudio-server-pro--shiny-server)
  - [6.1 RStudio Server Pro](#61-rstudio-server-pro)
  - [6.2 Shiny server](#62-shiny-server)
- [7. Executing long running/parallel processing jobs](#7-executing-long-runningparallel-processing-jobs)
  - [7.1 How to do it right](#71-how-to-do-it-right)
    - [7.1.1 screen/byobu](#711-screenbyobu)
    - [7.1.2 nohup](#712-nohup)
  - [7.2 Killing processes](#72-killing-processes)
- [8. Appendix: Admin notes (German)](#8-appendix-admin-notes-german)
  - [8.1 Installed R versions](#81-installed-r-versions)
  - [8.2 Remote file editing over ssh](#82-remote-file-editing-over-ssh)
  - [8.3 `/data` folder](#83-data-folder)
  - [8.4 `home` folders](#84-home-folders)
  - [8.5 Shiny Server setup](#85-shiny-server-setup)
  - [8.6 Installierte Bibliotheken (alle server)](#86-installierte-bibliotheken-alle-server)
    - [8.6.1 mccoy only (rstudio server)](#861-mccoy-only-rstudio-server)
    - [8.6.2 kirk, scotty, spock only](#862-kirk-scotty-spock-only)

# 1. Introduction

There are currently four servers set up tailored towards `R` processing:

* MCCOY (mccoy.geogr.uni-jena.de; 141.35.159.150)
* KIRK (kirk.geogr.uni-jena.de; 141.35.159.147)
* SCOTTY (scotty.geogr.uni-jena.de; 141.35.159.149)
* SPOCK (spock.geogr.uni-jena.de; 141.35.159.148)

All are currently running on a Debian 9 “stretch” operating system.
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

On any Debian derivate (e.g. Ubuntu) it would look as follows (fuse v2.9)

```bash
sshfs#patrick@141.35.159.150:/        /mnt/mccoy          fuse
  nonempty,reconnect,idmap=user,transform_symlinks,identityFile=~/.ssh/id_rsa,allow_other,cache=yes,
  kernel_cache,compression=no,default_permissions,uid=1000,gid=100,umask=0,_netdev,
  x-systemd.after=network-online.target   0 0
```

#### 4.1.2.2 Data

To connect to Windows servers in our environment, you can use a similar entry in `/etc/fstab`:

```bash
//141.35.159.70/home_geoinf /mnt/geoinf cifs credentials=~/.smbcredentials.txt,uid=1000,
  file_mode=0775,dir_mode=0775,gid=100,sec=ntlm,vers=1.0,dom=ads.uni-jena.de,forcegid,
  _netdev,x-systemd.after=network-online.target 0 0
```

You should also make sure that minimal permissions are set for `~/.smbcredentials`.
If not already done, do `sudo chmod 600 ~/.smbcredentials`.

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
$ ssh username@mccoy.geogr.uni-jena.de 'test -d ~/.ssh && mkdir ~/.ssh' # creates the .ssh directory if it does not exist
$ cat .ssh/id_rsa.pub | ssh username@mccoy.geogr.uni-jena.de 'cat >> .ssh/authorized_keys' # copies your local public key to the server
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


# 5. Working with multiple R versions

All R Versions starting from 3.4.3 are installed on the server under `/opt/<version>`.
Why? For reproducibility! A good workflow looks like this:
1. Create a new project with the most recent R version
2. Update all packages and never do that until this project is finished (unless an update is essential for some tasks)
3. Initialize a packrat project to bundle package versions only for this project

While the versions for a project are automatically managed by RStudio Server when you open the respective project, this is not the case if you start R from the shell.

Whenever you start an R process for your project that needs a different R version that the most current one, you need to explicitly tell the system.
An example: You started your project with R version 3.4.4.
Meanwhile R was updated to version 3.5.0 on the server.
Now everytime you start R from the command line using `R`, it will use version 3.5.0.
To use the packages associated with your project and its R version, you need to do two things:
1. Change the directory to your project directory. This way the packrat packages are recognized when starting R
2. Start the R version that is associated with the project. For R version 3.4.4 this would then be `/opt/R/3.4.4/bin/R`. You will see that during startup R will recognized the packrat libraries and everything will work. This will not be the case if you simply use `R` as this would start R version 3.5.0!

Keep that in mind when using commands like `Rscript` in `nohup` or `byobu`! Always make sure to use the correct R version.

# 6. RStudio Server Pro & Shiny Server

## 6.1 RStudio Server Pro
We have a license for `RStudio Server Pro` which runs on `MCCOY`.
`RStudio Server Pro` enables you to work in your familiar `RStudio` environment while all processing is executed on the server and not on your local machine.
This enables you to do other stuff at your local machine while the server is busy processing.
No crashing because of lack of RAM or limited number of cores.

To log in, simply connect to `mccoy.geogr.uni-jena.de:8787` or `mccoy.geogr.uni-jena.de/rstudio` in your browser and log in using your username and password.

All packages you install will also be used across all other servers as your personal library is by default stored within your `/home` directory.

**Note:** While the command line and WinSCP login should work without a [VPN](https://www.uni-jena.de/Universit%C3%A4t/Einrichtungen/URZ/Dienste/Datennetz/Netzzugang/VPN_Zugang/VPN+_+FSU+Jena.html) if you are not in the rooms of our chair, you need to use it if you want to use RStudio Server from outside.
Please log in to the VPN using

```
<URZ_username>@uni-jena.de
```

where “URZ_username” is your university username (not the one you use on the server!).
This identifies you as a temporary member of our group and gives you the remote access rights for the RStudio Server port.

## 6.2 Shiny server

Shiny server is running on MCCOY.
To launch your shiny apps, simply put the respective `server.R` and `ui.R` files in a folder `ShinyApps` in your home directory, e.g. `~/patrick/ShinyApps/hello/server.R`.
You can then access the shiny app via the following URLs: mccoy.geogr.uni-jena.de/shiny/patrick/hello or mccoy.geogr.uni-jena.de:3838/patrick/hello

# 7. Executing long running/parallel processing jobs

While these kind of processing can also be done in `RStudio Server`, I recommend to start long running jobs via the command line.
Sometimes, jobs get killed/stuck by some interference in `RStudio Server`, especially if you use parallelization.
From my personal experience, this can happen when you execute a particular script and work in a different one within the same `RStudio Server` session.
Also it may happen that you restart the wrong R session by accident or loose the connection to the server.
All this does not happen often but if your script crashes after several days, please do not say that I did not warn you :-)

Video with some usage instructions: https://www.rstudio.com/resources/videos/rstudio-server-pro-1-1-new-features/

## 7.1 How to do it right

1. If you use parallelization first make sure that nobody else is currently doing heavy processing on the server.
Check by using `htop` that the server is "free enough" for your processing.
That means, please checke the available RAM and that enough cores are idle in case you want to do parallel processing.
If you see all cores working, simply start your script on one of the other servers (`MCCOY`, `KIRK`, `SCOTTY`, `SPOCK`).
There will most likely be at least one server that is not fully loaded.
2. Next, ‘nice’ the priority of your heavy processing jobs.
This makes it possible that other small jobs will still work because they have a higher priority by default (default = 0).
What happens in detail is that if a higher priority job is started by a user (e.g. copying of files) it gets prioritised over the long running jobs.
Doing so, other users will not suffer from delays doing their normal work by the heavy processing.
I always ‘nice’  my processes to a value of `19` (lowest possible = 20).
3. R scripts can be started using `Rscript <path>`. Be aware that `Rscript` [does not load the `methods` package](https://stackoverflow.com/questions/19680462/rscript-does-not-load-methods-package-r-does-why-and-what-are-the-consequen)!
5. If you forgot to ‘nice’ your processes during starting, you can renice them afterwards using `renice -19 -u <yourusername>`.
However, note that this will ‘renice’ all processes of your user account including `RStudio Server` instances and other stuff.

### 7.1.1 screen/byobu

`screen` and `byobu` (the latter being just an enhanced version of the former) are two window-manager libraries that overcome some limitations of the standard shell:

* Sessions are not disconnected when the window is closed, i.e. your processes continue to run if their was a network disconnect or you turn off your computer
* Sessions can be labeled so that you know whats currently running (very useful for if you have multiple windows open)
* Sessions can be resumed

Both libraries are installed on the server. I recommend to go with `byobu`. To start a new session, do `byobu -S <name>`. You will see that `byobu` will add some information about the server in the navbar at the bottom of the window (e.g. who is logged in, the IP address of the server, which operating system and much more).

<img src="../../img/r_server_user_guide/byobu.png" style="width: 100%;">

If you close the window now, it will still exist and all processes will continue running. To get back into it, you need to execute `byobu -r` (`r` stands for "resume"). If you created multiple sessions, you need to append the name as well. If you forget it, `byobu` will ask which session should be resumed. To close a session, you can enter `exit` when its running or use `CRTL+A` and then press `D`.

For tiling windows and switching between them, see the "keybindings" section at http://byobu.co/documentation.html.

**Note**: You can customize the navbar by pressing `F9`.

### 7.1.2 nohup

`nohup` is basically taking a command and executing it until its finished. The command line output is redirected to a `.txt` file that you can specify.
Disadvantages compared to the `byobu` approach are that you will have no access to the shell once you executed the command. Also, to kill the process(es) you need to send a KILL signal to the process PID or (if there are parallel processes running) kill all your user processes using `killall -u <name>`. Furthermore, to see the progress, you always need to open the respective `.txt` file and reload it all the time.

A working `nohup` example that redirects the output to a file called `nohup.out` with a priority of 19 would look as follows: `nohup nice -19 Rscript /path/to/script.R > nohup.out&`

1. If you use parallelization first make sure that nobody else is currently doing heavy processing on the server.
Check by using `htop` that the server is "free enough" for your processing.
That means, please checke the available RAM and that enough cores are idle in case you want to do parallel processing.
If you see all cores working, simply start your script on one of the other servers (`MCCOY`, `KIRK`, `SCOTTY`, `SPOCK`).
There will most likely be at least one server that is not fully loaded.
2. Next, ‘nice’ the priority of your heavy processing jobs.
This makes it possible that other small jobs will still work because they have a higher priority by default (default = 0).
What happens in detail is that if a higher priority job is started by a user (e.g. copying of files) it gets prioritised over the long running jobs.
Doing so, other users will not suffer from delays doing their normal work by the heavy processing.
I always ‘nice’  my processes to a value of `19` (lowest possible = 20).
3. R scripts can be started using `Rscript <path>`. Be aware that `Rscript` [does not load the `methods` package](https://stackoverflow.com/questions/19680462/rscript-does-not-load-methods-package-r-does-why-and-what-are-the-consequen)!
5. If you forgot to ‘nice’ your processes during starting, you can renice them afterwards using `renice -19 -u <yourusername>`.
However, note that this will ‘renice’ all processes of your user account including `RStudio Server` instances and other stuff.


## 7.2 Killing processes

**Single process:**
Type `htop`, select the process and press "Kill".

**Multiple/all processes:**
`killall -u <username>`

# 8. Appendix: Admin notes (German)

## 8.1 Installed R versions

For reproducibility of projects it is important to have multiple R versions installed.
New projects will always use the most recent version.
However, RStudio-Server projects will always work with the version they have beenn initialized with.

The following script is used to install the respective version into `/opt/R/`.
The reason for this directory is that it is automatically picked up by RStudio-Server and then selectable in the dropdown.

```bash
R_VERSION="3.5.0"

sudo rm -rf /opt/R/$R_VERSION
sudo mkdir -p /opt/R/
cd /opt/R/
sudo wget https://cloud.r-project.org/src/base/R-3/R-$R_VERSION.tar.gz
sudo tar -xzf R-$R_VERSION.tar.gz
sudo rm R-$R_VERSION.tar.gz
cd R-$R_VERSION
sudo ./configure --prefix=/opt/R/$R_VERSION --enable-R-shlib --with-blas --with-lapack
sudo make
sudo make install
cd ..
sudo rm -rf R-$R_VERSION
```

The `PATH` variable is always set to the most recent installed version.
For bash-login shells this is done in `/etc/profiles.d/app-bin-path.sh`.
For z-login shells this is done in `/etc/zsh/zprofile`.
After upgrading to a new version, the R version in these files should be changed (on every server!).

## 8.2 Remote file editing over ssh

Is supported via [rsub](https://github.com/henrikpersson/rsub)/[rmate](https://github.com/aurora/rmate).
When `.ssh/config` is correctly set, one is logged in via ssh using remote port forwarding and has an editor that supports this (e.g. Atom, SublimeText3), simply calling `rsub/rmate <file.txt>` opens the file locally in SublimeText3.

## 8.3 `/data` folder

`/data` wird von `lossa.ads.uni-jena/data/data_mccoy_scotty_kirk`  (windows) mittels `cifs` zu `mccoy.geogr.uni-jena/data`, `scotty.geogr.uni-jena/data` und `kirk.geogr.uni-jena/data`(Debian) gemounted.

Da es wohl Netzwerk bedingte Zeitprobleme beim mounten gibt, wird `/data` nachträglich über `sudo mount -a` in `/etc/rc.local` gemounted.

Zugriff auf `/data` wird über Gruppe “data_users” geregelt mit Eintrag “gid=10000” in `/etc/fstab`.

Dieser Ansatz führt zu Berechtigungsproblemen wenn man versucht mit `WinSCP` auf den `/data` Ordner zuzugreifen.
Das liegt vermutlich daran, dass der `cifs` mount immer von einem user ausgeführt wird (momentan "patrick") und alle anderen Personen nur über die Gruppe Zugriff haben.
Alle Ordner gehören jedoch Nutzer "patrick", was `WinSCP` nicht gefällt.
Daher wird momentan empfohlen die Verbindungen zu LOSSA über den Windows Explorer herzustellen.
In Zukunft wäre es sinnvoll auch einen Linux Daten Server zu haben, damit dieser dann mit `nfs` gemounted werden kann und diese Probleme hoffentlich verschwinden.

## 8.4 `home` folders

MCCOY dient als '`nfs` share für `SCOTTY`,`KIRK` und `SPOCK` für `/home` mit der Ziel directory `/home`.
Die ursprüngliche `/home` directory von `SCOTTY`,`KIRK` und `SPOCK` ist nach `/home_local` verschoben.

## 8.5 Shiny Server setup

https://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/#user-libraries

To allow for port aliases (3838 = shiny, 8787 = rstudio) the following has been added to `/etc/nginx/sites-enabled/default`:

```
location /shiny/ {
proxy_pass http://127.0.0.1:3838/;
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
}

location /rstudio/ {
proxy_pass http://127.0.0.1:8787/;
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
}
```

The "prox-pass" modifications are needed to suppress websocket related errors.

The ability to give users the option to place apps in their home directory was enabled (http://docs.rstudio.com/shiny-server/#let-users-manage-their-own-applications).

## 8.6 Installierte Bibliotheken (alle server)

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

* 05/04/2018
  * nginx
  
* 01/06/2018
  * libsecret-1-dev

- 24/06/2018
  - libwxgtk3.0-dev

### 8.6.1 mccoy only (rstudio server)

* gdebi-core
* libssl1.0.0_1.0.1
* nfs-kernel-server
* nfs-server

### 8.6.2 kirk, scotty, spock only

* nfs-common
