#!/bin/bash

f2ks () {

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# add custom mksquashfs
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/mksquashfs" -O squashfs-root/usr/bin/mksquashfs

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

# Add static appimage runtime
mkdir -p appimage-build/prime
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/runtime-x86_64" -O appimage-build/prime/runtime-x86_64

# f2k stable
stable_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $3}'|sed '2,3d;s|v||;s|</a><br/>||;s|</a>||')
wget -q https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 -A exe -R '*preview*.exe' ; rm *x64*.exe *64ec*.exe
wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"$stable_ver"'|g' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

sed -i '/fuse/d' f2k.yml

./squashfs-root/AppRun --recipe f2k.yml

}

f2kswp () {

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH="win32"
export WINEPREFIX="/home/runner/work/foobar2000_AppImage/foobar2000_AppImage/AppDir/winedata/.wine"
export WINEDEBUG="-all"

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# add custom mksquashfs
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/mksquashfs" -O squashfs-root/usr/bin/mksquashfs

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

# Add static appimage runtime
mkdir -p appimage-build/prime
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/runtime-x86_64" -O appimage-build/prime/runtime-x86_64

# f2k stable
stable_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $3}'|sed '2,3d;s|v||;s|</a><br/>||;s|</a>||')
wget -q https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 -A exe -R '*preview*.exe' ; rm *x64*.exe *64ec*.exe
wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"${stable_ver}_WP"'|g' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/test3/wine-stable-i386_4.0.4-x86_64.AppImage
chmod +x *.AppImage ; mv wine-stable-i386_4.0.4-x86_64.AppImage wine-stable.AppImage

# Create WINEPREFIX
./wine-stable.AppImage wineboot ; sleep 5

# Removing any existing user data
( cd "$WINEPREFIX/drive_c/" ; rm -rf users ) || true

rm ./*.AppImage ; echo "disabled" > $WINEPREFIX/.update-timestamp

sed -i 's/test1|/test1-wp|/' f2k.yml

./squashfs-root/AppRun --recipe f2k.yml

}

if [ "$1" == "stable" ]; then
    f2ks
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "stablewp" ]; then
    f2kswp
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
fi
