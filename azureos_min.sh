touch /tmp/stop.services.start
#stop services
sudo rccron stop
sudo systemctl stop waagent
touch /tmp/stop.services.complete

touch /tmp/install.start
#install hana prereqs
sudo zypper install -y glibc-2.22-51.6
sudo zypper install -y systemd-228-142.1
sudo zypper install -y unrar
sudo zypper install -y sapconf
sudo zypper install -y saptune
sudo zypper se -t pattern
sudo mkdir /etc/systemd/login.conf.d
touch /tmp/install.start.complete