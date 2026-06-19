# See: https://github.com/secureblue/secureblue/blob/495468f595430210167af52bfdd16c8ca1d0badd/files/scripts/removesudo.sh
# See: https://github.com/secureblue/secureblue/blob/495468f595430210167af52bfdd16c8ca1d0badd/files/scripts/unprotectsudo.sh

#!/usr/bin/env bash

set -euo pipefail

rm -f /etc/dnf/protected.d/sudo.conf

dnf remove -y --setopt=protected_packages=, sudo

rm -rf /usr/bin/sudo
