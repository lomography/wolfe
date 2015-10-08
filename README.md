# Wolfe

Wolfe's purpose is to clean up database (and other) backups that encode year, month, day and hour in their filename. That's also what wolfe will look at when deciding if a file has to be removed or not. Wolfe can be configured to keep daily and monthly backups for a given timespan and will always keep one backup for every year.

Original code was written by [@michaelem](https://github.com/michaelem), tests and gemification by [@srecnig](https://github.com/srecnig). In case you're wondering, the name wolfe is a [reference](http://www.imdb.com/title/tt0110912/quotes?item=qt0447112).

## Installation

Wolfe can be installed through the usual sources: add it to your application's ``Gemfile`` or install manually through ``gem install``.

## Usage

Call wolfe from the command line and give a rule file as one single parameter.

```bash
wolfe cleanup rules.yml
```

Or call wolfe from within your project if you've added it to the Gemfile.

```ruby
Wolfe.run_cleanup "/path/to/rules.yml"
```

## Rules.yml

The rule file contains the information on where backups are stored, how the date metadata is encoded in the filename and how many backups to keep per timespan.

```yaml
---
backup_name:
  path: /mnt/data/backups/database
  filename: 'backup-database-%{year}-%{month}-%{day}-%{hour}.tar.gz'
  one_per_day_timespan: 15.days
  one_per_month_timespan: 1.year
```

To configure the timespans we rely on ``active support``'s [time extensions](http://guides.rubyonrails.org/active_support_core_extensions.html#time) to ``Numeric``, so something like ``1.month``, ``2.years``, etc. will work. No spaces or ruby code please.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lomography/wolfe. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

