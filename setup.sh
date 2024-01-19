#!/usr/bin/bash
###############################################################################
#############################System Configuration##############################
###############################################################################
#audio setup
# `pactl list short sinks` to get the output names for sink
# `pactl list short sources` to get the input names for source
sudo dnf install -y pactl
pactl set-default-sink alsa_output.usb-Schiit_Audio_Schiit_Modi_-00.analog-stereo
pactl set-default-source alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo

#setup NAS
sudo dnf install -y nfs-utils
sudo mkdir /mnt/nas
sudo bash -c "echo '192.168.1.81:/mnt/tank/dustin    /mnt/nas    nfs    defaults    0 0' >> /etc/fstab"
sudo systemctl daemon-reload
sudo mount /mnt/nas

#Create symlink to libnvidia-ml.so.1 so t-rex miner can access NVML to monitor GPU
sudo ln -s /usr/lib/libnvidia-ml.so.1 /usr/lib/libnvidia-ml.so
sudo ln -s /usr/lib64/libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so

#revert back to unpredicatble kernerl interface names
sudo sed -i '/GRUB_CMDLINE_LINUX/s/"nofb"/"nofb net.ifnames=0"/' /etc/default/grub
sudo update-grub

#Upgrade pip
pip install --upgrade pip

###############################################################################
#############################Shell Configuration###############################
###############################################################################
#Setup gnome shell behavior
gsettings set org.gnome.desktop.interface enable-hot-corners false

#Setup gnome file browser
gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true
gsettings set org.gnome.nautilus.preferences always-use-location-entry true
echo 'file:///mnt/nas' >> ~/.config/gtk-3.0/bookmarks
mkdir ~/Projects
echo file://$HOME/Projects >> ~/.config/gtk-3.0/bookmarks

#Setup Gnome file templates
mv ~/Templates/Text\ file ~/Templates/text_file.txt
touch ~/Templates/empty_file
touch ~/Templates/script.sh
echo -e '#!/bin/bash\n' > ~/Templates/script.sh
touch ~/Templates/py_script.py
echo -e '#!/usr/bin/python3' > ~/Templates/py_script.py

#Enable and setup system gnome extensions 
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gsettings set org.gnome.shell favorite-apps \
"['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.gedit.desktop', 'firefox.desktop', \
'com.visualstudio.code.desktop', 'com.discordapp.Discord.desktop', 'steam.desktop', 'org.gnome.Software.desktop']"

#setup Gnome Weather
gsettings set org.gnome.Weather locations "[<(uint32 2, <('Alexandria', 'KDCA', true, \
[(0.67803131976116615, -1.3444998506811625)], [(0.67727215389642637, -1.3447224499739618)])>)>, \
<(uint32 2, <('Washington DC, Reagan National Airport', 'KDCA', false, [(0.67803131976116615, -1.3444998506811625)], @a(dd) [])>)>]"

#Install dependencies for gnome user extensions
sudo dnf install -y ddcutil #needed for control-monitor-brightness-and-volume-with-ddcutil

#Install Gnome extension CLI installer
pip install gnome-extensions-cli

#install user gnome extensions
# https://extensions.gnome.org/extension/307/dash-to-dock/
# https://extensions.gnome.org/extension/517/caffeine/
# https://extensions.gnome.org/extension/4362/fullscreen-avoider/
# https://extensions.gnome.org/extension/6325/control-monitor-brightness-and-volume-with-ddcutil/
# https://extensions.gnome.org/extension/4228/wireless-hid/
# https://extensions.gnome.org/extension/3193/blur-my-shell/
# https://extensions.gnome.org/extension/841/freon/
gext install 307 517 4362 6325 4228 3193 841

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
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock custom-background-color true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(145,65,172)'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock background-opacity 0.30
#caffeine
gsettings --schemadir ~/.local/share/gnome-shell/extensions/caffeine\@patapon.info/schemas/ set org.gnome.shell.extensions.caffeine show-indicator 'always'
#freon
gsettings --schemadir ~/.local/share/gnome-shell/extensions/freon@UshakovVasilii_Github.yahoo.com/schemas set org.gnome.shell.extensions.freon hot-sensors \
"['__average__', '__max__', 'NVIDIA GeForce RTX 3090', 'T_Sensor']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/freon@UshakovVasilii_Github.yahoo.com/schemas set org.gnome.shell.extensions.freon use-gpu-nvidia true

