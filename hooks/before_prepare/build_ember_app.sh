#!/bin/bash
if [[ $CORDOVA_CMDLINE =~ release ]]; then
  echo "Creating production build of ember app"
  ./node_modules/ember-cli/bin/ember build --environment=production
else
  echo "Creating debug build of ember app"
  ./node_modules/ember-cli/bin/ember build
fi
