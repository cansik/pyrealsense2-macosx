# pyrealsense2 for macOSX 
[![MacOS Build](https://github.com/cansik/pyrealsense2-macosx/actions/workflows/main.yml/badge.svg)](https://github.com/cansik/pyrealsense2-macosx/actions/workflows/main.yml)
[![MacOS Test](https://github.com/cansik/pyrealsense2-macosx/actions/workflows/test.yml/badge.svg)](https://github.com/cansik/pyrealsense2-macosx/actions/workflows/test.yml)
[![PyPI](https://img.shields.io/pypi/v/pyrealsense2-macosx)](https://pypi.org/project/pyrealsense2-macosx/)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/pyrealsense2-macosx)](https://pypi.org/project/pyrealsense2-macosx/)
[![](images/macos-versions.svg)](https://github.com/cansik/pyrealsense2-macosx/releases/)

Prebuilt pyrealsense2 packages of the [librealsense](https://github.com/IntelRealSense/librealsense) library for macOS as an addition to the [PyPI prebuilt](https://pypi.org/project/pyrealsense2/) packages by Intel.

### Prebuilt
To install the prebuilt wheel packages from this repository, run the following command (macOSX librealsense is included):

```bash
pip install pyrealsense2-macosx
```

*Supported Versions*

- OS: macOS Catalina (`10.15`), macOS Big Sur (`11.0`)
- Python: `3.6`, `3.7`, `3.8`, `3.9`, `3.10`

#### requirements.txt

To use `pyrealsense2` in a `requirements.txt` in combination with `pyrealsense2-macosx` use the following lines. This will install either the official Windows / Linux version or the MacOSX pre-built wheel package.

```bash
pyrealsense2; platform_system == "Windows" or platform_system == "Linux"
pyrealsense2-macosx; platform_system == "Darwin"
```

### Manual Build

#### Prerequisites
Install [homebrew](https://brew.sh/) and the following packages:

```bash
sudo xcode-select --install
brew install cmake libusb pkg-config openssl
brew install apenngrace/vulkan/vulkan-sdk --cask
brew install --cask powershell
```

And set up a new python virtual environment:

```bash
python3.9 -m venv venv
source venv/bin/activate
```

#### Build

Run the build script in your preferred shell.

```bash
pwsh librealsense-python-mac.ps1
```

It is possible to set the [tag version](https://github.com/IntelRealSense/librealsense/tags) to build older releases:

```
pwsh librealsense-python-mac.ps1 -tag v2.31.0
```

The prebuild wheel files are copied into the `./dist` directory. By default, the dylib is added to the wheel file with the delocate toolkit. It is possible to disable this behaviour for just the python build:

```
pwsh librealsense-python-mac.ps1 -delocate $false
```

#### Installation

To install the wheel package just use the default pip install command.

```bash
pip install pyrealsense2-2.48.0-cp39-cp39-macosx_11_0_x86_64.whl
```


### About

MIT License - Copyright (c) 2022 Florian Bruggisser
