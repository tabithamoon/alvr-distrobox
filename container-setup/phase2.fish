#!/usr/bin/env fish

echo "Renaming xdg-open to run apps within container"
sudo mv -v /usr/local/bin/xdg-open /usr/local/bin/xdg-open2

echo
echo "Setting up repositories..."
echo "[multilib]
Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu --noconfirm

echo
echo "Setting up locales..."
echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf
echo "LC_ALL=en_US.UTF-8" | sudo tee /etc/locale.conf
echo "export LANG=en_US.UTF-8" | tee -a ~/.bashrc
echo "export LC_ALL=en_US.UTF-8" | tee -a ~/.bashrc

echo
echo "Installing dependencies..."
sudo pacman -q --noprogressbar -Syu git glibc lib32-glibc xdg-utils qt5-tools qt5-multimedia at-spi2-core lib32-at-spi2-core tar wget --noconfirm