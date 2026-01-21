# Edit this file in your ~/nixos-config folder.
# After saving, run: git add . && sudo nixos-rebuild switch --flake .#nixos

{ config, pkgs, inputs, ... }@args:

let
  # we anchor the inputs here so they are locked into the file's scope
  # this prevents the "undefined variable" error when home-manager evaluates
  flake-inputs = args.inputs or inputs;
in
{
  imports = [
    ./hardware-configuration.nix
    ./dev-toolchain.nix
  ];

  # --- THE "INPUTS" FORCE-INJECTION ---
  # We use _module.args to inject it into every submodule globally
  _module.args = { inputs = flake-inputs; };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Force Xe driver in early boot to prevent black screens
  boot.initrd.kernelModules = [ "xe" "intel_lpss_pci" ];
  
  boot.kernelParams = [
	# Probe B580 (e20b) and iGPU (7d67) with the new Xe driver
	"xe.force_probe=e20b"
	# Blacklist legacy i915 driver for these specific IDs
	"i915.force_probe=!"
	"modeprobe.blacklist=i915"
	
	# Helps dGPU talk to CPU on arrow lake and Pass through for better GPU stability
	"intel_iommu=on"
	"iommu=pt"
	"video=efifb:off"
	# stabilize power management
	"pcie_aspm=off"
	# Force kernel to use the first PCI card for the console
	"fbcon=primary:0"
	"video=HDMI-A-1:e" # DP1 to enabled
	# Prevent handover hangs from EFI framebuffer
	"i915.modeset=0"
	"video=1920x1080@60"
	"xe.fastboot=1"
  ];

  systemd.services.display-manager.after = [ "sys-devices-pci0000:00-0000:00:01.0-0000:01:00.0-0000:02:01.0-0000:03:00.0-0000:04:00.0-drm-card0.device" ];
  systemd.services.display-manager.wants = [ "sys-devices-pci0000:00-0000:00:01.0-0000:01:00.0-0000:02:01.0-0000:03:00.0-0000:04:00.0-drm-card0.device" ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # Flake specific settings 
  nix.settings.auto-optimise-store = true;
  nix.gc = {
	automatic = true;
	dates = "weekly";
	options = "--delete-older-than 7d --keep-generations 5";
	};

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  
  # FIX Resolve too many open files error during build
  nix.settings.max-jobs = "auto";
  systemd.settings.Manager = { 
	DefaultLimitNOFILE = "2048";
  };
  
  # Crucial for Intel BE200 Wi-Fi 7 and GPU microcode
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  hardware.graphics = {
	enable = true;
	enable32Bit = true;
	extraPackages = with pkgs; [
		intel-media-driver # iHD driver
		vpl-gpu-rt         # Video processing for modern Intel
		intel-vaapi-driver
		libvdpau-va-gl
	];
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  
  services.displayManager.sddm = {
	enable = false;
	wayland.enable = true;
	theme = "maldives";
  };
  # Disable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = false;
  # services.xserver.desktopManager.gnome.enable = false;

  services.getty.autologinUser = null;    

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Hyprland setup
  programs.hyprland = {
	enable = true;
	xwayland.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.h4rsh = {
    isNormalUser = true;
    description = "h4rsh";
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
    packages = with pkgs; [
    #  thunderbird
  	kitty # terminal for hyprland
  	git #
  	wget
  	pciutils # for lspci
  	btop # monitor systems
    inputs.antigravity-nix.packages.${pkgs.system}.default
    ];
  }; 

  services.dbus.enable = true;
  programs.dconf.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  qt = {
	enable = true;
	platformTheme = "qt5ct";
	style = "adwaita-dark";
  };

  # --- HOME MANAGER ---
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    
    backupFileExtension = "backup";    
    # We use the anchored variable to ensure it's passed to home.nix
    extraSpecialArgs = { inputs = flake-inputs; };

    users.h4rsh = {
      imports = [ ./home.nix ];
      
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          # FIX based on Reddit/Omarchy research:
          # If your Hyprland version is complaining about "missing a value",
          # we use the more explicit windowrulev2 syntax.
          windowrulev2 = [
            # Some versions prefer 'suppressevent' without the space or as a rule
            "suppressevent maximize, class:.*"
            # The "missing a value" fix: Ensure nofocus is treated as a 
            # rule string, not a boolean attribute.
            "nofocus, class:^$, title:^$"
          ];
        };
      };
    };
  }; 

  environment.sessionVariables = {
	NIXOS_OZONE_WL = "1";              # Force Electron apps to use Wayland
	LIBVA_DRIVER_NAME = "iHD";         # Hardware acceleration
	WLR_NO_HARDWARE_CURSORS = "1";     # Fix for disappearing cursors on new Intel
	AQ_DRM_DEVICES = "/dev/dri/card0"; # force GPU selection
	WLR_DRM_NO_ATOMIC = "1";           # disable atomic handshake which is buggy on current xe+ lg hdmi
  };

  # Install firefox.
  programs.firefox.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  	vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  	unzip
	  vivaldi
    nixd
    nixfmt-rfc-style
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
 # environment.interactiveShellInit = ''
#	if [ "(tty)"="/dev/tty1" ]; then
#	  sleep 1
#	  exec Hyprland
#	fi
#	'';
  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "25.11"; # Did you read the comment?
}
