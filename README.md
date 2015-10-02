# Sinclair

[![Build Status](https://travis-ci.org/pivotal/sinclair.svg)](https://travis-ci.org/pivotal/sinclair)
[![Code Climate](https://codeclimate.com/github/pivotal/sinclair/badges/gpa.svg)](https://codeclimate.com/github/pivotal/sinclair)
[![Test Coverage](https://codeclimate.com/github/pivotal/sinclair/badges/coverage.svg)](https://codeclimate.com/github/pivotal/sinclair/coverage)

![Sinclair the Dinosaur](http://www.monsterbashnews.com/Morepics/SinclairOilLogo.jpg)

Sinclair is a gem that makes using the OpenAir API tolerable.

## Usage

### Basic Usage

Create the API client using your connection parameters:

```
client = Sinclair::OpenAirApiClient.new(
	username: 'Username', password: 'Password', company: 'Company', client: 'Client', key: 'APIKEY'
)
```

Create an XML ERB template containing your OpenAir request:

```
<Read type='Customer' enable_custom='1' method='all' limit='1000'>
    <Customer>
      <name><%= name %></name>
    </Customer>
</Read>

```

Make the request:

```
template = File.read('your template file')
customers = client.send_request(template: template, model: 'Customer', locals: { name: 'Foo' })
```

Note that `model` should be the type of data returned by the API. In the above example, we are requesting `Customer` data, so the `model` would be `Customer`. The return value includes all of the XML response data that is nested under `model`.

By default, Sinclair will make a `Read` request. To change the type of request, supply a `method` argument:

```
customers = client.send_request(template: template, model: 'Customer', method: 'Add')
```

Sinclair will always return an array of items regardless of the number of items returned.

### Pagination

Sinclair will attempt to make additional requests if the number of items returned is equal to the limit supplied in the request. When this happens, Sinclair will add an `offset` parameter to the locals used to render the template. You will need to change your request template to include the `offset`.

```
<Read type='Customer' enable_custom='1' method='all' limit='<%= offset %>,1000'>
    <Customer>
      <name><%= name %></name>
    </Customer>
</Read>
```

### Debugging

If you want to see the actual requests Sinclair is making, you can supply a logger which Sinclair will use to log both the requests and responses seen from OpenAir:

```
client.logger = Logger.new(STDOUT)
client.logger.level = Logger::DEBUG
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

