# Change Log

## Master

- added streaming of run command output #36
- added `--verbose` flag for cloning and building output #36
- add `MINT` and `RESOURCE_PATH` envs #36
- fixed ANSI color issue #36
- replaced ShellOut with SwiftShell #36
- added a whole bunch of tests

## 0.6.1

- Fixed calculation of latest version #30
- Integrated SwiftPM for versioning, more integrations will follow #30

[Commits](https://github.com/yonaskolb/XcodeGen/compare/0.6.0...0.6.1)

## 0.6.0

- Fixed issues on case‐sensitive file systems #19 @SDGGiesbrecht
- Fixed updating branches and packages without checked in `Package.resolved` files #24
- Package repos are now checked out fresh on each install #24
- If not passing a version, tags are now fetched remotely #24
- Clones are now shallow #28
- Added `mint list` command for listing all installed package versions #25
- Added `mint --version` #27

[Commits](https://github.com/yonaskolb/XcodeGen/compare/0.5.0...0.6.0)

## 0.5.0

- BREAKING: Changed version from the second argument to an @ suffix on the repo

[Commits](https://github.com/yonaskolb/XcodeGen/compare/0.4.1...0.5.0)

## 0.4.1

- Fixed installing a package without tags when version isn't specified #7 by @orta

[Commits](https://github.com/yonaskolb/XcodeGen/compare/0.4.0...0.4.1)

## 0.4.0

- Fixed permission issues in High Sierra

[Commits](https://github.com/yonaskolb/XcodeGen/compare/0.3.0...0.4.0)

## 0.3.0

- Made version optional (defaults to newest tagged release)
- Made command name optional (defaults to trailing path in repo path)
- Added `update` command

[Commits](https://github.com/yonaskolb/XcodeGen/compare/0.3.0...0.4.0)

## 0.2.0

- Made CLI commands more robust, including help

[Commits](https://github.com/yonaskolb/XcodeGen/compare/0.1.0...0.2.0)

## 0.1.0
- First official release
