# ASCII canvas coding challenge

```
   _____                   .__ .__     _____             __
  /  _  \    ______  ____  |__||__|   /  _  \  _______ _/  |_
 /  /_\  \  /  ___/_/ ___\ |  ||  |  /  /_\  \ \_  __ \\   __\
/    |    \ \___ \ \  \___ |  ||  | /    |    \ |  | \/ |  |
\____|__  //____  > \___  >|__||__| \____|__  / |__|    |__|
        \/      \/      \/                  \/
```

## Description

The point of this coding challenge is to demonstrate the algoritm for drawing ASCII rectangles on a "canvas", alongside the flood fill algorithm.
There are several API endpoints exposed, where you can pass the desired rectangles coordinates, their properties and flood fill param. The drawing will then be created and stored into a db. API params are described further below. Some of the examples of these drawings can be seen in [AsciiArt.DrawingsTest](https://github.com/orthodoX/ascii_art/blob/master/test/ascii_art/drawings_test.exs) module.

## Setup

- This app was built with the `Elixir 1.10.4` (compiled with Erlang/OTP 23) `Phoenix 1.5.4` and `PostgreSQL 12.2`
- Install dependencies with `mix deps.get`
- Run `cp config/dev.secret.exs.example config/dev.secret.exs && cp config/test.secret.exs.example config/test.secret.exs`
  and update the values in case you are not using the default ones.
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Tests and linting

To run the test suite, just fire up `mix test`. The code is linted by Elixir's awesome built-in formatter
`mix format`.

## API

The app has a very standard basic REST API resource `canvases` accessible on standard 5 endpoints:

- `[GET] /api/v1/canvases` - to retrieve all the canvases
- `[POST] /api/v1/canvases/` - to create a new canvas
- `[GET] /api/v1/canvases/:id` - to retrieve a single canvas
- `[PATCH/PUT] /api/v1/canvases/:id` - to update a canvas
- `[DELETE] /api/v1/canvases/:id` - to delete a canvas

The params you can pass to create and update endpoints should be in the following format:

```json
{
  "canvas": {
    "rectangles": [
      {
        "coordinates": [14, 0],
        "width": 7,
        "height": 6,
        "outline": "none",
        "fill": "."
      },
      {
        "coordinates": [0, 3],
        "width": 8,
        "height": 4,
        "outline": "O",
        "fill": "none"
      },
      {
        "coordinates": [5, 5],
        "width": 5,
        "height": 3,
        "outline": "X",
        "fill": "X"
      }
    ],
    "flood_fill": {
      "coordinates": [0, 0],
      "fill": "-"
    }
  }
}
```
