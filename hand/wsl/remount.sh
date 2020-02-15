


# remount drive for git use

# remount $drive
hand_wsl_remount()
{
    sudo umount /mnt/$1
    sudo mount -t drvfs D: /mnt/$1 -o metadata
}