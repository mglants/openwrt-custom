<!---
NOTE: AUTO-GENERATED FILE
to edit this file, instead edit its template at: ./ci/templates/README.md.j2
-->
<div align="center">


## OpenWrt Firmwares

_Collection of firmwares for routers to fight against censorship_

</div>

<div align="center">

![GitHub Repo stars](https://img.shields.io/github/stars/mglants/openwrt-custom?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/mglants/openwrt-custom?style=for-the-badge)
![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/mglants/openwrt-custom/scheduled-release.yaml?style=for-the-badge&label=Scheduled%20Release)

</div>

---

## About

This repository contains a custom **OpenWrt firmware** focused on reliability, reproducibility, and autonomous operation in constrained network environments.
The goal is to provide a ready-to-use system that requires minimal user configuration while remaining flexible and maintainable over time.

- Nikki is main software for VLESS subscriptions
- Some packages are added to make VPN tunnels
- Minimal software packs for routers
- For LTE/4G routers software are included
- No custom build or kernel, just repacking
- Suggestions are welcomed

The firmware includes a curated set of networking and management packages:

- `nikki`
- `luci-app-nikki`
- `luci`
- `kmod-amneziawg`
- `luci-proto-amneziawg`
- `amneziawg-tools`
- `luci-proto-wireguard`
- `wireguard-tools`

---


### Firmwares

Router | OpenWrt | Packages | Release
--- | --- | --- | ---
**ax3000t** | v24.10.5 | [8 packages](https://github.com/mglants/openwrt-custom/blob/main/devices/ax3000t/packages.txt) | —
**ax6s** | v24.10.5 | [8 packages](https://github.com/mglants/openwrt-custom/blob/main/devices/ax6s/packages.txt) | —
**netisn6** | v24.10.5 | [21 packages](https://github.com/mglants/openwrt-custom/blob/main/devices/netisn6/packages.txt) | —
**wr3000h** | v24.10.5 | [8 packages](https://github.com/mglants/openwrt-custom/blob/main/devices/wr3000h/packages.txt) | —
