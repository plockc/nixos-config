# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Enable nested virtualization
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = 1;

  networking.hostName = "mini"; # Define your hostname.
  # not needed with network manager enabled
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.enableIPv6 = false;
  networking.search = ["lan"];
  networking.interfaces = {
    enp3s0f0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.24.1";
        prefixLength = 21;
      }];
    };
  };
  networking.networkmanager = {
    enable = true;
    dns =  "none";
  };

  environment.etc = {
    "hosts.dnsmasq".text = (builtins.readFile ./dnsmasq/hosts.dnsmasq);
    "dnsmasq.d/pocket".text = (builtins.readFile ./dnsmasq/pocket);
    "dnsmasq.d/static-leases".text = (builtins.readFile ./dnsmasq/static-leases);
  };

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
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    xkbOptions = "caps:escape_shifted_capslock";
  };

  # console gets mapping too
  console.useXkbConfig = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.plockc = {
    isNormalUser = true;
    description = "Chris P";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
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
    dnsmasq
    ripgrep
    ldns
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.dnsmasq = {
    enable = true;
    settings = {
      conf-dir = "/etc/dnsmasq.d";
      server = ["1.1.1.1"  "8.8.8.8"];
    };
  };

  networking.firewall.enable = true;
  # Open ports in the firewall.
  # ssh dns http https alt_http alt_https
  networking.firewall.allowedTCPPorts = [ 22 53 80 443 8080 8443 ];
  # dns dhcp_server dhcp_client
  networking.firewall.allowedUDPPorts = [ 53 67 68 ];
  networking.nftables = {
    enable = true;
    ruleset = ''
      table ip nat {
        chain postrouting {
          type nat hook postrouting priority 100; policy accept;
          oifname "wlp2s0" masquerade
        } 
      }
    '';
  };
  networking.firewall.rejectPackets = true;
  networking.firewall.filterForward = false;
  networking.firewall.extraForwardRules = ''
  '';
  networking.firewall.extraCommands = ''
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "shutdown";
    };
  };

  #programs.dconf.enable = true;
  #dconf.settings = {
  #  "org/virt-manager/virt-manager/connections" = {
  #    autoconnect = ["qemu:///system"];
  #    uris = ["qemu:///system"];
  #  };
  #};
}
