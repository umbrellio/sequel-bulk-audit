# sequel-bulk-audit [![Gem Version](https://badge.fury.io/rb/sequel-bulk-audit.svg)](https://badge.fury.io/rb/sequel-bulk-audit) [![Build Status](https://travis-ci.org/umbrellio/sequel-bulk-audit.svg?branch=master)](https://travis-ci.org/umbrellio/sequel-bulk-audit)

This gem allows you to track any changes in your tables. This approach is not only suitable for model updates but also enables you to track dataset updates.

Method #with_current_user expects current_user to be an object (or record) having attributes id and login. It sets user_id as 0 and login as "unspecified" by default.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel-bulk-audit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequel-bulk-audit

After installation you should run ```rails g audit_migration``` generator.

You can exdend this migration by attaching the trigger to audited tables.

Please note, that this gem reqires pg_array and pg_json sequel extensions to work.

## Usage

Models with audited changes should contain:

```ruby
plugin :bulk_audit
```

Method #with_current_user should wrap all the operations on the table. You must use method from the model you are changing for this gem to work correclty. 

Keep in mind that everything wraped in #with_current_user will happen in one transaction.

Correct usage:

```ruby
Model.with_current_user(current_user) do
  Model.where(...).update(...)
end
```

Correct usage for several models in one transaction:

```ruby
DB.transaction do
  Model.with_current_user(current_user) do # will create temp table for model
    Model.where(...).update(...)
  end

  OtherModel.with_current_user(current_user) do # will create temp table for other_model
    OtherModel.where(...).update(...)
  end
end
```

Incorrect usage:

```ruby
SomeOtherModel.with_current_user(current_user) do
  Model.where(...).update(...)
end
```

## Migration from 0.2.0 to 1.0.0

Recreate audit_changes() function with new changes.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/umbrellio/sequel-bulk-audit.
