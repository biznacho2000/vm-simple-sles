#stop services
rccron stop
systemctl stop waagent

#install hana prereqs
sudo zypper install -y glibc-2.22-51.6
sudo zypper install -y systemd-228-142.1
sudo zypper install -y unrar
sudo zypper install -y sapconf
sudo zypper install -y saptune
sudo zypper se -t pattern
sudo mkdir /etc/systemd/login.conf.d

cp -f /etc/waagent.conf /etc/waagent.conf.orig
sedcmd="s/ResourceDisk.EnableSwap=n/ResourceDisk.EnableSwap=y/g"
sedcmd2="s/ResourceDisk.SwapSizeMB=0/ResourceDisk.SwapSizeMB=163840/g"
sedcmd3="s/Provisioning.DecodeCustomData=n/Provisioning.DecodeCustomData=y/g"
sedcmd4="s/Provisioning.ExecuteCustomData=n/Provisioning.ExecuteCustomData=y/g"
cat /etc/waagent.conf | sed $sedcmd | sed $sedcmd2 > /etc/waagent.conf.new
cp -f /etc/waagent.conf.new /etc/waagent.conf


mv /var /var.new
mv /home /home.new
mv /tmp /tmp.new
mv /opt /opt.new

mv 

echo "logicalvols start" >> /tmp/parameter.txt
  vg_infraagentlun="$(lsscsi $number 0 0 3 | grep -o '.\{9\}$')"
  pvcreate $vg_infraagentlun
  pvcreate $vg_system
  vgcreate vg_infraagent $vg_infraagentlun 
  vgcreate vg_system $vg_system
  lvcreate -L 4G -n lv_var vg_system
  lvcreate -L 4G -n lv_home vg_system
  lvcreate -L 8G -n lv_tmp vg_system
  lvcreate -L 4G -n lv_opt vg_system
mkfs.ext4 /dev/vg_system/lv_var
mkfs.ext4 /dev/vg_system/lv_home
mkfs.ext4 /dev/vg_system/lv_tmp
mkfs.ext4 /dev/vg_system/lv_opt

echo "logicalvols end" >> /tmp/parameter.txt


#!/bin/bash
echo "mounthanashared start" >> /tmp/parameter.txt

mkdir /var
mkdir /home
mkdir /tmp
mkdir /opt

mount -t ext4 /dev/vg_system/lv_var /var
mount -t ext4 /dev/vg_system/lv_home /home
mount -t ext4 /dev/vg_system/lv_tmp /tmp
mount -t ext4 /dev/vg_system/lv_opt /opt

mkdir /hana/data/sapbits
echo "mounthanashared end" >> /tmp/parameter.txt

#data moves
mv /var.new/* /var
mv /var.new/.* /var
mv /home.new/* /home
mv /home.new.* /home
mv /tmp.new/* /tmp
mv /tmp.new/.* /tmp
mv /opt.new/* /opt
mv /opt.new/.* /opt

echo "write to fstab start" >> /tmp/parameter.txt
echo "/dev/mapper/vg_system-lv_home /home ext4 defaults 0 0" >> /etc/fstab
echo "/dev/mapper/vg_system-lv_tmp /tmp ext4 defaults 0 0" >> /etc/fstab
echo "/dev/mapper/vg_system-lv_opt /opt ext4 defaults 0 0" >> /etc/fstab
echo "/dev/mapper/vg_system-lv_var /var ext4 defaults 0 0" >> /etc/fstab
echo "write to fstab end" >> /tmp/parameter.txt


echo "update boot.ini"


echo "final reboot to reenable boot.ini and services"
shutdown -r now