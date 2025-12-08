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

  systemd.services.fastapi-app = {
    enable = true;
    description = "FastAPI example app (uvicorn)";
    wants = ["network.target"];
    after = ["network.target"];

    serviceConfig = {
      User = "fastapi";
      Group = "fastapi";
      Restart = "on-failure";
      Environment = "PYTHONUNBUFFERED=1 PYTHONPATH=/var/lib/fastapi";
      WorkingDirectory = "/var/lib/fastapi";
    };

    preStart = ''
      if [ ! -d /var/lib/fastapi ]; then
        mkdir -p /var/lib/fastapi
        if [ ! -d /var/lib/fastapi ]; then
          echo "Cannot create /var/lib/fastapi" >&2
          exit 1
        fi
      fi

      if [ ! -d /var/lib/fastapi/venv ]; then
        ${python.interpreter} -m venv /var/lib/fastapi/venv
        /var/lib/fastapi/venv/bin/pip install --upgrade pip setuptools
        /var/lib/fastapi/venv/bin/pip install fastapi uvicorn
      fi
    '';
    serviceConfig.ExecStart = "/var/lib/fastapi/venv/bin/uvicorn app:app --host 127.0.0.1 --port 8000 --lifespan off";
  };
}
