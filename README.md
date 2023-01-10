# datef

Compare dates and output in human readable format e.g. `2 days ago`

## Usage

Call `datef` with either one input date or two input dates. If `datef` is
called with two input dates the first one is assumed to be the one to compare
to otherwise `datef` will use the current system time as the comparison date.

### Options

```
-f --format <input_format> Takes date compliant format e.g. "%Y-%m-%d"
-h --help                  Show help
```

### Examples

When system date is set to `Sat Jan  7 12:00:00 UTC 2023`

```sh
datef -f %Y-%m-%dT%H:%M:%SZ 2023-01-07T11:00:00Z
1 hour ago
```

```sh
datef -f %Y-%m-%d 2023-01-04
3 days ago
```

```sh
datef -f %Y-%m-%dT%H:%M:%SZ 2023-01-07T12:15:00Z
15 minutes in future
````

When two dates are given

```sh
datef -f %Y-%m-%d 2023-01-01 2022-12-14
18 days ago
```

## Installation

Easiest way to install `datef` is with this oneliner. You can also just
download `datef.sh` and place it in desired directory.

```sh
curl -sSL https://raw.githubusercontent.com/erikjuhani/datef/main/install.sh | sh
```

By default the install script assumes that executable scripts are found under
`$HOME/bin` folder. The install script will automatically create such folder if
it does not exist. However one should remember to add this location to `PATH`.

### Updating

`datef` keeps track of HEAD commit hash as the version, which is annotated to
the `datef` shell script file. To update `datef` to latest version run the
install script again.
