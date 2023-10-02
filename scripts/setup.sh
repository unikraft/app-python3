#!/bin/bash

test ! -d "workdir" && echo "Cloning repositories ..." || true
test ! -d "workdir/unikraft" && git clone https://github.com/unikraft/unikraft workdir/unikraft || true
test ! -d "workdir/libs/musl" && git clone https://github.com/unikraft/lib-musl workdir/libs/musl || true
test ! -d "workdir/libs/lwip" && git clone https://github.com/unikraft/lib-lwip workdir/libs/lwip || true
test ! -d "workdir/libs/python3" && git clone https://github.com/unikraft/lib-python3 workdir/libs/python3 || true
test ! -d "workdir/libs/compiler-rt" && git clone https://github.com/unikraft/lib-compiler-rt workdir/libs/compiler-rt || true
