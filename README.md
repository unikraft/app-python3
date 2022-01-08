# Python 3 on Unikraft

This application prints "Hello, world!" using python3.

To configure, build and run this application you need to have [kraft](https://github.com/unikraft/kraft) installed.

Configure the application:
```
kraft configure
```

Build the application:
```
kraft build
```

And finally, run the application:
```
kraft run -M 1024 " -- helloworld.py"
```

If you want to have more control, you can configure and run the application manually.

To configure it with the desired features:
```
make menuconfig
```

Build the application:
```
make
```

Run the application:
- Create a sub-directory named fs0 in the application directory and extract the contents of minrootfs.tgz there.
- If you built the application for `kvm`:
```
sudo qemu-system-x86_64 \
	     -fsdev local,id=myid,path=$(pwd)/fs0,security_model=none \
	     -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
	     -kernel build/python3_kvm-x86_64 \
	     -append "-- helloworld.py" \
	     -enable-kvm \
	     -m 1G \
	     -nographic
```

For more information about `kraft` type ```kraft -h``` or read the
[documentation](http://docs.unikraft.org).
