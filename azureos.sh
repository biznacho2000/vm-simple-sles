#install hana prereqs
sudo zypper install -y glibc-2.22-51.6
sudo zypper install -y systemd-228-142.1
sudo zypper install -y unrar
sudo zypper install -y sapconf
sudo zypper install -y saptune
sudo zypper se -t pattern
sudo mkdir /etc/systemd/login.conf.d

#update audit

echo "write to audit config begin" >> /tmp/audit.txt
echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "#install udf /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install vfat /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "options ipv6 disable=1" >> /etc/modprobe.d/CIS.conf
systemctl disable autofs
echo "write to audit config end" >> /tmp/audit.txt

echo "update boot.ini"

#mv /etc/rc.d/boot.local /etc/rc.d/boot.local.orig
#mkdir /usr/local/buildscript
#cd /usr/local/buildscript
#/usr/bin/wget --quiet --no-check-certificate "https://raw.githubusercontent.com/biznacho2000/vm-simple-sles/master/boot_sbx.sh"
#echo '#!/bin/sh' > /etc/rc.d/boot.local
#echo "sh /usr/local/buildscript/boot_sbx.sh >> /usr/local/buildscript/boot_sbx.sh.log 2>&1" >> /etc/rc.d/boot.local
#chmod 744 /etc/rc.d/boot.local

#echo "final reboot to reenable boot.ini and services"
#shutdown -r 1
#!/bin/bash

#stop services
sudo rccron stop

cp -f /etc/waagent.conf /etc/waagent.conf.orig
sedcmd="s/ResourceDisk.EnableSwap=n/ResourceDisk.EnableSwap=y/g"
sedcmd2="s/ResourceDisk.SwapSizeMB=0/ResourceDisk.SwapSizeMB=163840/g"
sedcmd3="s/Provisioning.DecodeCustomData=n/Provisioning.DecodeCustomData=y/g"
sedcmd4="s/Provisioning.ExecuteCustomData=n/Provisioning.ExecuteCustomData=y/g"
cat /etc/waagent.conf | sed $sedcmd | sed $sedcmd2 | sed $sedcmd3 | sed $sedcmd4 > /etc/waagent.conf.new
cp -f /etc/waagent.conf.new /etc/waagent.conf


bootdisk="$(df | grep boot | cut -c6,7,8)"
number="$(lsscsi [*] 0 0 0| grep -v sr0| grep -v $bootdisk| cut -c2)"
vg_system="$(lsscsi $number 0 0 0 | grep -o '.\{9\}$' | cut -c 1-8)"

parted -s $vg_system mklabel msdos
parted -s $vg_system mkpart primary 0GB 128GB
parted -s $vg_system mkpart primary 129GB 257GB

# pvcreate on both new paritions


  # vg_infraagentlun="$(lsscsi $number 0 0 3 | grep -o '.\{9\}$')"
  # pvcreate $vg_infraagentlun
  pvcreate $vg_system'1'
  pvcreate $vg_system'2'
  # vgcreate vg_infraagent $vg_infraagentlun
  vgcreate vg_system $vg_system'1'
  vgcreate vg_infraagent $vg_system'2'
  lvcreate -L 15G -n lv_home vg_system
  lvcreate -L 15G -n lv_tmp vg_system
  lvcreate -L 15G -n lv_vartmp vg_system
  mkfs.ext4 /dev/vg_system/lv_home
  mkfs.ext4 /dev/vg_system/lv_tmp
  mkfs.ext4 /dev/vg_system/lv_vartmp


mv /var/tmp /var/tmp.new
mv /home /home.new
mv /tmp /tmp.new

mkdir /var/tmp
mkdir /home
mkdir /tmp

mount -t ext4 /dev/vg_system/lv_vartmp /var/tmp
mount -t ext4 /dev/vg_system/lv_home /home
mount -t ext4 /dev/vg_system/lv_tmp /tmp

sleep 5

#
#data moves
mv /home.new/* /home
mv /home.new.* /home
mv /tmp.new/* /tmp
mv /tmp.new/.* /tmp
mv /var/tmp.new/* /var/tmp
mv /var/tmp.new/.* /var/tmp
rmdir /var.new
rmdir /home.new
rmdir /tmp.new
rmdir /var/tmp.new
chmod 1777 /tmp
chmod 1777 /var/tmp


echo "write to fstab start" >> /tmp/parameter.txt
uuid1="$(blkid | grep lv_vartmp | sed -e s/UUID=\"// | awk -F\" '{print $1}' | cut -d " " -f2)"
uuid2="$(blkid | grep lv_home | sed -e s/UUID=\"// | awk -F\" '{print $1}' | cut -d " " -f2)"
uuid3="$(blkid | grep lv_tmp | sed -e s/UUID=\"// | awk -F\" '{print $1}' | cut -d " " -f2)"
echo "UUID=$uuid1 /var/tmp ext4 noexec,nosuid,nodev,nobarrier,nofail 0 0" >> /etc/fstab
echo "UUID=$uuid2 /home ext4 nodev,nobarrier,nofail 0 0" >> /etc/fstab
echo "UUID=$uuid3 /tmp ext4 noexec,nosuid,nodev,nobarrier,nofail 0 0" >> /etc/fstab
echo "write to fstab end" >> /tmp/parameter.txt

