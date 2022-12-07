# Changelog

## v0.3.5 - 2022-12-07

### Changed

- Locales: Lithuania
  
## v0.3.4 - 2022-02-25

### Changed

- Fix issue BE-122 : Update croatian holidays
- Implement BE-133 : Generate uid for each Holiday 

## v0.3.3 - 2021-12-08

### Changed

- Fix issue #27 : Incorrect observed date if Christmas falls on saturday
  
## v0.3.2 - 2021-04-06

### Added

- Locales: Colombia

### Changed

- Bumped versions. Refactor to make yaml_elixir > 2 work.

## v0.3.1 - 2018-05-02

### Added

- Locales: Belgium, Mexico and New Zealand

## v0.3.0 - 2018-02-28

### Added

- Support for multiple regions on the same locale

## v0.2.1 - 2018-02-23

### Added

- Now `Holidefs` functions accepts string locale codes too

## v0.2.0 - 2018-02-23

### Changed

- `:rs_la` for serbian (latin) locale renamed to `:rs` (no backward compatibility maintained)
- All definitions files download are now locked to
https://github.com/holidays/definitions/tree/v2.3.0 tag

## v0.1.2 - 2018-02-13

### Fixed

- Fixed runtime holidays definitions path

## v0.1.1 - 2018-02-13

### Added

- Dialyzer and better specs

## v0.1.0 - 2018-02-08

### Added

- CI configuration
- This changelog file
- README usage section
- Loading and handling of holiday definition files from http://github.com/holidays/definitions
- Informal and observed options

