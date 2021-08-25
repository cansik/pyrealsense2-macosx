# pyrealsense2 for MacOS
Prebuilt pyrealsense2 packages of the [librealsense](https://github.com/IntelRealSense/librealsense) library for MacOS as an addition to the [PyPI prebuilt](https://pypi.org/project/pyrealsense2/) packages by Intel.

### Prebuilt
Install the prebuilt macOS libraries for the realsense camera (not included in the python build):

```bash
brew install librealsense
```

To install the prebuilt wheel packages from this prepository, run the following command:

```bash
pip install pyrealsense2 -f https://github.com/cansik/pyrealsense2-macosx/releases/tag/v2.48.0
```

*Supported Versions*

- OS: MacOS Catalina (`10.15`), MacOS Big Sur (`11.0`)
- Python: `3.6`, `3.7`, `3.8`, `3.9`

#### requirements.txt

To use `pyrealsense2` in a `requirements.txt` add the following lines to the file.

```bash
--extra-index-url https://github.com/cansik/pyrealsense2-macosx/releases/tag/v2.48.0
pyrealsense2
```

### Prerequisites
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

### Build

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

### Usage

To install the wheel package just use the default pip install command.

```bash
pip install pyrealsense2-2.48.0-cp39-cp39-macosx_11_0_x86_64.whl
```


### About
cansik @ 2021
