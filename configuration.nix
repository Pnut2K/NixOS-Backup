
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).



{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader = {
  timeout = 10;

  efi = {
    efiSysMountPoint = "/boot";
  };

  grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true; # Otherwise /boot/EFI/BOOT/BOOTX64.EFI isn't generated
    devices = ["nodev"];
    useOSProber = true;
    extraEntriesBeforeNixOS = false;
    extraEntries = ''
      menuentry "Reboot" {
        reboot
      }
      menuentry "Poweroff" {
        halt
      }
    '';
  };
  };

  networking.hostName = "NixOS"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable ZRAM swap
  zramSwap.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pnut = {
    isNormalUser = true;
    description = "Pnut";
    extraGroups = [ "networkmanager" "wheel" "storage" "libvirtd" "vboxusers" ];
    packages = with pkgs; [];
  };
  
  # Enable automatic garbage collection
  nix.gc = {
		automatic = true;
		dates = "daily";
		options = "--delete-older-than 3d";
	};

  # Enable fish and set it as the default login shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  
  # Enable automount for USB filesystems
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
   nerd-fonts.ubuntu-sans
   steam-devices-udev-rules
   micro
   fish
   fishPlugins.tide
   btop
   noto-fonts
   fastfetch
   doas
   appimage-run
   busybox
   xdg-user-dirs
   xdg-utils
   posy-cursors
   at-spi2-core
   spicetify-cli
   glib
   git
   github-desktop
   perl
   curl
   wget
   wineWowPackages.full
   winetricks
   gtk3
   cmake
   gcc
   gettext
   gnumake
   steam-run
   gnome-browser-connector
   ghostty
   gnome-tweaks
   xdg-desktop-portal-gnome
   nss
   nspr
   nh
  ];
 
  # Enable Virt-manager 
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = ["pnut"];
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    
  # Enable sound with pipewire
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      };
  
  # Doas setup
    security.doas.enable = true;
    security.sudo.enable = false;
    security.doas.extraRules = [{
      users = ["pnut"];
      keepEnv = true;
      persist = true;
      }];

  # Enable GNOME
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;	
    };
    
  # Disable unwanted gnome programs
    environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    epiphany # web browser
    geary # email reader. Up to 24.05. Starting from 24.11 the package name is just geary.
    evince # document viewer
    gnome-music
    totem
    simple-scan
    gnome-contacts
    gnome-system-monitor
    snapshot
    yelp
    gnome-clocks
    gnome-calendar
    gnome-weather
    gnome-maps
    gnome-software
    file-roller
  ];


  # Enable flatpak support
   services.flatpak.enable = true;

  # Enable mullvad service and module
   services.mullvad-vpn.package = pkgs.mullvad-vpn;
   services.mullvad-vpn.enable = true;
    
 # Enable CachyOS kernel
   boot.kernelPackages = pkgs.linuxPackages_cachyos-rc;
   boot.kernelParams = [ "quiet" "udev.log_level=3" ];
   
 # Set initrd parameters
   boot.initrd.verbose = false;
   boot.initrd.systemd.enable = true;

 # Enable appimage interpreter
   boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
   };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  system.stateVersion = "24.05"; # Did you read the comment?

}
