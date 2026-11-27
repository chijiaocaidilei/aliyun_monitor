sh << 'EOF'
#!/bin/sh
# Alpine VNC Auto Install
P="yiwan123"
D="/dev/vda"
R="http://mirrors.aliyun.com/alpine/v3.23"
setup-interfaces -a -r
sleep 2
cat>/tmp/a<<E
KEYMAPOPTS="us us"
HOSTNAMEOPTS="-n alpine"
INTERFACESOPTS="auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp"
DNSOPTS="-d 223.5.5.5 8.8.8.8"
TIMEZONEOPTS="-z PRC"
PROXYOPTS="none"
APKREPOSOPTS="$R/main"
SSHDOPTS="-c openssh"
NTPOPTS="-c chrony"
USEROPTS="-a -k none"
DISKOPTS="-m sys -s 0 $D"
E
export ERASE_DISKS="$D"
echo|setup-alpine -f /tmp/a -e
mkdir -p /mnt
mount ${D}2 /mnt
mount ${D}1 /mnt/boot
echo "root:$P"|chroot /mnt chpasswd
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /mnt/etc/ssh/sshd_config
printf "$R/main\n$R/community\n">/mnt/etc/apk/repositories
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
chroot /mnt apk update
chroot /mnt apk add util-linux grub grub-bios curl vim bash parted e2fsprogs
umount /mnt/boot
swapoff -a 2>/dev/null
dd if=/dev/zero of=$D bs=1K seek=32 count=992 conv=notrunc
dd if=/dev/zero of=$D bs=512 seek=1 count=33 conv=notrunc
B=$(basename $D)
S=$(cat /sys/block/$B/size)
dd if=/dev/zero of=$D bs=512 seek=$((S-33)) count=33 conv=notrunc
sync
mount ${D}1 /mnt/boot
chroot /mnt grub-install --recheck $D
chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
chroot /mnt apk del syslinux 2>/dev/null
sync
umount /mnt/boot /mnt/dev /mnt/proc /mnt/sys /mnt 2>/dev/null
reboot
EOF




VNC无法换行可以用这个
( f=$(mktemp) && { trap 'rm -f "$f"' EXIT; printf '%b' '#!/bin/sh\n# Alpine VNC Auto Install\nD="/dev/vda"\nR="http://mirrors.aliyun.com/alpine/v3.23"\nsetup-interfaces -a -r\nsleep 2\ncat >/tmp/a <<E\nKEYMAPOPTS="us us"\nHOSTNAMEOPTS="-n alpine"\nINTERFACESOPTS="auto lo\niface lo inet loopback\nauto eth0\niface eth0 inet dhcp"\nDNSOPTS="-d 223.5.5.5 8.8.8.8"\nTIMEZONEOPTS="-z PRC"\nPROXYOPTS="none"\nAPKREPOSOPTS="$R/main"\nSSHDOPTS="-c openssh"\nNTPOPTS="-c chrony"\nUSEROPTS="-a -k none"\nDISKOPTS="-m sys -s 0 $D"\nE\nexport ERASE_DISKS="$D"\necho | setup-alpine -f /tmp/a -e || exit 1\nmkdir -p /mnt\nmount "${D}2" /mnt || exit 1\nmount "${D}1" /mnt/boot || exit 1\nchroot /mnt passwd root || exit 1\nsed -i '"'"'s/#PermitRootLogin.*/PermitRootLogin yes/'"'"' /mnt/etc/ssh/sshd_config\nprintf "%s/main\\n%s/community\\n" "$R" "$R" > /mnt/etc/apk/repositories\nmount --bind /dev /mnt/dev\nmount --bind /proc /mnt/proc\nmount --bind /sys /mnt/sys\nchroot /mnt apk update\nchroot /mnt apk add util-linux grub grub-bios curl vim bash parted e2fsprogs || exit 1\numount /mnt/boot || exit 1\nswapoff -a 2>/dev/null\ndd if=/dev/zero of=$D bs=1K seek=32 count=992 conv=notrunc\ndd if=/dev/zero of=$D bs=512 seek=1 count=33 conv=notrunc\nB=$(basename "$D")\nS=$(cat "/sys/block/$B/size") || exit 1\ndd if=/dev/zero of=$D bs=512 seek=$((S-33)) count=33 conv=notrunc\nsync\nmount "${D}1" /mnt/boot || exit 1\nchroot /mnt grub-install --recheck "$D" || exit 1\nchroot /mnt grub-mkconfig -o /boot/grub/grub.cfg || exit 1\nchroot /mnt apk del syslinux 2>/dev/null\nsync\numount /mnt/boot /mnt/dev /mnt/proc /mnt/sys /mnt 2>/dev/null\nreboot\n' >"$f" && [ "$(cksum <"$f")" = '582179661 1520' ] && sh -n "$f" || { echo 'Script check failed. Nothing was installed.' >&2; exit 1; }; printf 'Erase /dev/vda? Type ERASE to proceed: ' && read -r reply && [ "$reply" = ERASE ] && sh "$f"; } )


看到 Erase /dev/vda? 后，只有确认这块盘上的数据可以全部清空，才输入 ERASE 并回车。安装时会提示你设置新的 root 密码。已验证单行命令能还原脚本，尚未在你的 ECS 实例上试跑。


命令已成功粘贴并通过校验。终端现在停在 Erase /dev/vda?，还没开始清盘。

如果确认 /dev/vda 上的数据可以全部清除，就在黑色终端直接输入大写 ERASE，然后按回车。安装过程中会提示你输入两次新的 root 密码，输入时屏幕不会显示字符。

如果不确定盘上有没有要保留的数据，按 Ctrl+C 取消。

Alpine 已写入系统盘。现在停在 New password:，等你为新系统的 root 账户设置密码。

在 VNC 黑色终端直接输入新密码并按回车。输入时屏幕不会显示字符或星号。 出现 Retype password: 后，再输入同一个密码并按回车。

先别手动重启。密码设置成功后，脚本还会配置引导，完成后会自动重启。重启后用 root 和刚设置的密码登录。

















