#!/bin/bash

mkdir -vp ${PREFIX}/bin;

ARCH="$(uname 2>/dev/null)"

export CFLAGS="-m64 -pipe -O2 -march=x86-64 -fPIC"
export CXXLAGS="${CFLAGS}"
#export CPPFLAGS="-I${PREFIX}/include"
#export LDFLAGS="-L${PREFIX}/lib64"

LinuxInstallation() {
    # Build dependencies:
    # - wxGTK-devel
    # - wxBase
    # - SDL-devel
    # - gstreamer-devel
    # - gstreamer-plugins-base-devel

    chmod +x configure;

    ./configure \
        --enable-utf8 \
        --enable-sound \
        --enable-unicode \
        --enable-monolithic \
        --enable-rpath='$ORIGIN/../lib' \
        --with-gtk \
        --with-sdl \
        --with-expat=builtin \
        --with-libjpeg=builtin \
        --with-libpng=builtin \
        --with-libtiff=builtin \
        --with-regex=builtin \
        --with-zlib=builtin \
        --prefix="${PREFIX}" || return 1;
    make || return 1;
    make install || return 1;

    pushd wxPython/;
    ${PYTHON} -u ./setup.py install UNICODE=1 BUILD_BASE=build WX_CONFIG="${PREFIX}/bin/wx-config --prefix=${PREFIX}" \
        --record installed_files.txt --prefix="${PREFIX}" || return 1;
    popd;

    return 0;
}

case ${ARCH} in
    'Linux')
        LinuxInstallation || exit 1;
        ;;
    *)
        echo -e "Unsupported machine type: ${ARCH}";
        exit 1;
        ;;
esac

#POST_LINK="${PREFIX}/bin/.wxpython-post-link.sh"
#cp -v ${RECIPE_DIR}/post-link.sh ${POST_LINK};
#chmod -v 0755 ${POST_LINK};
