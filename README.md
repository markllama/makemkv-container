# Make MKV CLI in a minimal software container

This container image provides a tool to convert various video media to MKV format using
the [MakeMKV](https://makemkv.com) CLI tool, makemkvcon.


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
