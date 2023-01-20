# Install Tuist.
if ! [[ -x $(command -v tuist) ]]; then
  echo "Tuist is not installed."
  curl -Ls https://install.tuist.io | bash
fi

# Run Tuist.
tuist generate
