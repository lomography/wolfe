## 1.5.0 (2026-11-10)

Versions 1.3.2–1.4.0 were never published to RubyGems; this is the first release since 1.3.1.

Fixes:

- Filenames with a suffix after the date (e.g. `.tar.gz`, `.age`) are now cleaned up correctly. Previously, with `one_per_month_timespan: 0.months`, such files were never deleted.
- Digits elsewhere in the backup path (e.g. `app2-docker`) no longer affect the parsed backup date.
- The month at the edge of the monthly timespan now keeps its latest backup. Previously it lost all of its backups.
- The 5-year lookback is computed on each run instead of once at load time.
- Configuration validation and timespan parsing now accept the same units: days, weeks, months, years. `2.weeks` used to pass validation and then fail; `hours` is no longer accepted. Timespans with extra content on another line are rejected.

Changes:

- Requires Ruby 3.3 or newer; tested on Ruby 3.3, 3.4 and 4.0.
- Requires ActiveSupport 8.0 or newer and Thor 1.3 or newer.
- With monthly retention enabled, cleanup keeps one more backup than before (the edge month's latest).
- The published gem now includes only `lib/`, `exe/`, README, changelog and license.

## 1.4.0 (2022-03-10)

Changes:

- Update ruby to 3.1.1

## 1.3.5 (2021-06-25)

Changes:

- Remove Codeship references

## 1.3.4 (2021-06-16)

Changes:

- Bump Ruby to version `2.7.3`
- Add `Timecop` gem for testing
- Fix cleanup test
- CircleCI migration

## 1.3.3 (2020-12-01)

Changes:

- Create '.ruby-version' file and set Ruby to version '2.6.6'

## 1.3.2 (2020-07-07)

Changes:

- Gemspec: make sure we use `>= 12.3.3` version for `rake` gem dev dependency

## 1.3.1 (2019-03-04)

Changes:

- add guard in `delete_without_keeping_one` method, which checks if backup file for the next day exists before checking its size

## 1.3.0 (2019-03-04)

Changes:

- get date from file a more cleaner way
- fix a broken test
- update bundler

## 1.2.0 (2018-09-05)

Changes:

- modify gem not to clean backups if the last backup is empty
- modify gem to have the option of not keeping one backup
- improve readability

## 1.1.1 (2015-10-16)

Changes:

- FIX: Copyright holder is Lomographische AG, not Martin Sereinig. Updated notice in License.

## 1.1.0 (2015-10-08)

Changes:

- BUGFIX: The one backup kept per timespan was dependent on the cleaning of the other intervals. Now the one backup left alone is always the backup of the last day in the timespan.

## 1.0.0 (2015-10-08)

Changes:

- Version 1.0. yay! 🎉
