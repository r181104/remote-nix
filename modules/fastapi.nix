{
  config,
  pkgs,
  lib,
  ...
}: let
  python = pkgs.python314;
in {
  environment.systemPackages = with pkgs; [
    python
    git
  ];

  users.groups.fastapi = {};
  users.users.fastapi = {
    isSystemUser = true;
    createHome = false;
    description = "FastAPI app user";
    group = "fastapi";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/fastapi 0750 fastapi fastapi - -"
  ];

  # add/replace in your module fastapi.nix
  systemd.services.fastapi-app = {
    enable = true;
    description = "FastAPI example app (uvicorn)";
    wantedBy = ["multi-user.target"]; # optional top-level - nix will set install.wantedBy automatically if present
    serviceConfig = {
      User = "fastapi";
      Group = "fastapi";
      WorkingDirectory = "/var/lib/fastapi";
      ExecStart = "/var/lib/fastapi/venv/bin/uvicorn app:app --app-dir /var/lib/fastapi --host 127.0.0.1 --port 8000 --lifespan off";
      Restart = "on-failure";
      Environment = "PYTHONUNBUFFERED=1";
    };
    preStart = ''
      mkdir -p /var/lib/fastapi
      chown -R fastapi:fastapi /var/lib/fastapi
    '';
    install.wantedBy = ["multi-user.target"]; # ensures `systemctl enable` behaves as expected
  };
}
