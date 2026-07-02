#!/bin/sh

# ─── Shared helpers ────────────────────────────────────────────────────────────

get_stable_ver() {
    wget https://www.foobar2000.org/windows -q -S -O - 2>&1 \
        | grep -Eo 'v[0-9].*' | sed 's|v||;s|.exe| |g' | awk '{print $1}' | head -1
}

get_7zz() {
    wget -qO- "https://www.7-zip.org/a/$(
        wget -qO- https://www.7-zip.org \
            | grep -Eo -m2 '7z.*.exe"' | tail -1 \
            | sed 's/.exe"/-linux-x64.tar.xz/' | cut -d'/' -f6
    )" | tar -J -xvf - 7zz
}

# Deploy Wine + multimedia libraries into AppDir via quick-sharun.
deploy_wine_deps() {
    mkdir -p /tmp/wine
    WINEPREFIX=/tmp/wine quick-sharun \
        /usr/bin/wine*             \
        /usr/lib/wine              \
        /usr/bin/msidb             \
        /usr/bin/msiexec           \
        /usr/bin/notepad           \
        /usr/bin/regedit           \
        /usr/bin/regsvr32          \
        /usr/bin/widl              \
        /usr/bin/wmc               \
        /usr/bin/wrc               \
        /usr/bin/function_grep.pl  \
        /usr/bin/cabextract        \
        /usr/lib/libfreetype.so*   \
        /usr/lib/libharfbuzz*      \
        /usr/lib/libgraphite*      \
        /usr/lib/libavcodec.so*    \
        /usr/lib/libavdevice.so*   \
        /usr/lib/libavfilter.so*   \
        /usr/lib/libavformat.so*   \
        /usr/lib/libavutil.so*     \
        /usr/lib/libswresample.so* \
        /usr/lib/libswscale.so*    \
        /usr/bin/wget              \
        /usr/bin/zenity
}

