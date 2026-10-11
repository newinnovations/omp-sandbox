FROM buildpack-deps:trixie

ARG USERNAME=pi
ARG GROUPNAME=pi
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        sudo \
        ripgrep \
        vim \
        clang \
        libgtk-4-dev

# Create the user and group for the development environment
RUN /sbin/groupadd --gid $USER_GID $GROUPNAME \
    && /sbin/useradd --uid $USER_UID --gid $USER_GID -m -g $GROUPNAME $USERNAME \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Copy the entrypoint script and other scripts into the image
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY toolchain.sh /usr/local/bin/update-toolchain

# Make a copy of the home directory's configuration files
RUN echo "PATH=/home/$USERNAME/.local/bin:$PATH" >> "/home/$USERNAME/.bashrc" \
    && mkdir -p /seed/home/$USERNAME \
    && cp -a /home/$USERNAME/. /seed/home/$USERNAME/. \
    && chmod +x /usr/local/bin/*

# Ensure the container runs as the specified user
USER $USERNAME

ENV TZ="Europe/Amsterdam"
ENV NVM_DIR=/home/$USERNAME/.nvm

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/bin/bash"]