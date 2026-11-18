{ lib, ... }:
{
  # Temporary: turn HTTP/2 off on every nginx virtual host, on the node hosts
  # and on the web hosts alike, until nginx is upgraded past the HTTP/2 CVEs
  # CVE-2026-123633 (use-after-free) and CVE-2026-123007 (send_window integer
  # underflow), written up in
  # https://www.wiz.io/blog/nginx-http2-rce-vulnerabilities
  #
  # Both need HTTP/2 to be reachable, so turning it off is the workaround that
  # write-up names for the time before the upgrade. nixpkgs currently gives us
  # nginx 1.30.6, which is affected; the fixes are in 1.30.7 stable and 1.31.9
  # mainline.
  #
  # This extends the type of `services.nginx.virtualHosts` instead of setting
  # the hosts in `config`. That way it also covers the virtual hosts a user of
  # this library defines themselves, e.g. when overwriting the default domain
  # vhost to put FULL_ACCESS behind authentication. Reading the attribute set
  # to rewrite it in `config` would be a cycle.
  #
  # `mkForce` so the virtual hosts we define ourselves don't need touching and
  # a user's own definition can't accidentally turn HTTP/2 back on.
  #
  # Remove this file and its entry in lib.nix once nginx is 1.30.7 or newer.
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config.http2 = lib.mkForce false;
      }
    );
  };
}
