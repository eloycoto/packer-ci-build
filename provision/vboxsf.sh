#!/usr/bin/env bash

set -eux

git clone https://github.com/jwrdegoede/vboxsf.git
cd vboxsf
make
sudo make modules_install
sudo depmod -a
