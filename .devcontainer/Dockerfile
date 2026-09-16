# https://mcr.microsoft.com/v2/devcontainers/cpp/tags/list
FROM mcr.microsoft.com/devcontainers/cpp:3.0.5-trixie
RUN apt-get update && apt-get install --yes --no-install-recommends \
  chromium \
  clang-format \
  clang-tidy \
  clangd \
  fonts-liberation2 \
  jq \
  libffi-dev \
  libgmp-dev \
  libncurses-dev \
  libsdl2-dev \
  tmux \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  && rm -rf /var/lib/apt/lists/*
# Chromium on the desktop: without this, it asks to create a GNOME Keyring password
RUN printf '%s\n' '# Keep saved passwords in the profile, not GNOME Keyring (which asks for a keyring password)' \
    'export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --password-store=basic"' > /etc/chromium.d/password-store
# In /etc/zsh, not ~/.zshrc, which is hidden by the home volume
RUN echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> /etc/zsh/zshrc
# oh-my-zsh settings for vscode and root, and zsh as their login shell (used by
# editors without their own shell setting, e.g. Zed, and by sudo su -).
# /home/vscode is a volume, so vscode's settings only reach a new home volume
RUN for home in /root /home/vscode; do \
    sed -i -e 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' \
      -e 's/^plugins=.*/plugins=(git zsh-syntax-highlighting)/' "$home/.zshrc" \
    && printf '%s\n' '' '# agnoster: show the user only when it is root, in red' \
      'prompt_context() {' \
      '  if [[ $UID -eq 0 ]]; then' \
      '    prompt_segment red black "%n"' \
      '  fi' \
      '}' >> "$home/.zshrc" \
    && mkdir -p "$home/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
    && echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' \
      > "$home/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" \
    || exit 1; \
  done \
  && chown -R vscode:vscode /home/vscode/.zshrc /home/vscode/.oh-my-zsh/custom \
  && chsh -s /usr/bin/zsh root \
  && chsh -s /usr/bin/zsh vscode
# Haskell as on the course's setup page: GHC, cabal, HLS and QuickCheck from ghcup.
# In /opt, because the home volume hides ~/.ghcup and ~/.cabal. Owned by vscode,
# so ghcup install and cabal install still work without sudo
ENV GHCUP_INSTALL_BASE_PREFIX=/opt \
  CABAL_DIR=/opt/cabal \
  PATH=/opt/.ghcup/bin:$PATH
RUN install -d -o vscode -g vscode /opt/.ghcup /opt/.ghcup/bin /opt/cabal
USER vscode
# HLS ships a server for each GHC version (500 MB each): keep only ours
RUN curl --proto '=https' --tlsv1.2 -sSfL -o /opt/.ghcup/bin/ghcup \
    "https://downloads.haskell.org/~ghcup/0.2.6.2/$(uname -m)-linux-ghcup-0.2.6.2" \
  && chmod +x /opt/.ghcup/bin/ghcup \
  && ghcup install ghc --set 9.14.1 \
  && ghcup install cabal --set 3.16.1.0 \
  && ghcup install hls --set 2.14.0.0 \
  && find /opt/.ghcup/hls -name 'haskell-language-server-9*' ! -name '*-9.14.1' -delete \
  && find /opt/.ghcup/hls/*/lib/*/lib -mindepth 1 -maxdepth 1 ! -name 9.14.1 -exec rm -rf {} + \
  && find /opt/.ghcup/bin -xtype l -delete \
  && ghcup gc --profiling-libs --cache --tmpdirs
# cabal install --lib records packages in ~/.ghc, also hidden by the home volume,
# so register QuickCheck and its dependencies in GHC's global package database.
# The package index is pinned to a date, so rebuilds get the same versions
RUN cabal update 'hackage.haskell.org,2026-09-16T00:00:00Z' \
  && env=$(mktemp) \
  && cabal install --lib QuickCheck --package-env "$env" \
  && rm "$env" \
  && cp /opt/cabal/store/ghc-*/package.db/*.conf "$(ghc --print-libdir)/package.conf.d/" \
  && ghc-pkg --global recache
USER root
# Fourmolu formats Haskell code: HLS for GHC 9.14 has no formatter built in
RUN arch=$(uname -m | sed 's/aarch64/arm64/') \
  && curl --proto '=https' --tlsv1.2 -sSfL -o /tmp/fourmolu.zip \
    "https://github.com/fourmolu/fourmolu/releases/download/v0.20.1.0/fourmolu-0.20.1.0-linux-$arch.zip" \
  && unzip -j /tmp/fourmolu.zip -d /usr/local/bin \
  && rm /tmp/fourmolu.zip
RUN ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime \
  && echo Europe/London > /etc/timezone
