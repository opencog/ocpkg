## Collection of scripts

#### ocpkg
* This script installs an OpenCog development environment on a fresh
  installation of Ubuntu >= 14.04 . It has options to selectively
  download, build, test, install OpenCog projects.

For a quick start using Ubuntu version >= 14.04, run
```
sudo curl -L http://raw.github.com/opencog/ocpkg/master/ocpkg -o /usr/local/bin/octool &&\
sudo chmod +x /usr/local/bin/octool &&\
octool
```

For details, see the
[instructions on the OpenCog wiki](http://wiki.opencog.org/wikihome/index.php/Building_OpenCog#octool_for_ubuntu).

#### octool-wip
Work-in-progress (abandoned).
The separate octool script is not yet ready. Use the above.

#### ocbootstrap
(This hasn't been tested for a while)
A script to create an OpenCog build environment on ''any'' Linux system.

#### ocfeedbot
An IRC bot of some sort, purpose not clear.

Uses debootstrap. Requires ocpkg.

#### octool_rpi
For installing opencog on a Raspberry Pi Computer running Raspbian.
The readme [here](https://github.com/opencog/opencog_rpi/blob/master/README.md) will be helpful.

May be out of date.

#### Example Usage
* To install all dependencies necessary to build OpenCog:
```
 ./octool -rdpcav -l default
 # Optional: Add -s for installing dependencies for haskell binding.
 # Optional: Add -n for installing dependencies and kernels for jupyter notebooks.
```

* To install all dependencies necessary to build AtomSpace and AS-MOSES:
```
 ./octool -rdcv
```

* To install all dependencies necessary to build Cogutil:
```
 ./octool -rdv
```
