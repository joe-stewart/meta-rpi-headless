# meta-custom — rpi-headless

A minimal, opinionated Yocto layer for headless Raspberry Pi deployment.
Targets CM4 and RPi4 (`raspberrypi4-64`). No busybox. No implicit package groups.
Every package in the image is listed explicitly.

First boot is configured via a drop-in `firstboot.ini` file written to the SD card
before it goes in the board — no HDMI, no keyboard, no cloud-init.

Tested on scarthgap.

---

## Getting started

Clone the repo and run the setup script:

```bash
git clone git@github.com:joe-stewart/meta-rpi-headless meta-custom
cd meta-custom
bash setup.sh
```

The script clones poky, meta-openembedded, and meta-raspberrypi into the Yocto
workspace, creates `build-cm4/conf/` with populated `bblayers.conf` and
`local.conf`, and generates a `firstboot.ini` template ready to edit.

**Scripts included:**

`setup.sh` — environment setup for a new build. Prompts for a base directory,
clones all required layers, creates the build directory, and generates
`firstboot.ini`. Safe to rerun — skips anything already present.

`test.sh` — clean build test. Uses an isolated `build-test` directory and a
separate sstate cache (`shared/sstate-test`) so the build reflects a genuine
clean run. Downloads are shared with the dev environment to avoid re-fetching.
Exits 0 on pass, 1 on fail.

```bash
bash test.sh
```

`common.sh` — shared functions sourced by both scripts. Not run directly.

## How it works

On first boot, `firstboot.sh` runs as a systemd oneshot service. It reads
`/firstboot.ini` from the root filesystem and applies user creation, SSH key
installation, and hostname configuration, then locks root and deletes the ini
file. If no ini file is present, root is locked and the system shuts down — this
is intentional. The board does nothing useful until it has been configured.

A template is installed at `/etc/firstboot.ini.template`. To reconfigure a
deployed board: copy the template to `/firstboot.ini`, delete
`/etc/firstboot.done`, and reboot.

---

## Dependencies

| Layer | Branch |
|---|---|
| poky | scarthgap |
| meta-openembedded (meta-oe, meta-python, meta-networking) | scarthgap |
| meta-raspberrypi | scarthgap |

Clone all three alongside this layer:

```bash
git clone -b scarthgap git://git.yoctoproject.org/poky
git clone -b scarthgap https://github.com/openembedded/meta-openembedded
git clone -b scarthgap https://github.com/agherzan/meta-raspberrypi
git clone https://github.com/YOUR_USERNAME/meta-custom
```

---

## Build configuration

Source the Yocto environment from your build directory:

```bash
source poky/oe-init-build-env build-cm4
```

**bblayers.conf** — add these layers (adjust paths to your layout):

```
BBLAYERS ?= " \
    /path/to/poky/meta \
    /path/to/poky/meta-poky \
    /path/to/meta-openembedded/meta-oe \
    /path/to/meta-openembedded/meta-python \
    /path/to/meta-openembedded/meta-networking \
    /path/to/meta-raspberrypi \
    /path/to/meta-custom \
"
```

**local.conf** — minimum additions:

```
MACHINE = "raspberrypi4-64"
DISTRO = "rpi-headless"
LICENSE_FLAGS_ACCEPTED = "synaptics-killswitch"
```

Shared cache (recommended):

```
DL_DIR = "/path/to/shared/downloads"
SSTATE_DIR = "/path/to/shared/sstate-cache"
```

---

## Building

```bash
bitbake rpi-base-image
```

Output: `tmp-glibc/deploy/images/raspberrypi4-64/rpi-base-image-raspberrypi4-64.rootfs.rpi-sdimg`

Flash to SD card:

```bash
sudo dd if=rpi-base-image-raspberrypi4-64.rootfs.rpi-sdimg of=/dev/sdX bs=4M status=progress conv=fsync
```

---

## Configuring a card before first boot

Mount the root partition and drop in an ini file:

```bash
sudo mkdir -p /tmp/root
sudo mount /dev/sdX2 /tmp/root
sudo cp /tmp/root/etc/firstboot.ini.template /tmp/root/firstboot.ini
sudo vi /tmp/root/firstboot.ini
sudo umount /tmp/root
```

**firstboot.ini** format:

```ini
[user]
username=joe
password=changeme
uid=1000

[ssh]
authorized_keys=ssh-ed25519 AAAA...

[hostname]
hostname=rpiheadless
```

All fields are optional individually, but `username` should always be set.
Without a user account there is no supported path into the system — SSH root
login is blocked by OpenSSH defaults, and no other access mechanism is
provisioned. If `authorized_keys` is set, keys are installed to
`~/.ssh/authorized_keys` with correct permissions.

The ini file is deleted after processing. Root is locked on completion;
sudo is the only supported path to root access.

---

## Hardware notes

**CM4 and RPi4 are equivalent** for this layer. Both use `MACHINE =
"raspberrypi4-64"` and produce the same image. The distinction is physical
only: the CM4 requires a carrier board with a USB or PCIe SD interface for
flashing, whereas the RPi4 takes a standard microSD directly.

Serial console access differs between the two boards depending on your carrier
board and any serial HAT fitted. The image enables UART (`ENABLE_UART = "1"` in
the distro config) and masks `serial-getty@ttyS0.service` at firstboot. If you
need a getty on the serial console, unmask it after provisioning:

```bash
sudo systemctl unmask serial-getty@ttyS0.service
sudo systemctl enable --now serial-getty@ttyS0.service
```

---

## Layer structure

```
meta-custom/
├── conf/
│   ├── layer.conf
│   └── distro/
│       └── rpi-headless.conf
├── recipes-bsp/
│   └── bootfiles/
│       └── rpi-config_git.bbappend   # strips comments from config.txt at deploy
├── recipes-core/
│   ├── firstboot/
│   │   ├── firstboot.bb
│   │   └── files/
│   │       ├── firstboot.sh
│   │       ├── firstboot.service
│   │       └── firstboot.ini.template
│   ├── images/
│   │   ├── rpi-base-image.bb
│   │   ├── qemu-base-image.bb
│   │   └── rpi-headless-common.inc   # shared package list
│   └── sudo/
│       └── sudo-config.bb            # grants sudo group full access via sudoers
```

---

## Design notes

- No busybox — replaced by coreutils, util-linux, bash, and standard tools
- No image features or package groups — every package is listed in `rpi-headless-common.inc`
- No cloud-init, no NetworkManager — systemd-networkd handles networking
- DHCP by default; static IP configuration is not yet wired into firstboot (planned)
- `config.txt` comments are stripped at deploy time to avoid a firmware file size bug
  ([raspberrypi/firmware#1948](https://github.com/raspberrypi/firmware/issues/1948))

**v1.1 candidates:** `parted`, `python3-pip`, `screen`, and `iptables` are flagged for
removal. Dropping `parted` and `screen` has no functional impact on the headless use case.
Removing `python3-pip` (meta-python) and `iptables` (meta-networking) may allow
meta-openembedded to be dropped as a dependency entirely, pending verification.
