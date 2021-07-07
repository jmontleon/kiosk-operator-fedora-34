#!/bin/bash
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${DEUSER:-vnc}:x:$(id -u):0:${DEUSER:-vnc}:/home/${DEUSER}:/bin/${DESHELL}" >> /etc/passwd
    if  [ ! -d "/home/${DEUSER}" ] &&  [ -d "/home/vnc" ]; then
    mv /home/vnc /home/${DEUSER}
    fi
  fi
fi
export HOME=/home/${DEUSER}

mkdir -p ~/.config/autostart/
cat << EOF > ~/.config/autostart/xfce-polkit.desktop
[Desktop Entry]
Hidden=true
EOF
cat << EOF > ~/.config/autostart/nm-applet.desktop
[Desktop Entry]
Hidden=true
EOF
cat << EOF > ~/.xscreensaver
mode:		off
EOF

mkdir -p ~/.vnc
echo $VNCPASS | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd

cat << EOF > ~/.vnc/config
geometry=$RESOLUTION
EOF

cat << EOF > ~/.vnc/xstartup
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
exec /etc/X11/xinit/xinitrc
EOF

chmod 755 ~/.vnc/xstartup

if [ "$DE" == "fvwm" ]; then
  echo PREFERRED=fvwm > /etc/sysconfig/desktop
elif [ "$DE" == "i3" ]; then
  echo PREFERRED=i3 > /etc/sysconfig/desktop
elif [ "$DE" == "KDE" ]; then
  echo PREFERRED=startkde > /etc/sysconfig/desktop
elif [ "$DE" == "LXDE" ]; then
  echo PREFERRED=startlxde > /etc/sysconfig/desktop
elif [ "$DE" == "LXQt" ]; then
  echo PREFERRED=startlxqt > /etc/sysconfig/desktop
elif [ "$DE" == "MATE" ]; then
  echo PREFERRED=mate-session > /etc/sysconfig/desktop
elif [ "$DE" == "Sugar" ]; then
  echo PREFERRED=sugar > /etc/sysconfig/desktop
elif [ "$DE" == "Xfce" ]; then
  echo PREFERRED=startxfce4 > /etc/sysconfig/desktop
else
  echo PREFERRED=twm > /etc/sysconfig/desktop
fi

if [ ! -f ~/.bashrc ]; then
  cp -r /etc/skel/.[b,c,k,m,z]* ~
fi

cd ~

if [ ! -z "$ADDITIONAL_PLAYBOOK_URL" ]; then
  curl -o /tmp/playbook.yml $ADDITIONAL_PLAYBOOK_URL
  ansible-playbook /tmp/playbook.yml
fi

vncserver -t -fg :1
