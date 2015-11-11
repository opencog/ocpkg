#!/usr/bin/env bash
#
#Designed for Debian Jessie.
#This script installs dependencies, downloads OpenCog from Github, compiles and installs it, and leaves the build environment.
#Script also allows for building with Moses.
#Author: Noah Bliss
#Last editor: 
#Last updated on: 11/11/2015

#Prompt for root
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

#Add menu here. Skip menu if variables were attached when run. 
#1.) Just install dependencies. Prompt to download OpenCog from Github at the end.
#2.) Dependencies, then install OpenCog without MOSES
#3.) Dependencies, OpenCog with MOSES.
