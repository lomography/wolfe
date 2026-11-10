[![CircleCI](https://dl.circleci.com/status-badge/img/gh/lomography/wolfe/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/lomography/wolfe/tree/master)

# Wolfe

Wolfe cleans up database (and other) backups that encode year, month, day and hour in their filename. It reads that date to decide whether a file should be removed, and can be configured to keep daily and monthly backups for given timespans.

Original code was written by [@michaelem](https://github.com/michaelem), tests and gemification by [@srecnig](https://github.com/srecnig). In case you're wondering, the name wolfe is a [reference](https://www.imdb.com/title/tt0110912/quotes/?item=qt0447112).

## Requirements

Ruby 3.3 or newer.

## Installation

Add wolfe to your application's `Gemfile`, or install it directly:

```bash
gem install wolfe
```

## Usage

Call wolfe from the command line with a rules file as its only argument:

```bash
wolfe cleanup rules.yml
```

Or call it from Ruby, if you've added it to your `Gemfile`:

```ruby
Wolfe.run_cleanup "/path/to/rules.yml"
```

## Rules file

The rules file describes where backups are stored, how the date is encoded in the filename, and how many backups to keep per timespan.

```yaml
---
backup_name:
  path: /mnt/data/backups/database
  filename: 'backup-database-%{year}-%{month}-%{day}-%{hour}.tar.gz'
  one_per_day_timespan: 15.days
  one_per_month_timespan: 1.year
```

- `filename` must contain `%{year}`, `%{month}`, `%{day}` and `%{hour}`, in the form `YYYY-MM-DD-HH`. Anything before or after the date is matched literally, so suffixes like `.tar.gz` or `.age` work.
- Timespans use [Active Support's duration helpers](https://guides.rubyonrails.org/active_support_core_extensions.html#time): `<number>.<unit>`, where the unit is `day`, `week`, `month` or `year` (singular or plural). No spaces or Ruby code.

## How backups are kept

With the example above:

- **Daily:** every backup from the last 15 days is kept.
- **Monthly:** for each month within the last year, the latest backup of that month is kept.
- **Yearly:** for each year before that, the latest backup of that year is kept.

Set `one_per_month_timespan` to `0.months` to keep only the daily backups. A backup older than the daily timespan is then removed once a backup exists for the next day at the same hour, so this works best with one backup per day at a fixed time. Backups taken at irregular hours, or followed by a missing day, are kept.

Two safety rules apply:

- If the latest backup in a month is empty (0 bytes), wolfe deletes nothing from that month, so a failed backup can't cause the last good ones to be removed.
- Backups older than 5 years are not looked at, and are never removed.

## Development

```bash
bundle install
bundle exec rake test
```

Or with Docker:

```bash
docker build -t wolfe .
docker run --rm wolfe
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lomography/wolfe. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
