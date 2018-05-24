#!/usr/bin/env bash

set -euo pipefail

Ninja_URL=""
CMake_VERSION="3.11.2"
CMake_URL=""
# OS-dependent operations
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
  CMake_URL="https://cmake.org/files/v${CMake_VERSION%.*}/cmake-${CMake_VERSION}-Linux-x86_64.tar.gz"
  Ninja_URL="https://goo.gl/4g5Jjv"
  echo "-- Installing CMake $CMake_VERSION"
  if [[ -f $HOME/Deps/cmake/bin/cmake ]]; then
    echo "-- CMake $CMake_VERSION FOUND in cache"
  else
    echo "-- CMake $CMake_VERSION NOT FOUND in cache"
    cd $HOME/Deps
    mkdir -p cmake
    curl -Ls $CMake_URL | tar -xz -C cmake --strip-components=1
    cd $TRAVIS_BUILD_DIR
  fi
  echo "-- Done with CMake"
elif [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update &> /dev/null
  brew cask uninstall --force oclint
  brew uninstall --force --ignore-dependencies boost
  brew install gcc pkg-config ossp-uuid
  brew upgrade cmake
  Ninja_URL="https://goo.gl/qLgScp"
fi

echo "-- Installing Ninja"
if [[ -f $HOME/Deps/ninja/ninja ]]; then
  echo "-- Ninja FOUND in cache"
else
  echo "-- Ninja NOT FOUND in cache"
  cd $HOME/Deps
  mkdir -p ninja
  curl -Ls $Ninja_URL | tar -xz -C ninja --strip-components=1
  cd $TRAVIS_BUILD_DIR
fi
echo "-- Done with Ninja"

cd $TRAVIS_BUILD_DIR
