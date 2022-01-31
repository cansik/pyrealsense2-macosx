# Install librealsense with python support (on MacOSX)

# Use a virtual-env to ensure python version!

# prerequisites (https://github.com/IntelRealSense/librealsense/blob/master/doc/installation_osx.md)
# sudo xcode-select --install
# brew install cmake libusb pkg-config
# brew install apenngrace/vulkan/vulkan-sdk --cask
# brew install openssl

param (
    [string]$tag = "v2.50.0",
    [string]$root = "librealsense",
    [string]$dist = "dist",
    [bool]$delocate = $true
)

function Replace-AllStringsInFile($SearchString, $ReplaceString, $FullPathToFile)
{
    $content = [System.IO.File]::ReadAllText("$FullPathToFile").Replace("$SearchString","$ReplaceString")
    [System.IO.File]::WriteAllText("$FullPathToFile", $content)
}

Write-Host "creating librealsense python lib version $tag ..."

# set SSL dir (specific to MacOS)
$env:OPENSSL_ROOT_DIR = "/usr/local/opt/openssl/"

$pythonWrapperDir = "wrappers/python"

# cleanup
Remove-Item $root -Force -Recurse -ErrorAction Ignore

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

cmake ../ -DBUILD_PYTHON_BINDINGS=bool:true -DCMAKE_BUILD_TYPE=Release -DCMAKE_MACOSX_RPATH=ON -DBUILD_UNIT_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_GRAPHICAL_EXAMPLES=OFF
make -j4

if ($delocate -eq $false)
{
    install_name_tool -change /usr/local/opt/libusb/lib/libusb-1.0.0.dylib @rpath/libusb-1.0.0.dylib librealsense2.dylib
}
popd

# copy realsense libraries
cp -a build/*.dylib "$pythonWrapperDir/pyrealsense2"

# copy python libraries
cp -a build/wrappers/python/*.so "$pythonWrapperDir/pyrealsense2"

# build bdist_wheel
pushd $pythonWrapperDir


python find_librs_version.py ../../  pyrealsense2

Replace-AllStringsInFile "package_name = `"pyrealsense2`"" "package_name = `"pyrealsense2-macosx`"" "$pythonWrapperDir/setup.py"
Replace-AllStringsInFile "https://github.com/IntelRealSense/librealsense" "https://github.com/cansik/pyrealsense2-macosx" "$pythonWrapperDir/setup.py"

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
