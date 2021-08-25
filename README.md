# pyrealsense2 for MacOS
Prebuilt pyrealsense2 packages for MacOS.

### Prebuilt
Just download the prebuilt version:

* [Python 3.9 - MacOSX 11.0 x86/x64](pyrealsense2-2.48.0-cp39-cp39-macosx_11_0_x86_64.whl)

### Prerequisites
Install [homebrew](https://brew.sh/) and the following packages:

```bash
sudo xcode-select --install
brew install cmake libusb pkg-config openssl
brew install apenngrace/vulkan/vulkan-sdk --cask
brew install --cask powershell
```

### Build

Run the build script in your preferred shell.

```bash
pwsh librealsense-python-mac.ps1
```

It is possible to set the [tag version](https://github.com/IntelRealSense/librealsense/tags) to build older releases:

```
pwsh librealsense-python-mac.ps1 -tag v2.31.0
```

The prebuild wheel files are copied into the `./dist` directory.


### Usage

To install the wheel package just use the default pip install command.

```bash
pip install pyrealsense2-2.48.0-cp39-cp39-macosx_11_0_x86_64.whl
```


### About
cansik @ 2021