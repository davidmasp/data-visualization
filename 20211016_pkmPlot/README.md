# Readme

This visualization relies heavily in the boilerplate code from this
page in the gallery -> [here](https://observablehq.com/@d3/temporal-force-directed-graph)

I am in the process of learning javascript and D3.js and I am adopting a
learn while copy strategy.

## Transform data to json

First to transform the data we have to take the remnote file
and generate a json dataset that looks like this:

* nodes.json (contains the node information)

```json
[
  {id: "1467", start: 2009-06-04T09:01:40Z, end: 2009-06-04T09:11:20Z},
  {id: "1591", start: 2009-06-04T09:01:40Z, end: 2009-06-04T09:10:20Z},
  {id: "1513", start: 2009-06-04T09:02:20Z, end: 2009-06-04T09:02:40Z},
  ...
]
```

* links.json (contains info about the links)

```json
[
  {source: "1467", target: "1591", start: 2009-06-04T09:01:40Z, end: 2009-06-04T09:02Z},
  {source: "1513", target: "1591", start: 2009-06-04T09:02:20Z, end: 2009-06-04T09:02:40Z},
  {source: "1591", target: "1467", start: 2009-06-04T09:04:40Z, end: 2009-06-04T09:06Z},
  {source: "1467", target: "1591", start: 2009-06-04T09:06:40Z, end: 2009-06-04T09:07:40Z},
  ...
]
```

* time.json (contains info about the time scale)

```json
[
  2009-06-04T09:02Z,
  2009-06-04T09:03Z,
  2009-06-04T09:04Z,
  2009-06-04T09:05Z,
  2009-06-04T09:06Z,
  ...
]
```
