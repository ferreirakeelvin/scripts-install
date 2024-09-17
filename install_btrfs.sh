#!/bin/bash

# Atualizar o sistema e instalar pacotes necessários
sudo apt update && sudo apt upgrade -y
sudo apt install -y btrfs-progs zram-tools timeshift snapper preload flatpak

# Configuração do Btrfs (adaptado, assumindo que a partição Btrfs esteja em /dev/sdXn)
sudo mount /dev/sdXn /mnt
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@log
sudo btrfs subvolume create /mnt/@cache

# Desmontar e montar subvolumes
sudo umount /mnt
sudo mount -o noatime,compress=zstd,subvol=@ /dev/sdXn /mnt
sudo mkdir -p /mnt/{home,var/log,var/cache}
sudo mount -o noatime,compress=zstd,subvol=@home /dev/sdXn /mnt/home
sudo mount -o noatime,compress=zstd,subvol=@log /dev/sdXn /mnt/var/log
sudo mount -o noatime,compress=zstd,subvol=@cache /dev/sdXn /mnt/var/cache

# Configuração do ZRAM
sudo bash -c 'cat > /etc/default/zramswap <<EOF
PERCENTAGE=50
ALGO=zstd
EOF'

# Ativar o ZRAM
sudo systemctl enable zramswap
sudo systemctl start zramswap

# Configuração do Zswap
sudo bash -c 'echo "zswap.enabled=1 zswap.compressor=zstd" >> /etc/default/grub'
sudo update-grub

# Instalar e habilitar Preload
sudo apt install -y preload
sudo systemctl enable preload
sudo systemctl start preload

# Instalar Timeshift e Snapper para snapshots Btrfs
sudo apt install -y timeshift snapper

# Configuração de Snapper
sudo snapper -c root create-config /

# Instalar Flatpak
sudo apt install -y flatpak

# Finalização da instalação
echo "Instalação e configuração de Btrfs, ZRAM, Zswap, Preload, Timeshift, Snapper e Flatpak concluídas no Debian!"