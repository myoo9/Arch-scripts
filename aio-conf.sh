echo "Easy installation script for Arch Linux"

#hostname
read -p "Hostname:" hname

#Separator
#read -n 1 -r -s -p $'Press enter to continue...\n'

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
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf
locale-gen
echo "$hname" > /etc/hostname

#Base propgrams installation
pacman -S --noconfirm --noprogressbar nvim dhcpcd alacritty gnome-boxes localsend
systemctl enable dhcpcd

#Gnome installation
pacman -Sq --noconfirm gnome
systemctl enable gdm
