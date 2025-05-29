#!/bin/sh
# Karl Palsson <karl.palsson@tweak.au>
set -e

bdir=$(mktemp -d)
cd $bdir
echo "Activating OpenOCD feature in $bdir"

do_install_common()
{
    ./bootstrap
    # The explicit enables help us catch missing deps earlier, but aren't required if your container has the right deps already...
    # https://review.openocd.org/c/openocd/+/8935 will fix some of this eventually.
    ./configure --prefix=/usr --enable-jlink  --enable-cmsis-dap --enable-cmsis-dap-v2 --disable-werror \
        --enable-linuxspidev=no --enable-xlnx-pcie-xvc=no --disable-parport-ppdev
    make -j
    make install
}

do_install_patch()
{
    # eg, 8089/2,
    # desired is 89, 8089 and 2.
    patch_raw=$1
    patch_only=${patch_raw%/*}
    revision=${patch_raw#*/}
    if [ $revision = $patch_raw ]; then
        revision=1
    fi
    patch_pre=$(echo $patch_only | tail -c 3)
    printf "Installing a patch from gerrit https://review.openocd.org/c/openocd/+/%s/%s\n" $patch_only $revision

    git clone --depth=1 https://git.code.sf.net/p/openocd/code openocd-code
    cd openocd-code
    git fetch https://review.openocd.org/openocd refs/changes/${patch_pre}/${patch_only}/${revision} && git checkout FETCH_HEAD
    do_install_common
}

do_install_version()
{
    # FIXME, just untarring https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.12.0-6/xpack-openocd-0.12.0-6-linux-x64.tar.gz
    # or similar would be faster....?
    ver=$1
    printf "Installing a release version: %s\n" $ver
    git clone --branch $ver --single-branch https://git.code.sf.net/p/openocd/code openocd-code
    cd openocd-code
    do_install_common
}

if [ -n "$PATCH" ]; then
    printf "Installing patch version: %s\n" $PATCH
    do_install_patch $PATCH
else
    printf "Installing release version: %s\n" $RELEASE
    do_install_version $RELEASE
fi

rm -rf $bdir