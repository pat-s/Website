+++
title = 'User guide for the R processing servers'
author = 'Patrick Schratz'
date = '2018-08-11'
tags = ['r_server_user_guide']
+++

[NEWS](https://pat-s.github.io/files/changelog)

Acknowledgements:
Thanks to Sven Kralisch and Benjamin Ludwig who helped me a lot!

#### Table of Contents

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
- [5. Working on the server - best practices](#5-working-on-the-server---best-practices)
  - [5.1 Enable packrat](#51-enable-packrat)
  - [5.2 Using R from the command line](#52-using-r-from-the-command-line)
  - [5.3 Robust command line usage / heave processing tasks](#53-robust-command-line-usage--heave-processing-tasks)
  - [5.4 Monitoring / killing processes](#54-monitoring--killing-processes)
- [6. RStudio Server Pro & Shiny Server](#6-rstudio-server-pro--shiny-server)
  - [6.1 RStudio Server Pro](#61-rstudio-server-pro)
  - [6.2 Shiny server](#62-shiny-server)
- [7. Appendix: Admin notes (German)](#7-appendix-admin-notes-german)
  - [7.1 Installed R versions & installing new R versions](#71-installed-r-versions--installing-new-r-versions)
  - [7.2 Remote file editing over ssh](#72-remote-file-editing-over-ssh)
  - [7.3 `/data` folder](#73-data-folder)
  - [7.4 `home` folders](#74-home-folders)
  - [7.5 Shiny Server setup](#75-shiny-server-setup)
  - [7.6 Installierte Bibliotheken (alle server)](#76-installierte-bibliotheken-alle-server)
    - [7.6.1 mccoy only (rstudio server)](#761-mccoy-only-rstudio-server)
    - [7.6.2 kirk, scotty, spock only](#762-kirk-scotty-spock-only)

# 1. Introduction

There are currently four servers set up tailored towards `R` processing:

- MCCOY (mccoy.geogr.uni-jena.de; 141.35.159.150)
- KIRK (kirk.geogr.uni-jena.de; 141.35.159.147)
- SCOTTY (scotty.geogr.uni-jena.de; 141.35.159.149)
- SPOCK (spock.geogr.uni-jena.de; 141.35.159.148)

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

**Note:*- A *personal recommendation- of mine is to split your data directory into `raw` and `mod` to have a clear cut between read-only raw data and modified data by you.

# 3. Geospatial libraries

The servers can be used for any geo-related processing but are set up with a focus on `R` processing.
System libraries will be updated once a week.

A list of important geo-related libraries:

- `GDAL`
- `GEOS`
- `SAGA`
- `GRASS7`
- `TAUDEM` (compiled from source, v5.3.8)

# 4. Accessing the servers

Accessing servers is two fold:

1. Mount the servers to your local machine to move and access files.

2. Log in via shell using your favourite terminal application to communicate to the server via the command line.

## 4.1 Accessing the folders

### 4.1.1 Windows

#### 4.1.1.1 Access scripts and files on MCCOY

Please use [WinSCP](https://winscp.net/eng/index.php).
Enter `mccoy.geogr.uni-jena.de` with the `sftp` protocol and your username + password from the server.
You only need to connect to MCCOY as your `/home` directory is shared across all servers.

#### 4.1.1.2 Access data on LOSSA

All data is stored on LOSSA.
LOSSA is a Windows server which is mounted to MCCOY, KIRK, SCOTTY and SPOCK under `/data`.
To access your files, you can connect to the server via Windows Explorer by doing the following:

1. Right-click on "Network" -> Map network drive
2. In "Folder" enter `\\lossa.ads.uni-jena.de\data\data_mccoy_kirk_scotty`
3. Check "Connect using different credentials"
4. Username: `FSUJENA\<URZ_ID>`
5. Password: `<Your URZ_ID password>`

To successfully connect to the Windows servers from outside the university, you need to use a VPN.
See section on "RStudio Server Pro" for more information.
Also, your URZ needs to be added to LOSSA in the first place.
When you read this the first time, this is usually not the case.
To do so, write/talk to the system admin!
Only he can add you to the server so you can use the above approach.
Otherwise, please use the WinSCP approach and access the data via the `/data` folder over MCCOY.
However, you will get annyoing message that you lack write access when you drop data there via this approach.
This is a false positive and it will work anyways.
Nevertheless you should try to get the other approach working in the long run!

### 4.1.2 Linux & Mac

#### 4.1.2.1 Access scripts and files on MCCOY

As MCCOY is a Linux server, you can directly mount it to your file manager via entries in `/etc/fstab`.

On (Arch) Linux (`fuse` > v3.0), a possible entry in `/etc/fstab` would looks as follows:

```bash
<username>@141.35.159.150:/      /mnt/mccoy      fuse.sshfs
  nonempty,reconnect,idmap=user,transform_symlinks,identityFile=~/.ssh/id_rsa,allow_other,cache=yes,
  kernel_cache,compression=no,default_permissions,uid=1000,gid=100,umask=0,_netdev,
  x-systemd.after=network-online.target   0 00
```

On any Debian derivate (e.g. Ubuntu) it looks a bit different because `fuse` v2.9 is still used:

```bash
sshfs#<username>@141.35.159.150:/        /mnt/mccoy          fuse
  nonempty,reconnect,idmap=user,transform_symlinks,identityFile=~/.ssh/id_rsa,allow_other,cache=yes,
  kernel_cache,compression=no,default_permissions,uid=1000,gid=100,umask=0,_netdev,
  x-systemd.after=network-online.target   0 0
```

Now you can call  `sudo mount -a` and MCCOY will be available in your file-manager under `/mnt/mccoy`.

#### 4.1.2.2 Access data on LOSSA

To connect to Windows servers, you can use a similar entry in `/etc/fstab` using the `cifs` protocol:

```bash
//141.35.159.70/home_geoinf /mnt/geoinf cifs credentials=~/.smbcredentials.txt,uid=1000,
  file_mode=0775,dir_mode=0775,gid=100,sec=ntlm,vers=1.0,dom=ads.uni-jena.de,forcegid,
  _netdev,x-systemd.after=network-online.target 0 0
```

You need to store your URZ credentials somewhere, e.g. in a text file called `.smbcredentials` in your home directory.
It should look as follows:

```sh
username: <URZ_ID>
password: <URZ_ID password>
```

You should also make sure that minimal permissions are set for `~/.smbcredentials`.
If not already done, do `sudo chmod 600 ~/.smbcredentials`.

## 4.2 Command-line access

### 4.2.1 Windows

On Windows the easiest option is probably to use [MobaXterm](https://mobaxterm.mobatek.net/).

Go to `Session >> SSH` and enter the following:

- Remote Host: `mccoy.geogr.uni-jena.de`
- Username: `<your username>` (not your URZ, your MCCOY username. Usually your first name, e.g. "patrick".)

Then answer 'yes' if you are asked whether your password should be saved.
You can open multiple tabs in [MobaXterm](https://mobaxterm.mobatek.net/) and re-use your just created session.
You can also create splitted view by using the `split` button from the toolbar.
This way, one session can always show what's going on on the server using `htop` and the other can be used for your commands.

### 4.2.2 Linux & Mac

On Unix system you can directly use your Terminal application.
You should aim to have a password-less login using `ssh`.
This can be achieved by storing an authentication file which identifies you as a user so you do not have to type in your password every time you log in.

If you have never set a "ssh keygen pair" at your local machine, please do so by calling `ssh-keygen -t rsa`.

If you already have a file named `id_rsa.pub` in your `~/.ssh` folder at your local machine, skip this step!
Otherwise it will override your existing one and may invalidate previous ssh connections you set up.
You now have a `id_rsa.pub` file in a (hidden!) folder named `.ssh` within `/home` (at your local machine).
Now you need to copy this file (`id_rsa.pub`) to the server so that you can be identified:

```sh
ssh username@mccoy.geogr.uni-jena.de 'test -d ~/.ssh && mkdir ~/.ssh' # creates the .ssh directory if it does not exist
cat .ssh/id_rsa.pub | ssh username@mccoy.geogr.uni-jena.de 'cat >> .ssh/authorized_keys' # copies your local public key to the server
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

Now you can just do `ssh mccoy`.
This can be done for all four servers.

**Personal recommendation:** Set up profiles in your terminal application that automatically send the log in command once you open the profile.
You can further save arrangements of multiple profiles if your terminal application supports that.
If you restore the arrangement, all your profiles will be loaded.
This is extremely useful to log in to all servers with multiple windows with just one click.

# 5. Working on the server - best practices

## 5.1 Enable packrat

The following is a "best practice" recommendation from Patrick Schratz (August 2018).

For reproducibility, its important to have a standalone R package library for each of your projects/papers.
This is possible by using [packrat](https://rstudio.github.io/packrat/).

To initiate packrat, create/open a RStudio project and click on "Packages -> Packrat -> Use Packrat with this project".
What happens is that a unique library is created that will only be used for this project.
So later, when you submit your paper, you can refer to these package versions you used to create your results.
You can export this library later and attach it as supplemtary material to your paper.
I recommend to put it into a [Mendeley Data](https://data.mendeley.com/) repo that can be attached seamlessly to most journals and gives you 10 GB of free storage per project.

So whenever you work on this project, make sure to use the packrat library you just created.
Do not switch to a new R version.
Just stay with this R version you started and also stay with all the package versions.
Unless there is a major reason to upgrade the packages (e.g. packages are not working anymore or an important new feature was integrated that is important for your work), don't upgrade!

RStudio is capable of using any R version since 3.4.3 (I started once with this and I do not see the need to install older versions).

## 5.2 Using R from the command line

While the versions for a project are automatically managed by RStudio Server when you open the respective project, this is not the case if you start R from the command line.

If you `ssh` into the server and you are at the command prompt, you may want to start R.
As you may know, there are two commands to do so: Simply typing `R` and using `Rscript`.
The first will just start a new R session, the latter expect a R script and runs the whole script.
My advice: Never use any of them!
Why?

The first will always start the default R version of the server.
This version will at some point not be equal to the R version of the packrat library.
Also, to use the packrat library in the first place, you need to start R from the directory of your project and not from your `/home` directory!

The latter will always source an Rscript also using the default R version on the server.
But you want to use the packrat library for your specifc project!

So, to do it right, you need to to:

1. Change directory to your project: `cd <path>`
2. Use the R version associated to your packrat library. All R versions are installed under `/opt/R/<version>`. So to start e.g. v.3.4.4 you need to do: `/opt/R/3.4.4/bin/R`.

Well yes, this is tedious.
So how to simplify things?
Create an alias that runs exactly these two commands!

1. Open your `.bash_profile` via `nano ~/.bash_profile`
2. Add an "alias" by adding `alias R-paper1='cd <path> && /opt/R/<version>/bin/R'`

Replace `<path` with your packrat directory path and `<version>` with the R version you created it with.
Open a new shell window.
Every time you call `R-paper1` now, the directory will automatically be changed and the correct R version will be used.
Of course you are free to use any other name for the alias.

## 5.3 Robust command line usage / heave processing tasks

Now that you know how to use the correct R version together with your packrat library, the next step is processing.
Do not just start a long running process using RStudio server (which runs on MCCOY).
Why?
First, it blocks your current R session (unless you use the "jobs" feature).
Second, it takes CPU/Memory on MCCOY and will maybe slow down other peoples RStudio session.

Its better to start such tasks on the command line on KIRK/SCOTTY/SPOCK.
And not by just typing `R-paper1`.
Whats the problem this time?
Well, if your current connection to the server gets disturbed for some reason, your process will stop.
This can always happen and also you want to shut down your machine at some point, right?

To help here, use `byobu`.
[byobu](http://byobu.co/) is an open-source window-manager that does not get killed when you close the window.
Coming back, you can just continue your session at the current state.
So how do you do it?
Start with a new session: `byobu -S <session name>`.
Then you will see a little footer bar.
It displays some server info and you can be sure that you are now in a "byobu" session.
From here you can now call `R-paper1` and do what you want in there.
Finally ;)

After powering off your machine and coming back, simple call `byobu` and your session will re-loaded (if you only have one).
If you have two, calling `byobu` will ask you which session to continue.

So to summarise all the best practices:

1. Use packrat with your project!
2. Stay with one R version and the do not update the packages!
3. Make sure to use the correct R version in the correct directory by creating an alias!
4. Use `byobu` to start robust terminal sessions.

## 5.4 Monitoring / killing processes

Please monitor the CPU and RAM usage of your procesess, especially if you run tasks in parallel.
This can be done by calling `htop`.
Exceeding the RAM on the server means that everything will run very, very slowly, other users will not be able to do any stuff anymore.
This is especially important on MCCOY, on which all the single RStudio processes are running!

Also, make sure to start your long running processes with a lower priority.
The default is 0, max is -20, min is +20.

Always lower the priority of your processes so that "log in" processes (with the default prio of 0) always have a higher prio and will subsequently work even if you use the full power of the server.

Next, if your processes are exceeding the RAM, kill them!
Otherwise I will do it when I see it ;)
Or alternatively I'll kill you when I have to do this all the time :P

To start an R session with a lower priority, do for example `nice -18 <whatever>`.

If you missed it, please do it after starting the process: `renice -18 -u <your username>`.

Processes can be killed by doing `kill <PID>` to call a single process where the PID number can be found in the very left column in the `htop` view.
When you run parallel stuff, do `killall -u <yourusername>`.

# 6. RStudio Server Pro & Shiny Server

## 6.1 RStudio Server Pro

We have a license for `RStudio Server Pro` which runs on `MCCOY`.
`RStudio Server Pro` enables you to work in your familiar `RStudio` environment while all processing is executed on the server and not on your local machine.
This enables you to do other stuff at your local machine while the server is busy processing.
No crashing because of lack of RAM or limited number of cores.

To log in, simply connect to `mccoy.geogr.uni-jena.de:8787` in your browser and log in using your username and password.

All packages you install will also be used across all other servers as your personal library is by default stored within your `/home` directory.

**Note:*- While the command line and WinSCP login should work without a [VPN](https://www.uni-jena.de/Universit%C3%A4t/Einrichtungen/URZ/Dienste/Datennetz/Netzzugang/VPN_Zugang/VPN+_+FSU+Jena.html) if you are not in the rooms of our chair, you need to use it if you want to use RStudio Server from outside.
Please log in to the VPN using

```sh
<URZ_username>@uni-jena.de
```

where “URZ_username” is your university username (not the one you use on the server!).
This identifies you as a temporary member of our group and gives you the remote access rights for the RStudio Server port.

## 6.2 Shiny server

Shiny server is running on MCCOY.
To launch your shiny apps, simply put the respective `server.R` and `ui.R` files in a folder `ShinyApps` in your home directory, e.g. `~/patrick/ShinyApps/hello/server.R`.
You can then access the shiny app via the following URLs: mccoy.geogr.uni-jena.de/shiny/patrick/hello or mccoy.geogr.uni-jena.de:3838/patrick/hello

# 7. Appendix: Admin notes (German)

## 7.1 Installed R versions & installing new R versions

For reproducibility of projects it is important to have multiple R versions installed.
New projects will always use the most recent version.
However, RStudio-Server projects will always work with the version they have been initialized with.

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

## 7.5 Shiny Server setup

[https://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/#user-libraries](https://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/#user-libraries)

To allow for port aliases (3838 = shiny, 8787 = rstudio) the following has been added to `/etc/nginx/sites-enabled/default`:

```sh
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

The ability to give users the option to place apps in their home directory was enabled [(http://docs.rstudio.com/shiny-server/#let-users-manage-their-own-applications)](http://docs.rstudio.com/shiny-server/#let-users-manage-their-own-applications).

## 7.6 Installierte Bibliotheken (alle server)

- 18/08/2017

  - apt-transport-https
  - dirmngr
  - r-base
  - libgdal-dev
  - libssl-dev
  - libudunits2-dev
  - portmap
  - ufw
  - psmisc
  - libv8-3.14-dev
  - git
  - saga
  - grass
  - qgis
  - cifs-utils
  - samba
  - gvfs
  - pwgen

- 22/08/2017
  - members

- 25/07/2017
  - libprotobuf-dev
  - protobuf-compiler

- 04/09/2017
  - parallel

- 08/09/2017
  - default-jre
  - default-jdk

- 11/09/2017
  - python-pip
  - python3-pip

- 13/09/20017
  - libgsl-dev
  - mkdocs
  - libjs-mathjax
  - python-markdown

- 15/09/2017
  - screen

- 19/09/2017
  - docker

- 02/11/2017
  - net-tools

- 03/11/2017
  - curl
  - autoconf
  - autoconf-archive
  - autogen
  - automake
  - libmnl-dev

- 16/11/2017
  - fftw-dev
  - libfftw3-dev

- 08/12/2017
  - libopenmpi-dev
  - cmake

- 11/12/2017
  - libgconf-2-4

- 18/12/2017
  - ccache

- 02/02/2018
  - libcairo2-dev

- 05/04/2018
  - nginx
  
- 01/06/2018
  - libsecret-1-dev

- 24/06/2018
  - libwxgtk3.0-dev

### 7.6.1 mccoy only (rstudio server)

- gdebi-core
- libssl1.0.0_1.0.1
- nfs-kernel-server
- nfs-server

### 7.6.2 kirk, scotty, spock only

- nfs-common
