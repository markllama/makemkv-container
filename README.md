# Make MKV CLI in a minimal software container

This container image provides a tool to convert various video media to MKV format using
the [MakeMKV](https://makemkv.com) CLI tool, makemkvcon.

The goal is to make it easier to create a fully containerized Jellyfin service hosted on
an immutable OS such as Fedora CoreOS. Jellyfin itself is already containerized. The container
image created here is meant to be a component of a video stream 

## Invocation

INPUTS:

* License Key
* Mode (info|mkv|backup)
* Input Stream (iso|file|disc:dev)
* Input Format
* Output Stream (optional)

```
podman run quay.io/markllama/makemkv -v <key file>:/settings.conf -v <input>
```

## Build Details

## References

* [MakeMKV](https://www.makemkv.com/)
* [MakeMKV Version 1.18.4 Release Announcement](https://forum.makemkv.com/forum/viewtopic.php?t=224)
* [FFMpeg](https://ffmpeg.org/)

* [Jellyfin](https://jellyfin.org/)
* [Jellyfin Software Container Image](https://jellyfin.org/docs/general/installation/container/)


