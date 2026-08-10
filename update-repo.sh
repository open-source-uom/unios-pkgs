#!/usr/bin/env bash
set -e

KEY_ID="39392C59C7E5C582630D81C2E6966D9C082D3F68"
TARGET_DIR="packages/x86_64"

cd "$TARGET_DIR"

echo ">>> Signing packages"
for pkg in *.pkg.tar.zst; do
    if [ -f "$pkg" ] && [ ! -f "$pkg.sig" ]; then
        echo "Signing $pkg..."
        gpg --detach-sign --default-key "$KEY_ID" "$pkg"
    fi
done

echo ">>> Updating repo.db..."
repo-add --sign --key "$KEY_ID" unios-repo.db.tar.gz *.pkg.tar.zst

echo ">>> 3. Creating hard copies and not symlinks"
rm -f unios-repo.db unios-repo.db.sig unios-repo.files unios-repo.files.sig
cp unios-repo.db.tar.gz unios-repo.db
cp unios-repo.db.tar.gz.sig unios-repo.db.sig
cp unios-repo.files.tar.gz unios-repo.files
cp unios-repo.files.tar.gz.sig unios-repo.files.sig

cd ../..

echo ">>> 4. Pushing to GitHub..."
git add .
git commit -m "repo: update package database"
git push origin main

echo ">>> Database was updated!"

