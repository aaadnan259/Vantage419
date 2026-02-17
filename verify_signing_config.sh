#!/bin/bash

# Check if android/app/build.gradle.kts contains the vulnerable pattern
if grep -q 'signingConfigs.getByName("debug")' android/app/build.gradle.kts; then
  echo "❌ Vulnerability found: Release signing config is set to debug in android/app/build.gradle.kts"
  exit 1
else
  echo "✅ Vulnerability check passed: Release signing config is not set to debug."
  exit 0
fi
