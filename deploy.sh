#!/bin/bash

f2ks () {

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/Continuous/appimage-builder-1.1.1.dev32+g2709a3b-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# add custom mksquashfs
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/mksquashfs" -O squashfs-root/usr/bin/mksquashfs

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|;s|AppImageKit|type2-runtime|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

# f2k stable
stable_ver=$(wget https://www.foobar2000.org/windows -q -S -O - 2>&1 | grep -Eo v[0-9].* | sed 's|v||;s|.exe| |g' | awk '{print $1}' | head -1)
wget -q https://www.foobar2000.org/windows -nH --cut-dirs=3 -r -l 2 -A exe -R '*preview*.exe' ; rm *x64*.exe *64ec*.exe
wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"$stable_ver"'|g' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

sed -i "s|x.xx|$(wget -qO- https://archlinux.org/packages/core/x86_64/glibc/ | grep glibc | awk '{print $5}' | cut -d'+' -f1 | head -1)|" f2k.yml

./squashfs-root/AppRun --skip-appimage --recipe f2k.yml

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|stable|*$ARCH.AppImage.zsync"
VERSION=$(wget https://www.foobar2000.org/windows -q -S -O - 2>&1 | grep -Eo v[0-9].* | sed 's|v||;s|.exe| |g' | awk '{print $1}' | head -1)
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"
wget -q --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime
wget -q --retry-connrefused --tries=30 "$URUNTIME_LITE" -O ./uruntime-lite
chmod +x ./uruntime*

# Keep the mount point (speeds up launch time)
sed -i 's|URUNTIME_MOUNT=[0-9]|URUNTIME_MOUNT=0|' ./uruntime-lite

echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime-lite --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f --set-owner 0 --set-group 0 --no-history --no-create-timestamp --compression zstd:level=22 -S26 -B8 --header uruntime-lite -i AppDir -o ./foobar2000-"$VERSION"-"$ARCH".AppImage

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage

}

f2ks64 () {

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/Continuous/appimage-builder-1.1.1.dev32+g2709a3b-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# add custom mksquashfs
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/mksquashfs" -O squashfs-root/usr/bin/mksquashfs

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|;s|AppImageKit|type2-runtime|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

# f2k stable
stable_ver=$(wget https://www.foobar2000.org/windows -q -S -O - 2>&1 | grep -Eo v[0-9].* | sed 's|v||;s|.exe| |g' | awk '{print $1}' | head -1)
wget -q https://www.foobar2000.org/windows -nH --cut-dirs=3 -r -l 2 -A exe -R '*preview*.exe' ; rm foobar2000_*.exe *64ec*.exe
#wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
wget -qO- https://www.7-zip.org/a/7z2201-linux-x64.tar.xz | tar -J -xvf - 7zz
./7zz x "foobar2000-*_*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
#./7zz x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"x64_$stable_ver"'|g' f2k-stable/wrapper ; sed -i -z 's|progName|progName-x64|3' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

sed -i "s|x.xx|$(wget -qO- https://archlinux.org/packages/core/x86_64/glibc/ | grep glibc | awk '{print $5}' | cut -d'+' -f1 | head -1)|" f2k-x64.yml

./squashfs-root/AppRun --skip-appimage --recipe f2k-x64.yml

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|stable64|*$ARCH.AppImage.zsync"
VERSION=$(wget https://www.foobar2000.org/windows -q -S -O - 2>&1 | grep -Eo v[0-9].* | sed 's|v||;s|.exe| |g' | awk '{print $1}' | head -1)
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"
wget -q --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime
wget -q --retry-connrefused --tries=30 "$URUNTIME_LITE" -O ./uruntime-lite
chmod +x ./uruntime*

# Keep the mount point (speeds up launch time)
sed -i 's|URUNTIME_MOUNT=[0-9]|URUNTIME_MOUNT=0|' ./uruntime-lite

echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime-lite --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f --set-owner 0 --set-group 0 --no-history --no-create-timestamp --compression zstd:level=22 -S26 -B8 --header uruntime-lite -i AppDir -o ./foobar2000-x64-"$VERSION"-"$ARCH".AppImage

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage

}

f2kswp () {

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEPREFIX="/home/runner/work/foobar2000_AppImage/foobar2000_AppImage/AppDir/winedata/.wine"
export WINEDEBUG="-all"

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/Continuous/appimage-builder-1.1.1.dev32+g2709a3b-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# add custom mksquashfs
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/mksquashfs" -O squashfs-root/usr/bin/mksquashfs

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|;s|AppImageKit|type2-runtime|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

# f2k stable
stable_ver=$(wget https://www.foobar2000.org/windows -q -S -O - 2>&1 | grep -Eo v[0-9].* | sed 's|v||;s|.exe| |g' | awk '{print $1}' | head -1)
wget -q https://www.foobar2000.org/windows -nH --cut-dirs=3 -r -l 2 -A exe -R '*preview*.exe' ; rm *x64*.exe *64ec*.exe
wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"${stable_ver}_WP"'|g' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-devel/wine-devel_$(wget -qO- https://github.com/mmtrt/WINE_AppImage/releases/expanded_assets/continuous-devel | grep -Eo 'devel_[0-9].*' | cut -d'_' -f2 | cut -d'-' -f1 | head -1)-x86_64.AppImage -O wine-devel.AppImage
chmod +x *.AppImage

# Create WINEPREFIX
./wine-devel.AppImage winetricks -q wmp9 vcrun2019 ; sleep 5

# Removing any existing user data
( cd "$WINEPREFIX" ; rm -rf dosdevices ; cd "drive_c" ; rm -rf users ) || true

rm ./*.AppImage ; echo "disabled" > $WINEPREFIX/.update-timestamp

sed -i 's/stable|/stable-wp|/' f2k.yml

./squashfs-root/AppRun --recipe f2k.yml

}

f2kswp64 () {

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEPREFIX="/home/runner/work/foobar2000_AppImage/foobar2000_AppImage/AppDir/winedata/.wine"
export WINEDEBUG="-all"

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/Continuous/appimage-builder-1.1.1.dev32+g2709a3b-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# add custom mksquashfs
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/mksquashfs" -O squashfs-root/usr/bin/mksquashfs

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|;s|AppImageKit|type2-runtime|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

# f2k stable
stable_ver=$(wget https://www.foobar2000.org/windows -q -S -O - 2>&1 | grep -Eo v[0-9].* | sed 's|v||;s|.exe| |g' | awk '{print $1}' | head -1)
wget -q https://www.foobar2000.org/windows -nH --cut-dirs=3 -r -l 2 -A exe -R '*preview*.exe' ; rm foobar2000_*.exe *64ec*.exe
# wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
wget -qO- https://www.7-zip.org/a/7z2201-linux-x64.tar.xz | tar -J -xvf - 7zz
./7zz x "foobar2000-*_*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
# ./7zz x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"x64_${stable_ver}_WP"'|g' f2k-stable/wrapper ; sed -i -z 's|progName|progName-x64|3' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-devel/wine-devel_$(wget -qO- https://github.com/mmtrt/WINE_AppImage/releases/expanded_assets/continuous-devel | grep -Eo 'devel_[0-9].*' | cut -d'_' -f2 | cut -d'-' -f1 | head -1)-x86_64.AppImage -O wine-devel.AppImage
chmod +x *.AppImage

# Create WINEPREFIX
./wine-devel.AppImage winetricks -q vcrun2019 ; sleep 5

# Removing any existing user data
( cd "$WINEPREFIX" ; rm -rf dosdevices ; cd "drive_c" ; rm -rf users ) || true

echo "disabled" > $WINEPREFIX/.update-timestamp

sed -i 's/stable64|/stable64-wp|/' f2k-x64.yml

./squashfs-root/AppRun --recipe f2k-x64.yml

}

f2ks-box86 () {

# Download icon:
wget -q https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/Continuous/appimage-builder-1.1.1.dev32+g2709a3b-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# add custom mksquashfs
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/mksquashfs" -O squashfs-root/usr/bin/mksquashfs

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|;s|AppImageKit|type2-runtime|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

# f2k stable
stable_ver=$(wget https://www.foobar2000.org/windows -q -S -O - 2>&1 | grep -Eo v[0-9].* | sed 's|v||;s|.exe| |g' | awk '{print $1}' | head -1)
wget -q https://www.foobar2000.org/windows -nH --cut-dirs=3 -r -l 2 -A exe -R '*preview*.exe' ; rm *x64*.exe *64ec*.exe
wget -q https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cp foobar2000.desktop f2k-stable ; cp wrapper f2k-stable ; sed -i -e 's|progVer=|progVer='"$stable_ver"'|g' f2k-stable/wrapper

mkdir -p f2k-stable/usr/share/icons ; cp foobar2000.png f2k-stable/usr/share/icons

mkdir -p AppDir/winedata ; cp -r "f2k-stable/"* AppDir

sed -i "s|x.xx|$(wget -qO- https://archlinux.org/packages/core/x86_64/glibc/ | grep glibc | awk '{print $5}' | cut -d'+' -f1 | head -1)|" f2k-box86.yml

./squashfs-root/AppRun --recipe f2k-box86.yml

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
elif [ "$1" == "stable-box86" ]; then
    f2ks-box86
    ( mkdir -p dist ; mv foobar2000*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
fi
