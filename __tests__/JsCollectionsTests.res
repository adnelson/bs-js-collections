open Jest
open Expect

module MapTests = {
  open JsMap
  describe("Map", () => {
    test("string keys", () => {
      let map = fromArray([("foo", "bar")])
      expect(map->size)->toEqual(1)
      expect(map->get("foo"))->toEqual(Some("bar"))
      expect(map->has("foo"))->toBe(true)
      expect(map->get("qux"))->toEqual(None)
      expect(map->has("qux"))->toBe(false)
      expect(map->toArray)->toEqual([("foo", "bar")])
      expect(map->toList)->toEqual(list{("foo", "bar")})
      expect(map->keysArray)->toEqual(["foo"])
      expect(map->keysList)->toEqual(list{"foo"})
      expect(map->valuesArray)->toEqual(["bar"])
      expect(map->valuesList)->toEqual(list{"bar"})
    })
    test("int keys", () => {
      let map = fromArray([(123, "bar")])
      expect(map->get(123))->toEqual(Some("bar"))
    })
    test("mutable operations", () => {
      let map = fromArray([(123, "bar")])
      let _ = map->setMut(456, "qux")
      expect(map->get(456))->toEqual(Some("qux"))
      let deleted = map->deleteMut(123)
      expect(deleted)->toBe(true)
      expect(map)->toEqual(fromArray([(456, "qux")]))
    })

    test("immutable versions of mutable operations", () => {
      let map = fromArray([(123, "bar")])
      expect(map->setPure(456, "qux")->get(456))->toEqual(Some("qux"))
      expect(map->deletePure(123))->toEqual(empty())
    })

    test("mapping a function over a Map", () => {
      let map1 = fromArray([(1, 10), (2, 20), (3, 30)])
      expect(map1->map(string_of_int)->valuesArray)->toEqual(["10", "20", "30"])

      expect(map1->mapKeys(string_of_int)->toArray)->toEqual([("1", 10), ("2", 20), ("3", 30)])

      expect(map1->mapWithKey((k, v) => string_of_int(k + v))->toArray)->toEqual([
        (1, "11"),
        (2, "22"),
        (3, "33"),
      ])

      expect(map1->mapEntries((k, v) => (string_of_int(k), v + 1))->toArray)->toEqual([
        ("1", 11),
        ("2", 21),
        ("3", 31),
      ])
    })

    test("updating a key with a function", () => {
      let map1 = fromArray([(1, 10), (2, 20), (3, 30)])
      expect(map1->update(2, x => x * 12)->valuesArray)->toEqual([10, 240, 30])
    })

    test("reducing", () => {
      let map = fromArray([(123, "bar"), (456, "baz"), (789, "qux")])

      expect(map->reduce("", (s1, s2) => s1 ++ s2))->toEqual("barbazqux")
      expect(map->reduceWithKey("", (s1, i, s2) => s1 ++ (i->string_of_int ++ s2)))->toEqual(
        "123bar456baz789qux",
      )
    })

    test("filtering", () => {
      let map = fromArray([(123, "bar"), (456, "baz"), (789, "qux")])

      expect(map->keep(s => s == "bar"))->toEqual(singleton(123, "bar"))
      expect(map->keepWithKey((k, s) => s == "bar" || k == 789))->toEqual(map->deletePure(456))
    })

    test("set operations", () => {
      let map1 = fromArray([(1, 10), (2, 20), (3, 30)])
      let map2 = fromArray([(4, 40), (5, 50), (6, 60)])
      let map3 = fromArray([(3, 30), (4, 40), (5, 50)])
      expect(map1->diff(map2))->toEqual(map1)
      expect(map2->diff(map3))->toEqual(singleton(6, 60))
      expect(map1->union(map2)->keysArray)->toEqual([1, 2, 3, 4, 5, 6])
      expect(unionAll([map1, map2, map3]))->toEqual(
        fromArray([(1, 10), (2, 20), (3, 30), (4, 40), (5, 50), (6, 60)]),
      )
      expect(unionAllWith([map1, map2, map3], (x, y) => x + y))->toEqual(
        fromArray([(1, 10), (2, 20), (3, 60), (4, 80), (5, 100), (6, 60)]),
      )
      expect(map1->union(map3))->toEqual(fromArray([(1, 10), (2, 20), (3, 30), (4, 40), (5, 50)]))
      expect(map1->unionWith(map3, (x, y) => x * y))->toEqual(
        fromArray([(1, 10), (2, 20), (3, 900), (4, 40), (5, 50)]),
      )
      expect(map2->intersection(map3))->toEqual(fromArray([(4, 40), (5, 50)]))
    })

    test("option keys", () => expect([(Some(1), "x")]->fromArray->get(Some(1)))->toEqual(Some("x")))

    Skip.test("option values (AVOID IF POSSIBLE)", () => {
      let m = [(1, Some("x")), (2, None)]->fromArray
      expect(m->get(1))->toEqual(Some(Some("x")))
      // Known failure
      expect(m->get(2))->toEqual(Some(None))
    })

    Skip.test("nested option values (AVOID IF POSSIBLE)", () => {
      let map = fromArray([("x", Some(None)), ("y", Some(Some(123))), ("z", None)])
      expect(map->get("x"))->toEqual(Some(Some(None)))
      expect(map->get("y"))->toEqual(Some(Some(Some(123))))
      // NOTE this is the known fail and why option values shouldn't be used
      expect(map->get("z"))->toEqual(Some(None))
      expect(map->get("xxx"))->toEqual(None)
    })

    test("forEach", () => {
      let map = fromArray([("a", 1), ("b", 2), ("c", 3)])
      let sum = ref(0)
      map->forEach(n => sum := sum.contents + n)
      expect(sum.contents)->toEqual(6)
    })

    test("forEachWithKey", () => {
      let map = fromArray([("a", 1), ("b", 2), ("c", 3)])
      let sum = ref(0)
      map->forEachWithKey((k, n) => sum := sum.contents + n + k->Js.String.length)
      expect(sum.contents)->toEqual(9)
    })

    test("toJson", () =>
      expect(
        fromArray([("a", 1.0), ("b", 2.0), ("c", 3.0)]) |> toJson(~k=s => s, ~v=Js.Json.number),
      )->toEqual(%raw(`{a: 1, b: 2, c: 3}`))
    )
  })
}

