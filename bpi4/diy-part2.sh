#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

cd package
git clone https://github.com/gSpotx2f/ruantiblock_openwrt.git --depth=1
git clone https://github.com/mglants/awg-openwrt.git --depth=1
git clone https://github.com/zerolabnet/SSClash.git --depth=1
#git clone https://github.com/itdoginfo/podkop.git --depth=1
cd -
