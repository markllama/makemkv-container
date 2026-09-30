# make it easier to use pkg specific variant functions
function set_os_id() {
    eval "export $(grep -e '^ID=' /etc/os-release)"
}

function prepare_model_tree() {
    local model_root=$1

    [ -d ${model_root}/usr/bin ] || mkdir -p ${model_root}/usr/bin
    [ -d ${model_root}/usr/lib ] || mkdir -p ${model_root}/usr/lib
}

# Generate a list of dynamically linked binaries under a file root
function find_dynamic_binaries() {
    local model_root=$1

    [ -z "${DEBUG}" ] || echo "discovering dynamic binaries in ${model_root}" >&2

    find ${model_root} -type f |
	xargs file | grep executable |
	grep 'dynamically linked' |
	cut -d: -f1
}

# Generate a list of dynamic libraries required by a matching list of
# dynamically linked binaries
function find_dynamic_libraries() {
#
# find shared libraries linked to the specified binary
#
    local library_path=$1
    shift
    local binaries=$*

    [ -z "${DEBUG}" ] || echo "discovering shared libraries on ${binary}" >&2

    # Select Only lines with filenames and only one file path
    LD_LIBRARY_PATH="${library_path}" ldd ${binaries} |
	grep '=>' |
        sed 's/^.*=> //' |
	cut -d' ' -f1 |
	grep -v ${MODEL_ROOT} |
	sort -u

}

function resolve_packages() {
    local libraries="$*"
    
    # Accumulate the list of packages that provide the required libraries
    declare -a pkgs
    local library_file
    for library_file in $libraries ; do
    	pkgs+=($(find_file_package $library_file))
    done
    # Remove any duplicates
    echo ${pkgs[@]} | tr ' ' '\n' | sort -u

}

# Determine what package provides a given file
function find_file_package() {
    local filename=$1

    case ${ID} in
	fedora | redhat | centos)
	    rpm -qf --qf "%{NAME}\n" ${filename}
	    ;;

	debian | ubuntu)
	    # debian resolves to /lib* but the package installs /usr/lib*
	    # dpkg --search /usr${filename} | cut -d: -f1
	    [[ "${filename}" =~ ^/lib/ ]] && filename="/usr${filename}"
	     dpkg --search ${filename} | cut -d: -f1
	     ;;

	*)
	    echo "FATAL: OS not supported: ${OS_ID}.  Valid: debian | ubuntu | fedora | redhat" >&2
	    exit 1
	    ;;
    esac
}

# Download a package to a given location
function download_package() {
    local package_dir=$1
    local package_name=$2

    case ${ID} in
	fedora | redhat | centos)
	    dnf download --quiet --arch ${PACKAGE_ARCH} --destdir ${package_dir} ${package_name}
	    ;;

	debian | ubuntu)
	    (cd ${package_dir} ; apt-get download ${package_name})
	    ;;

	*)
	    echo "FATAL: OS not supported: ${OS_ID}.  Valid: debian | ubuntu | fedora | redhat" >&2
	    exit 1
	    ;;
    esac
}

#
# Unpack a package into a working directory
#
function unpack_package() {
    local package_filename=$1
    local unpack_root=$2

    case ${ID} in
	fedora | redhat | centos)
	    rpm2cpio ${package_filename} | cpio -idmu --quiet --directory ${unpack_root}
	    ;;
	debian | ubuntu)
	    dpkg-deb --extract ${package_filename} ${unpack_root}
	    ;;
	*)
	    echo "FATAL: OS not supported: ${OS_ID}.  Valid: debian | ubuntu | fedora | redhat" >&2
	    exit 1
	    ;;
    esac
}

function populate_libraries() {
    local unpack_root=$1
    local resolved_root=$2
    shift ; shift
    local libraries=$*

    local libdir=${resolved_root}/usr/lib
    mkdir -p ${libdir}
    
    # Copy the required library files to the model
    local library_file
    for library_file in $libraries ; do
	cp ${unpack_root}${library_file} ${libdir}
    done
}
