// Interface to the primitive Set type in JS. In practice, 'a
// must be a type that JavaScript is able to handle, so use carefully:

// * Primitive types (string, int, bool, undefined, null) work fine
// * Abstract versions of those types
// * Enums which have a primitive representation such as `Blue or `utf8
// * `option` versions of the above, although *NESTED OPTIONS WON'T WORK*

type t<'a>

// Construct an empty set.
let empty: unit => t<'a>

// Construct a set with one element.
let singleton: 'a => t<'a>

// Construct a set from an array.
let fromArray: array<'a> => t<'a>

// Construct a set from an array-like.
let fromArrayLike: Js.Array.array_like<'a> => t<'a>

// Convert to an array.
let toArray: t<'a> => array<'a>

// Convert to an array-like
let toArrayLike: t<'a> => Js.Array.array_like<'a>

// Convert to a list
let toList: t<'a> => list<'a>

// Convert to an array after mapping a function.
// The function IS allowed to output non-hashable values.
let mapToArray: (t<'a>, 'a => 'b) => array<'b>

// Convert to a list after mapping a function.
// The function IS allowed to output non-hashable values.
let mapToList: (t<'a>, 'a => 'b) => list<'b>

// True if the item is in the set
let has: (t<'a>, 'a) => bool

// How many elements in the set
let size: t<'a> => int

// Mutably add an element to the set.
let addMut: (t<'a>, 'a) => t<'a>

// Set a key in a set, producing a new set. O(n).
let addPure: (t<'a>, 'a) => t<'a>

// Mutably delete an element from the set. Returns true if the
// element was in the set when called.
let deleteMut: (t<'a>, 'a) => bool

// Delete a key from a set, producing a new set. O(n).
let deletePure: (t<'a>, 'a) => t<'a>

// Run a side-effecting function on each element of the set.
let forEach: (t<'a>, 'a => unit) => unit

// Traverse the set, building up an output value.
let reduce: (t<'a>, 'b, ('b, 'a) => 'b) => 'b

// Map a function over the set. Note that the output type must also be hashable,
// this is on the developer to get right :)
let map: (t<'a>, 'a => 'b) => t<'b>

// Filter the set.
let keep: (t<'a>, 'a => bool) => t<'a>

// Filter and map at the same time using a function that returns `option`.
let keepMap: (t<'a>, 'a => option<'b>) => t<'b>

// Create a copy of the set
let copy: t<'a> => t<'a>

// Construct a set with elements that exist in either input set.
let union: (t<'a>, t<'a>) => t<'a>

// Take the union of any number of sets.
let unionAll: array<t<'a>> => t<'a>

// Construct a set with elements that exist in both input sets.
let intersection: (t<'a>, t<'a>) => t<'a>

// Construct a set with elements that exist in the first set but not the second.
let diff: (t<'a>, t<'a>) => t<'a>

// Convert a Belt string set to a JS set
let fromStringBeltSet: Belt.Set.String.t => t<string>

// Convert to string set
let toStringBeltSet: t<string> => Belt.Set.String.t

// Convert a belt int set to a JS set
let fromIntBeltSet: Belt.Set.Int.t => t<int>

// Convert a set containing integers to a Belt set
let toIntBeltSet: t<int> => Belt.Set.Int.t

// Convert a set to JSON, using an array representation.
let toJson: ('a => Js.Json.t, t<'a>) => Js.Json.t

// Use a set to deduplicate items in an array. The `'a` type must be hashable.
let dedupeArray: array<'a> => array<'a>
