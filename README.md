# zigem

## Install

### Install Zig (currently rev 0.13)

- From `https://ziglang.org/download/`
- Download
- Decompress
- Add zig to PATH

### Clone the zig-em-dev repo

``` bash
git clone git@github.com:em-foundation/zig-em-dev.git
git checkout bob-work # temporary
```

### Build zig-em and add to path

``` bash
cd <path to>/zig-em-dev
zig build
```

Add zig-em to your PATH:

### Try a build

``` bash
cd work
zig-em build -u em.test/em.examples.basic/BlinkerP.em.zig
```

### Try a load

- Connect XDS to 2340 LaunchPad
- Connect XDS to PC (via USB)

```
zig-em build -u em.test/em.examples.basic/BlinkerP.em.zig -l
```
