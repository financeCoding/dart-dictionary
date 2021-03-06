library dictionary;

import 'dart:collection';
import 'package:option/option.dart';

class Dictionary<K, V> extends HashMap<K, V> {

  /**
   * Vanilla constructor
   */
  Dictionary();

  /**
   * Factory constructor for initializing Dictionaries from Maps
   */
  factory Dictionary.fromMap(Map<K, V> other) {
    return new Dictionary<K, V>()..addAll(other);
  }

  /**
   * Returns an optional value based on the key
   *
   * @param {Option<V>} - A `Some` if the key exists, `None` otherwise
   */
  Option<V> operator [](K key) {
    return this.get(key);
  }

  /**
   * Returns an optional value based on the key
   *
   * @param {Option<V>} - A `Some` if the key exists, `None` otherwise
   */
  Option<V> get(K key) {
    if (this.containsKey(key)) {
      return new Some(super[key]);
    } else {
      return new None<V>();
    }
  }

  /**
   * Given a `key` if that key exists then it's value will be returned,
   * otherwise the `alternative` value will be returned.
   *
   * @param {K} key               - The key to lookup
   * @param {dynamic} alternative - The alternative value
   * @return {V}                  - Either the value or the alternative
   */
  V getOrElse(K key, dynamic alternative) {
    return this.get(key).getOrElse(alternative);
  }

  /**
   * Given a predicate returns the first key that passes it as a `Some`.
   * If no key is found a `None` is returned.
   *
   * @param {bool(V, K)} predicate - The predicate to test against
   * @return {Option<K>}           - The optional key
   */
  Option<K> findKey(bool predicate(V value, K key)) {
    for (K key in this.keys) {
      if (predicate(super[key], key)) {
        return new Some(key);
      }
    }
    return new None<K>();
  }

  /**
   * Given a predicate returns the fist value that passes it as a `Some`.
   * If no value is found a `None` is returned.
   *
   * @param {bool(V, K)} predicate - The predicate to test against
   * @return {Option<K>}           - The optional value
   */
  Option<V> findValue(bool predicate(V value, K key)) {
    for (K key in this.keys) {
      if (predicate(super[key], key)) {
        return new Some(super[key]);
      }
    }
    return new None<V>();
  }

  /**
   * Given a predicate this method partitions the dictionary by the elements
   * that pass the predicate from the ones that don't
   *
   * @param {bool(V, K)} predicate    - The predicate to test against
   * @return {List<Dictionary<K, V>>} - The tuple list of the partitioning
   */
  List<Dictionary<K, V>> partition(bool predicate(V value, K key)) {
    var tuple = new List(2);
    tuple[0] = new Dictionary<K, V>();
    tuple[1] = new Dictionary<K, V>();
    for (K key in this.keys) {
      if (predicate(super[key], key)) {
        tuple[0][key] = super[key];
      } else {
        tuple[1][key] = super[key];
      }
    }
    return tuple;
  }

  /**
   * Given an identifier function this will group all key/value pairs
   * by the identifier they generate.
   *
   * @param {dynamic(V, K)} identifier - Generates identifiers for each kv pair
   * @return {Dictionary<dynamic, Dictionary<K, V>>} - The grouping
   */
  Dictionary<dynamic, Dictionary<K, V>> groupBy(dynamic identifier(V value, K key)) {
    var init = new Dictionary<dynamic, Dictionary<K, V>>();
    return this.keys.reduce(init, (memo, key) {
      var value   = super[key];
      var id      = identifier(value, key);
      var bucket  = memo.getOrElse(key, () => new Dictionary<K, V>());
      bucket[key] = value;
      memo[id]    = bucket;
      return memo;
    });
  }

  /**
   * Creates a new `Dictionary` that doesn't contain any of the keys in `other`
   *
   * @param {Dictionary<K, V>} other - The other dictionary
   * @return {Dictionary<K, V>}      - The difference by key
   */
  Dictionary<K, V> differenceKey(Dictionary<K, V> other) {
    var difference = new Dictionary<K, V>();
    for (K key in this.keys) {
      if (!other.containsKey(key)) {
        difference[key] = super[key];
      }
    }
    return difference;
  }

  /**
   * Creates a new `Dictionary` that doesnt contain values in `other`
   *
   * @param {Dictionary<K, V>} other - The other dictionary
   * @return {Dictionary<K, V>}      - The difference by value
   */
  Dictionary<K, V> difference(Dictionary<K, V> other) {
    var difference = new Dictionary<K, V>();
    for (K key in this.keys) {
      var value = super[key];
      if (!other.containsValue(value)) {
        difference[key] = value;
      }
    }
    return difference;
  }

  /**
   * Creates a new `Dictionary` where keys are present in both arrays
   *
   * @param {Dictionary<K, V>} other - The other dictionary
   * @return {Dictionary<K, V>}      - The intersection by key
   */
  Dictionary<K, V> intersectionKey(Dictionary<K, V> other) {
    var intersection = new Dictionary<K, V>();
    for (K key in this.keys) {
      if (other.containsKey(key)) {
        intersection[key] = super[key];
      }
    }
    return intersection;
  }

  /**
   * Creates a new `Dictionary` where values are present in both arrays
   *
   * @param {Dictionary<K, V>} other - The other dictionary
   * @return {Dictionary<K, V>}      - The intersection by value
   */
  Dictionary<K, V> intersection(Dictionary<K, V> other) {
    var intersection = new Dictionary<K, V>();
    for (K key in this.keys) {
      if (!other.containsValue(super[key])) {
        intersection[key] = super[key];
      }
    }
    return intersection;
  }

  /**
   * Creates a new `Dictionary` where the `other` array is merged into
   * this array. Overlapping keys in `other` overwrite the keys in the
   * merged result
   *
   * @param {Dictionary<K, V>} other - The other dictionary
   * @return {Dictionary<K, V>}      - The merged result
   */
  Dictionary<K, V> merge(Dictionary<K, V> other) {
    var merged = new Dictionary()..addAll(this);
    for (K key in other.keys) {
      merged[key] = other[key].get();
    }
    return merged;
  }

}