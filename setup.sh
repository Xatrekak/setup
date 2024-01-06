#!/usr/bin/bash

# sudo yum -y install https://extras.getpagespeed.com/release-latest.rpm
# sudo yum -y install lastversion

# lastversion download gorhill/uBlock  --format assets --filter firefox.xpi -o uBlock.xpi

wget https://addons.mozilla.org/firefox/downloads/file/4198829/ublock_origin-latest.xpi
wget https://addons.mozilla.org/firefox/downloads/file/4208799/lastpass_password_manager-latest.xpi
wget https://addons.mozilla.org/firefox/downloads/file/4215671/betterttv-latest.xpi
wget https://addons.mozilla.org/firefox/downloads/file/3848032/nighttab-latest.xpi
firefox ublock_origin-latest.xpi
firefox lastpass_password_manager-latest.xpi
firefox betterttv-latest.xpi
wget -P ~/Downloads https://raw.githubusercontent.com/Xatrekak/wallpaperRD/main/nighttab_backup.json
firefox nighttab-latest.xpi
rm *.xpi


sudo dnf install -y nfs-utils
sudo mkdir /mnt/nas
sudo bash -c "echo '192.168.1.81:/mnt/tank/dustin    /mnt/nas    nfs    defaults    0 0' >> /etc/fstab"
sudo systemctl daemon-reload
sudo mount /mnt/nas

echo 'file:///mnt/nas' >> /home/dustin/.config/gtk-3.0/bookmarks

cp /mnt/nas/firefox/places.sqlite ~/.mozilla/firefox/bysvtelr.default-release/places.sqlite
