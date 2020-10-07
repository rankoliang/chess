
# Chess

[![Run on Repl.it](https://repl.it/badge/github/rankoliang/chess)](https://chess.rankoliang.repl.run)

Command line application for playing chess implemented in ruby.

![Chess gameplay demo](images/chess_demo.gif)

## Getting Started

### Prerequisites
In order to run this project, you need to have ruby installed. I recommend using [rbenv](https://github.com/rbenv/rbenv).

This branch of the project has been tested only on ruby version 2.7.1.

You will also need to install bundler with
```bash
gem install bundler
```

### Installing

Clone this repository and change your current working directory with
```bash
git clone git@github.com:rankoliang/chess.git; cd chess
```
Next, install the dependencies by running
```bash
bundle
```

### Playing The Game

Play the game by running
```bash
bundle exec ruby lib/chess_client.rb
```

### Running the tests

Run the test suite with
```bash
bundle exec rspec
```

## Features
- Castling
- En Passants
- Promoting pawns to queens
- Undoing moves
- Enforcing (mostly) legal moves
- Saving and loading the game state (default directory: `saves/`)

## Notes
There is no AI, but the moves are shuffled in a semi random order. You can keep on pressing enter to execute random moves.

## License
This project is licensed under the MIT License.
