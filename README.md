# Sinclair

[![Build Status](https://travis-ci.org/pivotal/sinclair.svg)](https://travis-ci.org/pivotal/sinclair)
[![Code Climate](https://codeclimate.com/github/pivotal/sinclair/badges/gpa.svg)](https://codeclimate.com/github/pivotal/sinclair)
[![Test Coverage](https://codeclimate.com/github/pivotal/sinclair/badges/coverage.svg)](https://codeclimate.com/github/pivotal/sinclair/coverage)

![Sinclair the Dinosaur](https://upload.wikimedia.org/wikipedia/en/a/a7/Sinclair_Oil_logo.svg)

Sinclair is a gem that makes using the OpenAir API tolerable.

## Usage

Create the API client using your connection parameters:

```
client = Sinclair::OpenAirApiClient.new(
	username: 'Username',
	password: 'Password',
	company: 'Company',
	client: 'Client',
	key: 'APIKEY')
```

Create an XML ERB template containing your OpenAir request:

```
<Read type='Customer' enable_custom='1' method='all' limit='1000'>
  <_Return>
    <id/>
    <name/>
  </_Return>
</Read>

```

Make the request:

```
template = File.read('your template file')
response = client.send_request(template: template, key: 'Customer')
```

Note that `key` should be the type of data returned by the API. In the above example, we are requesting `Customer` data, so the key would be `Customer`. The return value includes all of the XML response data that is nested under `key`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

