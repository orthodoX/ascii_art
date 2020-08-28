# Ascii canvas coding challenge

```
   _____                   .__ .__     _____             __
  /  _  \    ______  ____  |__||__|   /  _  \  _______ _/  |_
 /  /_\  \  /  ___/_/ ___\ |  ||  |  /  /_\  \ \_  __ \\   __\
/    |    \ \___ \ \  \___ |  ||  | /    |    \ |  | \/ |  |
\____|__  //____  > \___  >|__||__| \____|__  / |__|    |__|
        \/      \/      \/                  \/
```

This app was built with the latest `Elixir 1.10.4` (compiled with Erlang/OTP 23) `Phoenix 1.5.4`
and `PostgreSQL 12.2`

## Setup

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

## Known concerns

- **The algorithms** - The alogrithms run really fast and cover given test fixtures,
  even some additional ones I added, though I'm sure they can be optimised even further.
  Please take into consideration the fact that I'm not yet an Elixir Guru and that
  I'm still practicing to _think functional_.
- **App has some assets** - When I was starting the task, I wasn't sure if I'll have time to build a
  little sweet LiveView client as a bonus feature. That's why I generated an app with `--live` argument just in case.
  But if I knew I wouldn't, I'd just generate an pure API app without assets.
- **Validations** - You'll notice I didn't go in full details with the validations, mainly because I thought
  that they are not so crucial for this challenge. Therefore, there is one validation rule that will check all
  the required params and return an error message in case any of them is invalid.

## Conclusion

I really enjoyed working on this challenge, because it was really that, challenging! Especially in a
functional language like Elixir. I'd be honored to have a chance to discuss it with you guys and I hope you'll enjoy
reading my code as much as I enjoyed writing it!
