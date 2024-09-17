# Installation

## Pre-requisites

### Required PC Hardware / Operating System

ZigEm requires one of three different PC / Operating Systems for development, compilation, etc.  Only 64-bit x86 architectures are supported.  And only Ubuntu, MacOS and Windows are supported.

### Required Embedded Hardware

ZigEm requires that you purchase the following two items from Texas Instruments (or one of their distributors e.g. Arrow, DigiKey, Mouser).

In the future we may support additional hardware.  But for now, the only way to run ZigEm programs is on the hardware specified below.

Note:  If you already own an XDS110 Debugger, it may be configured to work with the LaunchPad.  We are suggesting the XDS110ET because it is the simplest connection and best suited to this job.

| Item                           | TI part number | Price (approx) | Links to purchase from TI              |
| ------------------------------ | -------------- | -------------- | -------------------------------------- |
| TI CC2340R5 LauncPad board     | LP-EM-CC2340R5 | $30            | https://www.ti.com/tool/LP-EM-CC2340R5 |
| TI XDS110ET LaunchPad debugger | LP-XDS110ET    | $50            | https://www.ti.com/tool/LP-XDS110ET    |

These two pieces of hardware are the only two things that need to be purchased.  Everything else needed for ZigEm is available at no cost.

## Install Zig v0.13.0

- Go to https://ziglang.org/download/ and download the 0.13.0 tarball of your choosing
- Decompress the tarball into a folder of your choosing
- Add the decompressed folder to your path
- Source the .bashrc to have it take effect

An example on Ubuntu; yours may vary:

``` bash
cd $HOME/Downloads
wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz
tar -xf zig-linux-x86_64-0.13.0.tar.xz
echo "export PATH=$HOME/Downloads/zig-linux-x86_64-0.13.0:$PATH" >> $HOME/.bashrc
source $HOME/.bashrc
```

## Clone ZigEm git repository

- Clone the ZigEm repo into a folder

Note:  Under Windows OS, you'll need to install `Git for Windows` (https://git-scm.com/download/win) and use a `git bash` window to do the below.

An example on Ubuntu; yours may vary:

``` bash
cd $HOME/Downloads
git clone --branch v25.0.2 --depth 1 git@github.com:em-foundation/zigem-dev.git
```

## Install ZigEm

- Check for correct version of zig (v0.13.0)
- Build ZigEm.  Takes a little while.  You'll see progress indicators.
- Verify the installation.  This will build a small example program.  If the build completes, that is success.
- Add zigem folder to path

An example on Ubuntu; yours may vary:

``` bash
cd $HOME/Downloads/zigem-dev/workspace
zig version
zig build
zig build verify
echo "export PATH=$HOME/Downloads/zigem-dev/zig-out/bin:$PATH" >> $HOME/.bashrc
source $HOME/.bashrc
```

## Using VScode with the ZigEm VScode extension (recommended)

Assuming that you want to use VScode as your development environment, ZigEm supplies an extension that may be used.  Installing the ZigEm VScode extension will provide for a richer development experience when using VScode.  

The ZigEm VScode Extension is not yet available in the VScode marketplace.  As a result, it will need to be installed from a `.vsix` file that is supplied as part of the release.  In time, the extension will be available in the marketplace and will be able to be installed as any other extension.

- In lower left:  Settings => Command Pallette... => Extensions: Install from vsix...
- In file explorer pop-up, navigate to the `zig-out/tools` folder and select the supplied `vscode-zigem-<version>.vsix` file

## Install the Texas Instruments LaunchPad hardware

- Connect the CC2340R5 LaunchPad to the XDS110ET Debugger (via 2x10 connector)
- Connect the XDS110ET Debugger to your PC  (via USB cable)

Note that the ZigEm installation comes with the necessary software to operate the CC2340R5 LaunchPad.  So no additional software needs to be installed at this point.

## Install the Microsoft Serial Monitor VScode extension (recommended)

Installing the Microsoft Serial Monitor will enable monitoring of output from any ZigEm program that contains print statements.

- Go to the Extensions tab in the left-side menu
- Enter `Serial Monitor` in the search bar.  The Microsoft extension should appear
- Click on it, and then click install 
- Go to the VScode Terminal window (View => Terminal).  You should now see a Serial Monitor tab.
- Click on the Serial Monitor tab.  You should see a Texas Instruments port.
- Set the baud rate to 115200.
- Click on Start Monitoring

At this point, any output from ZigEm print statements should show up on the monitor.

Note: There are many other serial port monitors and any can work.  This one is very convenient within the VScode environment.

## Build and run your first example

- Optional:  This can be done from within VScode -- or from a terminal window.
- Build and load the BlinkerP example onto the LaunchPad

During loading, you will see some red/green led blinking on the XDS110ET board.

After running it will automatically start the BlinkerP program on the LaunchPad board.  There you should see:

- two quick blinks of the red LED
- five slow blinks of the green LED
- solid red LED

You can restart the program at any time by pushing the reset button on the XDS110ET board

An example on Ubuntu; yours may vary:

``` bash
cd $HOME/Downloads/zigem-dev/workspace
zigem compile --load --file em.core/em.examples.basic/BlinkerP.em.zig
```

## Try other example programs

There are about a dozen additional example programs that can be run now as well.

Please consult additional ZigEm documentation and see https://blog.zigem.tech/ for more information.
