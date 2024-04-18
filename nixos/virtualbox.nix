{
  users.extraGroups.vboxusers.members = ["user-with-access-to-virtualbox"];

  nixpkgs.config.allowUnfree = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  environment.systemPackages = [
    pkgs.virtualbox
  ];
}
