{ config, pkgs, ... }:

{

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.consoleLogLevel = 1

  boot.kernelParams = [
    #"quiet" #Disable most log messages
    "splash" #splash screen
  ];


}
