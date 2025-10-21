#!/bin/bash
# Create Xcode project for DirectorStudio

# Generate Xcode project from Package.swift
swift package generate-xcodeproj

echo "✅ Xcode project created! Open DirectorStudio.xcodeproj"