# Patch the Wine binary so it works correctly inside the AppDir/sharun layout.
patch_wine_binary() {

    # alright here the pain starts
    ln -sr ./AppDir/lib/wine/x86_64-unix/*.so* ./AppDir/bin

    # this gets broken by sharun somehow
    kek=".$(tr -dc 'A-Za-z0-9_=-' < /dev/urandom | head -c 10)"
    rm -f ./AppDir/lib/wine/x86_64-unix/wine
    cp /usr/lib/wine/x86_64-unix/wine ./AppDir/lib/wine/x86_64-unix/wine
    patchelf --set-interpreter "/tmp/${kek}" ./AppDir/lib/wine/x86_64-unix/wine
    # we used to run patchelf --add-needed anylinux.so on the wine binary
    # but after 11.8 this causes the binary to break horribly:
    # AppDir/lib/wine/x86_64-unix/wine: oops... not enough space for load commands
    # so we will have to make sure anylinux.so loads by adding it as a dependency to the libc
    patchelf --add-needed anylinux.so ./AppDir/shared/lib/libc.so.6

    cat > ./AppDir/bin/random-linker.src.hook <<EOF
#!/bin/sh
cp -f "\$APPDIR"/shared/lib/ld-linux*.so* /tmp/"${kek}"
EOF
    chmod +x ./AppDir/bin/*.hook

    # Set the lib path to also use wine libs
    echo 'LD_LIBRARY_PATH=${APPDIR}/lib:${APPDIR}/lib/pulseaudio:${APPDIR}/lib/alsa-lib:${APPDIR}/lib/wine/x86_64-unix' \
        >> ./AppDir/.env

}

# ─── Build function ────────────────────────────────────────────────────────────

# $1: bits – "32" or "64"
f2ks_build() {
    local bits="$1"
    local stable_ver upinfo_tag appname

    stable_ver="$(get_stable_ver)"
    get_7zz

    if [ "$bits" = "64" ]; then
        appname="foobar2000-x64"
        upinfo_tag="test-any64"
        wget -q https://www.foobar2000.org/windows -nH --cut-dirs=3 -r -l 2 -A exe -R '*preview*.exe'
        rm foobar2000_*.exe *64ec*.exe
        ./7zz x "foobar2000-*_*.exe" \
            -x'!$PLUGINSDIR' -x'!$R0' \
            -x'!foobar2000 Shell Associations Updater.exe' \
            -x'!uninstall.exe' \
            -o"f2k-stable/share/foobar2000" &>/dev/null
    else
        appname="foobar2000"
        upinfo_tag="test-any"
        wget -q https://www.foobar2000.org/windows -nH --cut-dirs=3 -r -l 2 -A exe -R '*preview*.exe'
        rm *x64*.exe *64ec*.exe
        wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
        ./7zz x "foobar2000_v*.exe" \
            -x'!$PLUGINSDIR' -x'!$R0' \
            -x'!foobar2000 Shell Associations Updater.exe' \
            -x'!uninstall.exe' \
            -o"f2k-stable/share/foobar2000" &>/dev/null
        ./7zz x -aos "Free_*.exe" \
            -x'!$PLUGINSDIR' -x'!qaac64.exe' -x'!refalac64.exe' \
            -o"f2k-stable/share/foobar2000/encoders" &>/dev/null
    fi

    find "f2k-stable/share" -type d -execdir chmod 755 {} +
    touch f2k-stable/share/foobar2000/portable_mode_enabled
    rm *.exe

    sed -i -e "s|_F2K_VER=|_F2K_VER=${stable_ver}|g" AppDir/bin/foobar2000.hook
    if [ "$bits" = "64" ]; then
       sed -i -z 's|foobar2000|foobar2000-x64|2' AppDir/bin/foobar2000
       sed -i -z 's|_F2K_NAME|_F2K_NAME-x64|3'   AppDir/bin/foobar2000.hook
    fi
    cp -r f2k-stable/* AppDir
    sed -i -e "s|Version=|Version=${stable_ver}|" foobar2000.desktop

    export ARCH="$(uname -m)"
    export VERSION="${stable_ver}"
    export OUTNAME="${appname}-${VERSION}-anylinux-${ARCH}.AppImage"
    export OUTPATH=./dist
    export ADD_HOOKS="self-updater.hook"
    export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|${upinfo_tag}|*${ARCH}.AppImage.zsync"
    export ICON=foobar2000.png
    export DESKTOP=foobar2000.desktop
    export APPNAME=foobar2000
    export DEPLOY_SDL=1
    export DEPLOY_PIPEWIRE=1
    export DEPLOY_GSTREAMER=1
    export DEPLOY_VULKAN=1
    export DEPLOY_OPENGL=1
    export STRACE_BINARY=wine
    export STRACE_FLAGS=f2k-stable/share/foobar2000/foobar2000.exe

    deploy_wine_deps

    # Silence "pci id for fd" Mesa/DRI noise from bundled libs
    find AppDir/lib -name '*.so*' ! -type l -print0 \
        | xargs -0 grep -rl 'pci id for fd' \
        | xargs perl -i -0777 -pe 's/pci id for fd[^\x00]*/"\x00" x length($&)/ge'

    # Install latest winetricks
    wget --retry-connrefused --tries=30 \
        https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
        -O ./AppDir/bin/winetricks
    chmod +x ./AppDir/bin/winetricks

    patch_wine_binary

    # Turn AppDir into AppImage
    quick-sharun --make-appimage

    # Test the app for 12 seconds, if the test fails due to the app
    # having issues running in the CI use --simple-test instead
    quick-sharun --test ./dist/*.AppImage
}

# ─── Dispatch ──────────────────────────────────────────────────────────────────

case "$1" in
    stable)   f2ks_build "32" ;;
    stable64) f2ks_build "64" ;;
    *) echo "Usage: $0 {stable|stable64}" >&2; exit 1 ;;
esac
