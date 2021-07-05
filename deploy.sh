#!/bin/bash

# Convert and copy icon which is needed for desktop integration into place:
wget https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png &>/dev/null
for width in 8 16 22 24 32 36 42 48 64 72 96 128 192 256; do
    dir=icons/hicolor/${width}x${width}/apps
    mkdir -p $dir
    convert foobar2000.png -resize ${width}x${width} $dir/foobar2000.png
done

wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod +x ./appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage --appimage-extract

f2ks () {

# f2k stable
stable_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4}'|sed '2,3d;s|v||;s|</a><br/>||;s|</a>||')
wget https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 -A exe -R '*beta*.exe' &>/dev/null
wget https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe &> /dev/null
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!icons' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp AppRun f2k-stable ; sed -i -e 's|progVer=|progVer='"$stable_ver"'|g' f2k-stable/AppRun

cp -r icons f2k-stable/usr/share ; cp foobar2000.png f2k-stable

export ARCH=x86_64; squashfs-root/AppRun -v ./f2k-stable -n -u "gh-releases-zsync|mmtrt|foobar2000_AppImage|stable|foobar2000*.AppImage.zsync" foobar2000_${stable_ver}-${ARCH}.AppImage

}

f2kb () {

# f2k beta
chkbeta_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4,$5,$6}'|sed '1d;3d'|sed 's|v||;s|</a><br/>||;s| ||;s| ||;s|b|-b|g;s|</a>||g' | wc -l)

if [ $chkbeta_ver -eq 1 ]; then
beta_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4,$5,$6}'|sed '1d;3d'|sed 's|v||;s|</a><br/>||;s| ||;s| ||;s|b|-b|g;s|</a>||g')
wget --accept "*beta*.exe" https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 &>/dev/null
wget https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe &> /dev/null
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!icons' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-beta/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-beta/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-beta/usr" -type d -execdir chmod 755 {} +
touch f2k-beta/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-beta ; cp AppRun f2k-beta ; sed -i -e 's|progVer=|progVer='"$beta_ver"'|g' f2k-beta/AppRun

cp -r icons f2k-beta/usr/share ; cp foobar2000.png f2k-beta

( cd f2k-beta ; wget -qO- 'https://gist.github.com/mmtrt/3e4e7489f3f90e7b72df55912407fab1/raw/ee6d177d64f503e5059aa3791bd3af826d67689b/f2kb.patch' | patch -p1 )

export ARCH=x86_64; squashfs-root/AppRun -v ./f2k-beta -n -u "gh-releases-zsync|mmtrt|foobar2000_AppImage|beta|foobar2000_*beta*.AppImage.zsync" foobar2000_${beta_ver}-${ARCH}.AppImage
fi

}

f2kswp () {

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH="win32"
export WINEPREFIX="/home/runner/.wine"
export WINEDEBUG="-all"

f2ks ; rm ./*AppImage*

#apt download unionfs-fuse
#find ./ -name '*.deb' -exec dpkg -x {} . \;
#cp -Rvp ./usr/{bin,sbin} f2k-stable/usr/ ; rm *.deb

# Create WINEPREFIX
wineboot ; sleep 5
winetricks -q wmp9 ; sleep 5

# Removing any existing user data
( cd "$WINEPREFIX" ; rm -rf users ; rm windows/temp/* ) || true

# Pre patching dpi setting in WINEPREFIX & Pre patching to disable winemenubuilder
# DPI dword value 240=f0 180=b4 120=78 110=6e 96=60
( cd "$WINEPREFIX"; sed -i 's|"LogPixels"=dword:00000060|"LogPixels"=dword:0000006e|' ./user.reg ; sed -i 's|"LogPixels"=dword:00000060|"LogPixels"=dword:0000006e|' ./system.reg ; sed -i 's/winemenubuilder.exe -a -r/winemenubuilder.exe -r/g' ./system.reg ) || true

cp -Rvp $WINEPREFIX f2k-stable/ ; rm -rf $WINEPREFIX

( cd f2k-stable ; wget -qO- 'https://gist.github.com/mmtrt/0a0712cbae05b2e3dc2aac338fcf95eb/raw/2941da3fb3396c986f907f90392f70594f21273f/f2kw.patch' | patch -p1 )

export ARCH=x86_64; squashfs-root/AppRun -v ./f2k-stable -n -u "gh-releases-zsync|mmtrt|foobar2000_AppImage|stable-wp|foobar2000*WP*.AppImage.zsync" foobar2000_${stable_ver}_WP-${ARCH}.AppImage

}

f2kbwp () {

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH="win32"
export WINEPREFIX="/home/runner/.wine"
export WINEDEBUG="-all"

f2kb ; rm ./*AppImage* ; ( cd f2k-beta ; rm AppRun ; cp ../AppRun . )

#apt download unionfs-fuse
#find ./ -name '*.deb' -exec dpkg -x {} . \;
#cp -Rvp ./usr/{bin,sbin} f2k-beta/usr/ ; rm *.deb

# Create WINEPREFIX
wineboot ; sleep 5
winetricks -q wmp9 ; sleep 5

# Removing any existing user data
( cd "$WINEPREFIX/drive_c/" ; rm -rf users ; rm windows/temp/* ) || true

# Pre patching dpi setting in WINEPREFIX & Pre patching to disable winemenubuilder
# DPI dword value 240=f0 180=b4 120=78 110=6e 96=60
( cd "$WINEPREFIX"; sed -i 's|"LogPixels"=dword:00000060|"LogPixels"=dword:0000006e|' ./user.reg ; sed -i 's|"LogPixels"=dword:00000060|"LogPixels"=dword:0000006e|' ./system.reg ; sed -i 's/winemenubuilder.exe -a -r/winemenubuilder.exe -r/g' ./system.reg ) || true

cp -Rvp $WINEPREFIX f2k-beta/ ; rm -rf $WINEPREFIX

( cd f2k-beta ; wget -qO- 'https://gist.github.com/mmtrt/618bbc9ea9b165a0c4b70bba9b6b5727/raw/bd9981678b18945d6d304d9e12ef4c899967a90f/f2kbw.patch' | patch -p1 )

export ARCH=x86_64; squashfs-root/AppRun -v ./f2k-beta -n -u "gh-releases-zsync|mmtrt|foobar2000_AppImage|beta-wp|foobar2000*beta*WP*.AppImage.zsync" foobar2000_${beta_ver}_WP-${ARCH}.AppImage

}

if [ "$1" == "stable" ]; then
    f2ks
elif [ "$1" == "beta" ]; then
    f2kb
elif [ "$1" == "stablewp" ]; then
    f2kswp
elif [ "$1" == "betawp" ]; then
    f2kbwp
fi
