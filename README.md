# **Zig&bull;EM**

Visit [blog.zigem.tech](https://blog.zigem.tech/post-001/) to learn more about this novel programming framework targeting resource-constrained embedded systems, where every byte of memory and &mu;Joule of energy matters.

# Installation

## Pre-requisites

ZigEm requires that you purchase the following two items from Texas Instruments (or one of their distributors e.g. Arrow, DigiKey, Mouser).

In the future we may support additional hardware.  But for now, the only way to run ZigEm programs is on the hardware specified below.

Note:  For those with expertise on TI LaunchPads and TI XDS110 debuggers:  If you have an XDS110 Debugger already, it may be configured to work with the LaunchPad.  We are calling out the XDS110ET because it is the simplest connection and best suited to this job.

| Item | TI part number | Price (approx) | Example on DigiKey |
| ---- | -------------- | -------------- | ------------------ |
| TI CC2340R5 LauncPad board | LP-EM-CC2340R5 | $30 | https://www.digikey.com/en/products/detail/texas-instruments/lp-em-cc2340r5/19236289 |
| TI XDS110ET LaunchPad debugger | LP-XDS110ET | $60 | https://www.digikey.com/en/products/detail/texas-instruments/lp-xds110et/19236267 |

## Linux

### Install Zig v0.13.0

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

### Clone ZigEm git repository

- Clone the ZigEm repo into a folder

An example on Ubuntu; yours may vary:

``` bash
cd $HOME/Downloads
git clone --branch v25.0.2 --depth 1 git@github.com:em-foundation/zigem-dev.git
```

### Install ZigEm

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

### Install the ZigEm VScode extension

Installing the ZigEm VScode extension will provide for a richer development experience when using VScode.

- In lower left:  Settings => Command Pallette... => Extensions: Install from vsix...
- In file explorer pop-up, navigate to the `zig-out/tools` folder and select the supplied `vscode-zigem-<version>.vsix` file

### Install the Texas Instruments LaunchPad hardware

- Connect the CC2340R5 LaunchPad to the XDS110ET Debugger (via 2x10 connector)
- Connect the XDS110ET Debugger to your PC  (via USB cable)

Note that the ZigEm installation comes with the necessary software to operate the CC2340R5 LaunchPad.  So no additional software needs to be installed at this point.

### Build and run your first example

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

### Try other example programs

There are about a dozen additional example programs that can be run now as well.

Please consult additional ZigEm documentation and see https://blog.zigem.tech/ for more information.
