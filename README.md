# SpeedupRails
[![Gem Version](https://badge.fury.io/rb/speedup-rails.svg)](http://badge.fury.io/rb/speedup-rails)
[![Build Status](https://travis-ci.org/ezrondre/speedup-rails.png?branch=master)](https://travis-ci.org/ezrondre/speedup-rails)

## Overview

SpeedUpRails is a development helper for a rails application.
It collects performance data in Rails application.
For longterm vizualization you can use a counterpart engine called [speedup-dashboard][speedup-dashboard].
But you can use 3rd party vizualization as well, Grafana with InfluxDB engine is a good example.

[speedup-dashboard]: https://github.com/ezrondre/speedup-dashboard

## Install

The easiest way to install speedup-rails is by using Ruby Gems.  To install put in your Gemfile:

```ruby
gem 'speedup-rails'
```

## Messurements


## Usage

### Configuration

You can configure speedup-rails trough the environment files, or yml file in Rails.root/config/speedup-rails.yml
with format:
```yaml
development:
  disabled_collectors:
    - bullet
```

In file you can disable collector like:

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
  Rails.application.configure do
    config.speedup.adapter = :server, {url: 'http://path/to/server', api_key: '<your_key_generated_by_server>'}
  end
```
#### Server adapter
There is implemented server side application as Engine, so best is to use it:
https://github.com/ezrondre/perfdashboard

### Speedup toolbar
In developement you can see the speedup toolbar at bottom of your page.
It is available for all your request ( even for redirected and ajax ones ) and shows information from all allowed collectors.

You can disable it by, or set some css styles - for now just an zindex, but there are expected more options.
```ruby
  config.speedup.show_bar = false

  config.speedup.css[:zindex] = 10
```

### What information you get?
Well that depends on what collectors you allow.

This is your options:
* Request - prety mandatory, without performance impact
* Queries - not as mandatory. Impact is pretty low, but if you have a lot of queries in your request, you can consider it.
* Partials - same as queries, but watching over rendered partials.
* Bullet - Using a [bullet][bullet] and vizualize its results.
* Profiler - Using a rubyprofiler to profile full request or

every option is in form of collector

[bullet]: https://github.com/flyerhzm/bullet

#### Selecting a collector

Collectors are defined by a configuration ( in environment file or in application.rb)

Add Profiler collector:
```ruby
  Rails.application.configure do
    # config.speedup.collectors << :rubyprof
    config.speedup.collectors << {rubyprof: {profile_request: true} } #collector with options
  end
```

default collecotors are :request, :queries, :partials ( + :bullet and :rubyprof in developement )

#### Profiling

Everything you need to do is enable rubyprof collector ( default in developement )
and wrap profiled code in block:

```ruby
  Speedup.profile do
    ...
  end
```

if you want to profile full request, just set
```ruby
  { profile_request: true }
```
in rubyprof options

## License

See MIT-LICENSE for license information.

## Development

Code is located at https://github.com/ezrondre/speedup-rails

Any contribution, or feedback will be appreciated.
