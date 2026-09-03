#!/bin/bash
#
#
# This script assumes that the MakeMKV artifacts have been downloaded and built in
# sub directories under the current working directory.
#
MAKEMKV_VERSION=1.18.4

# Create a new working container
container=$(buildah from scratch)

# mount a space in the container and report the path
scratchmnt=$(buildah mount container)
echo $scratchmnt

# commit the container for test and publication
buildah commit ${container} makemkvcli:latest
