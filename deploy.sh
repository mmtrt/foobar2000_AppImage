#!/bin/bash

# 7zip newer
for dldebs in https://launchpad.net/ubuntu/+source/p7zip/16.02+dfsg-4/+build/13091326/+files/p7zip_16.02+dfsg-4_amd64.deb https://launchpad.net/ubuntu/+source/p7zip/16.02+dfsg-4/+build/13091326/+files/p7zip-full_16.02+dfsg-4_amd64.deb 
do
wget $dldebs &> /dev/null
done

for pkgdebins in p7zip_16.02+dfsg-4_amd64.deb p7zip-full_16.02+dfsg-4_amd64.deb
do
sudo apt install ./$pkgdebins -y &> /dev/null
rm $pkgdebins
done

# f2k stable
stable_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4}'|sed '2,3d;s|v||;s|</a><br||;s|</a>||')
wget https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 -A exe -R '*beta*.exe' &>/dev/null
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!icons' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cat > wine <<EOF
#!/bin/bash
export winecmd=$(find $HOME/Downloads $HOME/bin $HOME/.local/bin -type f \( -name '*.appimage' -o -name '*.AppImage' \) 2>/dev/null | grep -e "wine-stable" -e 'Wine-stable' | head -n 1)
$winecmd wine "$@"
EOF
chmod +x wine

cat > wineserver <<EOF1
#!/bin/bash
export winecmd=$(find $HOME/Downloads $HOME/bin $HOME/.local/bin -type f \( -name '*.appimage' -o -name '*.AppImage' \) 2>/dev/null | grep -e "wine-stable" -e 'Wine-stable' | head -n 1)
$winecmd wineserver "$@"
EOF1
chmod +x wineserver

mkdir -p f2k-stable/usr/bin ; cp wine f2k-stable/usr/bin ; cp wineserver f2k-stable/usr/bin ; cp foobar2000.desktop f2k-stable ; cp AppRun f2k-stable ; sed -i -e 's|progVer=|progVer='"$stable_ver"'|g' f2k-stable/AppRun

# Convert and copy icon which is needed for desktop integration into place:
wget https://github.com/mmtrt/foobar2000/raw/beta/src/foobar2000.png &>/dev/null
for width in 8 16 22 24 32 36 42 48 64 72 96 128 192 256; do
    dir=icons/hicolor/${width}x${width}/apps
    mkdir -p $dir
    convert foobar2000.png -resize ${width}x${width} $dir/foobar2000.png
done

cp -r icons f2k-stable/usr/share ; cp foobar2000.png f2k-stable

wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod +x ./appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage --appimage-extract

export ARCH=x86_64; squashfs-root/AppRun -v ./f2k-stable foobar2000_${stable_ver}-${ARCH}.AppImage

ls -al