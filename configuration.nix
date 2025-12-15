{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: let
  pkgs = import (fetchTarball {
    url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
  }) {};
  unstable = import (fetchTarball {
    url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  }) {};
in {
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
    ./modules/base.nix
  ];

  networking.hostName = "remote-nix";
  users.users.sten = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = ["wheel"];
    description = "sten";
  };

  environment.shells = with pkgs; [bash];
  environment.systemPackages = with pkgs; [
    curl
    git
    unstable.neovim
  ];

  programs.bash = {
    enable = true;
    completion.enable = true;

    shellAliases = {
      rebuild = "nixos-rebuild switch";
      # ls (safe defaults)
      ls = "ls --color=auto";
      ll = "ls -lah --color=auto";
      la = "ls -A --color=auto";
      l = "ls -CF --color=auto";

      # navigation
      home = "cd ~";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      pd = "cd -";

      # misc
      c = "clear";
      d = "cd";
      h = "history | grep";
      p = "ps aux | grep";
      less = "less -R";

      # editors
      n = "nvim";
      sn = "sudo nvim";
      v = "vim";
      sv = "sudo vim";
      nv = "neovide";
      snd = "sudo neovide";

      # tmux
      tns = "tmux new -s";
      ta = "tmux attach";
      td = "tmux detach";

      # networking / system
      myip = "curl ifconfig.me";
      ping = "ping -c 5";
      openports = "ss -tulpen";
      reboot = "systemctl reboot";
      shutdown = "shutdown now";
      restart-dm = "sudo systemctl restart display-manager";

      # disk / fs
      mkdir = "mkdir -p";
      cp = "cp -iv";
      cpr = "cp -r";
      rmd = "rm -rfv";
      mx = "chmod a+x";

      # safer chmod aliases (explicit)
      chmod644 = "chmod -R 644";
      chmod755 = "chmod -R 755";
      chmod777 = "chmod -R 777";

      # utils
      topcpu = "ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10";
      diskspace = "du -S | sort -n -r | less";
      folders = "du -h --max-depth=1";
      mountedinfo = "df -hT";
      duf = "duf -hide special";
      sha1 = "openssl sha1";
      own = "sudo chown -R $USER";
      fetch = "fastfetch -c my.jsonc";
      open = "xdg-open";
    };

    promptInit = ''
      __kali_ps1() {
        GREEN="\[\e[1;32m\]"
        BLUE="\[\e[1;34m\]"
        RED="\[\e[1;31m\]"
        RESET="\[\e[0m\]"

        if [ "$EUID" -eq 0 ]; then
          COLOR="$RED"
          SYMBOL="#"
        else
          COLOR="$GREEN"
          SYMBOL="$"
        fi

        IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
        [ -z "$IP" ] && IP="no-ip"

        PS1="┌──$COLOR(\u㉿$IP)$RESET-$BLUE[\w]$RESET\n└─$COLOR$SYMBOL$RESET "
      }

      PROMPT_COMMAND=__kali_ps1

      # Kali-like history behavior
      HISTCONTROL=ignoreboth
      HISTSIZE=1000
      HISTFILESIZE=2000
      shopt -s histappend
      shopt -s checkwinsize

      export LESS="-R"
    '';
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  systemd.tmpfiles.rules = ["d /swap 0755 root root -"];
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 4096;
    }
  ];
  system.stateVersion = "25.11";
}
