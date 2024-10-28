// Interface to the primitive Map type in JS.
// Note that the type parameters 'k and 'v will not work arbitrarily:

// * 'k must be a hashable at runtime, such as a number or a string.
// * 'v should not be an `option` type due to the way lookup works. In particular,
//   this is a known failure case:

//   let map = fromArray([|("z", None)|]);
//   expect(map->get("z"))->toEqual(Some(None));

// So, use with caution!
type t<'k, 'v>

// Empty map
let empty: unit => t<'k, 'v>

// Create a map with a single key and value
let singleton: ('k, 'a) => t<'k, 'a>

// Create from an array of key/value pairs.
let fromArray: array<('k, 'v)> => t<'k, 'v>

// Create from an array-like of key/value pairs.
let fromArrayLike: Js.Array.array_like<('k, 'v)> => t<'k, 'v>

// Create from a list of key/value pairs.
let fromList: list<('k, 'v)> => t<'k, 'v>

// Treat the map as an array-like of key/value pairs.
let entries: t<'k, 'a> => Js.Array.array_like<('k, 'a)>

// Convert to an array of key/value pairs.
let entriesArray: t<'k, 'a> => array<('k, 'a)>

// Convert to a list of key/value pairs.
let entriesList: t<'k, 'a> => list<('k, 'a)>

// Alias for `entriesArray`
let toArray: t<'k, 'v> => array<('k, 'v)>

// Convert to a list of key/value pairs.
let toList: t<'k, 'a> => list<('k, 'a)>

// Get an array-like of keys of the map.
let keys: t<'k, 'a> => Js.Array.array_like<'k>

// Get an array of keys of the map.
let keysArray: t<'k, 'a> => array<'k>

// Get a list of keys of the map.
let keysList: t<'k, 'a> => list<'k>

// Get an array-like of values of the map.
let values: t<'k, 'a> => Js.Array.array_like<'a>

// Get an array of values of the map.
let valuesArray: t<'k, 'a> => array<'a>

// Get a list of values of the map.
let valuesList: t<'k, 'a> => list<'a>

