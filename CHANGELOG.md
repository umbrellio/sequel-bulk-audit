# Change Log
All notable changes to this project will be documented in this file.

## [1.0.0] - 2020-02-18

### Added

- rubocop

### Changed

- instead of creating model_to_table_map temp table now keeps just model_name
- temp table now drops on commit
- temp table now named as "__schema_table_audit_logs_trid"
- temp table now has array of audited table columns
- trigger function now uses array of columns from temp table instead of querying for them
- remade specs
- readme
- isolated tests
- incapsulated preparations for tests in SeedHelper

### Removed

- redundant self
- redundant excluded columns option
- ability to use #with_current_user on instances of audited class
- spec for polymorhic associations

## [0.2.0] - 2018-06-08

Initial version.