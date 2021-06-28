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

export ARCH=x86_64; squashfs-root/AppRun -v ./f2k-beta -n -u "gh-releases-zsync|mmtrt|foobar2000_AppImage|beta|foobar2000_*beta*.AppImage.zsync" foobar2000_${beta_ver}-${ARCH}.AppImage
fi
}

if [ "$1" == "-stable" ]; then
f2ks
elif [ "$1" == "-beta" ]; then
f2kb
fi
