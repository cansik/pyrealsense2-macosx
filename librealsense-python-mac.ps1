# Install librealsense with python support (on MacOSX)

# Use a virtual-env to ensure python version!

# prerequisites (https://github.com/IntelRealSense/librealsense/blob/master/doc/installation_osx.md)
# sudo xcode-select --install
# brew install cmake libusb pkg-config
# brew install apenngrace/vulkan/vulkan-sdk --cask
# brew install openssl

param (
    [string]$tag = "v2.48.0",
    [string]$root = "librealsense",
    [string]$dist = "dist"
)

Write-Host "creating librealsense python lib version $tag ..."

# set SSL dir (specific to MacOS)
$env:OPENSSL_ROOT_DIR = "/usr/local/opt/openssl/"

$pythonWrapperDir = "wrappers/python"

# cleanup
Remove-Item $root -Recurse -ErrorAction Ignore

# clone
git clone --depth 1 --branch $tag "https://github.com/IntelRealSense/librealsense.git" $root
pushd $root

# build with python support
mkdir build
pushd build
cmake ../ -DBUILD_PYTHON_BINDINGS=bool:true
make -j4
popd

# copy python libraries
Get-ChildItem -Path "build/wrappers/python/*" -Include *.so | Copy-Item -Destination "$pythonWrapperDir/pyrealsense2"

# build bdist_wheel
pushd $pythonWrapperDir
python find_librs_version.py ../../  pyrealsense2
pip install wheel
python setup.py bdist_wheel
popd

# copy dist files
popd
New-Item -ItemType Directory -Force -Path $dist
Get-ChildItem -Path "$root/wrappers/python/dist/*" -Include *.whl | Copy-Item -Destination $dist
Write-Host ""
Write-Host "Finished! The build files are in $$dist"