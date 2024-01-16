#!/usr/bin/bash

#Setup tmp workspace
mkdir /tmp/quick-setup
cd /tmp/quick-setup

#Install dependencies for gnome extensions
sudo dnf install -y ddcutil
#install user gnome extensions
array=( https://extensions.gnome.org/extension/307/dash-to-dock/
https://extensions.gnome.org/extension/517/caffeine/
https://extensions.gnome.org/extension/4362/fullscreen-avoider/
https://extensions.gnome.org/extension/6325/control-monitor-brightness-and-volume-with-ddcutil/
https://extensions.gnome.org/extension/4228/wireless-hid/
https://extensions.gnome.org/extension/3193/blur-my-shell/
https://extensions.gnome.org/extension/841/freon/ )

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

#Setup firefox extensions.
#Get nighttab setup data. This must be imported manually by the user.
wget -P ~/Downloads https://raw.githubusercontent.com/Xatrekak/wallpaperRD/main/nighttab_backup.json
#Install extensions via policy
sudo mkdir -p /etc/firefox/policies
sudo touch /etc/firefox/policies/policies.json
sudo bash -c 'cat > /etc/firefox/policies/policies.json << EOT
{
    "policies": {
      "Extensions": {
        "Install": [
          "https://addons.mozilla.org/firefox/downloads/file/4198829/ublock_origin-latest.xpi",
          "https://addons.mozilla.org/firefox/downloads/file/4208799/lastpass_password_manager-latest.xpi",
          "https://addons.mozilla.org/firefox/downloads/file/4215671/betterttv-latest.xpi",
          "https://addons.mozilla.org/firefox/downloads/file/3848032/nighttab-latest.xpi",
          "https://addons.mozilla.org/firefox/downloads/file/4219481/load_reddit_images_directly-latest.xpi",
          "https://addons.mozilla.org/firefox/downloads/file/3977700/youtube_window_fullscreen-latest.xpi"
        ]
      },
      "ExtensionUpdate": true,
      "Homepage": {
      "URL": "moz-extension://ecde9aef-d343-4155-b326-7cb3939950f8/index.html"
      },
      "DisableTelemetry": true,
      "DisableFirefoxStudies": true,
      "EnableTrackingProtection": {
        "Value": true,
        "Locked": false,
        "Cryptomining": true,
        "Fingerprinting": true,
        "EmailTracking": true,
        "Exceptions": []
      }
    }
}
EOT'


#setup NAS
sudo dnf install -y nfs-utils
sudo mkdir /mnt/nas
sudo bash -c "echo '192.168.1.81:/mnt/tank/dustin    /mnt/nas    nfs    defaults    0 0' >> /etc/fstab"
sudo systemctl daemon-reload
sudo mount /mnt/nas

#Setup gnome shell
 gsettings set org.gnome.desktop.interface enable-hot-corners false

#Setup gnome file browser
gsettings set org.gnome.nautilus.preferences always-use-location-entry true
echo 'file:///mnt/nas' >> ~/.config/gtk-3.0/bookmarks
touch ~/Templates/script.sh
echo -e '#!/bin/bash\n' > ~/Templates/script.sh
mkdir ~/Projects
echo file://$HOME/Projects >> ~/.config/gtk-3.0/bookmarks

#Add bookmarks to Firefox
cp /mnt/nas/firefox/places.sqlite ~/.mozilla/firefox/bysvtelr.default-release/places.sqlite

#install and setup flatpaks
flatpak install flathub com.visualstudio.code --noninteractive --user
mkdir -p ~/.var/app/com.visualstudio.code/config/Code/User/
touch ~/.var/app/com.visualstudio.code/config/Code/User/settings.json
cat > ~/.var/app/com.visualstudio.code/config/Code/User/settings.json << EOT
{
    "terminal.integrated.defaultProfile.linux": "bash",
    "terminal.integrated.profiles.linux": {
      "bash": {
        "path": "host-spawn",
        "args": ["bash"]
      }
    },
    "security.workspace.trust.enabled": false
  }
EOT
touch ~/.var/app/com.visualstudio.code/config/electron-flags.conf
echo "--enable-features=UseOzonePlatform,WaylandWindowDecorations" >> ~/.var/app/com.visualstudio.code/config/electron-flags.conf
echo "--ozone-platform=wayland" >> ~/.var/app/com.visualstudio.code/config/electron-flags.conf
flatpak install flathub com.microsoft.Edge --noninteractive --user
flatpak install flathub org.qbittorrent.qBittorrent --noninteractive --user
sudo flatpak install flathub com.github.tchx84.Flatseal --noninteractive --system

#install GNS3
pip install gns3-gui

# #install and setup VS Code
# sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
# sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
# sudo dnf check-update
# sudo dnf install code

#Enable and setup system gnome extensions 
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gsettings set org.gnome.shell favorite-apps ['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.gedit.desktop', 'firefox.desktop', 'com.visualstudio.code.desktop', 'com.discordapp.Discord.desktop', 'steam.desktop', 'org.gnome.Software.desktop']

#setup gnome user extensions
#dash-to-doc
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock multi-monitor true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock show-mounts-network false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 64
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(145,65,172)'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock background-opacity 0.30
#caffeine
gsettings --schemadir ~/.local/share/gnome-shell/extensions/caffeine\@patapon.info/schemas/ set org.gnome.shell.extensions.caffeine show-indicator 'always'
#freon
gsettings --schemadir ~/.local/share/gnome-shell/extensions/freon@UshakovVasilii_Github.yahoo.com/schemas set org.gnome.shell.extensions.freon hot-sensors ['__average__', '__max__', 'NVIDIA GeForce RTX 3090', 'T_Sensor']
gsettings --schemadir ~/.local/share/gnome-shell/extensions/freon@UshakovVasilii_Github.yahoo.com/schemas set org.gnome.shell.extensions.freon use-gpu-nvidia true

#Create symlink to libnvidia-ml.so.1 so t-rex miner can access NVML to monitor GPU
sudo ln -s /usr/lib/libnvidia-ml.so.1 /usr/lib/libnvidia-ml.so
sudo ln -s /usr/lib64/libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so

#audio setup
# `pactl list short sinks` to get the output names for sink
# `pactl list short sources` to get the input names for source
sudo dnf install -y pactl
pactl set-default-sink alsa_output.usb-Schiit_Audio_Schiit_Modi_-00.analog-stereo
pactl set-default-source alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo.2

#Setup and install xbox controller dongle dependendencies may need to be ran again after reboot
sudo dnf install -y "dnf5-command(builddep)"
nobara-controller-config

#Move to Nvidia new feature branch
sudo dnf update nobara-repos --refresh
sudo dnf4 config-manager --set-enabled nobara-nvidia-new-feature-39
sudo dnf update --refresh
akmods
sudo nobara-sync
