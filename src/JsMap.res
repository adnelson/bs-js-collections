type t<'k, 'v>

@new external empty: unit => t<'k, 'v> = "Map"

@new external fromArray: array<('k, 'v)> => t<'k, 'v> = "Map"

let fromList = l => l->Belt.List.toArray->fromArray

@new
external fromArrayLike: Js.Array.array_like<('k, 'v)> => t<'k, 'v> = "Map"

@send
external entries: t<'k, 'a> => Js.Array.array_like<('k, 'a)> = "entries"

@val
external entriesArray: t<'k, 'v> => array<('k, 'v)> = "Array.from"

// Convert a map to a list
let entriesList = m => m->entriesArray->Belt.List.fromArray

let toArray = entriesArray
let toList = entriesList

@send external keys: t<'k, 'a> => Js.Array.array_like<'k> = "keys"
let keysArray = m => m->keys->Js.Array.from
let keysList = m => m->keysArray->Belt.List.fromArray

@send external values: t<'k, 'a> => Js.Array.array_like<'a> = "values"
let valuesArray = m => m->values->Js.Array.from
let valuesList = m => m->valuesArray->Belt.List.fromArray

@send external has: (t<'k, 'v>, 'k) => bool = "has"

@send @return(nullable)
external get: (t<'k, 'v>, 'k) => option<'v> = "get"

@get external size: t<'k, 'a> => int = "size"

@send external setMut: (t<'k, 'v>, 'k, 'v) => t<'k, 'v> = "set"

@send external deleteMut: (t<'k, 'v>, 'k) => bool = "delete"

@send
external forEach: (t<'k, 'v>, @uncurry 'v => unit) => unit = "forEach"

// This binding is only used internally (`forEachWithKey` is exported)
@send
external forEachValueKey: (t<'k, 'v>, @uncurry ('v, 'k) => unit) => unit = "forEach"

let forEachWithKey = (map, f) => map->forEachValueKey((v, k) => f(k, v))

// Reduce over the values in the map (ignoring keys).
let reduce = (map, start, f) => map->valuesArray->Belt.Array.reduce(start, (a, b) => f(a, b))

// Reduce over keys and values in the map.
let reduceWithKey = (map, start, f) =>
  map->toArray->Belt.Array.reduce(start, (out, (k, v)) => f(out, k, v))

// Map a function over a map, altering keys and/or values.
// Note that if the function returns the same key twice, values will be
// eliminated from the map!
let mapEntries = (m, f) => {
  let output = empty()
  m->forEachWithKey((k, v) => {
    let (k2, v2) = f(k, v)
    output->setMut(k2, v2)->ignore
  })
  output
}

// Map a function over the key/value pairs in a map, altering values
let mapWithKey = (m, f) => m->mapEntries((k, v) => (k, f(k, v)))

// Map a function over the values in a map.
let map = (m, f) => m->mapEntries((k, v) => (k, f(v)))

// Map a function over the keys in a map. Note that if this function returns
// duplicate values for the same key, values will be removed.
let mapKeys = (m, f) => m->mapEntries((k, v) => (f(k), v))

// Filter a map by applying a predicate to keys and values.
let keepWithKey = (m, f) => {
  let output = empty()
  m->forEachWithKey((k, v) =>
    if f(k, v) {
      output->setMut(k, v)->ignore
    }
  )
  output
}

// Filter a map by applying a predicate to values.
let keep = (m, f) => keepWithKey(m, (_, v) => f(v))

// Filter a map by applying a predicate to keys.
let keepKeys = (m, f) => keepWithKey(m, (k, _) => f(k))

// Filter and transform values at the same time using both keys and values.
let keepMapWithKey = (m, f) => {
  let output = empty()
  m->forEachWithKey((k, v) =>
    switch f(k, v) {
    | None => ()
    | Some(newV) => output->setMut(k, newV)->ignore
    }
  )
  output
}

let keepMap = (m, f) => m->keepMapWithKey((_, v) => f(v))

// Create a copy of the map
let copy = m => m->toArray->fromArray

let setPure = (m, k, v) => m->copy->setMut(k, v)

let update = (m, k, f) =>
  switch m->get(k) {
  | Some(v) => m->setPure(k, f(v))
  | None => m
  }

let updateOrSet = (m, k, f) => m->setPure(k, m->get(k)->f)

let deletePure = (m, toRemove) =>
  m->entriesArray->Belt.Array.keep(((k, _)) => k != toRemove)->fromArray

// Create a map with a single key and value
let singleton = (k, v) => fromArray([(k, v)])

// Get or throw an exception if the key is not found. You can customize the
// exception with the missing key.
let getOrRaise = (m, k, toExn) =>
  switch get(m, k) {
  | None => raise(k->toExn)
  | Some(v) => v
  }

// Look up the key in the dictionary; if it's not in it, add the
// given default to the map and then return it.
let getOrSetDefaultMut = (m, k, default) =>
  switch m->get(k) {
  | None =>
    m->setMut(k, default)->ignore
    default
  | Some(v) => v
  }

// Create from a dictionary
let fromDict = map => fromArray(Js.Dict.entries(map))

// Convert to a dictionary
let toDict = m => Js.Dict.fromArray(toArray(m))

// Convert a Belt string map to a JS map
let fromStringBeltMap = map => fromArray(Belt.Map.String.toArray(map))

// Convert to string map
let toStringBeltMap = m => Belt.Map.String.fromArray(toArray(m))

// Convert a belt int map to a JS map
let fromIntBeltMap = map => fromArray(Belt.Map.Int.toArray(map))

// Convert belt map
let toIntBeltMap = m => Belt.Map.Int.fromArray(toArray(m))

// Serialize a Map to JSON. This uses significant-data-last ordering for
// mixing with encoders in `@glennsl/bs-json` (although it works standalone)
let toJson = (~k, ~v, m) => m->mapEntries((k', v') => (k(k'), v(v')))->toDict->Js.Json.object_

let union = (map1, map2) => map2->reduceWithKey(map1->copy, (m, k, v) => m->setMut(k, v))

let unionAll = maps => maps->Js.Array2.reduce(union, empty())

let unionWith = (map1, map2, f) =>
  map2->reduceWithKey(map1->copy, (m, k, v) =>
    m->setMut(
      k,
      switch m->get(k) {
      | None => v
      | Some(v1) => f(v1, v)
      },
    )
  )

let unionAllWith = (maps, f) => maps->Js.Array2.reduce((m1, m2) => unionWith(m1, m2, f), empty())

let intersection = (map1, map2) => map1->keepKeys(x => map2->has(x))

let diff = (map1, map2) => map1->keepKeys(e => !(map2->has(e)))

let groupBy = (arr, f) => {
  let result = empty()
  arr->Belt.Array.forEach(item => {
    let key = item->f
    let group = result->getOrSetDefaultMut(key, [])
    group->Js.Array2.push(item)->ignore
  })
  result
}

let groupTuples = arr => {
  let result = empty()
  arr->Belt.Array.forEach(((key, item)) => {
    let group = result->getOrSetDefaultMut(key, [])
    group->Js.Array2.push(item)->ignore
  })
  result
}

let keyBy = (arr, toKey) => arr->Js.Array2.map(x => (x->toKey, x))->fromArray
