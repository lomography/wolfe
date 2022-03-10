## 1.4.0 (2021-03-10)

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
