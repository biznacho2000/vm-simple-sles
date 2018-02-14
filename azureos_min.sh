#stop services
rccron stop
systemctl stop waagent

#install hana prereqs
zypper install -y glibc-2.22-51.6
zypper install -y systemd-228-142.1
zypper install -y unrar
zypper install -y sapconf
zypper install -y saptune
zypper se -t pattern
mkdir /etc/systemd/login.conf.d