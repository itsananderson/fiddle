#!/bin/bash

set -e

if [[ ! -z $MACOS_CERT_P12 ]]
then

  export CERTIFICATE_P12=cert.p12;
  echo $MACOS_CERT_P12 | base64 --decode > $CERTIFICATE_P12;
  export KEYCHAIN=build.keychain;

  # Create the keychain with a password
  security create-keychain -p travis $KEYCHAIN;

  # Make the custom keychain default, so xcodebuild will use it for signing
  security default-keychain -s $KEYCHAIN;

  # Unlock the keychain
  security unlock-keychain -p travis $KEYCHAIN;

  # Add certificates to keychain and allow codesign to access them
  # Apple Worldwide Developer Relations Certification Authority
  security import ./tools/certs/apple.cer -k ~/Library/Keychains/$KEYCHAIN -T /usr/bin/codesign
  # Developer Authentication Certification Authority
  security import ./tools/certs/dac.cer -k ~/Library/Keychains/$KEYCHAIN -T /usr/bin/codesign
  # Developer ID Felix
  security import $CERTIFICATE_P12 -k $KEYCHAIN -P $MACOS_CERT_PASSWORD -T /usr/bin/codesign 2>&1 >/dev/null;
  rm $CERTIFICATE_P12;

  security set-key-partition-list -S apple-tool:,apple: -s -k travis $KEYCHAIN

  # Echo the identity
  security find-identity -v -p codesigning
fi