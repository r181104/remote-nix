{
  config,
  pkgs,
  lib,
  ...
}: let
  python = pkgs.python314;
  pyPkgs = pkgs.python314Packages;
in {
  environment.systemPackages = with pkgs; [
    python
    pyPkgs.virtualenv
    git
  ];

  users.groups.fastapi = {};
  users.users.fastapi = {
    isSystemUser = true;
    createHome = false;
    description = "FastAPI app user";
    group = "fastapi";
  };

  systemd.services.fastapi-app = {
    description = "FastAPI example app (uvicorn)";
    wants = ["network.target"];
    after = ["network.target"];

    serviceConfig = {
      User = "fastapi";
      Group = "fastapi";
      Restart = "on-failure";
      Environment = "PYTHONUNBUFFERED=1";
    };

    preStart = ''
      mkdir -p /var/lib/fastapi
      chown -R fastapi:fastapi /var/lib/fastapi

      if [ ! -d /var/lib/fastapi/venv ]; then
        ${python.interpreter} -m venv /var/lib/fastapi/venv
        /var/lib/fastapi/venv/bin/pip install --upgrade pip setuptools
        /var/lib/fastapi/venv/bin/pip install fastapi uvicorn
      fi
    '';

    serviceConfig.ExecStart = "/var/lib/fastapi/venv/bin/uvicorn app:app --host 127.0.0.1 --port 8000 --lifespan off";
  };
}