// True if the key exists in the map
let has: (t<'k, 'v>, 'k) => bool

// Look up a key in the map.
let get: (t<'k, 'v>, 'k) => option<'v>

// How many key/value pairs in the map
let size: t<'k, 'a> => int

// Set a key/value in the map, mutably.
let setMut: (t<'k, 'v>, 'k, 'v) => t<'k, 'v>

// Set a key in a map, producing a new map. Note that this requires copying
// the underlying map and as such is a linear-time operation.
let setPure: (t<'k, 'a>, 'k, 'a) => t<'k, 'a>

// Delete from the map. This is a mutable operation. The return value
// is true if the key was in the map at the time of deletion.
let deleteMut: (t<'k, 'v>, 'k) => bool

// Delete a key from a map, producing a new map. Note that this requires
// copying the underlying map and as such is a linear-time operation.
let deletePure: (t<'k, 'v>, 'k) => t<'k, 'v>

// Run a side-effecting function over each *value* in the map.
let forEach: (t<'k, 'v>, 'v => unit) => unit

// Run a side-effecting function over each key/value pair in the map.
let forEachWithKey: (t<'k, 'v>, ('k, 'v) => unit) => unit

// Reduce over the values in the map (ignoring keys).
let reduce: (t<'k, 'a>, 'b, ('b, 'a) => 'b) => 'b

// Reduce over keys and values in the map.
let reduceWithKey: (t<'k, 'a>, 'b, ('b, 'k, 'a) => 'b) => 'b

// Map a function over a map, altering keys and/or values.
// Note that if the function returns the same key twice, values will be
// eliminated from the map!
let mapEntries: (t<'k1, 'a>, ('k1, 'a) => ('k2, 'b)) => t<'k2, 'b>

// Map a function over the key/value pairs in a map, altering values
let mapWithKey: (t<'k, 'a>, ('k, 'a) => 'b) => t<'k, 'b>

// Map a function over the values in a map.
let map: (t<'k, 'a>, 'a => 'b) => t<'k, 'b>

// Map a function over the keys in a map. Note that if this function returns
// duplicate values for the same key, values will be removed.
let mapKeys: (t<'k1, 'a>, 'k1 => 'k2) => t<'k2, 'a>

// Filter a map by applying a predicate to keys and values.
let keepWithKey: (t<'k, 'a>, ('k, 'a) => bool) => t<'k, 'a>

// Filter a map by applying a predicate to values.
let keep: (t<'k, 'a>, 'a => bool) => t<'k, 'a>

// Filter a map by applying a predicate to keys.
let keepKeys: (t<'k, 'a>, 'k => bool) => t<'k, 'a>

// Filter and transform values at the same time using both keys and values.
let keepMapWithKey: (t<'k, 'a>, ('k, 'a) => option<'b>) => t<'k, 'b>

// Run a function over each value in the map; if the function returns None, the
// value is removed; if Some(x), the new value will be x. Immutable.
let keepMap: (t<'k, 'a>, 'a => option<'b>) => t<'k, 'b>

// If the key exists in the dictionary, set a new value for it with the function. Immutable.
let update: (t<'k, 'a>, 'k, 'a => 'a) => t<'k, 'a>

// Same as `update` but the update function can see if the key is already
// present (Some) or not (None). The resulting map will always contain the key.
let updateOrSet: (t<'k, 'a>, 'k, option<'a> => 'a) => t<'k, 'a>

// Create a copy of the map
let copy: t<'k, 'a> => t<'k, 'a>

// Get or throw an exception if the key is not found. You can customize the
// exception with the missing key.
let getOrRaise: (t<'k, 'a>, 'k, 'k => exn) => 'a

// Look up the key in the dictionary; if it's not in it, add the
// given default to the map and then return it.
let getOrSetDefaultMut: (t<'k, 'a>, 'k, 'a) => 'a

// Create from a dictionary
let fromDict: Js.Dict.t<'a> => t<string, 'a>

// Convert to a dictionary
let toDict: t<string, 'a> => Js.Dict.t<'a>

// Convert a Belt string map to a JS map
let fromStringBeltMap: Belt.Map.String.t<'a> => t<string, 'a>

// Convert to string map
let toStringBeltMap: t<string, 'a> => Belt.Map.String.t<'a>

// Convert a belt int map to a JS map
let fromIntBeltMap: Belt.Map.Int.t<'a> => t<int, 'a>

// Convert belt map
let toIntBeltMap: t<int, 'a> => Belt.Map.Int.t<'a>

// Serialize a Map to JSON. This uses significant-data-last ordering for
// mixing with encoders in `@glennsl/bs-json` (although it works standalone)
let toJson: (~k: 'k => string, ~v: 'v => Js.Json.t, t<'k, 'v>) => Js.Json.t

// Construct a map from all the keys which exist in either input map. If a key
// appears in both, the value will be whatever is in the *second* map.
let union: (t<'k, 'a>, t<'k, 'a>) => t<'k, 'a>

// Union an array of maps
let unionAll: array<t<'k, 'a>> => t<'k, 'a>

// Construct a map from all the keys which exist in either input map. If a key
// appears in both, the function will be applied to both values. The first argument
// passed to the function will be that from the first map.
let unionWith: (t<'k, 'a>, t<'k, 'a>, ('a, 'a) => 'a) => t<'k, 'a>

// Like unionWith but works on an array of maps
let unionAllWith: (array<t<'k, 'a>>, ('a, 'a) => 'a) => t<'k, 'a>

// Construct a map from all the keys which exist in both input maps. The value
// will be whatever's in the *second* map.
let intersection: (t<'k, 'a>, t<'k, 'a>) => t<'k, 'a>

// Construct a map from all the keys which exist in the first map and not
// in the second map.
let diff: (t<'k, 'a>, t<'k, 'a>) => t<'k, 'a>

// Convert an array to a map given a function to make a key for an object in the array.
let keyBy: (array<'a>, 'a => 'k) => t<'k, 'a>

// Group items in an array by a common result to a function. The key
// type must be hashable by javascript -- the type system can't guarantee this.
let groupBy: (array<'a>, 'a => 'k) => t<'k, array<'a>>

// Group an array of tuples. Each first element is a key in the resulting
// map, and each second element appears in an array with other values
// sharing the same key.
let groupTuples: array<('k, 'v)> => t<'k, array<'v>>
