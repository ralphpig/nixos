# Pinned apps, in order: GNOME's dash (./gnome) and Dux Shell's dock (./dux).
# Desktop file names; installed ones are in
# /etc/profiles/per-user/$USER/share/applications and
# /run/current-system/sw/share/applications, PWAs in
# ~/.local/share/applications.
[
  "org.gnome.Nautilus.desktop"
  "com.mitchellh.ghostty.desktop"
  "dev.zed.Zed.desktop"
  "sublime_merge.desktop"
  "insomnia.desktop"
  "microsoft-edge.desktop"
  "msedge-ompifgpmddkgmclendfeacglnodjjndh-Default.desktop" # Teams
  "spotifast.desktop"
  # Edge PWAs (Apps > Install this site as an app). The id is per install:
  # after reinstalling one, look up the new file name with
  #   grep -H '^Name=' ~/.local/share/applications/msedge-*.desktop
  # "msedge-jnpecgipniidlgicjocehkhajgdnjekh-Default.desktop" # Protonmail; not installed
  "msedge-agimnkijcaahngcdmfeangaknmldooml-Default.desktop" # YouTube
  "msedge-ifpboanaelncmlfhjbnnloipmogocahb-Default.desktop" # WorkFlowy
]
