## Collection of scripts

#### ocpkg
* It is a script to install an OpenCog development environment on a fresh installation of Ubuntu >= 14.04 . It has options to selectively download, build, test, install and package OpenCog projects. Don't use the package option, as it
is still work in progress.

For a quick start using Ubuntu version >= 14.04, run
```
 wget http://raw.github.com/opencog/ocpkg/master/ocpkg -O octool && chmod +rx octool && ./octool -h
```
#### octool
Note: [busybox](https://en.wikipedia.org/wiki/BusyBox) works this way
Options are available with 'octool -h'.

#### ocbootstrap
(This hasn't been tested for a while)
A script to create an OpenCog build environment on ''any'' Linux system.

#### ocfeedbot
An IRC bot of some sort, purpose not clear.

Uses debootstrap. Requires ocpkg.

#### Usages
* To install all dependencies necessary to build OpenCog:
```
 ./octool -rdpcalv
```

* To install all dependencies necessary to build AtomSpace and MOSES:
```
 ./octool -rdcv
```

* To install all dependencies necessary to build Cogutils:
```
 ./octool -rdv
```
