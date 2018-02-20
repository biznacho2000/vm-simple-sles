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

mv /etc/rc.d/boot.local /etc/rc.d/boot.local.orig
cd /tmp
/usr/bin/wget --quiet "https://raw.githubusercontent.com/shortkidd610/vm-simple-sles/master/boot.sh"
echo "sh /tmp/boot.sh >> /tmp/boot.sh.log 2>&1" > /etc/rc.d/boot.local
chmod 744 /etc/rc.d/boot.local

echo "final reboot to reenable boot.ini and services"
shutdown -r 1
