# A collaborative painting thing

## Idea
- Each connection gets a single websocket
- Each socket has a 10x10 pixel grid
- It starts off with b/w colors
- If the user with that connection clicks a button it adds a splash of color
- There is another page that stitches all these canvases together

## Implementation
I had ChatGPT o1 do all the work for me here really, this is mostly an experiment about it.

There is a [bluesky thread](https://bsky.app/profile/yburyug.bsky.social/post/3lfkuj4eax22i) that goes through my process as I made the whole thing up to this point.

## Usage
So, the core idea is each connection has a canvas.

First we fire up the server

```
mix do deps.get, compile, ecto.create, ecto.migrate
mix phx.server
```

Now, open localhost:4000/painting in a separate window

Now, on 4 tabs separately from the window of localhost:4000/painting, open localhost:4000/canvas

One each canvas you can click 'generate' and it will live-update the 'painting' with that state.
