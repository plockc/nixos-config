# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # allows for installing packages from the unstable channel (which is more up to date)
  # without having to move the entire system to unstable
  # e.g. to use unstable foo package, use unstable.foo in environment.systemPackages
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
      # allow specific version of electron to be loaded from unstable
      # this supports obsidian
      permittedInsecurePackages = [ "electron-25.9.0" ];
    };
  };

  oldArmEmbeddedPkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/05ae01fcea6c7d270cc15374b0a806b09f548a9a.tar.gz";
  }) {};
 
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
  };

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable grub cryptodisk
  boot.loader.grub.enableCryptodisk=true;

  # Enable nested virtualization
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  boot.initrd.luks.devices = {
    "luks-40422ee3-379b-4ed6-aa02-890c86b2a1d3".keyFile = "/crypto_keyfile.bin";
  };
  networking.hostName = "nixos"; # Define your hostname.

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # I think the display manager manages X and does the auto login
  # services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
    # for changes to take effect, log out after running the below commands
    # gsettings reset org.gnome.desktop.input-sources xkb-options
    # gsettings reset org.gnome.desktop.input-sources sources
    xkb.options = "caps:escape_shifted_capslock";
  };
  # console gets mapping too
  console.useXkbConfig = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # nvidia card
  hardware.opengl.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };


  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.plockc = {
    isNormalUser = true;
    description = "Chris Plock";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    # final and prev are arguments, the prev is the un-modified packages, final is the modified packages
    # it is possible to reference final in the expressions
    # commented out as this doesn't actually appear to run properly (obsidian 1.5.3 or the OS is not compatible with 26) 2024-01-06
    # (final: prev: {
    #   # override key/values in obsidian, this is found in pkgs/top-level/all-packages.nix
    #   obsidian = prev.obsidian.override {
    #     # update electron to 26 from 25 as 25 is EOL
    #     electron = prev.electron_26;
    #   };
    # })

    # NOTE: this does not quite work, but I think it's close
    # Use a remote branch's package instead of directly updating, and allowUnfree for the specific package
    # (self: super: {
    #   obsidian = (import (builtins.fetchTarball {
    #     url =
    #       "https://github.com/plockc/nixpkgs/archive/4f7a8b4b37de6c7a2c3c689ff7202069fc5832d1.tar.gz";
    #     # I trust my own repo, so not updating the verification SHA
    #     # sha256 = "sha for remote tarball";
    #   }) { config = { allowUnfree = true; }; }).obsidian;
    # })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  environment.systemPackages = with pkgs; [
    neovim
    git
    go
    pciutils
    lshw
    dmidecode
    nix-index
    sysstat
    gnome.gnome-tweaks    
    gnomeExtensions.dash-to-dock
    kubectl
    kubectx
    yq
    jq
    python3
    wget
    htop
    virt-manager
    ethtool
    tcpdump
    conntrack-tools
    nixos-option
    usbutils # provides lsusb
    # SDL2 # for sunvox synthesizer
    exfat # for reading modern windows filesystems
    zig # systems programming language
    # see overlay above for electron
    unstable.obsidian # note taking
    dropbox-cli
    unzip
    file
    ripgrep
    vscode
    openocd # for programming microcontrollers
    oldArmEmbeddedPkgs.gcc-arm-embedded

    # build essential
    gcc
    autoconf
    automake
    libtool
    flex
    bison
    libiconv
    gnumake
    # more build (for openocd)
    libusb
    texinfo
    pkg-config

    # nvidia attempt 8-17-24
    # nvidia-x11
    # nvidia-settings
    # nvidia-persistenced

  ];

  services.kubernetes.roles = [ "master" "node" ];
  services.kubernetes.masterAddress = "localhost";
  services.kubernetes.addons.dns.enable = true;

  # add user access to stlink v3 for programming stm32 microcontrollers
  services.udev.extraRules = ''
  ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3754", MODE="660", TAG+="uaccess"
  '';

  programs.virt-manager.enable=true;
  virtualisation.libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "shutdown";
  };
  virtualisation.spiceUSBRedirection.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11DisplayOffset = 10;
    };
    settings.X11Forwarding = true;
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  systemd.user.services.dropbox = {
    description = "Dropbox";
    wantedBy = [ "graphical-session.target" ];
    environment = {
      QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
      QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
    };
    serviceConfig = {
      ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
      ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
      KillMode = "control-group"; # upstream recommends process
      Restart = "on-failure";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };
}
