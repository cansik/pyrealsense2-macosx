# Install librealsense with python support (on MacOSX)

# Use a virtual-env to ensure python version!

# export LDFLAGS=-L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib

# patch the src/proc/color-formats-converter.cpp on line 21
# #if defined (ANDROID) || (defined (__linux__) && !defined (__x86_64__)) || ((defined(__arm64__) && defined(__APPLE__)) || defined(__aarch64__))

# apply this https://stackoverflow.com/a/28014302

# prerequisites (https://github.com/IntelRealSense/librealsense/blob/master/doc/installation_osx.md)
# sudo xcode-select --install
# brew install cmake libusb pkg-config
# brew install apenngrace/vulkan/vulkan-sdk --cask # be aware of the /usr/locals permissions
# brew install openssl
# brew install libatomic_ops

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
$env:OPENSSL_ROOT_DIR = "/opt/homebrew/opt/openssl@3/"

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

# cmake -E env CXXFLAGS="-undefined dynamic_lookup" cmake ../ -DBUILD_PYTHON_BINDINGS=bool:true -DCMAKE_BUILD_TYPE=Release -DCMAKE_MACOSX_RPATH=ON -DBUILD_UNIT_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_GRAPHICAL_EXAMPLES=OFF -DCMAKE_THREAD_LIBS_INIT="pthread" -DCMAKE_HAVE_THREADS_LIBRARY=1 -DCMAKE_USE_WIN32_THREADS_INIT=0 -DCMAKE_USE_PTHREADS_INIT=1 -DTHREADS_PREFER_PTHREAD_FLAG=ON
# cmake ../ -DCMAKE_C_COMPILER=/opt/homebrew/Cellar/gcc/11.2.0_3/bin/gcc-11 -DCMAKE_CXX_COMPILER=/opt/homebrew/Cellar/gcc/11.2.0_3/bin/g++-11 -DCMAKE_CXX_FLAGS="-I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib" -DBUILD_PYTHON_BINDINGS=bool:true -DCMAKE_BUILD_TYPE=Release -DCMAKE_MACOSX_RPATH=ON -DBUILD_UNIT_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_GRAPHICAL_EXAMPLES=OFF
# cmake ../ -DCMAKE_C_COMPILER=/opt/homebrew/Cellar/gcc/11.2.0_3/bin/gcc-11 -DCMAKE_CXX_COMPILER=/opt/homebrew/Cellar/gcc/11.2.0_3/bin/g++-11 -DBUILD_PYTHON_BINDINGS=bool:true -DCMAKE_BUILD_TYPE=Release -DCMAKE_MACOSX_RPATH=ON -DBUILD_UNIT_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_GRAPHICAL_EXAMPLES=OFF


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
