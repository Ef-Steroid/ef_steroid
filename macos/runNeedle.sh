#!/bin/sh

export PATH="$PATH:/opt/homebrew/bin"

if which needle; then
  export SOURCEKIT_LOGGING=0 && needle generate Runner/Services/ServiceLocator.generated.swift Runner/
else
  echo "warning: Needle not installed, download from https://github.com/uber/needle using Homebrew"
fi
