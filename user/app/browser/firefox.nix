{ pkgs, userSettings, ... }:

{
  # Module installing firefox as default browser
  home.packages = if (userSettings.desktopType == "wayland") then [ pkgs.firefox-wayland ]
                else [ pkgs.firefox ];

  home.sessionVariables = if (userSettings.desktopType == "wayland")
                            then { DEFAULT_BROWSER = "${pkgs.firefox-wayland}/bin/firefox";}
                          else
                            { DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";};

  home.file.".mozilla/firefox.overrides.cfg".text = ''
    defaultPref("font.name.serif.x-western","''+userSettings.font+''");

    defaultPref("font.size.variable.x-western",20);
    defaultPref("browser.toolbars.bookmarks.visibility","always");
    defaultPref("privacy.resisttFingerprinting.letterboxing", true);
    defaultPref("network.http.referer.XOriginPolicy",2);
    defaultPref("privacy.clearOnShutdown.history",false);
    defaultPref("privacy.clearOnShutdown.downloads",true);
    defaultPref("privacy.clearOnShutdown.cookies",false);
    defaultPref("gfx.webrender.software.opengl",true);
    defaultPref("webgl.disabled",false);
    pref("font.name.serif.x-western","''+userSettings.font+''");

    pref("font.size.variable.x-western",20);
    pref("browser.toolbars.bookmarks.visibility","always");
    pref("privacy.resisttFingerprinting.letterboxing", true);
    pref("network.http.referer.XOriginPolicy",2);
    pref("privacy.clearOnShutdown.history",false);
    pref("privacy.clearOnShutdown.downloads",true);
    pref("privacy.clearOnShutdown.cookies",false);
    pref("gfx.webrender.software.opengl",true);
    pref("webgl.disabled",false);
    '';

  xdg.mimeApps.defaultApplications = {
  "text/html" = "firefox.desktop";
  "x-scheme-handler/http" = "firefox.desktop";
  "x-scheme-handler/https" = "firefox.desktop";
  "x-scheme-handler/about" = "firefox.desktop";
  "x-scheme-handler/unknown" = "firefox.desktop";
  };

}
