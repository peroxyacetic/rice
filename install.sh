# Set username
read - p "Enter your username: " name

# Allow user to run sudo without password. Since AUR programs must be installed
# in a fakeroot environment, this is required for all builds with AUR.
trap 'rm -f /etc/sudoers.d/temp' HUP INT QUIT TERM PWR EXIT
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/temp

# Make pacman colorful, concurrent downloads and Pacman eye-candy.
grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sed -Ei "s/^#(ParallelDownloads).*/\1 = 5/;/^#Color$/s/#//" /etc/pacman.conf

# Use all cores for compilation.
sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf

# Installing normal packages
sudo pacman --noconfirm -S archlinux-keyring
sudo pacman -S --noconfirm --needed xorg-server xorg-xwininfo xorg-xinit xorg-xprop xcompmgr zsh polkit ttf-linux-libertine git base-devel chromium bc arandr libnotify dunst exfat-utils sxiv xwallpaper python-qdarkstyle neovim mpv man-db noto-fonts-emoji ntfs-3g pipewire pipewire-pulse pulsemixer pamixer maim unclutter unzip xcape xclip xdotool xorg-xdpyinfo zathura zathura-pdf-mupdf poppler mediainfo atool fzf bat xorg-xbacklight xfce4-power-manager slock socat moreutils neofetch

# Installing .git Packages
mkdir /home/$name/.local/src
cd /home/$name/.local/src
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
git clone https://github.com/peroxyacetic/suckless.git
cd suckless
cd dwm
make install
cd ..
cd dwmblocks
make install
cd ..
cd dmenu
make install
cd ..
cd st
make install
cd "/home/$name/"

# Installing AUR packages
yay -S --noconfirm libxft-git lf-git gtk-theme-arc-gruvbox-git noto-fonts sc-im zsh-fast-syntax-highlighting-git simple-mtpfs htop-vim spotify ani-cli-git nerd-fonts-fira-code

# Make zsh the default shell for the user
chsh -s /bin/zsh "$name" >/dev/null 2>&1
sudo -u "$name" mkdir -p "/home/$name/.cache/zsh/"

# Enable tap to click
[ ! -f /etc/X11/xorg.conf.d/40-libinput.conf ] && printf 'Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
	# Enable left mouse button by tapping
	Option "Tapping" "on"
EndSection' >/etc/X11/xorg.conf.d/40-libinput.conf

# Allow wheel users to sudo with password and allow several system commands
# (like `shutdown` to run without password).
echo "%wheel ALL=(ALL:ALL) ALL" >/etc/sudoers.d/00-wheel-can-sudo
echo "%wheel ALL=(ALL:ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/yay,/usr/bin/pacman -Syyuw --noconfirm" >/etc/sudoers.d/01-cmds-without-password

# Installing dotfiles
mv "/dots/*" "/home/$name/"
rm -rf "/home/$name/.git/" "/home/$name/README.md"