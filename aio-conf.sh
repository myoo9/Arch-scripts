echo "Easy installation script for Arch Linux"

#hostname
read -p "Hostname:" hname

#Separator
read -n 1 -r -s -p $'Press enter to continue...\n'

#Bootloader configurator
echo "Limine installation script (For Arch Linux)"
options=("MBR" "GPT")

select opt in "${options[@]}"; do
  case $opt in
    "MBR")
      echo "MBR selected"
      opt="MBR"
    break
    ;;
    "GPT")
      echo "GPT selected"
      opt="GPT"
    break
    ;;
    *)
      echo "$REPLY is not an option"
      echo "Retry or press Ctrl + C to exit"
      REPLY=""
      ;;
  esac
done

read -p "Write your disk name /dev/:" Dname
read -p "Specify your EFI partition:" Epart
read -p "Specify your boot partition:" Bpart
read -p "Specify your root partition:" Rpart

UUID=$(lsblk -no UUID /dev/${Dname}${Rpart})

pacman -Syu --noconfirm
pacman -S --noconfirm limine efibootmgr
mkdir -p /boot/EFI/arch-limine
cp /usr/share/limine/BOOTX64.EFI /boot/EFI/arch-limine/
efibootmgr --create --disk /dev/$Dname --part $Epart --label "Bootloader" --loader '\EFI\arch-limine\BOOTX64.EFI' --unicode

if [[ "$opt" == "MBR" ]]; then
  mkdir -p /boot/limine
  cp /usr/share/limine/limine-bios.sys /boot/limine
  limine bios-install /dev/$Dname

elif [[ "$opt" == "GPT" ]]; then
  limine bios-install /dev/$Dname $Bpart

else
  echo "An error ocurred"
  break

fi

echo "Timeout: 5

/Arch linux
  protocol: linux
  path: boot():/vmlinuz-linux
  cmdline: root=UUID=$UUID rw
  module_path: boot():/initramfs-linux.img

" > /boot/limine.conf


#Date, time, timezone and hostname configuration
ln -sf /usr/share/zoneinfo/Area/Location /etc/localtime
hwcloack --systohc
echo "es_ES.UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf
echo "$hname" > /etc/hostname

#Base propgrams installation & configuration
pacman -Sq --needed --noconfirm --noprogressbar git base-devel
git clone https://aur.archlinux.org/yay.git
makepkg -si -D ~/yay
rm -rf ~/yay
yay -Sa --answerclean a --answerdiff N brave-origin-bin portmaster-bin vscodium 
pacman -S --needed --noconfirm --noprogressbar dhcpcd alacritty gnome-boxes nautilus localsend

systemctl enable dhcpcd

#Kde plasma installation & configuration
pacman -Syu
pacman -S --noconfirm aurorae bluedevil breeze breeze-cursors breeze-gtk kactivitymanagerd kde-cli-tools kde-gtk-config kdecoration kde-plasma-addons kgamma kdeglobalacceld kinfocenter kmenuedit krpd kscreen kdescreenlocker ksystemstats kwayland kwin layer-shell-qt libkscreen libksysguard libplasma milou plasma-activities plasma-activities-stats plasma-desktop plasma-disks plasma-integration plasma-login-manager plasma-pa plasma-sdk plasma-system-monitor plasma-thunderbolt plasma-workspace plasma5support polkit-kde-agent print-manager qqc2-breeze-style