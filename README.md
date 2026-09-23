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

## makemkvcon Usage Information

### `--help` output

```
Use: makemkvcon [switches] Command [Parameters]

Commands:
  info <source>
      prints info about disc
  mkv <source> <title id> <destination folder>
      saves a single title to mkv file
  backup <source> <destination folder>
      backs up disc to a hard drive
  f <args>
      run universal firmware tool
  reg <key string or file name>
      enter registration key into program

Source specification:
  iso:<FileName>    - open iso image <FileName>
  file:<FolderName> - open files in folder <FolderName>
  disc:<DiscId>     - open disc with id <DiscId> (see list Command)
  dev:<DeviceName>  - open disc with OS device name <DeviceName>

  Switches:
  -r --robot        - turn on "robot" mode, see http://www.makemkv.com/developers

```

### Man Page: MAKEMKVCON

From [beandog's post](https://forum.makemkv.com/forum/viewtopic.php?p=120048&sid=362c5ff03aa92a0fec429548501f6a6a#p120048)

#### MAKEMKVCON
Section: \ \& (1)
Updated: 08/28/2022
Index Return to Main Contents  

#### NAME

makemkvcon - MakeMKV console application  

#### SYNOPSIS

`makemkvcon [OPTIONS] <backup|info|mkv> [PARAMETERS]`

#### DESCRIPTION

Command-line options for MakeMKV.

Configuration options and setup keys are located in `~/.MakeMKV/`

#### OPTIONS

##### General options:

* `--messages=FILE`

Output all messgaes to a file. Special file names: stdout, stderr, null. Default is to 

* `--progress=FILE`

Output all progress messages to a file. Special file names: stdout, stderr, null. Use -same to use --messages argument. Default is no output. 

* `--debug[=FILE]`

Enables debug messages. Optionally saves to output file. 

* `--directio=[true|false]`

Enables or disables direct disc access. 

* `--noscan`

Don`t access any media during disc scan and do not check for media insertion and removal. Helpful when other applications are already accessing discs in other drives. 

* `--cache=SIZE`

Specifies size of read cache in megabytes. By default program uses a huge amount of memory. About 128 MB is recommended for backup, 512MB for DVD conversion and 1024MB for Blu-ray conversion. 

* `-r, --robot`

Enables automation mode. Program will output more information in a format that is easier to parse. All output is line-based and output is flushed on line end. All strings are quoted, all control characters and quotes are backlash-escaped. If you automate this program it is highly recommended to use this option. Some options make reference to apdefs.h file that can be found in MakeMKV open-source package, included with version for Linux. These values will not change in future versions. 

##### Backup options:

* `--decrypt`

Decrypt stream files during backup. Default: no decryption. 

* `--minlength=SECONDS`

Specify minimum title length. Default: program preferences. 

 
#### COMMANDS

* `backup` Backup disc.

* `info` Display information about a disc.

* `mkv` Copy titles from disc.

* `f` Run universal firmware tool.

#### PARAMETERS

* `source iso:FILENAME`

Open ISO image. 

* `source file:DIRECTORY`

Open files in directory. 

* `source disc:DISC ID`

Open disc with ID. 

* `source dev:DEVICE`

Open disc with device name. 

 
#### EXAMPLES

* Copy all titles from first disc and save as MKV files into current directory:_
    `makemkvcon mkv disc:0 all .`

* List all available drives:__
    `makemkvcon -r --cache=1 info disc:9999`

* Backup first disc decrypting all video files in automation mode with progress output:_
    `makemkvcon backup --decrypt --cache=16 --noscan -r --progress=-same disc:0 .`

 
#### MESSAGE FORMATS

##### Message output

`MSG:code,flags,count,message,format,param0,param1,...`

* code - unique message code, should be used to identify particular string in language-neutral way.
* flags - message flags, see AP_UIMSG_xxx flags in apdefs.h
* count - number of parameters
* message - raw message string suitable for output
* format - format string used for message. This string is localized and subject to change* unlike message code.
* paramX - parameter for message

##### Current and total progress title

PRGC:code,id,name

PRGT:code,id,name

code - unique message code

id - operation sub-id

name - name string

##### Progress bar values for current and total progress

PRGV:current,total,max

current - current progress value

total - total progress value

max - maximum possible value for a progress bar, constant

##### Drive scan messages

DRV:index,visible,enabled,flags,drive name,disc name

index - drive index

visible - set to 1 if drive is present

enabled - set to 1 if drive is accessible

flags - media flags, see AP_DskFsFlagXXX in apdefs.h

drive name - drive name string

disc name - disc name string

Disc information output messages

TCOUT:count

count - titles count

##### Disc and title information

CINFO:id,code,value

TINFO:id,code,value

SINFO:id,code,value

id - attribute id, see AP_ItemAttributeId in apdefs.h

code - message code if attribute value is a constant string

value - attribute value

#### RESOURCES

* Console usage: https://www.makemkv.com/developers/usage.txt
* MakeMKV for Linux forum: https://www.makemkv.com/forum/viewforum.php?f=3
* Main web site: https://www.makemkv.com/
```



## References

* [MakeMKV](https://www.makemkv.com/)
* [MakeMKV Version 1.18.4 Release Announcement](https://forum.makemkv.com/forum/viewtopic.php?t=224)
* [FFMpeg](https://ffmpeg.org/)

* [Jellyfin](https://jellyfin.org/)
* [Jellyfin Software Container Image](https://jellyfin.org/docs/general/installation/container/)


