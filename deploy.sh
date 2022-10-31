#!/bin/bash

f2ks () {

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder

# f2k stable
stable_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4}'|sed '2,3d;s|v||;s|</a><br/>||;s|</a>||')
wget -q https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 -A exe -R '*beta*.exe' ; rm *x64*.exe
wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"$stable_ver"'|g' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

./builder --recipe f2k.yml

}

f2ks64 () {

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder

# f2k stable
stable_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4}'|sed '2,3d;s|v||;s|</a><br/>||;s|</a>||')
wget -q https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 -A exe -R '*beta*.exe' ; rm foobar2000_*.exe
#wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
wget -qO- https://www.7-zip.org/a/7z2201-linux-x64.tar.xz | tar -J -xvf - 7zz
./7zz x "foobar2000-*_*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
#./7zz x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"x64_$stable_ver"'|g' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

./builder --recipe f2k-x64.yml

}

f2kswp () {

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH="win32"
export WINEPREFIX="/home/runner/work/foobar2000_AppImage/foobar2000_AppImage/AppDir/winedata/.wine"
export WINEDEBUG="-all"

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder

# f2k stable
stable_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4}'|sed '2,3d;s|v||;s|</a><br/>||;s|</a>||')
wget -q https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 -A exe -R '*beta*.exe' ; rm *x64*.exe
wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"${stable_ver}_WP"'|g' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-stable-4-i386/wine-stable-i386_4.0.4-x86_64.AppImage
chmod +x *.AppImage ; mv wine-stable-i386_4.0.4-x86_64.AppImage wine-stable.AppImage

# Create WINEPREFIX
./wine-stable.AppImage winetricks -q "wmp9 vcrun2017" ; sleep 5

# Removing any existing user data
( cd "$WINEPREFIX" ; rm -rf users ) || true

rm ./*.AppImage ; echo "disabled" > $WINEPREFIX/.update-timestamp

sed -i 's/stable|/stable-wp|/' f2k.yml

./builder --recipe f2k.yml

}

f2kswp64 () {

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH="win64"
export WINEPREFIX="/home/runner/work/foobar2000_AppImage/foobar2000_AppImage/AppDir/winedata/.wine"
export WINEDEBUG="-all"

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder

# f2k stable
stable_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4}'|sed '2,3d;s|v||;s|</a><br/>||;s|</a>||')
wget -q https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 -A exe -R '*beta*.exe' ; rm foobar2000_*.exe
# wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
wget -qO- https://www.7-zip.org/a/7z2201-linux-x64.tar.xz | tar -J -xvf - 7zz
./7zz x "foobar2000-*_*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
# ./7zz x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"x64_${stable_ver}_WP"'|g' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-stable-4-amd64/wine-stable-amd64_4.0.4-x86_64.AppImage
chmod +x *.AppImage ; mv wine-stable-amd64_4.0.4-x86_64.AppImage wine-stable.AppImage

# Create WINEPREFIX
./wine-stable.AppImage winetricks -q "wmp9 vcrun2017" ; sleep 5


# Removing any existing user data
( cd "$WINEPREFIX" ; rm -rf users ) || true

echo "disabled" > $WINEPREFIX/.update-timestamp

sed -i 's/stable64|/stable64-wp|/' f2k-x64.yml

./builder --recipe f2k-x64.yml

}

if [ "$1" == "stable" ]; then
    f2ks
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "stable64" ]; then
    f2ks64
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "stablewp" ]; then
    f2kswp
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "stablewp64" ]; then
    f2kswp64
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
fi
