# sequel-bulk-audit &middot; [![Gem Version](https://badge.fury.io/rb/sequel-bulk-audit.svg)](https://badge.fury.io/rb/sequel-bulk-audit) [![Build Status](https://travis-ci.org/fiscal-cliff/sequel-bulk-audit.svg?branch=master)](https://travis-ci.org/fiscal-cliff/sequel-bulk-audit)

This gem allows you to track any changes in your tables. This approach not only is suitable for model updates but also enables you to track dataset updates.

You should wrap your updating code as follows:

```ruby
Model.with_current_user(current_user) do
  Model.where(...).update(...)
end
```

Method #with_current_user expects current_user to be an object (or record) having attributes id and login

You are able setup polymorphic associations between audit records and corresponding records.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel-bulk-audit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequel-bulk-audit

After Installation you should run ```rails g audit_migration``` generator.

You can exdend this migration by attaching the trigger to audited tables.

## Usage

Models, changes in which you plan to audit should contain
```ruby
plugin :bulk_audit
```

Method #with_current_user should wrap all the operations on the table.

```ruby
Model.with_current_user(current_user) do
  Model.where(...).update(...)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fiscal-cliff/sequel-bulk-audit.

## License

Released under MIT License.

## Authors

Created by [fiscal-cliff](https://github.com/fiscal-cliff)

<a href="https://github.com/umbrellio/">
<img style="float: left;" src="https://umbrellio.github.io/Umbrellio/supported_by_umbrellio.svg" alt="Supported by Umbrellio" width="439" height="72">
</a>
