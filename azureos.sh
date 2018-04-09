
bootdisk="$(df | grep boot | cut -c6,7,8)"
number="$(lsscsi [*] 0 0 0| grep -v sr0| grep -v $bootdisk| cut -c2)"
vg_system="$(lsscsi $number 0 0 0 | grep -o '.\{9\}$' | cut -c 1-8)"

parted -s $vg_system mklabel msdos
parted -s $vg_system mkpart primary 0GB 128GB
parted -s $vg_system mkpart primary 129GB 257GB

  pvcreate $vg_system'1'
  vgcreate vg_system $vg_system'1'
  lvcreate -L 50G -n lv_home vg_system
  lvcreate -L 50G -n lv_tmp vg_system
  lvcreate -L 50G -n lv_vartmp vg_system
  mkfs.ext4 /dev/vg_system/lv_home
  mkfs.ext4 /dev/vg_system/lv_tmp
  mkfs.ext4 /dev/vg_system/lv_vartmp


mv /var/tmp /var/tmp.new
mv /home /home.new
mv /tmp /tmp.new

mkdir /var/tmp
mkdir /home
mkdir /tmp

mount -t ext4 /dev/vg_system/lv_vartmp /var/tmp -o nodev,nosuid,noexec
mount -t ext4 /dev/vg_system/lv_home /home -o nodev
mount -t ext4 /dev/vg_system/lv_tmp /tmp -o nodev,nosuid,noexec

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

