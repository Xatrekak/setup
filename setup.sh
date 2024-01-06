#!/usr/bin/bash

#install missing user gnome extensions
array=( https://extensions.gnome.org/extension/307/dash-to-dock/
https://extensions.gnome.org/extension/517/caffeine/ )

for i in "${array[@]}"
do
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$EXTENSION_ID" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
    wget -O ${EXTENSION_ID}.zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
    gnome-extensions install --force ${EXTENSION_ID}.zip
    if ! gnome-extensions list | grep --quiet ${EXTENSION_ID}; then
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${EXTENSION_ID}
    fi
    gnome-extensions enable ${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
done

#install firefox extensions. close firefox after an extension is installed to isntall the next ones
#requires user to agree to isntall
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

#setup NAS
sudo dnf install -y nfs-utils
sudo mkdir /mnt/nas
sudo bash -c "echo '192.168.1.81:/mnt/tank/dustin    /mnt/nas    nfs    defaults    0 0' >> /etc/fstab"
sudo systemctl daemon-reload
sudo mount /mnt/nas

#Add NAS to gnome file browser
echo 'file:///mnt/nas' >> /home/dustin/.config/gtk-3.0/bookmarks

#Add bookmarks to Firefox
cp /mnt/nas/firefox/places.sqlite ~/.mozilla/firefox/bysvtelr.default-release/places.sqlite

#install and setup flatpaks
flatpak install flathub com.visualstudio.code
touch /home/dustin/.var/app/com.visualstudio.code/config/electron-flags.conf
echo "--enable-features=UseOzonePlatform,WaylandWindowDecorations" >> /home/dustin/.var/app/com.visualstudio.code/config/electron-flags.conf
echo "--ozone-platform=wayland" >> /home/dustin/.var/app/com.visualstudio.code/config/electron-flags.conf

#Enable and setup gnome extensions 
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gsettings set org.gnome.shell favorite-apps ['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'firefox.desktop', 'com.visualstudio.code.desktop', 'com.discordapp.Discord.desktop', 'org.gnome.Software.desktop']
gsettings set org.gnome.nautilus.preferences always-use-location-entry true

#Create symlink to t-rex miner can access NVML to monitor GPU
sudo ln -s /usr/lib/libnvidia-ml.so.1 /usr/lib/libnvidia-ml.so
sudo ln -s /usr/lib64/libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so
