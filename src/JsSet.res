type t<'a>

@new external empty: unit => t<'a> = "Set"

@new external fromArray: array<'a> => t<'a> = "Set"

@val external toArray: t<'a> => array<'a> = "Array.from"

let copy = s => s->toArray->fromArray

@new external fromArrayLike: Js.Array.array_like<'a> => t<'a> = "Set"

external toArrayLike: t<'a> => Js.Array.array_like<'a> = "%identity"

let toList: t<'a> => list<'a> = s => s->toArray->Belt.List.fromArray

@bs.send external has: (t<'a>, 'a) => bool = "has"

@get external size: t<'a> => int = "size"

@bs.send external addMut: (t<'a>, 'a) => t<'a> = "add"

let addPure = (s, v) => s->copy->addMut(v)

@bs.send external deleteMut: (t<'a>, 'a) => bool = "delete"

let deletePure = (s, v) => s->toArray->Belt.Array.keep(x => x != v)->fromArray

@bs.send
external forEach: (t<'a>, @uncurry ('a => unit)) => unit = "forEach"

let reduce = (set, start, f) => set->toArray->Belt.Array.reduce(start, f)

let map = (s, f) => {
  let output = empty()
  s->forEach(v => output->addMut(f(v))->ignore)
  output
}

let keep = (s, f) => {
  let output = empty()
  s->forEach(v =>
    if f(v) {
      output->addMut(v)->ignore
    }
  )
  output
}

let keepMap = (s, f) => {
  let output = empty()
  s->forEach(v =>
    switch f(v) {
    | None => ()
    | Some(newV) => output->addMut(newV)->ignore
    }
  )
  output
}

let union = (set1, set2) => set2->reduce(set1->reduce(empty(), addMut), addMut)

let unionAll = sets => sets->Js.Array2.reduce(union, empty())

let intersection = (set1, set2) => set1->keep(set2->has)

let diff = (set1, set2) => set1->keep(e => !(set2->has(e)))

let singleton = v => fromArray([v])

let fromStringBeltSet = set => fromArray(Belt.Set.String.toArray(set))

let toStringBeltSet = set => Belt.Set.String.fromArray(toArray(set))

let fromIntBeltSet = set => fromArray(Belt.Set.Int.toArray(set))

let toIntBeltSet = set => Belt.Set.Int.fromArray(toArray(set))

let toJson = (toJsonInner, set) => set->toArray->Belt.Array.map(toJsonInner)->Js.Json.array

let dedupeArray = arr => arr->fromArray->toArray

let mapToArray = (set, f) => set->toArray->Belt.Array.map(f)

let mapToList = (set, f) => set->toList->Belt.List.map(f)
