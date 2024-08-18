{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    exfat # for reading modern windows filesystems
    pciutils
    lshw
    dmidecode
    nix-index
    sysstat
    wget
    htop
    ethtool
    tcpdump
    conntrack-tools
    nixos-option
    usbutils # provides lsusb
    unzip
    file
    ripgrep
  ];
}


