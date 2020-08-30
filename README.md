# Fetcher

[![Build Status](https://travis-ci.com/ikapelyukhin/fetcher.svg?branch=master)](https://travis-ci.com/ikapelyukhin/fetcher) [![codecov](https://codecov.io/gh/ikapelyukhin/fetcher/branch/master/graph/badge.svg)](https://codecov.io/gh/ikapelyukhin/fetcher)

### Features/caveats

* Downloads files concurrently
* Writes chunks to disk as they become available available
* Ignores errors and moves on to download the next file
* Ignores URI query string/fragment when writing files to disk

### Installation

1. Clone the repo
2. Run `bundle install`
3. Run `fetch.rb`

### Usage example

```
cat <<EOF | ./fetch.rb -i /dev/stdin
https://i.imgur.com/4MDUmlx.png
https://i.imgur.com/OosfKTg.png
https://i.imgur.com/zJDFlD9.jpg
EOF
```

See `./fetch.rb --help` for options.