#!/usr/bin/bash

array=( https://extensions.gnome.org/extension/307/dash-to-dock/ )

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

gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gsettings set org.gnome.shell favorite-apps ['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'firefox.desktop', 'com.visualstudio.code.desktop', 'com.discordapp.Discord.desktop', 'org.gnome.Software.desktop']

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
