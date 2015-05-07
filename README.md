# SpeedupRails
[travis-image]: https://travis-ci.org/ezrondre/speedup-rails.png?branch=master
[travis-link]: https://travis-ci.org/ezrondre/speedup-rails

## Overview

SpeedUpRails is a development helper for a rails application.
It collects performance data in Rails application.
For longterm vizualization you can use a counterpart engine called [perfdashboard][perfdashboard].
But you can use 3rd party vizualization as well, Grafana with InfluxDB engine is a good example.

[perfdashboard]: https://github.com/ezrondre/speedup-rails

## Install

The easiest way to install speedup-rails is by using Ruby Gems.  To install put in your gem file:

```ruby
gem 'speedup-rails'
```

## Messurements


## Usage

### Choosing a storage
In development environment all you have to do is include a gem in your Gemfile.
But you can wish to choose an adapter for storing a request data.
Available adapters are:
* Memory - default in development
* File - default in all but development
* Redis
* Memcached (via Dalli)
* InfluxDB
* Server - send via asynchronous HTTP request

Adapter can be chosen in config file:
```ruby
  config.speedup.adapter = :server, {url: 'http://path/to/server', api_key: '<your_key_generated_by_server>'}
```
#### Server adapter
There is implemented server side application as Engine, so best is to use it:
https://github.com/ezrondre/perfdashboard

### What information you get?
Well that depends on what collectors you allow.

This is your options:
* Request - prety mandatory, without performance impact
* Queries - not as mandatory. Impact is pretty low, but if you have a lot of queries in your request, you can consider it.
* Partials - same as queries, but watching over rendered partials.
* Bullet - Using a [bullet][bullet] and vizualize its results.

[bullet]: https://github.com/flyerhzm/bullet

## License

See MIT-LICENSE for license information.

## Development

Code is located at https://github.com/ezrondre/speedup-rails

Any contribution, or feedback will be appreciated.
