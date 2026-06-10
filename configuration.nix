# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).



{ config, pkgs, inputs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.nix-mineral.nixosModules.nix-mineral
      inputs.maccel.nixosModules.default
    ];
   
  # Enable nix-mineral 
   nix-mineral = {
    enable = true;
   };
   
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Set default applications
  xdg.mime.defaultApplications = {
    "x-scheme-handler/http" = ["app.zen_browser.zen.desktop"];
    "x-scheme-handler/https" = ["app.zen_browser.zen.desktop"];
    "text/html" = ["app.zen_browser.zen.desktop"];
    "application/pdf" = ["zathura.desktop"];
  };
  
  # Enable ZRAM swap
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    # This refers to the uncompressed size, actual memory usage will be lower.
    memoryMax = 4096;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pnut = {
    isNormalUser = true;
    description = "Pnut";
    extraGroups = [ "networkmanager" "wheel" "storage" "dialout" ];
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

  # Enable Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  
  # Enable Helium overlay
  nixpkgs.overlays = [
   inputs.helium.overlays.default
  ];
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
   ananicy-cpp
   ananicy-rules-cachyos_git
   appimage-run
   at-spi2-core
   btop
   busybox
   curl
   distrobox
   fastfetch
   fish
   fishPlugins.tide
   gettext
   git
   glib
   gnome-tweaks
   gtk3
   helium
   micro
   nh
   nspr
   nss
   posy-cursors
   ptyxis
   scx.full
   steam-devices-udev-rules
   via
   vscode-fhs
   wget
   xdg-desktop-portal-gnome
   xdg-user-dirs
   xdg-utils
   yt-dlp
   zathura
  ];

 # Nix-ld for running dynamically linked binaries
 programs.nix-ld = {
    enable = true;
    libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
  };
 
 programs.steam = {
   enable = true;
 };

 fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    liberation_ttf
    nerd-fonts.geist-mono
    nerd-fonts.jetbrains-mono
    dejavu_fonts
  ]; 
  
  # Enable Maccel
  users.groups.maccel.members = ["pnut"];
  hardware.maccel = {
      enable = true;
      enableCli = true;
      parameters = {
      mode = "no_accel";
      sensMultiplier = 1.0;
      yxRatio = 1.0;
      inputDpi = 3200.0;
      angleRotation = -7.0;
     };
  };
  
  services.udev.packages = with pkgs; [
    via
    ];
      
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
  
  # sudo-rs setup
    security.sudo-rs.enable = true;

  # Enable GNOME
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.gnome.gnome-keyring.enable = true;
    
  # Disable unwanted gnome programs
    environment.gnome.excludePackages = with pkgs; [
    decibels
    gnome-characters
    gnome-tour
    gnome-connections
    epiphany # web browser
    geary # email reader. Up to 24.05. Starting from 24.11 the package name is just geary.
    evince # document viewer
    papers
    decibels
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
    gnome-console
  ];

  # Custom udev rules
  services.udev.extraRules =''

    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"


  '';
  
  # Enable flatpak support
   services.flatpak.enable = true;
   
  # Enable mullvad service and module
   services.mullvad-vpn.package = pkgs.mullvad-vpn;
   services.mullvad-vpn.enable = true;
   
 # Enable sched-ext
   services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    extraArgs = [ "performance" ];
  };
      
 # Enable latest kernel
  boot = {
    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
     
     #Set Kernel units
     kernel.sysctl = {
     "vm.swappiness" = 180;
     "vm.watermark_boost_factor" = 0;
     "vm.watermark_scale_factor" = 125;
     "vm.page-cluster" = 0;
     
     # Set initrd parameters
     initrd.verbose = false;
     initrd.systemd.enable = true;
   };
   
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };
   

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

  # Explicitly disable the Avahi daemon
   services.avahi.enable = false;

  # Explicitly disable the OpenSSH daemon
   services.openssh.enable = false;

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