module SetTests = {
  open JsSet

  describe("Set", () => {
    test("strings", () => {
      let set = fromArray(["foo", "bar"])
      expect(set->size)->toEqual(2)
      expect(set->has("foo"))->toBe(true)
      expect(set->has("qux"))->toBe(false)
      expect(set->toArray)->toEqual(["foo", "bar"])
      expect(set->toList)->toEqual(list{"foo", "bar"})
    })
    test("ints", () => {
      let set = fromArray([123, 456])
      expect(set->has(123))->toEqual(true)
    })
    test("option values", () => {
      let set = fromArray([Some(1), Some(123), None])
      expect(set->has(Some(1)))->toBe(true)
      expect(set->has(None))->toBe(true)
    })

    // This is a known failure case!
    Skip.test("nested option values", () => {
      let set = fromArray([Some(Some(1)), Some(Some(123)), Some(None), None])
      expect(set->has(Some(Some(1))))->toBe(true)
      expect(set->has(Some(None)))->toBe(true)
      expect(set->has(None))->toBe(true)
    })

    test("mutable operations", () => {
      let set = fromArray([123])
      let _ = set->addMut(456)
      expect(set->has(456))->toEqual(true)
      let deleted = set->deleteMut(123)
      expect(deleted)->toBe(true)
      expect(set)->toEqual(fromArray([456]))
    })

    test("pure versions of mutable operations", () => {
      let set = fromArray([123, 456])
      expect(set->addPure(789)->has(789))->toEqual(true)
      expect(set->deletePure(123))->toEqual(fromArray([456]))
    })

    test("forEach", () => {
      let set = fromArray([1, 2, 3])
      let sum = ref(0)
      set->forEach(n => sum := sum.contents + n)
      expect(sum.contents)->toEqual(6)
    })

    test("mapping a function over a Set", () => {
      let set1 = fromArray([10, 20, 30])
      expect(set1->map(string_of_int)->toArray)->toEqual(["10", "20", "30"])
    })

    test("addPure", () => {
      let set1 = fromArray([10, 20, 30])
      expect(set1->addPure(9999)->toArray)->toEqual([10, 20, 30, 9999])
    })

    test("set operations", () => {
      let set1 = fromArray([1, 2, 3])
      let set2 = fromArray([4, 5, 6])
      let set3 = fromArray([3, 4, 5])
      expect(set1->diff(set2))->toEqual(set1)
      expect(set2->diff(set3))->toEqual(singleton(6))
      expect(set1->union(set2))->toEqual(fromArray([1, 2, 3, 4, 5, 6]))
      expect(set1->union(set3))->toEqual(fromArray([1, 2, 3, 4, 5]))
      expect(unionAll([set1, set2, set3]))->toEqual(fromArray([1, 2, 3, 4, 5, 6]))
      expect(set2->intersection(set3))->toEqual(fromArray([4, 5]))
    })

    test("mapping a function over a Set", () => {
      let set1 = fromArray([1.0, 2.0, 3.0])
      expect(set1 |> toJson(Js.Json.number))->toEqual(Obj.magic([1.0, 2.0, 3.0]))
      expect(set1->mapToArray(i => [i]))->toEqual([[1.0], [2.0], [3.0]])
      expect(set1->mapToList(i => [i]))->toEqual(list{[1.0], [2.0], [3.0]})
    })

    test("dedupeArray", () =>
      expect(["a", "x", "b", "y", "x", "b", "z"]->dedupeArray)->toEqual(["a", "x", "b", "y", "z"])
    )
  })
}
