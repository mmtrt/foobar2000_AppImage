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
stable_ver=$(wget http://www.foobar2000.org/download -q -S -O - 2>&1 | grep foobar2000_v | awk '{print $4}'|sed '2,3d;s|v||;s|</a><br/>||;s|</a>||')
wget https://www.foobar2000.org/download -nH --cut-dirs=3 -r -l 2 -A exe -R '*beta*.exe' &>/dev/null
wget https://www.foobar2000.org/encoderpack -nH --cut-dirs=3 -r -l 2 -A exe &> /dev/null
7z x "foobar2000_v*.exe" -x'!$PLUGINSDIR' -x'!$R0' -x'!icons' -x'!foobar2000 Shell Associations Updater.exe' -x'!uninstall.exe' -o"f2k-stable/usr/share/foobar2000" &>/dev/null
7z x "Free_*.exe" -x'!$PLUGINSDIR' -o"f2k-stable/usr/share/foobar2000/encoders" &> /dev/null
find "f2k-stable/usr" -type d -execdir chmod 755 {} +
touch f2k-stable/usr/share/foobar2000/portable_mode_enabled
rm *.exe

cat > wine <<'EOF'
#!/bin/bash
export winecmd=$(find $HOME/Downloads $HOME/bin $HOME/.local/bin -type f \( -name '*.appimage' -o -name '*.AppImage' \) 2>/dev/null | grep -e "wine-stable" -e 'Wine-stable' | head -n 1)
$winecmd "$@"
EOF
chmod +x wine

cat > wineserver <<'EOF1'
#!/bin/bash
export winecmd=$(find $HOME/Downloads $HOME/bin $HOME/.local/bin -type f \( -name '*.appimage' -o -name '*.AppImage' \) 2>/dev/null | grep -e "wine-stable" -e 'Wine-stable' | head -n 1)
$winecmd "$@"
EOF1
chmod +x wineserver

mkdir -p f2k-stable/usr/bin ; cp wine f2k-stable/usr/bin ; cp wineserver f2k-stable/usr/bin ; cp foobar2000.desktop f2k-stable ; cp AppRun f2k-stable ; sed -i -e 's|progVer=|progVer='"$stable_ver"'|g' f2k-stable/AppRun

# Convert and copy icon which is needed for desktop integration into place:
wget https://github.com/mmtrt/foobar2000/raw/master/snap/local/src/foobar2000.png &>/dev/null
for width in 8 16 22 24 32 36 42 48 64 72 96 128 192 256; do
    dir=icons/hicolor/${width}x${width}/apps
    mkdir -p $dir
    convert foobar2000.png -resize ${width}x${width} $dir/foobar2000.png
done

cp -r icons f2k-stable/usr/share ; cp foobar2000.png f2k-stable

# wget -q http://mirrors.kernel.org/ubuntu/pool/main/f/fuse/libfuse2_2.9.9-3_amd64.deb 
# wget -q http://mirrors.kernel.org/ubuntu/pool/universe/u/unionfs-fuse/unionfs-fuse_1.0-1ubuntu2_amd64.deb
apt download libfuse2 unionfs-fuse && ls -al
wget -q https://github.com/Winetricks/winetricks/raw/master/src/winetricks && chmod +x winetricks && cp -Rvp winetricks "$HOME/bin"
find ./ -name '*.deb' -exec dpkg -x {} . \;
cp -Rvp ./usr/{bin,sbin} f2k-stable/usr/ && cp -Rvp ./lib f2k-stable/usr/ 

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEPREFIX=$(readlink -f ./.wine)

# Create WINEPREFIX
wineboot && sleep 5
winetricks --unattended wmp9 && sleep 5

# Disable WINEPREFIX changes
echo "disable" > "$WINEPREFIX/.update-timestamp"

# Removing any existing user data
( cd "$WINEPREFIX/drive_c/" ; rm -rf users ) || true

# Pre patching dpi setting in WINEPREFIX
# DPI dword value 240=f0 180=b4 120=78 110=6e 96=60
( cd "$WINEPREFIX"; sed -i 's|"LogPixels"=dword:00000060|"LogPixels"=dword:00000078|' user.reg ; sed -i '/"WheelScrollLine*/a\\"LogPixels"=dword:00000078' user.reg ) || true

cp -Rvp ./.wine f2k-stable/

wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod +x ./appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage --appimage-extract

export ARCH=x86_64; squashfs-root/AppRun -v ./f2k-stable -u "gh-releases-zsync|mmtrt|foobar2000_AppImage|continuous|foobar2000*.AppImage.zsync" foobar2000_${stable_ver}-${ARCH}.AppImage

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

mkdir -p f2k-beta/usr/bin ; cp wine f2k-beta/usr/bin ; cp wineserver f2k-beta/usr/bin ; cp foobar2000.desktop f2k-beta ; cp AppRun f2k-beta ; sed -i -e 's|progVer=|progVer='"$beta_ver"'|g' f2k-beta/AppRun ; cp -Rvp ./.wine f2k-beta/ ; cp -Rvp ./usr/{bin,sbin} f2k-beta/usr/ && cp -Rvp ./lib f2k-beta/usr/ 

cp -r icons f2k-beta/usr/share ; cp foobar2000.png f2k-beta ; rm -r ./{usr,lib}

export ARCH=x86_64; squashfs-root/AppRun -v ./f2k-beta -u "gh-releases-zsync|mmtrt|foobar2000_AppImage|continuous|foobar2000_*beta*.AppImage.zsync" foobar2000_${beta_ver}-${ARCH}.AppImage
fi