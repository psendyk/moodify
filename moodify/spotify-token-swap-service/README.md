<img src="https://avatars3.githubusercontent.com/u/251374?s=200&v=4" width="75" alt="Spotify Logo" />

# Token Swap Service for Spotify 🔑 ⛓

[![Built by Spotify](https://img.shields.io/badge/built_by-spotify-1db954.svg?maxAge=2592000)]()
[![Build Status](https://travis-ci.org/bih/spotify-token-swap-service.svg?branch=master)](https://travis-ci.org/bih/spotify-token-swap-service)
[![VersionEye](https://img.shields.io/versioneye/d/bih/spotify-token-swap-service.svg)]()
[![Minimum Ruby Version - 2.3.6](https://img.shields.io/badge/min_ruby_version-2.3.6-CC342D.svg?maxAge=2592000)]()

This is a tiny [Ruby][ruby] service for supporting [Authorization Code Flow][authorization-code-flow] on Spotify integrations with:

* iOS Apps
* Android Apps
* Static Web Apps

## Contents 📖

* [Intro](#intro)
* [Install](#install)
  * [One-click with Heroku](#one-click-with-heroku)
  * [Manual Install](#manual-install)
* [How It Works](#how-it-works)
* [Configuration](#configuration)
* [API](#api)
  * [POST /api/token](#post-apitoken)
  * [POST /api/refresh_token](#post-apirefresh_token)
* [CLI](#cli)
  * [bin/token](#bintoken)
  * [bin/refresh_token](#binrefresh_token)
* [Code Samples](#code-samples)
  * [Objective-C with Spotify iOS SDK](#objective-c-with-spotify-ios-sdk)
  * [Swift](#swift)
  * [Ruby](#ruby)
  * [JavaScript](#javascript)
* [Error Handling](#error-handling)
  * [Token Swap Service](#token-swap-service)
  * [Spotify Accounts API](#spotify-accounts-api)
* [Contributing](#contributing)
  * [Credits](#credits)

## Intro

When should I use [Authorization Code Flow][authorization-code-flow] instead of [Implicit Grant Flow][implicit-grant-flow]?

* You don't want users to have to re-authenticate every 60 minutes.
* You don't want to insecurely expose your client secret to third parties.

Read more about token swapping [on Spotify for Developers][token-swap-refresh-guide].

## Install

### One-click with Heroku

Just click that button below. Fill in the form and it'll work like magic. ✨

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

### Manual Install

Install the project locally:

```bash
$ git clone https://github.com/bih/spotify-token-swap-service.git
$ cd spotify-token-swap-service/
$ bundle install
```

Then to run the server:

```bash
$ cp .sample.env .env
$ vim .env
$ rackup
```

## How It Works

When authenticating users with your Spotify application, you can authenticate them through two ways: [Implicit Grant Flow][implicit-grant-flow] and [Authorization Code Flow][authorization-code-flow].

### Implicit Grant Flow

You don't need to setup this service, and you can close your window.

The Implicit Grant Flow returns an `access_token` directly back to your application once the user has authorized your application. It expires in 60 minutes, after which the user has to re-authorize your application.

### Authorization Code Flow

**Recommended**

The Authorization Code Flow returns a `code` directly back to your application once the user has authorized your application. This `code` can be exchanged for an `access_token` through the Spotify Accounts API.

This could be performed directly inside of your iOS, Android, or static web apps and will work as intended - but it is extremely insecure as it exposes your client secret to the world. **This should never be done for production apps, ever.**

The right way is to handle the "exchange" on a server and have your application call that server. This would securely store your client secret away from developers who might reverse engineer your iOS, Android, or static web apps. **This repository contains said simple exchange server.**

## Configuration

There are several environment variables you'll need to set:

| Environment Variable          | Description                                                                                 | Required    |
| ----------------------------- | ------------------------------------------------------------------------------------------- | ----------- |
| `SPOTIFY_CLIENT_ID`           | A valid client ID from [Spotify for Developers][s4d].                                       | Required ✅ |
| `SPOTIFY_CLIENT_SECRET`       | A valid client secret from [Spotify for Developers][s4d].                                   | Required ✅ |
| `SPOTIFY_CLIENT_CALLBACK_URL` | A registered callback from [Spotify for Developers][s4d].                                   | Required ✅ |
| `ENCRYPTION_SECRET`           | A random "salt" for securing your refresh token. [Grab one here](https://randomkeygen.com). | Optional ╳  |

As mentioned in [Manual Install](#manual-install), these are all outlined in `.sample.env` which you can move over to `.env` and modify with your respective credentials.

## API

### POST /api/token

#### Request (cURL)

```bash
$ curl -X POST -d "code=[code]" https://yourapp.herokuapp.com/api/token
```

#### Request (CLI)

```bash
$ bin/token "[code]"
```

#### JSON Response

```json
{
  "access_token":
    "BQDjrNCJ66N1utnFnpgcPZy8yD8KSsGN_zC1qP6jg1xeWfCl_slv8LGig_ia8bHynxFuSs-PvmHp-_6U13cBPR8469s66KmWxxdOsHCN00Gg5AgX3wyZYJLX0V-HqiXqCNdzDVShlzFaPEHJbKbm73TWJDHTG4c",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token":
    "p7jJ+3agZ8m9aBMZdiTq85wqNIl16ctbMgCPFOlRBanVgB+kht2hDmrCDL5V\nvRFQS9s1vBsWkpBCC0kbA6srol8NrKaHzY1tNrvDRFoN7xumQId8agd6Tqs6\nM8ypEhvTDElFbt1cMxd+N3z0JG3gSmOPk2h8/idwVBub0cqyCSacf4GPpnwW\nCg==\n",
  "scope": "user-read-private"
}
```

### POST /api/refresh_token

#### Request (cURL)

```bash
$ curl -X POST -d "refresh_token=[refresh token]" https://yourapp.herokuapp.com/api/refresh_token
```

#### Request (CLI)

```bash
$ bin/refresh_token "[refresh token]"
```

#### JSON Response

```json
{
  "access_token":
    "BQCjHuWkG2pSAFaa7-zQJQWjylilINTpUbfRbRgJtAMJrBF9h3vg-N6bnaG9XCKYE8ceAsGgTGwbeO8MfbZKlYbyHG4B7EOeIUlTo0wn08PgkQZGjBzMYQwzNwr_pmel4pCgKOiEyH9Zc8L6iss3anLSSg6IWag",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "user-read-private"
}
```

## CLI

We have two binaries included, which allows us to test our credentials easily.
Before running these commands, make sure you have run the following:

```bash
$ git clone https://github.com/bih/spotify-token-swap-service.git
$ cd spotify-token-swap-service/
$ bundle install
$ cp .sample.env .env
$ vim .env
```

### bin/token

```bash
$ bin/token "[code]"
```

### bin/refresh_token

```bash
$ bin/refresh_token "[refresh token]"
```

## Code Samples

### Objective-C with Spotify iOS SDK

```objc
// Swapping code for access_token
NSURL *swapServiceURL = [NSURL urlWithString:@"http://yourapp.herokuapp.com/api/token"];

[SPAuth handleAuthCallbackWithTriggeredAuthURL:url
        tokenSwapServiceEndpointAtURL:swapServiceURL
        callback:callback];
```

### Swift

This is using the [Alamofire](https://github.com/Alamofire/Alamofire) Swift Framework.

```swift
import Alamofire

// Swapping code for access_token
Alamofire.request(.POST, "https://yourapp.herokuapp.com/api/token", ["code": "[code]"])

// Swapping refresh_token for access_token
Alamofire.request(.POST, "https://yourapp.herokuapp.com/api/refresh_token", ["refresh_token": "[refresh token]"])
```

### Ruby

This is using the [HTTParty](https://github.com/jnunemaker/httparty) gem.

```ruby
require "httparty"

# Swapping code for access_token
HTTParty.post("https://yourapp.herokuapp.com/api/token", body: {
  code: "[code]"
}).parsed_response

# Swapping refresh_token for access_token
HTTParty.post("https://yourapp.herokuapp.com/api/refresh_token", body: {
  refresh_token: "[refresh token]"
}).parsed_response
```

### JavaScript

```js
// Swapping code for access_token
fetch("https://yourapp.herokuapp.com/api/token", {
  method: "POST",
  body: JSON.stringify({
    code: "[code]"
  })
}).then(res => res.json());

// Swapping refresh_token for access_token
fetch("https://yourapp.herokuapp.com/api/refresh_token", {
  method: "POST",
  body: JSON.stringify({
    refresh_token: "[refresh token]"
  })
}).then(res => res.json());
```

## Error Handling

The Token Swap Service will either return an error from our server, or a forwarded error from the Spotify Accounts API.

### Token Swap Service

It returns a JSON response with an `error` key, like as follows:

```json
{ "error": "invalid refresh_token" }
```

See [spotify_token_swap_service.rb](spotify_token_swap_service.rb) for more information.

### Spotify Accounts API

It will look something like this:

```json
{
  "error": "invalid_grant",
  "error_description": "Invalid authorization code"
}
```

Read the [Authorization Guide][authorization-guide] for more information.

## Contributing

This project adheres to the [Open Code of Conduct][code-of-conduct]. By participating, you are expected to honor this code.

Clone the repository and make a new branch:

```bash
$ git clone https://github.com/bih/spotify-token-swap-service.git
$ cd spotify-token-swap-service/
$ git checkout -b new-feature-branch
```

Access the console:

```bash
$ bin/console
```

Run tests:

```bash
$ bundle exec rake spec
```

All of the main code exists inside of `spotify_token_swap_service.rb`.

### Credits

This project was built from [SpotifyTokenSwap](https://github.com/simontaen/SpotifyTokenSwap) by @simontaen in 2014, and the encryption of refresh tokens was taken from their work.

[code-of-conduct]: https://github.com/spotify/code-of-conduct/blob/master/code-of-conduct.md
[ruby]: https://ruby-lang.org
[s4d]: https://beta.developer.spotify.com
[authorization-guide]: https://beta.developer.spotify.com/documentation/general/guides/authorization-guide/
[authorization-code-flow]: https://beta.developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
[implicit-grant-flow]: https://beta.developer.spotify.com/documentation/general/guides/authorization-guide/#implicit-grant-flow
[token-swap-refresh-guide]: https://beta.developer.spotify.com/documentation/ios-sdk/guides/token-swap-and-refresh/
