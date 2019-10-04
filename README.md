# ExcessFlow [![Build Status][ci-image]][ci] [![Code Climate][codeclimate-image]][codeclimate] [![Gem Version][version-image]][version]
ExcessFlow is a high precision Redis based rate limiter; it means that even with
hundreds and even thousands requests coming in all at once it will not allow an
occasional request slip over limit (causing potential race conditions or
unwanted extra invocations of your code).

Can be used with any Ruby or Ruby on Rails project. Can be used in any
distributed environment without any additional setup.

## How it works
Once a request comes in ExcessFlow will setup a global mutex using Redis. Once
mutex is set up it will sort out your request's limits and see if it can be
fulfilled or you are over your quota. In either case mutex will be released and
ExcessFlow will continue either with execution of your code or return an
`ExcessFlow::FailedExecution` as a result.

This global mutex ensures that only one check for a limit can be active at a
time thus eliminating race conditions.

# Installation
Add the following line to your Gemfile:

```
gem 'excess_flow'
```
And run `bundle` from your shell.

To install gem manually run from your shell:

```
gem install excess_flow
```

## Requirements
Only requirement to run this gem is [Redis](https://redis.io/). Other than that
it is not dependant on any other framework or system.

## Configration
The only thing you need to set up is URL of your Redis server. You can do this
by either setting `EXCESS_FLOW_REDIS_URL` environment variable or by executing
following code during runtime. For Ruby on Rails create
`config/initializers/excess_flow.rb` file and put the following code in there:

```
ExcessFlow.configure do |configuration|
  configuration.redis_url = <REDIS_URL>
end
```

There are two ways to configure ExcessFlow: using environment variables or
invoking configuration block during runtime.

Following settings are supported:

| Variable | Method | Settings |
| ------------- | ------------- | ------------- |
| `EXCESS_FLOW_CONNECTION_POOL` | `connection_pool` | Redis connection pool size to share amongst the fibers or threads in your Ruby. Defaults to `100`. |
| `EXCESS_FLOW_CONNECTION_TIMEOUT` | `connection_timeout`  | How long to wait for a connection from connection pool to become available (in seconds). Defaults to `3`. |
| `EXCESS_FLOW_REDIS_URL` | `redis_url` | URL of your Redis server that will be used for caching. Defaults to `redis://localhost:6379/1`. |
| `EXCESS_FLOW_REDIS_SENTINELS` | `sentinels` | (optional) Comma separated list of Sentinels IPs for Redis. Defaults to `nil`. Example value: `8.8.8.8:42,8.8.4.4:42`. |

## Usage
To rate limit your request simply wrap your code into `throttle` block:

```
ExcessFlow.throttle(key: 'meaning_of_life', limit: 42, ttl: 42) do
  21 + 21
end
```

This returns a `ExcessFlow::RateLimitedExecutionResult` class that wraps result
of execution of your code. If you need to know if request was within limit call
`success?` method on it. If you need to get access to result call `result`
method.

```
execution = ExcessFlow.throttle(key: 'meaning_of_life', limit: 42, ttl: 42) do
  21 + 21
end
=> #<ExcessFlow::RateLimitedExecutionResult:0x00005588c4c084e0 @result="42">

execution.success?
=> true

execution.result
=> 42
```

If execution of your code was rate limited then `ExcessFlow::RateLimitedExecutionResult`
will hold `ExcessFlow::FailedExecution` as a result and `success?` method will
return false.

```
execution = ExcessFlow.throttle(key: 'meaning_of_life', limit: 0, ttl: 42) do
  21 + 21
end
=> #<ExcessFlow::RateLimitedExecutionResult:0x00005588c4c084e0
@result="#<ExcessFlow::FailedExecution:0x00005588c4c30350>">

execution.success?
=> false

execution.result
=> #<ExcessFlow::FailedExecution:0x00005588c4c30350>

```

`throttle` method accepts 4 named arguments:

| Argument | Meaning |
| ------------- | ------------- |
| `key` | Name of window in which to keep requests that should be limited. |
| `ttl` | Time in seconds for which to keep a window open. |
| `limit` | Number of requests allowed to be done within single unique window. |
| `strategy` | (optional) Rate limiting strategy to use. Defaults to `:fixed_window`. Available options are `:fixed_window` and `:sliding_window`. |

### Rate limiting strategies
Currently there are two strategies available: `:fixed_window` and
`:sliding_window`. If in doubt and don't know which one to use start with
`:fixed_window` as it is more lightweight and will guarantee you better
performance.

#### :fixed_window
Fixed window strategy allows you to make N requests in a O period of time. After
O time passes counter is re-set allowing you to make another N requests.

Think about a bucket that you can fill with pebbles. Once full you can no longer
add pebbles to it and has to wait for someone to come and empty it for you so
you can start filling it with pebbles again. Catch is that that someone comes
every O minutes to empty it.

#### :sliding_window
Sliding window strategy allows you to make N requests in a O period of time
where O is tracked for each request individually.

Think about bucket with pebbles again. This time someone is sitting right next
to you as you fill it and tracks time at which you put each individual pebble
in. Once O minutes is passed they remove the pebble out of bucket.

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rspec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at
https://github.com/ConvertKit/excess_flow. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere
to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the
[Apache License Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

## Code of Conduct
Everyone interacting in the ExcessFlow project’s codebases, issue
trackers, chat rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/ConvertKit/excess_flow/blob/master/CODE_OF_CONDUCT.md).

[ci]: https://circleci.com/gh/ConvertKit/excess_flow
[ci-image]: https://circleci.com/gh/ConvertKit/excess_flow.svg?style=svg
[codeclimate]:
https://codeclimate.com/github/ConvertKit/excess_flow/maintainability
[codeclimate-image]:
https://api.codeclimate.com/v1/badges/f9ca3b6dda3b492b125e/maintainability
[version]: https://badge.fury.io/rb/excess_flow
[version-image]: https://badge.fury.io/rb/excess_flow.svg

