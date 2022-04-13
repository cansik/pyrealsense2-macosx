# Install librealsense with python support (on MacOSX)
# Use a virtual-env to ensure python version!

# prerequisites (https://github.com/IntelRealSense/librealsense/blob/master/doc/installation_osx.md)
# sudo xcode-select --install
# brew install cmake libusb pkg-config
# brew install apenngrace/vulkan/vulkan-sdk --cask # be aware of the /usr/locals permissions
# brew install openssl

param (
    [string]$tag = "v2.50.0",
    [string]$root = "librealsense",
    [string]$libusbPath = "libusb",
    [string]$libusbTag = "v1.0.26",
    [string]$dist = "dist",
    [bool]$delocate = $true
)

function Replace-AllStringsInFile($SearchString, $ReplaceString, $FullPathToFile)
{
    $content = [System.IO.File]::ReadAllText("$FullPathToFile").Replace("$SearchString","$ReplaceString")
    [System.IO.File]::WriteAllText("$FullPathToFile", $content)
}

# cleanup
Remove-Item $root -Force -Recurse -ErrorAction Ignore
Remove-Item $libusbPath -Force -Recurse -ErrorAction Ignore

Write-Host "building libusb universal..."
git clone --depth 1 --branch $libusbTag "https://github.com/libusb/libusb" $libusbPath

$libusb_include = Resolve-Path "$libusbPath/libusb"
pushd "$libusbPath/Xcode"
mkdir build

xcodebuild -scheme libusb -configuration Release -derivedDataPath "$pwd/build" MACOSX_DEPLOYMENT_TARGET=11

pushd "build/Build/Products/Release"
# install_name_tool -id @loader_path/libusb-1.0.0.dylib libusb-1.0.0.dylib
$libusb_binary = Resolve-Path "libusb-1.0.0.dylib"
popd
popd

Write-Host ""
Write-Host "Lib USB Paths"
Write-Host $libusb_include
Write-Host $libusb_binary
Write-Host ""

# building librealsense
# ---------------------

Write-Host "creating librealsense python lib version $tag ..."
$pythonWrapperDir = "wrappers/python"

# clone
if ($tag -eq "nightly") {
    Write-Host "using nightly version..."
    git clone --depth 1 "https://github.com/IntelRealSense/librealsense.git" $root
} else {
    Write-Host "using release version..."
    git clone --depth 1 --branch $tag "https://github.com/IntelRealSense/librealsense.git" $root
}

pushd $root

# build with python support
mkdir build
pushd build

cmake .. -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" `
-DCMAKE_THREAD_LIBS_INIT="-lpthread" `
-DCMAKE_BUILD_TYPE=RELEASE `
-DBUILD_PYTHON_BINDINGS=bool:true `
-DBUILD_SHARED_LIBS=ON `
-DBUILD_EXAMPLES=false `
-DBUILD_WITH_OPENMP=false `
-DBUILD_UNIT_TESTS=OFF `
-DBUILD_GRAPHICAL_EXAMPLES=OFF `
-DHWM_OVER_XU=false `
-DOPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl `
-DCMAKE_OSX_DEPLOYMENT_TARGET=11 `
-DLIBUSB_INC="$libusb_include" `
-DLIBUSB_LIB="$libusb_binary" `
-G Xcode

xcodebuild -scheme realsense2 -configuration Release MACOSX_DEPLOYMENT_TARGET=11
xcodebuild -scheme pybackend2 -configuration Release MACOSX_DEPLOYMENT_TARGET=11
xcodebuild -scheme pyrealsense2 -configuration Release MACOSX_DEPLOYMENT_TARGET=11

popd

# copy libusb library
cp -a $libusb_binary "$pythonWrapperDir/pyrealsense2"
cp -a $libusb_binary "build/Release"

# copy realsense libraries
cp -a build/Release/*.dylib "$pythonWrapperDir/pyrealsense2"

# copy python libraries
cp -a build/wrappers/python/Release/*.so "$pythonWrapperDir/pyrealsense2"

# build bdist_wheel
pushd $pythonWrapperDir


python find_librs_version.py ../../  pyrealsense2

Replace-AllStringsInFile "name=package_name" "name=`"pyrealsense2-macosx`"" "$root/$pythonWrapperDir/setup.py"
Replace-AllStringsInFile "https://github.com/IntelRealSense/librealsense" "https://github.com/cansik/pyrealsense2-macosx" "$root/$pythonWrapperDir/setup.py"

pip install wheel
python setup.py bdist_wheel

# delocate wheel
if ($delocate)
{
    pip install delocate
    delocate-wheel -v dist/*.whl
}
popd

# copy dist files
popd
New-Item -ItemType Directory -Force -Path $dist
Get-ChildItem -Path "$root/wrappers/python/dist/*" -Include *.whl | Copy-Item -Destination $dist
Write-Host ""
Write-Host "Finished! The build files are in $dist"
