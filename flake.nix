{
  description ="Sebo Darwin system flake";

  # NOTE before reinstalling System
  # - be sure config-files are up-to-date and pushed: nix, neovim
  # - export cold-turkey-blocker sites and application files
  #
  # To update nix:
  # nix flake update
  # To run config:
  # nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/nix#SebBook

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url ="github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;

      # NOTE
      # Packages to install manually:
      # PyCharm Professional
      # IntelliJ IDEA Ultimate
      # Cold-Turkey-Blocker
      # Micromanager Pro:# - https://vendors.paddle.com/download/product/6d5ecd31-628b-4d12-a672-9ab7e11c708e
      # Writer Pro:# - https://vendors.paddle.com/download/product/601195
      # fzf-git:# - git clone https://github.com/junegunn/fzf-git.sh.git

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
          pkgs.bat
          # pkgs.bitwarden-cli
          pkgs.eza
          pkgs.fd
          pkgs.fzf
          pkgs.git
          pkgs.go
          pkgs.lazygit
          pkgs.mas
          pkgs.mkalias
          pkgs.neovim
          pkgs.oh-my-posh
          pkgs.php
          pkgs.pngpaste
          pkgs.ripgrep
          pkgs.thefuck
          pkgs.tree-sitter
          pkgs.typst
          pkgs.wget
          # pkgs.zsh-autosuggestions
          # pkgs.zsh-syntax-highlighting
          pkgs.zoxide
        ];

      homebrew ={
        enable = true;
      	brews =[
          # "bat"
          "bitwarden-cli"
          "ffmpeg"
          "java"
          "julia"
          "node"
          "rust"
          "zsh-autosuggestions"
          "zsh-syntax-highlighting"
        ];
    	  casks =[
          "arc"
          "docker"
          "cleanmymac"
          # "ea"
          "font-maple-mono" # beautiful, but has no nerd-fonts compatibility
          "forklift"
          "iterm2"
          "inkscape"
          "inkstitch"
          "jetbrains-toolbox"
          "karabiner-elements"
          "lookaway"
          "logi-options+"
          "mactex"
          "makemkv"
          # "microsoft-edge"
          "microsoft-teams"
          "mkvtoolnix" # needs Rosetta2
          "monitorcontrol"
          "obsidian"
          "plex"
          "prusaslicer"
          "postman"
	        "raspberry-pi-imager"
          "raycast"
          "skim"
          "the-unarchiver"
          "tunnelblick"
          "ultimaker-cura"
          "zotero"
        ];
      	masApps ={
          "AdGuard for Safari" = 1440147259;
          "Apple Developer"= 640199958;
          "Affinity Designer 2"= 1616831348;
          "Bitwarden"= 1352778147;
          "CapCut" = 1500855883;
          "Compressor"= 424390742;
          "Darkroom"= 953286746;
          "DevCleaner for Xcode" = 1388020431;
          "eduVPN"= 1317704208;
          "Final Cut Pro"= 424389933;
          "Infuse"= 1136220934;
          "Logic Pro"= 634148309;
          "Microsoft Excel"= 462058435;
          "Numbers"= 409203825;
          "One Sec"= 1532875441;
          "PDF Expert"= 1055273043;
          "Social Focus"= 1661093205;
          "Vimlike"= 1584519802;
          "Xcode"= 497799835;
        };
      	onActivation.autoUpdate = true;
      	onActivation.upgrade = true;
        onActivation.cleanup ="zap";
      };

      fonts.packages = with pkgs; [ 
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ];

      # System defaults: 
      # - https://macos-defaults.com/
      # - https://nix-darwin.github.io/nix-darwin/manual/index.html
      system.defaults = {
        dock = {
          autohide = true;
      	  autohide-delay = 0.0;
      	  autohide-time-modifier = 0.0;
      	  magnification = false;
      	  mineffect ="scale";
      	  orientation ="left";
      	  mru-spaces = false;
      	  persistent-apps =[
      	    "/System/Applications/Launchpad.app"
      	    "/Applications/ForkLift.app"
            "Applications/Arc.app"
      	    # "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
      	    "/System/Applications/Mail.app"
      	    "/System/Applications/Calendar.app"
      	    "/System/Applications/Reminders.app"
      	    "/Applications/Obsidian.app"
            "/Applications/Zotero.app"
            "/Applications/iTerm.app"
      	    "/System/Applications/Music.app"
      	    "/System/Applications/System Settings.app"
          ];
      	  show-recents = false;
      	  showhidden = true;
        };
        NSGlobalDomain = {
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
          ApplePressAndHoldEnabled = false;
        };
          finder.FXPreferredViewStyle ="Column";
          universalaccess.reduceMotion = true;
      };
      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;
      #programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      security.pam.services.sudo_local.touchIdAuth = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."SebBook"= nix-darwin.lib.darwinSystem{
      modules =[
        configuration
        nix-homebrew.darwinModules.nix-homebrew{
          nix-homebrew ={
            enable = true;
            user ="sebastianbecker";
          };
        }
      ];
    };
    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."simple".pkgs;
  };
}
