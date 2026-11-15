# Discover correct socket for ssh-tpm-agent
export SSH_AUTH_SOCK="$(ssh-tpm-agent --print-socket)"