open Jest;
open Expect;

module MapTests = {
  open JsMap;
  describe("Map", () => {
    test("string keys", () => {
      let map = fromArray([|("foo", "bar")|]);
      expect(map->size)->toEqual(1);
      expect(map->get("foo"))->toEqual(Some("bar"));
      expect(map->has("foo"))->toBe(true);
      expect(map->get("qux"))->toEqual(None);
      expect(map->has("qux"))->toBe(false);
      expect(map->toArray)->toEqual([|("foo", "bar")|]);
      expect(map->toList)->toEqual([("foo", "bar")]);
      expect(map->keysArray)->toEqual([|"foo"|]);
      expect(map->keysList)->toEqual(["foo"]);
      expect(map->valuesArray)->toEqual([|"bar"|]);
      expect(map->valuesList)->toEqual(["bar"]);
    });
    test("int keys", () => {
      let map = fromArray([|(123, "bar")|]);
      expect(map->get(123))->toEqual(Some("bar"));
    });
    test("mutable operations", () => {
      let map = fromArray([|(123, "bar")|]);
      let _ = map->setMut(456, "qux");
      expect(map->get(456))->toEqual(Some("qux"));
      let deleted = map->deleteMut(123);
      expect(deleted)->toBe(true);
      expect(map)->toEqual(fromArray([|(456, "qux")|]));
    });

    test("mapping a function over a Map", () => {
      let map1 = fromArray([|(1, 10), (2, 20), (3, 30)|]);
      expect(map1->map(string_of_int)->valuesArray)
      ->toEqual([|"10", "20", "30"|]);
      expect(map1->mapKeys(string_of_int)->toArray)
      ->toEqual([|("1", 10), ("2", 20), ("3", 30)|]);
    });

    test("reduce/reduceWithKey", () => {
      let map = fromArray([|(123, "bar"), (456, "baz"), (789, "qux")|]);

      expect(map->reduce("", (s1, s2) => s1 ++ s2))->toEqual("barbazqux");
      expect(
        map->reduceWithKey("", (s1, i, s2) => s1 ++ i->string_of_int ++ s2),
      )
      ->toEqual("123bar456baz789qux");
    });

    test("set operations", () => {
      let map1 = fromArray([|(1, 10), (2, 20), (3, 30)|]);
      let map2 = fromArray([|(4, 40), (5, 50), (6, 60)|]);
      let map3 = fromArray([|(3, 30), (4, 40), (5, 50)|]);
      expect(map1->diff(map2))->toEqual(map1);
      expect(map2->diff(map3))->toEqual(singleton(6, 60));
      expect(map1->union(map2)->keysArray)->toEqual([|1, 2, 3, 4, 5, 6|]);
      expect(map1->union(map3))
      ->toEqual(
          fromArray([|(1, 10), (2, 20), (3, 30), (4, 40), (5, 50)|]),
        );
      expect(map2->intersection(map3))
      ->toEqual(fromArray([|(4, 40), (5, 50)|]));
    });

    test("option keys", () =>
      expect([|(Some(1), "x")|]->fromArray->get(Some(1)))
      ->toEqual(Some("x"))
    );

    Skip.test("option values (AVOID IF POSSIBLE)", () => {
      let m = [|(1, Some("x")), (2, None)|]->fromArray;
      expect(m->get(1))->toEqual(Some(Some("x")));
      // Known failure
      expect(m->get(2))->toEqual(Some(None));
    });

    Skip.test("nested option values (AVOID IF POSSIBLE)", () => {
      let map =
        fromArray([|
          ("x", Some(None)),
          ("y", Some(Some(123))),
          ("z", None),
        |]);
      expect(map->get("x"))->toEqual(Some(Some(None)));
      expect(map->get("y"))->toEqual(Some(Some(Some(123))));
      // NOTE this is the known fail and why option values shouldn't be used
      expect(map->get("z"))->toEqual(Some(None));
      expect(map->get("xxx"))->toEqual(None);
    });

    test("forEach", () => {
      let map = fromArray([|("a", 1), ("b", 2), ("c", 3)|]);
      let sum = ref(0);
      map->forEach(n => sum := sum^ + n);
      expect(sum^)->toEqual(6);
    });

    test("forEachWithKey", () => {
      let map = fromArray([|("a", 1), ("b", 2), ("c", 3)|]);
      let sum = ref(0);
      map->forEachWithKey((k, n) => sum := sum^ + n + k->Js.String.length);
      expect(sum^)->toEqual(9);
    });
  });
};

module SetTests = {
  open JsSet;

  describe("Set", () => {
    test("strings", () => {
      let set = fromArray([|"foo", "bar"|]);
      expect(set->size)->toEqual(2);
      expect(set->has("foo"))->toBe(true);
      expect(set->has("qux"))->toBe(false);
      expect(set->toArray)->toEqual([|"foo", "bar"|]);
      expect(set->toList)->toEqual(["foo", "bar"]);
    });
    test("ints", () => {
      let set = fromArray([|123, 456|]);
      expect(set->has(123))->toEqual(true);
    });
    test("option values", () => {
      let set = fromArray([|Some(1), Some(123), None|]);
      expect(set->has(Some(1)))->toBe(true);
      expect(set->has(None))->toBe(true);
    });

    // This is a known failure case!
    Skip.test("nested option values", () => {
      let set =
        fromArray([|Some(Some(1)), Some(Some(123)), Some(None), None|]);
      expect(set->has(Some(Some(1))))->toBe(true);
      expect(set->has(Some(None)))->toBe(true);
      expect(set->has(None))->toBe(true);
    });

    test("mutable operations", () => {
      let set = fromArray([|123|]);
      let _ = set->addMut(456);
      expect(set->has(456))->toEqual(true);
      let deleted = set->deleteMut(123);
      expect(deleted)->toBe(true);
      expect(set)->toEqual(fromArray([|456|]));
    });

    test("forEach", () => {
      let set = fromArray([|1, 2, 3|]);
      let sum = ref(0);
      set->forEach(n => sum := sum^ + n);
      expect(sum^)->toEqual(6);
    });

    test("mapping a function over a Set", () => {
      let set1 = fromArray([|10, 20, 30|]);
      expect(set1->map(string_of_int)->toArray)
      ->toEqual([|"10", "20", "30"|]);
    });

    test("set operations", () => {
      let set1 = fromArray([|1, 2, 3|]);
      let set2 = fromArray([|4, 5, 6|]);
      let set3 = fromArray([|3, 4, 5|]);
      expect(set1->diff(set2))->toEqual(set1);
      expect(set2->diff(set3))->toEqual(singleton(6));
      expect(set1->union(set2))->toEqual(fromArray([|1, 2, 3, 4, 5, 6|]));
      expect(set1->union(set3))->toEqual(fromArray([|1, 2, 3, 4, 5|]));
      expect(set2->intersection(set3))->toEqual(fromArray([|4, 5|]));
    });
  });
};
