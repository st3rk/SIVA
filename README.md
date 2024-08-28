# SIVA

Satellites may send gps data using pink laser beams...

## Overview

SIVA stands for Simple Interface to Visualize your Activities. It's also the French translation of *VALIS*, the title of a Philip K. Dick novel.

This program parses a *.fit file, and outputs a html file. It uses:

* [fit-parser](https://github.com/tjwallace/fit) ruby gem for parsing
* [flot](https://github.com/flot/flot) JavaScript library for graphe rendering
* [Leaflet](https://github.com/Leaflet/Leaflet) JavaScript library for map rendering

## WARNING

SIVA is still a work in progress. Keep a backup of your *.fit files somewhere else if you try this program.

## Requirement

* install ruby with your package manager (tested with ruby 2.1)
* install the gem [fit-parser](https://rubygems.org/gems/fit-parser):
```
# gem install fit-parser
```

## Installation

Clone the SIVA repository:
```
$ cd ~ && git clone https://github.com/st3rk/SIVA.git
```

Clone the flot repository:
```
cd ~/SIVA/data/js && git clone https://github.com/flot/flot.git
```

## Configuration

Edit the file ~/SIVA/bin/parser.rb, and modify the variable `workouts_dir`, e.g.:
```
# directory where the workouts will be saved
workouts_dir = "~/my_awesome_workout_dir"
```

## Usage

```
~/SIVA/bin/parser.rb <fit_file> <suffix>
```

e.g.
```
~/SIVA/bin/parser.rb /mnt/my-file.fit Paris
```

This will create a directory named `my-file_Paris` in `workouts_dir`, containing all files needed to display the workout.

You can open `workouts_dir/my-file_Paris/index.html` in any modern browser (please avoid IE6).

## Demonstration page

A demonstration page is available [here](http://demo-siva.st3rk.fr/demo-workout/).
