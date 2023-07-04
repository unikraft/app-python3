# Python3 on Unikraft

This application starts a Python3 web application with Unikraft.
Follow the instructions below to set up, configure, build and run Python3.

### Quick Setup (aka TLDR)

For a quick setup, run the commands below.
Note that you still need to install the [requirements](#requirements).

For building and running everything for `x86_64`, follow the steps below:

```console
git clone https://github.com/unikraft/app-python3 python3
cd python3/
mkdir fs0/
tar -C fs0/ -xvf rootfs.tar.gz
mkdir .unikraft
git clone https://github.com/unikraft/unikraft .unikraft/unikraft
git clone https://github.com/unikraft/lib-python3 .unikraft/libs/python3
git clone https://github.com/unikraft/lib-musl .unikraft/libs/musl
git clone https://github.com/unikraft/lib-lwip .unikraft/libs/lwip
git clone https://github.com/unikraft/lib-libuuid .unikraft/libs/libuuid
UK_DEFCONFIG=$(pwd)/.config.python3_qemu-x86_64 make defconfig
make -j $(nproc)
sudo /usr/bin/qemu-system-x86_64 \
    -fsdev local,id=myid,path="$(pwd)/fs0",security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
    -kernel build/python3_qemu-x86_64 -nographic
```

This will configure, build and run the `Python3` application, resulting in a Python3 console being started.

The same can be done for `AArch64`, by running the commands below:

```console
make properclean
UK_DEFCONFIG=$(pwd)/.config.python3_qemu-arm64 make defconfig
make -j $(nproc)
sudo /usr/bin/qemu-system-aarch64 \
    -fsdev local,id=myid,path="$(pwd)/fs0",security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
    -kernel build/python3_qemu-arm64 -nographic \
    -machine virt -cpu cortex-a57
```

Information about every step is detailed below.

## Requirements

In order to set up, configure, build and run Python3 on Unikraft, the following packages are required:

* `build-essential` / `base-devel` / `@development-tools` (the meta-package that includes `make`, `gcc` and other development-related packages)
* `sudo`
* `flex`
* `bison`
* `git`
* `wget`
* `uuid-runtime`
* `qemu-system-x86`
* `qemu-system-arm`
* `qemu-kvm`
* `sgabios`
* `gcc-aarch64-linux-gnu`

GCC >= 8 is required to build Python3 on Unikraft.

On Ubuntu/Debian or other `apt`-based distributions, run the following command to install the requirements:

```console
sudo apt install -y --no-install-recommends \
  build-essential \
  sudo \
  gcc-aarch64-linux-gnu \
  libncurses-dev \
  libyaml-dev \
  flex \
  bison \
  git \
  wget \
  uuid-runtime \
  qemu-kvm \
  qemu-system-x86 \
  qemu-system-arm \
  sgabios
```

## Set Up

The following repositories are required for Python3:

* The application repository (this repository): [`app-python3`](https://github.com/unikraft/app-python3)
* The Unikraft core repository: [`unikraft`](https://github.com/unikraft/unikraft)
* Library repositories:
  * The Python3 "library" repository: [`lib-python3`](https://github.com/unikraft/lib-python3)
  * The standard C library: [`lib-musl`](https://github.com/unikraft/lib-musl)
  * The networking stack library: [`lib-lwip`](https://github.com/unikraft/lib-lwip)
  * The uuid library: [`lib-libuuid`](https://github.com/unikraft/lib-libuuid)

Follow the steps below for the setup:

  1. First clone the [`app-python3` repository](https://github.com/unikraft/app-python3) in the `python3/` directory:

     ```console
     git clone https://github.com/unikraft/app-python3 python3
     ```

     Enter the `python3/` directory:

     ```console
     cd python3/

     ls -F
     ```

     This will show you the contents of the repository:

     ```text
     build  .config.python3_qemu-arm64  .config.python3_qemu-x86_64  kraft.yaml  Makefile  Makefile.uk  rootfs.tar.gz  README.md
     ```

  1. While inside the `python3/` directory, create the `fs0/` directory and extract the contents of `rootfs.tar.gz`:

     ```console
     rm -rf fs0/
     mkdir fs0/
     tar -C fs0/ -xvf rootfs.tar.gz
     ```

  1. While inside the `python3/` directory, create the `.unikraft/` directory:

     ```console
     mkdir .unikraft
     ```

     Enter the `.unikraft/` directory:

     ```console
     cd .unikraft/
     ```

  1. While inside the `.unikraft` directory, clone the [`unikraft` repository](https://github.com/unikraft/unikraft):

     ```console
     git clone https://github.com/unikraft/unikraft unikraft
     ```

  1. While inside the `.unikraft/` directory, create the `libs/` directory:

     ```console
     mkdir libs
     ```

  1. While inside the `.unikraft/` directory, clone the library repositories in the `libs/` directory:

     ```console
     git clone https://github.com/unikraft/lib-python3 libs/python3

     git clone https://github.com/unikraft/lib-musl libs/musl

     git clone https://github.com/unikraft/lib-lwip libs/lwip

     git clone https://github.com/unikraft/lib-libuuid libs/libuuid
     ```

  1. Get back to the application directory:

     ```console
     cd ../
     ```

     Use the `tree` command to inspect the contents of the `.unikraft/` directory.
     It should print something like this:

     ```console
     tree -F -L 2 .unikraft/
     ```

     The layout of the `.unikraft/` directory should look something like this:

     ```text
     .unikraft/
     |-- libs/
     |   |-- lwip/
     |   |-- musl/
     |   |-- libuuid/
     |   `-- python3/
     `-- unikraft/
         |-- arch/
         |-- Config.uk
         |-- CONTRIBUTING.md
         |-- COPYING.md
         |-- include/
         |-- lib/
         |-- Makefile
         |-- Makefile.uk
         |-- plat/
         |-- README.md
         |-- support/
         `-- version.mk

     10 directories, 7 files
     ```

## Configure

Configuring, building and running a Unikraft application depends on our choice of platform and architecture.
Currently, supported platforms are QEMU (KVM), Xen and linuxu.
QEMU (KVM) is known to be working, so we focus on that.

Supported architectures are x86_64 and AArch64.

Use the corresponding the configuration files (`config-...`), according to your choice of platform and architecture.

### QEMU x86_64

Use the `.config.python3_qemu-x86_64` configuration file together with `make defconfig` to create the configuration file:

```console
UK_DEFCONFIG=$(pwd)/.config.python3_qemu-x86_64 make defconfig
```

This results in the creation of the `.config` file:

```console
ls .config
.config
```

The `.config` file will be used in the build step.

### QEMU AArch64

Use the `.config.python3_qemu-arm64` configuration file together with `make defconfig` to create the configuration file:

```console
UK_DEFCONFIG=$(pwd)/.config.python3_qemu-arm64 make defconfig
```

Similar to the x86_64 configuration, this results in the creation of the `.config` file that will be used in the build step.

## Build

Building uses as input the `.config` file from above, and results in a unikernel image as output.
The unikernel output image, together with intermediary build files, are stored in the `build/` directory.

### Clean Up

Before starting a build on a different platform or architecture, you must clean up the build output.
This may also be required in case of a new configuration.

Cleaning up is done with 3 possible commands:

* `make clean`: cleans all actual build output files (binary files, including the unikernel image)
* `make properclean`: removes the entire `build/` directory
* `make distclean`: removes the entire `build/` directory **and** the `.config` file

Typically, you would use `make properclean` to remove all build artifacts, but keep the configuration file.

### QEMU x86_64

Building for QEMU x86_64 assumes you did the QEMU x86_64 configuration step above.
Build the Unikraft Python3 image for QEMU AArch64 by using the command below:

```console
make -j $(nproc)
```

You can see a list of all the files processed by the build system:

```text
[...]
  LD      python3_qemu-x86_64.dbg
  UKBI    python3_qemu-x86_64.dbg.bootinfo
  SCSTRIP python3_qemu-x86_64
  GZ      python3_qemu-x86_64.gz
make[1]: Leaving directory '/media/stefan/projects/unikraft/scripts/workdir/apps/app-python3/.unikraft/unikraft'
```

At the end of the build command, the `python3_qemu-x86_64` unikernel image is generated.
This image is to be used in the run step.

### QEMU AArch64

If you had configured and build a unikernel image for another platform or architecture (such as x86_64) before, then:

1. Do a cleanup step with `make properclean`.

1. Configure for QEMU AAarch64, as shown above.

1. Follow the instructions below to build for QEMU AArch64.

Building for QEMU AArch64 assumes you did the QEMU AArch64 configuration step above.
Build the Unikraft Python3 image for QEMU AArch64 by using the same command as for x86_64:

```console
make -j $(nproc)
```

Same as when building for x86_64, you can see a list of all the files 

```text
[...]
  LD      python3_qemu-arm64.dbg
  UKBI    python3_qemu-arm64.dbg.bootinfo
  SCSTRIP python3_qemu-arm64
  GZ      python3_qemu-arm64.gz
make[1]: Leaving directory '/media/stefan/projects/unikraft/scripts/workdir/apps/app-python3/.unikraft/unikraft'
```

Similarly to x86_64, at the end of the build command, the `python3_qemu-arm64` unikernel image is generated.
This image is to be used in the run step.

## Run

Run the resulting image using `qemu-system`.

### QEMU x86_64

To run the QEMU x86_64 build, use `qemu-system-x86_64`:

```console
sudo /usr/bin/qemu-system-x86_64 \
    -fsdev local,id=myid,path="$(pwd)/fs0",security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
    -kernel build/python3_qemu-x86_64 -nographic
```

This will open up a Python3 console:

```text
en1: Added
en1: Interface is up
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                  Atlas 0.13.1~5eb820bd
en1: Set IPv4 address 10.0.2.15 mask 255.255.255.0 gw 10.0.2.2
Python 3.7.4 (default, Jul  1 2023, 16:22:09) 
[GCC 9.4.0] on unknown
Type "help", "copyright", "credits" or "license" for more information.
>>> print("Hello, World!")
Hello, World!
>>>
```

To close the QEMU Python3 application, use the `Ctrl+a x` keyboard shortcut;
that is press the `Ctrl` and `a` keys at the same time and then, separately, press the `x` key.

### QEMU AArch64

To run the AArch64 build, use `qemu-system-aarch64`:

```console
sudo /usr/bin/qemu-system-aarch64 \
    -fsdev local,id=myid,path="$(pwd)/fs0",security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
    -kernel build/python3_qemu-arm64 -nographic \
    -machine virt -cpu cortex-a57
```

Just like when running for x86_64, this will run the Python3 application:

```text
en1: Added
en1: Interface is up
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                  Atlas 0.13.1~5eb820bd
en1: Set IPv4 address 10.0.2.15 mask 255.255.255.0 gw 10.0.2.2
Python 3.7.4 (default, Jul  1 2023, 16:22:09) 
[GCC 9.4.0] on unknown
Type "help", "copyright", "credits" or "license" for more information.
>>> print("Hello, World!")
Hello, World!
>>>
```

Similarly, to close the QEMU Python3 server, use the `Ctrl+a x` keyboard shortcut.
