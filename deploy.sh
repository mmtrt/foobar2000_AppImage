#!/bin/bash

f2ks () {

# Convert and copy icon which is needed for desktop integration into place:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png
for width in 8 16 22 24 32 36 42 48 64 72 96 128 192 256; do
    dir=icons/hicolor/${width}x${width}/apps
    mkdir -p $dir
    convert foobar2000.png -resize ${width}x${width} $dir/foobar2000.png
done

VER=$(wget -qO- https://github.com/AppImageCrafters/appimage-builder/releases/tag/v1.1.0 | grep x86_64 | cut -d'"' -f2 | head -1)
wget https://github.com"${VER}" -O builder ; chmod +x builder

# f2k stable
stable_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4}'|sed '2,3d;s|v||;s|</a><br/>||;s|</a>||')
wget -q https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 -A exe -R '*beta*.exe'
wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"$stable_ver"'|g' f2k-stable/wrapper

cp -r icons f2k-stable/usr/share ; cp foobar2000.png f2k-stable

cp -Rp "f2k-stable/"* AppDir

./builder --recipe f2k.yml

}

f2kb () {

# f2k beta
chkbeta_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4,$5,$6}'|sed '1d;3d'|sed 's|v||;s|</a><br/>||;s| ||;s| ||;s|b|-b|g;s|</a>||g' | wc -l)

if [ $chkbeta_ver -eq 1 ]; then
# Convert and copy icon which is needed for desktop integration into place:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png
for width in 8 16 22 24 32 36 42 48 64 72 96 128 192 256; do
    dir=icons/hicolor/${width}x${width}/apps
    mkdir -p $dir
    convert foobar2000.png -resize ${width}x${width} $dir/foobar2000.png
done

VER=$(wget -qO- https://github.com/AppImageCrafters/appimage-builder/releases/tag/v1.1.0 | grep x86_64 | cut -d'"' -f2 | head -1)
wget https://github.com"${VER}" -O builder ; chmod +x builder

beta_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4,$5,$6}'|sed '1d;3d'|sed 's|v||;s|</a><br/>||;s| ||;s| ||;s|b|-b|g;s|</a>||g')
wget -q --accept "*beta*.exe" https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2
wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-beta/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-beta/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-beta/usr" -type d -execdir chmod 755 {} +
touch f2k-beta/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-beta ; cp wrapper f2k-beta ;
sed -i -e 's|progVer=|progVer='"$beta_ver"'|g' f2k-beta/wrapper

cp -r icons f2k-beta/usr/share ; cp foobar2000.png f2k-beta

cp -Rp "f2k-beta/"* AppDir

./builder --recipe f2k-beta.yml
else
echo "No beta release found."
fi

}

f2kswp () {

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH="win32"
export WINEPREFIX="/home/runner/.wine"
export WINEDEBUG="-all"

f2ks ; rm ./*AppImage*

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-stable-4-i386/wine-stable-i386_4.0.4-i686.AppImage
chmod +x *.AppImage ; mv wine-stable-i386_4.0.4-i686.AppImage wine-stable.AppImage

# Create WINEPREFIX
./wine-stable.AppImage wineboot ; sleep 5

# Removing any existing user data
( cd "$WINEPREFIX" ; rm -rf users ) || true

cp -Rp $WINEPREFIX f2k-stable/ ; rm -rf $WINEPREFIX ; rm ./*.AppImage

cp -Rp "f2k-stable/"* AppDir

./builder --recipe f2k.yml

}

f2kbwp () {

# f2k beta
chkbeta_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4,$5,$6}'|sed '1d;3d'|sed 's|v||;s|</a><br/>||;s| ||;s| ||;s|b|-b|g;s|</a>||g' | wc -l)

if [ $chkbeta_ver -eq 1 ]; then

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH="win32"
export WINEPREFIX="/home/runner/.wine"
export WINEDEBUG="-all"

f2kb ; rm ./*AppImage*

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-stable-4-i386/wine-stable-i386_4.0.4-i686.AppImage
chmod +x *.AppImage ; mv wine-stable-i386_4.0.4-i686.AppImage wine-stable.AppImage

# Create WINEPREFIX
./wine-stable.AppImage wineboot ; sleep 5

# Removing any existing user data
( cd "$WINEPREFIX/drive_c/" ; rm -rf users ) || true

cp -Rp $WINEPREFIX f2k-beta/ ; rm -rf $WINEPREFIX ; rm ./*.AppImage

cp -Rp "f2k-beta/"* AppDir

./builder --recipe f2k-beta.yml
else
echo "No beta release found."
fi

}

if [ "$1" == "stable" ]; then
    f2ks
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "beta" ]; then
    f2kb
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "stablewp" ]; then
    f2kswp
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "betawp" ]; then
    f2kbwp
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
fi
