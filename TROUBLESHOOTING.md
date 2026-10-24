## Troubleshooting

### Flatpaks not preinstalled after bootc switch
If Flatpaks added to the preinstall files in `/etc/flatpak/preinstall.d/*.preinstall` do not get automatically installed after a `bootc switch`, check that the `flatpak-preinstall.service` has not exited with any errors. A `systemctl restart flatpak-preinstall.service` may help.
