---
title: Antergos/Arch Linux setup guide tailored towards data science, R and spatial analysis
author: Patrick Schratz
date: '2018-04-22'
lastmod: '2019-01-10'
slug: antergos-install-guide
categories:
  - Antergos
  - Arch Linux
  - Linux
  - R
  - r-bloggers
tags:
  - Antergos
  - Arch Linux
  - Linux
  - R
  - r-bloggers
summary: "This guide reflects my view on how to setup a working Arch Linux system tailored towards data science, R and spatial analysis. If you have suggestions for modifications, please open an issue at https://github.com/pat-s/antergos_setup_guide.
Enjoy the power of Linux!"
---

This guide does not claim to be complete.
It reflects my view on how to setup a working Arch Linux system tailored towards data science, R and spatial analysis.
If you have suggestions for modifications, please open an [issue](https://github.com/pat-s/antergos_setup_guide).
Enjoy the power of Linux!

<img src="../../img/antergos_setup_guide/antergos.jpeg" style="width: 30%;">

{{% toc %}}

I recommend using [Antergos](https://antergos.com).
It is an Arch Linux based distribution but most people refer to it as a graphical installer for Arch Linux.
It comes with the choice of 6 different desktop environments.
Choose a desktop that suites you.
The desktop environment is responsible for the look, feel and standard applications of your installation.
See [this comparison](https://fossbytes.com/best-linux-desktop-environments/) for some inspiration.  
But don't worry: You can seamlessly switch between the desktop at the login screen of Antergos.
This way you can try out all options and choose the one that suites you most (my favorites are KDE and GNOME).
What makes _Antergos_ a distribution rather than an "installer only" is the fact that it also comes with its own libraries maintained by the _Antergos_ developers.

First, create a bootable USB installer by following [this guide](https://antergos.com/wiki/uncategorized/create-a-working-live-usb/).
If you want to set up a dual boot, [this guide](https://antergos.com/wiki/de/install/how-to-dual-boot-antergos-windows-uefi-expanded-by-linuxhat) is a good resource.
Make sure to check out [the ArchWiki FAQs](https://wiki.archlinux.org/index.php/Frequently_asked_questions) and [Arch compared to other distributions - ArchWiki](https://wiki.archlinux.org/index.php/Arch_compared_to_other_distributions) to get a better understanding of Arch.

# 1. Installation

## 1.1 Install options

During installation you have several options to choose from.
Some are up to personal liking (e.g. Browser choice), others are important for a solid system:

- [x] SSH
- [x] NVIDIA drivers (if you have a NVIDIA graphics card)
- [x] AUR support
- [x] CUPS (printer support)
- [x] Bluetooth support

Whether you want to use the LTS Linux kernel or the most recent one is up to you.
I never faced any problems with the most recent one but the LTS one is theoretically the safer option.

## 1.2 Setting up the partitions

Several valid concepts exists on how to partition a Linux system.
The following reflects my current view:

1. Select "Manual" partitioning when being prompted
2. Create a partition of 1 GB. Mount point: `/boot/efi`. Format: `fat32`
3. Create a SWAP partition which is slightly larger than your RAM size. (e.g. for 16 GB RAM use 16.5 GB partition size). Format: `Linux Swap`
4. Create a 50 - 100 GB GB partition for "root". Mount point: `/`. Format: `ext4`
5. With the remainng space create "home". Mount point: `/home`. Format: `ext4`

# 2. Installing the package manager

(Sidenote: If you discover that your input source is missing (e.g. german keyboard layout), then run `sudo gedit /etc/locale` and remove the comment from your desired locale. Afterwards run `sudo locale-gen` and the locale is now selectable in "Region & Language". This happened to me in GNOME Desktop.)

When writing this post,  the best wrapper around `pacman`  is `trizen`.
Here is a list ([AUR helpers - ArchWiki](https://wiki.archlinux.org/index.php/AUR_helpers)) comparing alternatives (scroll to the bottom).

Install `trizen`:

```bash
git clone https://aur.archlinux.org/trizen-git.git
cd trizen-git
makepkg -si
```

(Whether to install the git version or the latest release is up to you). 

In `~/.config/trizen/trizen.conf` set "noedit" and "noconfirm" to "1".  You usually do not want to be prompted whether to edit source code or if you really want to install the package every time.
(Optional) Install [cyclon](https://github.com/gavinlyonsrepo/cylon) -> Wrapper around `trizen` and other tasks (system maintenance, etc.).

## 2.1 Choose your shell

All Linux system come with `bash` (Bourne-again shell) as default. While this shell is not bad, there are better alternatives. Most people do not use the shell so often, so you might think about if you wanna invest the time in configuring a different one. My current favorite is the `fish` shell and I can highly recommend it.

### 2.1.1   `zsh `

The `zsh` (Z-shell) is highly customizable but its settings are a bit complicated.
It has several advantages (file globbing, visual appearance, etc.) to `bash`.

A good `zsh` helper is `prezto`: [GitHub - sorin-ionescu/prezto: The configuration framework for Zsh](https://github.com/sorin-ionescu/prezto)).
First, install the "Z-shell": `trizen zsh` and use it: `zsh`.
In `zsh`, execute the following:

```bash
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

chsh -s /bin/zsh
```

Logout/login.
My favorite theme is "agnoster".
Set `theme: agnoster` in line 116 of `~/.zpreztorc`.
Afterwards set up some custom wrapper functions (`aliases`) around `trizen` to simplify  its usage:

In `~/.zshrc`, append the following line. This ensures that the custom functions are available in each new session.

```bash
source "${ZDOTDIR:-$HOME}/.zprezto/pac.zsh"
```

Next, create the following file `.zprezto/pac.zsh`.  
KDE: `kate .zprezto/pac.zsh`  
GNOME: `gedit .zprezto/pac.zsh`  

```zsh
pac () {
  case $* in
    install* ) shift 1; cd ~ && trizen -S "$@";;
    get* ) shift 1; cd ~ && trizen -G --aur "$@" ;;
    remove* ) shift 1; cd ~ && trizen -R --aur "$@" ;;
    search* ) shift 1; cd ~ && trizen -s "$@";;
    update-git* ) shift 1; cd ~ && trizen -Syu --devel --show-ood;;
    update* ) shift 1; cd ~ && trizen -Syu --needed --show-ood;;
    * ) echo "Invalid choice, see ~/.zpreto/pac.zsh for available commands." ;;
  esac
}
```

Open a new terminal window and the function `pac` should be available now.
You can now call `pac` with all arguments listed above (`install`, `search`, etc.).
Check [GitHub - trizen/trizen: Lightweight AUR Package Manager](https://github.com/trizen/trizen#usage) for an explanation of the created aliases.

- `pac install <pkg>`: Install the specified package (if it exists).
- `pac search <pkg>`: Executes a search with the specified `<pkg>` returning all matches. You can then type a number of the package you want to install. Package will be moved to `~/pkgs`.
- `pac update`: Update all installed packages (from both Arch repos and AUR). Shows packages which are marked as "out-of-date" by the community.
- `pac update-git`: Updates all packages installed from `git`.

**Note:** Git packages are always build from source and certain packages may take some time to install. Don't call that command on a daily base. On the other hand, git packages will never update automatically as they are just a snapshot build of the (at the time of installation) most recent state of the respective repository.
So think twice if you need a git package as it is in your responsibility to update it.

### 2.1.2 `fish`

The `fish` shell is similar to `zsh` but comes with better defaults and an easier syntax. The `omf` package manager is great for installing additional plugins that simplify the shell usage. Check [Oh-my-fish](https://github.com/oh-my-fish/oh-my-fish) for an introduction. 

The shell is available in the standard repos and can be installed with `trizen fish`.

A great way to get started is to call `fish_config` in a fish session to configure `fish` to your needs in a graphical browser window.

My current theme is [bobthefish](https://github.com/oh-my-fish/theme-bobthefish).



## 2.2 Enabling parallel compiling

Compiling packages from source can take time.
To speed up the process by enabling parallel compiling, set the `MAKEVARS` variable in `/etc/makepkg.conf`: `MAKEFLAGS="-j$(nproc)"`.
This will use all available cores on your machine for compiling.

(Lately this options seems to be enabled by default. However, it is still good to verify this.)

# 3. System related

## 3.1 Installing system libraries

A note before the installation process: If you only have 8 GB of RAM, you need to temporary increase the size of your `/tmp` folder.
Otherwise the `tmp` folder will run out of space due to all the package downloads and installations and you will face weird error messages.
Do so by calling `sudo mount -o remount,size=20G,noatime /tmp`.
This increases the size for your current session to 20 GB.
Usually the size is about half or your RAM size. The size will be resetted when you restart your machine next time.

For the following installation calls, you can either use `trizen` or your personally defined wrappers.
When calling `trizen <package>`,  first a search in the official repos and the AUR is done. The complementary `zsh` wrapper function for this would be `pac search <package>`.
(Calling `pac install` will directly install the given package.)

**My advice: Try to avoid installing python libraries via `pip`!  If you install libraries via `pacman` that have python dependencies, it will try to install the respective `python-<package>`. If you installed this package via `pip` before, you will face conflicts. First search if the package is available in the repos and if not, you can safely install it via `pip`.**

Python Modules for *QGIS* : *QGIS*  needs some external python libraries for its plugins. Otherwise it will throw errors during startup.

```bash
trizen -S python-gdal python-yaml python-jinja python-psycopg2 python-owslib python-numpy python-pygments
```

Other important system libraries for spatial applications:

`trizen -S gdal udunits postgis jdk10-openjdk openjdk10-src texlive-most pandoc-bin pandoc-citeproc-bin`

- `texlive-most` (this is a wrapper installation that installs the most important tex libraries. Similar to `texlive-full` on other Linux distributions.)
- `pandoc-bin pandoc-citeproc-bin` (for all kind of Rmarkdown stuff. Make sure to install this library as the one in the community repository comes with 1 GB Haskell dependencies!)

## 3.2 Apps

Here is a list of applications I use. Choose for yourself which could be helpful for your.

Messaging: [franz](https://meetfranz.com)  
Mail: [mailspring](https://github.com/Foundry376/Mailspring)
Notes: 

- I use [Notion](https://www.notion.so/) which atm has not Linux Desktop app and can be used in the browser only.  
- [notable](https://github.com/fabiospampinato/notable)
- [Boostnote](https://github.com/BoostIO/Boostnote)

Reference Manager: [zotero](https://www.zotero.org)
Google Drive:  I use the paid service [insync](https://www.insynchq.com).  
Dropbox: `trizen nautilus-dropbox`  
GIS: [qgis](https://www.qgis.org/de/site/)
Screenshot tool: [shutter](http://shutter-project.org) 
Image viewer: [xnviewmp](https://www.xnview.com/de/xnviewmp/)
Virtualbox: [VirtualBox – wiki.archlinux.de](https://wiki.archlinux.de/title/VirtualBox)  
Terminal: [tilix](https://gnunn1.github.io/tilix-web/)
Browser: [vivaldi](https://vivaldi.com)
[KDE only] Dock: [latte-dock](https://store.kde.org/p/1169519/) If you prefer a dock layout over the default layout)  
Twitter client: [corebird](https://corebird.baedert.org)

Writing: [Typora](https://typora.io)

A note on _Mailspring_: If you are on battery, quit the app as it consume a lot of energy while steadily trying to sync your mails.

## 3.3 Editors

Editors are an important topic so I devote an extra section to them.
You can use editors to only edit text files but they can also be used as an IDE for coding.
There are many editors out there, all loved by a certain group of people.

Here's a list of the most popular ones (this list does not claim to be complete). Also some of the listed apps are actually IDEs while some are only text editors.

- Vim
- Emacs
- Sublime Text (very fast)
- Visual Studio Code (my default for all non-R work)
- Atom
- Kate (KDE default)
- Gedit (GNOME defaul)
- Nano
- etc.

## 3.4 Office

`trizen libreoffice-fresh`

If you are on a KDE Desktop, _LibreOffice_ may flicker black/white.
This is caused by _OpenGl_.

To solve it, set the `value` item in following two lines of `~/.config/libreoffice/4/user/registrymodifications.xcu` to `false`:

```html
<item oor:path="/org.openoffice.Office.Common/VCL"><prop oor:name="ForceOpenGL" oor:op="fuse"><value>false</value></prop></item>
<item oor:path="/org.openoffice.Office.Common/VCL"><prop oor:name="UseOpenGL" oor:op="fuse"><value>false</value></prop></item>
```

Additionally, I recommend to install the [Papirus Icon theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) for Libreoffice: `trizen -s papirus-libreoffice-theme`.

# 4. R

## 4.1 General

### ccache

This library caches all C compiled code, making reoccuring package installations that use C code a lot faster.

Put the following into `~/.R/Makevars` (create it if missing):

```r
VER=
CCACHE=ccache
CC=$(CCACHE) gcc$(VER)
CXX=$(CCACHE) g++$(VER)
C11=$(CCACHE) g++$(VER)
C14=$(CCACHE) g++$(VER)
FC=$(CCACHE) gfortran$(VER)
F77=$(CCACHE) gfortran$(VER)
```

Additionally, install `ccache` on your system: `trizen ccache`.
See [this blog post](http://dirk.eddelbuettel.com/blog/2017/11/27/#011_faster_package_installation_one) by Dirk Eddelbuettel as a reference.

To use R from the shell without a prior defined mirror, you need the system libraries `tcl` and `tk` to launch the mirror selection popup (`trizen -S tcl tk`).

## 4.2 R & RStudio

### R with optimized Openblas / LAPACK

Next, install either the "Intel MKL" or `libopenblas` to be used in favor of the standard "libRlapack/libRblas" libraries that are shipped with the default R installation.
These libraries are responsible for numerical computations and have [impressive speedups](http://pacha.hk/2017-12-02_why_is_r_slow.html) compared to the default libraries.
Thanks [@marcosci](https://github.com/marcosci) for the hint.
While the "Intel MKL" library is the fasted according to the benchmarks, its also much more complicated to install.

`libopenblas` will automatically be used if its installed since the default `R` installation [on Arch](https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/r) is configured with the `--with-blas` option (see section A.3.1 in [https://cran.r-project.org/doc/manuals/r-release/R-admin.html#Installation](https://cran.r-project.org/doc/manuals/r-release/R-admin.html#Installation)).
I recommend installing the AUR package `openblas-lapack` as its package cominbing multiple libraries: `trizen -s openblas-lapack`.

To verify your installation in `R`, simply run `sessionInfo()` and check the printed information:

```R
sessionInfo()

R version 3.4.4 (2018-03-15)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Arch Linux

Matrix products: default
BLAS/LAPACK: /usr/lib/libopenblas_haswellp-r0.2.20.so
```

If you want to try out the "Intel-MKL" library, follow these instructions:

There is an AUR package that provides `R` compiled with `intel-mkl` named `r-mkl`.
**Note:** The download size of `intel-mkl` is around 4 GB and takes a lot of memory during installation.
Most of it will stored in the swap (around 10 GB) so make sure your SWAP space is > 10 GB.

Also to successfully install `intel-mkl`, you need to temporarly increase the `/tmp` directory as `intel-mkl` requires quite some space: `sudo mount -o remount,size=30G,noatime /tmp`.

### RStudio

Use `trizen -s rstudio` and pick your favorite release channel.
During installation R will get installed as a dependency (if you have not already done so).

## 4.3 Packages

Open RStudio and install the R package `usethis` (it will install quite a few dependencies, get a coffee) and then call `usethis::browse_github_pat()`.
Follow the instructions to set up a valid `GITHUB_PAT` environment variable that will be used for installing packages from Github.

### 4.3.1 Task view "Spatial"

Of course you it is not required to install all packages of a task view.
You will never use all packages of a task view.
In my opinion, however, it is pretty neat to have one command that installs (almost) all packages I use of a certain field.
I do not care about the additional packages installed.

Required system libraries:

- jq
- fortran
- v8-3.14 (Some R packages (`geojsonlite`, etc.) require the `V8` [package](https://github.com/jeroen/V8) which depends on the outdated `v8-314` library)
- tk
- nlopt
- gsl

`trizen -S jq gcc-fortran tk nlopt gsl`

`trizen -s nlopt`

`trizen -s v8-3.14`

For `rJava` we need to do `sudo R CMD javareconf`.

Now you can install the `ctv` package and then call `ctv::install.views("Spatial")`.
This will install all packages listed in the [spatial](https://cran.r-project.org/web/views/Spatial.html) task view.

Packages that error during installation (Please report back if you have a working solution):

- ProbitSpatial
- spaMM
- RPyGeo (Windows only)

### 4.3.2 Task view "Machine Learning"

Required system libraries:

- nlopt

Packages that error during installation (Please report back if you have a working solution):

- interval (requires Icens from Bioconductor)
 LTRCtrees (requires Icens from Bioconductor)

## 4.4 Git* repos

The easiest way (in my opinion) is to use _SSH_ and `usethis::create_from_github()`.

### 4.4.1 SSH configuration

If you have never set a “ssh keygen pair” at your local machine, please do so by calling `ssh-keygen -t rsa`.

If you already have a file named `id_rsa.pub` in your `~/.ssh` folder at your local machine, skip this step! Otherwise it will override your existing one and may invalidate previous ssh connections you set up.
You now have an `id_rsa.pub` file in a (hidden!) folder named `.ssh` within `/home` (at your local machine).
You can enable viewing hidden files/folders in the file-manager with the shortcut `ALT + .` (KDE) or `CTRL + h` (GNOME).

Next, make sure that the permissions of the ssh files [are correct](https://superuser.com/questions/215504/permissions-on-private-key-in-ssh-folder/925859): 

1. The local directory in which you want to store your Github repos should have 777 permissions. This usually is not the case if you create the directory.  If the permissions are wrong, `usethis::create_from_github()` will not be able to write files there.  `sudo chmod 777 ~/git`.
2. Make sure your ssh keys have the right permissions: `sudo chmod 600 ~/.ssh/id_rsa`, `sudo chmod 644 ~/.id_rsa.pub`
3. Add your ssh-key to the keychain: `ssh-add -K ~/.ssh/id_rsa`
4. For me, the `sshaskpass` does not work on KDE even though everything seems to be set up correctly. That's why I always have to hand over the information manually when using `create_from_github()`. To simplify this process, I have the following information in my `~/.Rprofile`:

`cred <- git2r::cred_ssh_key(publickey = "~/.ssh/id_rsa.pub", privatekey = "~/.ssh/id_rsa")`

This object is then passed to the `credentials` argument in `create_from_github()`.

Now clone all your repos from Github, e.g. `create_from_github(repo = "pat-s/oddsratio", destdir = "~/git", credentials = cred)`.
Alternatively, you can also check if `git2r::check_ssh_key()` returns the correct credentials.
If it returns

```r
git2r::cred_ssh_key()
$publickey
[1] "/home/pjs/.ssh/id_rsa.pub"

$privatekey
[1] "/home/pjs/.ssh/id_rsa"

$passphrase
character(0)

attr(,"class")
[1] "cred_ssh_key"
```

you can also use `create_from_github(repo = "pat-s/oddsratio", destdir = "~/git", credentials = git2r::cred_ssh_key())`.

The little overhead is really worth it: You have a working `ssh` setup and by reusing the command and just replacing the repo name the cloning off all your repos is done within minutes!

## 4.5 R from the command line

While most people use R from within _RStudio_, it is important to have a proper command line setup. I often call R in a second session (besides _RStudio_) to update packages, run `R CMD check` on a package, etc. The native R command line that you get when typing `R` in your shell lacks a lot of features. Fortunately, there is [radian](https://github.com/randy3k/radian). Its advantages are listed in the README of the repo.

I've set an alias that maps `r` to `radian`. So whenever I type `r` into the console and hit enter, I get a "21st century ready" R console.

Although I recommended to not use `pip` to install python packages, here you have to use it, because there is no AUR package for `radian`. Run `pip install --user radian`  and add `~/.local/bin` to your PATH to have it available in every console session. 

## 4.6 Rprofile

The `~/.Rprofile` holds several options that will be applied during R startup. However, specifying all custom functions, options and other calls in one R file can get messy. Fortunately, there is the [startup](https://github.com/HenrikBengtsson/startup) package. You can put several .R files into the `~/.Rprofile.d` directory. This way you can organize your custom R startup better. Also, by running `startup::startup(debug = TRUE)` you can actually see what happens if you start R. 

You can find my settings [in my Dropbox](https://www.dropbox.com/home/Mackup).

# 5. Accessing remote servers

## 5.1 File access (file manager)

### 5.1.1 `fstab`

There are multiple approaches how to achieve this ([Auto-mount network shares (cifs, sshfs, nfs) on-demand using autofs | Patrick Schratz](https://pat-s.github.io/post/autofs/), [fstab - ArchWiki](https://wiki.archlinux.org/index.php/fstab)).

Here  is an example of a `fstab` setup for a `sshfs` (to Linux server) and `cifs` (to Windows server) mount.
Append those lines to `/etc/fstab`; don't overwrite the existing content as this will result in boot errors otherwise!

```bash
# sshfs
sshfs#<username>@<ip>:<remote mount point> <local mount point> fuse        reconnect,idmap=user,transform_symlinks,identityFile=~/.ssh/id_rsa,allow_other,cache=yes,kernel_cache,compression=no,default_permissions,uid=1000,gid=100,umask=0,_netdev,x-systemd.after=network-online.target   0 0

# cifs
//<ip>/<remote mount point> <local mount point> cifs        credentials=/etc/.smbcredentials.txt,uid=1000,file_mode=0775,dir_mode=0775,gid=100,sec=ntlm,vers=1.0,dom=ads.uni-jena.de,forcegid,_netdev,x-systemd.after=network-online.target 0 0
```

**Notes:**

- (cifs) Depending how new the Windows server is, you do not need `vers=1.0`.
- (cifs) Store your login credentials for the windows server in a file, e.g. `/etc/.smbcredentials.txt` with contents being `username = <username>` and `password = <password>`.
- (sshfs) Copy `.ssh/id_rsa` to `root/.ssh/` as the mount will be executed by the root user.
- (cifs) Install the Arch Linux kernel headers for the `cifs` package to work (and later on for Virtualbox): `trizen linux-headers`

Reboot.

Both advantage and disadvantage of using `fstab` are that it tries to mount the directories during boot. However, often this fails. Either because of a missing network connection at this point or because you need a VPN to access a server remotely.

### 5.1.2 Manual mount

You can also put this information in a different file and do a manual mount when everything is ready (i.e. your machine is booted, your VPN connected). The syntax looks a bit different then:

```bash
sudo sshfs -o reconnect,idmap=user,transform_symlinks,identityFile=~/.ssh/id_rsa,allow_other,cache=yes,kernel_cache,compression=no,default_permissions,uid=1000,gid=100,umask=0 <username>@<server ip>:/ <local mount point>

sudo mount -t cifs -o credentials=<location of credentials file>,uid=1000,file_mode=0775,dir_mode=0775,gid=100,sec=ntlm,vers=1.0,dom=<domain name>,forcegid //<server ip>/<shared folder>     <local mount point>
```

I won't go into details of all options I used here. Check out the manual pages of the respective protocols if you are facing errors.

### 5.1.3 Executing the mount

If you use `fstab`, you can mount all mounts with `sudo mount -a`.

The manual approach needs to be saved in a `bash` script and called from your shell with `bash <filename>.sh`. 

To avoid conflicts when remounting (after a network disconnect or similar),  my wrapper script looks as follows:

```bash
#! /bin/bash

sudo pkill -kill -f "sshfs"
sudo umount -f /mnt/<name>
sudo umount -l /mnt//<name>
sudo umount -a -t cifs -l
sudo bash `<name of mount file`.sh
```

Some operations in this file may be redundant or ineffective. 

So in summary, I call my wrapper script which does the following:

1. Unmount all mounts 
2. Mount all mounts specified in `<name of mount file>.sh`.

## 5.2 Command-line access (Terminal)

### 5.2.1 SSH setup

SSH again.
Again we use `ssh`, this time to log into remote servers rather than downloading Github repos.

If you have never set a “ssh keygen pair” at your local machine, please do so by calling `ssh-keygen -t rsa`.

If you already have a file named `id_rsa.pub` in your `~/.ssh` folder at your local machine, skip this step! Otherwise it will override your existing one and may invalidate previous ssh connections you set up.
You now have an `id_rsa.pub` file in a (hidden!) folder named `.ssh` within /home (at your local machine).
Now you need to copy this file (`id_rsa.pub`) to the server so that you can be identified:

```sh
ssh username@<server ip> 'test -d ~/.ssh && mkdir ~/.ssh' # creates the .ssh directory if it does not exist
cat .ssh/id_rsa.pub | ssh username@<server> 'cat >> .ssh/authorized_keys' # copies your local public key to the server
```

Every time you log in via command line now, you will not be prompted for your password.

You can further simplify the login process.
Instead of having to type `ssh <user>@<server>` you can store all of this information in your `~/.ssh/config` file:

```sh
Host <name-you-wanna-use>
    user <username>
    Hostname <server>
    IdentityFile /path/to/.ssh/id_rsa
```

You can easily connect to all servers you have access to with a little one-time effort.

### 5.2.2 Creating profiles in your terminal app

Terminal applications are capable of storing "Profiles" that save the configuration to connect to a specific server.
In this example I refer to the application `tilix`.

1. Create a profile for each server
2. Under `<profile name> -> Command -> [x] Run a custom command instead of my shell` put your `ssh` command in, e.g. `ssh <username>@<servername>`.
3. Open all profiles in tabs: Select the desired profile and click "New session" (the left one of the three buttons at the top).
4. Save each open profile with `save as` in a folder of your liking.
5. Create a wrapper script that loads exactly this configuration:

<img src="../../img/antergos_setup_guide/tilix1.png" style="width: 30%;">
<img src="../../img/antergos_setup_guide/tilix2.png" style="width: 30%;">

```bash
#!/bin/bash

TILIX_SESSIONS_FOLDER=<path to folder with all saved configuration files>

TILIX_OPTS=""

for session in $TILIX_SESSIONS_FOLDER/*; do
  TILIX_OPTS="$TILIX_OPTS -s $session"
done

tilix $TILIX_OPTS
```

For convenience, set the execution of this script as an alias:

```bash
alias servers='bash ~/tilix_all.sh'
```

Now all you need to do is typing `servers` to load a terminal configuration with all your server connections.

Caution: Always have the "standard" profile set to load a normal session on your local machine.

# 6. Desktop related

## 6.1 KDE

KDE is probably the DE (Desktop environment) that is most customizable. By default it comes with a Windows-like navigation panel. However, you can have a dock by using [latte-dock](https://github.com/psifidotos/Latte-Dock). I used KDE for quite some time and they did really good work recently. 

**Networkmanager**

If you want to use an automatic login to a VPN and the networkmanager-daemon (e.g. Openconnect) does not store your password, try the `network-manager-applet` package.
It is the GNOME network-manager and has (for whatever reason) no problems with storing the password.

## 6.2 GNOME

GNOME looks more like macOS. Clean, fresh, smooth. However, it needs a bit more love in my opinion to get a proper working setup. You need to find which [gnome-extensions](https://extensions.gnome.org) you need for your work. Most of them are present in the AUR. 

I currently have the following ones installed:

```bash
trizen -Q | grep "gnome-shell"                                                                                                                   
gnome-shell 1:3.30.2-1
gnome-shell-extension-appindicator-git 1:21+15+g7bd97d4-1
gnome-shell-extension-arch-update 28-1
gnome-shell-extension-cpufreq-git v30.0.r0.g17e0861-1
gnome-shell-extension-dash-to-dock 1:64-1
gnome-shell-extension-freon-git 35.r16.g2cf167a-1
gnome-shell-extension-gravatar 4-1
gnome-shell-extension-multi-monitors-add-on-git 20171018-1
gnome-shell-extension-status-menu-buttons 0.3-2
gnome-shell-extension-system-monitor-git 884.21ae32a-1
gnome-shell-extension-taskbar 57.0-1
gnome-shell-extension-topicons 1:20-1
gnome-shell-extension-topicons-plus-git 21+23+g1766933-1
gnome-shell-extension-weather-git 1:r589.ea2d56a-1
gnome-shell-extensions 3.30.1-1
```

You can control the settings via the "Tweak tool" that comes with GNOME by default.

Note that GNOME comes with [Wayland](https://wayland.freedesktop.org) as the desktop compositor library while KDE still uses [X](https://www.x.org/wiki/). I am not an expert in both but the future is said to be Wayland. You might run into some troubles with driver support for Wayland and there is much better documentation and help for X. You can also run GNOME with X if you are facing too many issues. 

# 7. Laptop battery life optimization

Although the Linux kernel has a lot of power saving options, they are not all enabled by default.

There are two main power optimization tools:

- Powertop
- TLP

I prefer `tlp` as `powertop` often causes trouble with USB devices going into sleep mode.
Also, applying the changes on boot is easier with `tlp`.

Do `pac install tlp` and then follow the instructions on [TLP - ArchWiki](https://wiki.archlinux.org/index.php/TLP) to configure it correctly.
`powertop` though is useful to check the applied settings. Do `sudo powertop` and go to the "tunables" section and check if most settings are "GOOD" (most are "BAD" before applying `tlp`).

# 8. Miscellaneous

## 8.1 Backup your config files and settings

A system can crash every second. It is not only important to backup your data and scripts. You also want to backup all configurations of your apps so that you can restore them easily with a click. This is also important and useful if you want to sync all your configurations across multiple machines.

[mackup](https://github.com/lra/mackup) is a great tool for this. It syncs a variety of config files and uploads these to the cloud. 

On a new machine, you only need to run `mackup restore` to have all your settings back. Unfortunately it does not work with Windows but if you are reading this guide, you are most likely not on Windows anymore ;-). 

## 8.1 arara

[GitHub - cereda/arara: arara is a TeX automation tool based on rules and directives.](https://github.com/cereda/arara)
An automatization tool for TeX: `pac install arara-git`.
However, lately I use the `latex-workshop` extention in Visual Studio Code for all my LaTex stuff.

## 8.2 latexindent.pl: Required perl modules

`latexindent` is a library which automatically indents your LaTeX document during compilation: [GitHub - cmhughes/latexindent.pl](https://github.com/cmhughes/latexindent.pl)

`trizen -S perl-log-dispatch perl-dbix-log4perl perl-file-homedir perl-unicode-linebreak`.

It's also integrad in the `latex-workshop` extention in Visual Studio Code.

## 8.3 Editor schemes

I use the [Dracula](https://draculatheme.com) scheme in almost all applications.
While its comes integrated into RStudio, here are installation instructions for [Kate](https://draculatheme.com/kate/) and [Tilix](https://github.com/krzysztofzuraw/dracula-tilix).
Alternatively I like the [tomorrow-night-eighties](https://github.com/chriskempson/tomorrow-theme) theme lately.

## 8.4 Fonts

I enjoy using [Fira Code](https://github.com/tonsky/FiraCode).
I use it as a coding font in all editors (monospace ftw) but also as a system wide font (the "medium" variant) with size 10.
Another great monospace coding font is [Iosevka](https://github.com/be5invis/Iosevka).  

## 8.5 Icon themes

There are two awesome icon themes: [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) and [numix](http://numixproject.org).

Try them and choose for yourself.
You will see what a tremendous impact good icons can have on your daily work.

## 8.6 Desktop Themes

### 8.6.1 KDE

My overall desktop theme favorite is "Adapta".
Set it via "System Settings -> Workspace theme -> Desktop Theme".
For "Look and Feel" I prefer "Arc Dark".

To install these, simply click on "Get new looks" on the bottom right when you are in "System Settings -> Workspace theme".

### 8.6.2 GNOME

* [Flat Remix GTK theme](https://www.gnome-look.org/p/1214931/): Darkest-solid

KDE apps in GNOME (and the other way round) usually have an odd appearance because they are powered by different graphical libraries. To make KDE apps look acceptable in GNOME, do the following:

1. Install `qt5ct` 
2. Set the environment variable `QT_QPA_PLATFORMTHEME` to  `"qt5ct"` (add `set -gx QT_QPA_PLATFORMTHEME "qt5ct"` in `.config/fish/config.fish`).
3. Run `qt5ct` and change the settings to your liking. Note: The default GNOME font is "Cantarell Regular 11pt". To select the default KDE "Adwaita" theme, you need to install it first: `trizen -s adwaita-qt5`.

Now you can enjoy KDE apps such as `Dolphin` or `Okular`. However, you have to start them from the command line. A convenient workaround is to autostart them at boot. Create a file called `.config/autostart/dolphin.desktop` with the following content:

```bash
[Desktop Entry]
Name=dolphin
Comment=Run dolphin
Exec=dolphin
Terminal=false
Type=Application⏎
```

## 8.7 Presentations

To create presentations I use the R package [xaringan](https://github.com/yihui/xaringan).
Usually I convert the resulting HTML slides to PDF using [decktape](https://github.com/astefanutti/decktape) (install with `trizen -s nodejs-decktape`) and present the talk using [impressive](http://impressive.sourceforge.net) (install with `trizen -s impressive`).

## 8.8 Touchpad drivers

Some devices need to install the "synaptic touchpad drivers" to enable the a "soft-click" window activation.
`trizen -s xf86-input-synaptics`.

## 8.9 Other helpful tools

