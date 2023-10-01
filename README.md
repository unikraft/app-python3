# Python3 on Unikraft

This application starts a Python3 web application with Unikraft.
Follow the instructions below to set up, configure, build and run Python3.

To get started immediately, you can use Unikraft's companion command-line companion tool, [`kraft`](https://github.com/unikraft/kraftkit).
Start by running the interactive installer:

```console
curl --proto '=https' --tlsv1.2 -sSf https://get.kraftkit.sh | sudo sh
```

Once installed, clone [this repository](https://github.com/unikraft/app-python3) and run `kraft build`:

```console
git clone https://github.com/unikraft/app-python3 python3
cd python3/
kraft build
```

This will guide you through an interactive build process where you can select one of the available targets (architecture/platform combinations).
Otherwise, we recommend building for `qemu/x86_64` like so:

```console
kraft build --arch x86_64 --plat qemu
```

Once built, you can instantiate the unikernel via:

```console
kraft run
```

When left without any input flags, you'll be queried for the desired target architecture/platform.

If you are running on a virtual machine, or a system without KVM support, disable hardware acceleration by using the `-W` command line flag:

```console
kraft run -W
```

This starts a Python3 console in a virtual machine.
Note that KraftKit currently doesn't provide you the means to interact with the Python3 console in the virtual machine.
For that, see more below.

## Quick Setup (aka TLDR)

For a quick setup, run the commands below.
Note that you still need to install the [requirements](#requirements).

For building and running everything for `x86_64`, follow the steps below:

```console
git clone https://github.com/unikraft/app-python3 python3
cd python3/
wget https://raw.githubusercontent.com/unikraft/app-testing/staging/scripts/generate.py -O scripts/generate.py
chmod a+x scripts/generate.py
./scripts/generate.py
./scripts/build/make-qemu-x86_64-9pfs.sh
./scripts/run/qemu-x86_64-9pfs-interp.sh
```

This will configure, build and run the `Python3` application, resulting in a Python3 console being started.

The same can be done for `AArch64`, by running the commands below:

```console
git clone https://github.com/unikraft/app-python3 python3
cd python3/
wget https://raw.githubusercontent.com/unikraft/app-testing/staging/scripts/generate.py -O scripts/generate.py
chmod a+x scripts/generate.py
./scripts/generate.py
./scripts/build/make-qemu-arm64-9pfs.sh
./scripts/run/qemu-arm64-9pfs-interp.sh
```

Close the QEMU instance by using the `Ctrl+a x` keyboard combination.
That is, press `Ctrl` and `a` simultaneously, then release and press `x`.

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

In case you require networking support, such as starting a Python HTTP server, a specific configuration must be enabled for QEMU.
Run the commands below to enable that configuration (for the network bridge to work):

```console
sudo mkdir /etc/qemu/
echo "allow all" | sudo tee /etc/qemu/bridge.conf
```

## Set Up

The following repositories are required for Python3:

* The application repository (this repository): [`app-python3`](https://github.com/unikraft/app-python3)
* The Unikraft core repository: [`unikraft`](https://github.com/unikraft/unikraft)
* Library repositories:
  * The Python3 "library" repository: [`lib-python3`](https://github.com/unikraft/lib-python3)
  * The standard C library: [`lib-musl`](https://github.com/unikraft/lib-musl)
  * The networking stack library: [`lib-lwip`](https://github.com/unikraft/lib-lwip)
  * The compiler runtime library: [`lib-compiler-rt`](https://github.com/unikraft/lib-compiler-rt)

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
     defconfigs/  kraft.cloud.yaml  kraft.yaml  Makefile  Makefile.uk  README.md  rootfs.tar.gz  scripts/
     ```

  1. While inside the `python3/` directory, clone all required repositories:

     ```console
     git clone https://github.com/unikraft/unikraft workdir/unikraft
     git clone https://github.com/unikraft/lib-python3 libs/python3
     git clone https://github.com/unikraft/lib-musl libs/musl
     git clone https://github.com/unikraft/lib-lwip libs/lwip
     git clone https://github.com/unikraft/lib-compiler-rt libs/compiler-rt
     ```

  1. Use the `tree` command to inspect the contents of the `workdir/` directory.
     It should print something like this:

     ```console
     tree -F -L 2 workdir/
     ```

     The layout of the `workdir/` directory should look something like this:

     ```text
     workdir/
     |-- libs/
     |   |-- compiler-rt/
     |   |-- lwip/
     |   |-- musl/
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

## Scripted Building and Running

To build and run Unikraft images, it's easiest to generate build and running scripts and use those.

First of all, grab the [`generate.py` script](https://github.com/unikraft/app-testing/blob/staging/scripts/generate.py) and place it in the `scripts/` directory by running:

```console
wget https://raw.githubusercontent.com/unikraft/app-testing/staging/scripts/generate.py -O scripts/generate.py
chmod a+x scripts/generate.py
```

Now, run the `generate.py` script.
You must run it in the root directory of this repository:

```console
./scripts/generate.py
```

Running the script will generate build and run scripts in the `scripts/build/` and the `scripts/run/` directories:

```text
scripts/
|-- build/
|   |-- kraft-fc-arm64-initrd.sh*
|   |-- kraft-fc-x86_64-initrd.sh*
|   |-- kraft-qemu-arm64-9pfs.sh*
|   |-- kraft-qemu-arm64-initrd.sh*
|   |-- kraft-qemu-x86_64-9pfs.sh*
|   |-- kraft-qemu-x86_64-initrd.sh*
|   |-- make-fc-arm64-initrd.sh*
|   |-- make-fc-x86_64-initrd.sh*
|   |-- make-qemu-arm64-9pfs.sh*
|   |-- make-qemu-arm64-initrd.sh*
|   |-- make-qemu-x86_64-9pfs.sh*
|   `-- make-qemu-x86_64-initrd.sh*
|-- generate.py*
|-- run/
|   |-- fc-arm64-initrd-http-server.json
|   |-- fc-arm64-initrd-http-server.sh*
[...]
|   |-- kraft-qemu-arm64-initrd-http-server.sh*
|   |-- kraft-qemu-arm64-initrd-interp.sh*
|   |-- kraft-qemu-x86_64-9pfs-http-server.sh*
[...]
|   |-- qemu-x86_64-initrd-http-server.sh*
|   `-- qemu-x86_64-initrd-interp.sh*
`-- run.yaml
```

They are shell scripts, so you can use an editor or a text viewer to check their contents:

```console
cat scripts/run/qemu-x86_64-initrd-http-server.sh
```

You can now build and run images for different configurations

For example, to build and run for Firecracker on x86_64, run:

```console
./scripts/build/make-fc-x86_64-initrd.sh
./scripts/run/fc-x86_64-initrd-interp.sh
```

To build and run for QEMU on x86_64 using KraftKit, run:

```console
./scripts/build/kraft-qemu-x86_64-9pfs.sh
./scripts/run/kraft-qemu-x86_64-9pfs-interp.sh
```

The run script will start a Python3 console inside a Unikraft virtual machine.
You can run Python commands at the prompt.

Close KraftKit-opened instances by running `Ctrl+c`.
Then, check the open instances by using `kraft ps` or `sudo kraft ps.
Stop the instances by running `kraft stop <instance-id>`.

Close the QEMU instance by using the `Ctrl+a x` keyboard combination.
That is, press `Ctrl` and `a` simultaneously, then release and press `x`.

For Firecracker, you would have to kill the process by issuing a command.
Simplest is to open up another console and run:

```console
pkill -f firecracker
```

## Detailed Steps

### Configure

Configuring, building and running a Unikraft application depends on our choice of platform and architecture.
Currently, supported platforms are QEMU (KVM), Xen and linuxu.
QEMU (KVM) is known to be working, so we focus on that.

Supported architectures are x86_64 and AArch64.

Use the corresponding the configuration files in `defconfigs/`, according to your choice of platform and architecture.

#### QEMU x86_64

Use the `defconfigs/qemu-x86_64-9pfs` configuration file together with `make defconfig` to create the configuration file:

```console
UK_DEFCONFIG=$(pwd)/defconfigs/qemu-x86_64-9pfs make defconfig
```

This results in the creation of the `.config` file:

```console
ls .config
.config
```

The `.config` file will be used in the build step.

#### QEMU AArch64

Use the `defconfigs/qemu-arm64-9pfs` configuration file together with `make defconfig` to create the configuration file:

```console
UK_DEFCONFIG=$(pwd)/defconfigs/qemu-arm64-9pfs make defconfig
```

Similar to the x86_64 configuration, this results in the creation of the `.config` file that will be used in the build step.

### Build

Building uses as input the `.config` file from above, and results in a unikernel image as output.
The unikernel output image, together with intermediary build files, are stored in the `build/` directory.

#### Clean Up

Before starting a build on a different platform or architecture, you must clean up the build output.
This may also be required in case of a new configuration.

Cleaning up is done with 3 possible commands:

* `make clean`: cleans all actual build output files (binary files, including the unikernel image)
* `make properclean`: removes the entire `build/` directory
* `make distclean`: removes the entire `build/` directory **and** the `.config` file

Typically, you would use `make properclean` to remove all build artifacts, but keep the configuration file.

#### QEMU x86_64

Building for QEMU x86_64 assumes you did the QEMU x86_64 configuration step above.
Build the Unikraft Python3 image for QEMU x86_64 by using the commands below:

```console
make prepare
make -j $(nproc)
```

You can see a list of all the files processed by the build system:

```text
[...]
  LD      python3_qemu-x86_64.dbg
  UKBI    python3_qemu-x86_64.dbg.bootinfo
  SCSTRIP python3_qemu-x86_64
  GZ      python3_qemu-x86_64.gz
make[1]: Leaving directory '/media/stefan/projects/unikraft/scripts/workdir/apps/app-python3/workdir/unikraft'
```

At the end of the build command, the `python3_qemu-x86_64` unikernel image is generated.
This image is to be used in the run step.

#### QEMU AArch64

If you had configured and build a unikernel image for another platform or architecture (such as x86_64) before, then:

1. Do a cleanup step with `make properclean`.

1. Configure for QEMU AAarch64, as shown above.

1. Follow the instructions below to build for QEMU AArch64.

Building for QEMU AArch64 assumes you did the QEMU AArch64 configuration step above.
Build the Unikraft Python3 image for QEMU AArch64 by using the same command as for x86_64:

```console
make prepare
make -j $(nproc)
```

Same as when building for x86_64, you can see a list of all the files 

```text
[...]
  LD      python3_qemu-arm64.dbg
  UKBI    python3_qemu-arm64.dbg.bootinfo
  SCSTRIP python3_qemu-arm64
  GZ      python3_qemu-arm64.gz
make[1]: Leaving directory '/media/stefan/projects/unikraft/scripts/workdir/apps/app-python3/workdir/unikraft'
```

Similarly to x86_64, at the end of the build command, the `python3_qemu-arm64` unikernel image is generated.
This image is to be used in the run step.

### Run

Run the resulting image using `qemu-system`.

Before that, unpack the root filesystem:

```console
mkdir rootfs
tar xf rootfs.tar.gz -C rootfs
```

#### QEMU x86_64

To run the QEMU x86_64 build, use `qemu-system-x86_64`:

```console
sudo qemu-system-x86_64 \
    -accel kvm \
    -fsdev local,id=myid,path="$(pwd)/rootfs",security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs1,disable-modern=on,disable-legacy=off \
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
Python 3.7.4 (default, Jul  1 2023, 16:22:09) 
[GCC 9.4.0] on unknown
Type "help", "copyright", "credits" or "license" for more information.
>>> print("Hello, World!")
Hello, World!
>>>
```

Close the QEMU instance by using the `Ctrl+a x` keyboard combination.
That is, press `Ctrl` and `a` simultaneously, then release and press `x`.

#### QEMU AArch64

To run the AArch64 build, use `qemu-system-aarch64`:

```console
sudo qemu-system-aarch64 \
    -fsdev local,id=myid,path="$(pwd)/rootfs",security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs1,disable-modern=on,disable-legacy=off \
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
Python 3.7.4 (default, Jul  1 2023, 16:22:09) 
[GCC 9.4.0] on unknown
Type "help", "copyright", "credits" or "license" for more information.
>>> print("Hello, World!")
Hello, World!
>>>
```

Similarly, to close the QEMU Python3 server, use the `Ctrl+a x` keyboard shortcut.
