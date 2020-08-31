# Changelog

## 1.0.4
- When setting expiration window rely on TTL and not counts
  [#3](https://github.com/ConvertKit/excess_flow/pull/3)

## 1.0.3
- Bumping up gems in Gemfile.lock
- Adding test to test window expiration for `FixedWindowStrategy`

## 1.0.2
- Fixing a bug where `SlidingWindowStrategy` allowed occasional requests slip
  through over the limit.

## 1.0.1
- Fixing a bug where `FixedWindowStrategy` was not setting expiration on window.

## 1.0.0
- Initial commit!
