#!/usr/bin/env bash

YAI_LATEST=$(curl -fSsL https://api.github.com/repos/ublue-os/yai/releases/latest | jq -r --arg arch $(arch) '.assets[] | select(.name | match("yai-.*."+$arch+".rpm")) | .browser_download_url')
dnf=$(which dnf5 || which dnf)
$dnf install -y $YAI_LATEST
mkdir -p /etc/gnome-initial-setup
tee /etc/gnome-initial-setup/vendor.conf <<EOF
[live_user pages]
skip=privacy;timezone;software;goa

[install]
application=yai.desktop
EOF
mkdir -p /etc/xdg/
tee /etc/xdg/plasma-welcomerc <<EOF
[General]
LiveEnvironment=true
LiveInstaller=yai
EOF

# We can tell what desktop environment we are targeting by looking at
# the session files. Lets decide by the first file found.
_session_file="$(find /usr/share/wayland-sessions/ /usr/share/xsessions \
    -maxdepth 1 -type f -name '*.desktop' -printf '%P' -quit)"
case $_session_file in
gnome*)
    cat >>/etc/environment <<"ENVEOF"
YAI_HIDE=user
ENVEOF
    ;;
esac
