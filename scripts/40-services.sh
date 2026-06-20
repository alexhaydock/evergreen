#!/usr/bin/env bash

set -ouex pipefail

systemctl preset-all
systemctl --global preset-all
