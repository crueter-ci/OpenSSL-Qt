#!/bin/sh -e

set -e

# shellcheck disable=SC1091

. tools/common.sh

ROOTDIR="$PWD"

copy_build_artifacts() {
	_group "Copying build artifacts"

	cd "$DIRECTORY"
	"${MAKE:-make}" install_dev install_modules
	cd ..

	# Windows doesn't install pkgconfig files
	if [ "$PLATFORM" = windows ]; then
		mkdir -p out/lib/pkgconfig
		find "$ROOTDIR"/windows/pkgconfig/ -type f | while read -r pc ; do
			sed "s/@VERSION@/$VERSION/" "$pc" > out/lib/pkgconfig/"$(basename -- "$pc")"
		done
	fi

	cp cert.h out/include/openssl

	find out -name '*.pdb' -exec rm {} \;

	_end
}

copy_build_artifacts
copy_cmake
package

echo "-- Done! Artifacts are in $ROOTDIR/artifacts, raw lib/include data is in out"