# This Dockerfile creates a Debian-based SSH server with:
# - A user 'bas' with sudo rights
# - SSH key-based authentication only (password auth disabled)
# - A mounted todo directory
# - Host keys generated on first start
#
# To use:
# 1. Build: docker build -t debian-ssh .
# 2. Run:   docker run -d --name Debian-ssh -p 2222:22 -v /path/to/todo:/home/bas/todo debian-ssh
#
# To add your SSH key:
# 1. Copy your public key (usually ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub)
# 2. Add it to the authorized_keys file in this directory
# 3. Rebuild the container
#
# Note: Host keys are generated on first container start.
# They will persist as long as the container exists.
# If you remove the container, new host keys will be generated.

FROM debian:latest

# Update en installeer SSH
RUN apt-get update && apt-get install -y openssh-server sudo pwgen

# Maak gebruiker 'bas' en geef sudo-rechten
RUN export PART1=$(pwgen -A0 6 1) && \
    export PART2=$(pwgen -A0 6 1) && \
    export PART3=$(pwgen -A0 6 1) && \
    export PASS="$PART1-$PART2-$PART3" && \
    useradd -m -s /bin/bash bas && \
    echo "bas:$PASS" | chpasswd && \
    usermod -aG sudo bas && \
    echo "Generated password for user 'bas': $PASS" && \
    echo "IMPORTANT: Save this password if needed. Even though SSH password login is disabled, this password might be needed for sudo."

# Configureer SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

# Create todo directory
RUN mkdir -p /home/bas/todo && \
    chown -R bas:bas /home/bas/todo

# Set up SSH keys
RUN mkdir -p /home/bas/.ssh
COPY authorized_keys /home/bas/.ssh/authorized_keys
RUN chown -R bas:bas /home/bas/.ssh && \
    chmod 700 /home/bas/.ssh && \
    chmod 600 /home/bas/.ssh/authorized_keys

# Create script to generate host keys on first start
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Generate host keys if they do not exist\n\
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then\n\
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""\n\
fi\n\
if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then\n\
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""\n\
fi\n\
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then\n\
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""\n\
fi\n\
\n\
# Start SSH daemon\n\
exec "$@"' > /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Start SSH-service using the entrypoint script
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