###############################################################################
#############################App Configuration#################################
###############################################################################
#Setup firefox.
# This method is commented out while we try the NAS import method
# #Get nighttab extension setup data. This must be imported manually by the user.
# wget -P ~/Downloads https://raw.githubusercontent.com/Xatrekak/wallpaperRD/main/nighttab_backup.json
# #Install extensions via policy
# sudo mkdir -p /etc/firefox/policies
# sudo touch /etc/firefox/policies/policies.json
# sudo bash -c 'cat > /etc/firefox/policies/policies.json << EOT
# {
#     "policies": {
#       "Extensions": {
#         "Install": [
#           "https://addons.mozilla.org/firefox/downloads/file/4198829/ublock_origin-latest.xpi",
#           "https://addons.mozilla.org/firefox/downloads/file/4208799/lastpass_password_manager-latest.xpi",
#           "https://addons.mozilla.org/firefox/downloads/file/4215671/betterttv-latest.xpi",
#           "https://addons.mozilla.org/firefox/downloads/file/3848032/nighttab-latest.xpi",
#           "https://addons.mozilla.org/firefox/downloads/file/4219481/load_reddit_images_directly-latest.xpi",
#           "https://addons.mozilla.org/firefox/downloads/file/3977700/youtube_window_fullscreen-latest.xpi"
#         ]
#       },
#       "ExtensionUpdate": true,
#       "Homepage": {
#       "URL": "moz-extension://ecde9aef-d343-4155-b326-7cb3939950f8/index.html"
#       },
#       "DisableTelemetry": true,
#       "DisableFirefoxStudies": true,
#       "EnableTrackingProtection": {
#         "Value": true,
#         "Locked": false,
#         "Cryptomining": true,
#         "Fingerprinting": true,
#         "EmailTracking": true,
#         "Exceptions": []
#       }
#     }
# }
# EOT'
# #Add bookmarks to Firefox
# firefox &
# sleep 5
# pkill -f firefox
# FFX_PATH=$(find ~/.mozilla/firefox/ -maxdepth 1 -type d -name '*default-release*' -print -quit)>/dev/null
# rm $FFX_PATH/places.sqlite
# ln -s /mnt/nas/firefox/places.sqlite $FFX_PATH/places.sqlite

# link mozzila from nas to profile
ln -s /mnt/nas/firefox/.mozilla ~/.mozilla

#install apps
#install and setup flatpaks
sudo flatpak install flathub com.github.tchx84.Flatseal --noninteractive --system
flatpak install flathub com.discordapp.Discord --noninteractive --user
flatpak install flathub com.mattjakeman.ExtensionManager --noninteractive --user
flatpak install flathub org.onlyoffice.desktopeditors --noninteractive --user
flatpak install flathub org.filezillaproject.Filezilla --noninteractive --user
flatpak install flathub com.microsoft.Edge --noninteractive --user
flatpak install flathub org.qbittorrent.qBittorrent --noninteractive --user
flatpak install flathub com.visualstudio.code --noninteractive --user
#Set VSCode to use host terminal
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
#Attempt to tell vscode to use wayland native. New update broke this.
touch ~/.var/app/com.visualstudio.code/config/electron-flags.conf
echo "--enable-features=UseOzonePlatform,WaylandWindowDecorations" >> ~/.var/app/com.visualstudio.code/config/electron-flags.conf
echo "--ozone-platform=wayland" >> ~/.var/app/com.visualstudio.code/config/electron-flags.conf

#install GNS3
pip install gns3-gui

#setup and install input-leap
sudo firewall-cmd --permanent --add-port=24800/tcp
sudo firewall-cmd --reload
sudo dnf4 copr enable ofourdan/input-leap-ei-enabled
sudo dnf4 install input-leap --repo copr:copr.fedorainfracloud.org:ofourdan:input-leap-ei-enabled
sudo dnf4 reinstall libportal --repo copr:copr.fedorainfracloud.org:ofourdan:input-leap-ei-enabled

###############################################################################
#############################Final Configuration###############################
###############################################################################
#setup restart script
mkdir -p ~/.config/autostart
touch ~/.config/autostart/setup.desktop
touch ~/.config/autostart/setup.sh
cat > ~/.config/autostart/setup.desktop << EOT
[Desktop Entry]
Type=Application
Name=startup script
Exec=$HOME/.config/autostart/setup.sh
#X-GNOME-Autostart-enabled=true
EOT
cat > ~/.config/autostart/setup.sh << EOT
sudo nobara-controller-config
rm ~/.config/autostart/setup.desktop
rm ~/.config/autostart/setup.sh
EOT


#Setup and install xbox controller. The install will run on next boot.
sudo usermod -a -G pkg-build $USER
#setup restart script
mkdir -p ~/.config/autostart
touch ~/.config/autostart/setup.desktop
touch ~/.config/autostart/setup.sh
cat > ~/.config/autostart/setup.desktop << EOT
[Desktop Entry]
Type=Application
Name=startup script
Exec=$HOME/.config/autostart/setup.sh
#X-GNOME-Autostart-enabled=true
EOT
cat > ~/.config/autostart/setup.sh << EOT
nobara-controller-config
rm ~/.config/autostart/setup.desktop
rm ~/.config/autostart/setup.sh
sudo reboot now
EOT

#Move to Nvidia new feature branch
sudo dnf update nobara-repos --refresh
sudo dnf4 config-manager --set-enabled nobara-nvidia-new-feature-39
sudo dnf update --refresh
sudo akmods
sudo nobara-sync
sudo reboot now
