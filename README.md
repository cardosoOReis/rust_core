# rust_core
[![Pub Version](https://img.shields.io/pub/v/rust_core.svg)](https://pub.dev/packages/rust_core)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/rust_core/latest/)
[![License: Apache 2.0](https://img.shields.io/github/license/mcmah309/path_type)](https://opensource.org/license/apache-2-0)
[![Build Status](https://github.com/mcmah309/rust_core/actions/workflows/test.yml/badge.svg)](https://github.com/mcmah309/rust_core/actions)

[rust_core](https://github.com/mcmah309/rust_core) is an implementation of Rust's Core Library in Dart, bringing the power of Rust to Dart!

[Rust Core Book 📖](https://mcmah309.github.io/rust_core)

## Example
> Goal: Get the index of every "!" in a string not followed by a "?"

**Rust:**
```rust
use std::iter::Peekable;

fn main() {
  let string = "kl!sd!?!";
  let mut answer: Vec<usize> = Vec::new();
  let mut iter: Peekable<_> = string
      .chars()
      .map_windows(|w: &[char; 2]| *w)
      .enumerate()
      .peekable();

  while let Some((index, window)) = iter.next() {
      match window {
          ['!', '?'] => continue,
          ['!', _] => answer.push(index),
          [_, '!'] if iter.peek().is_none() => answer.push(index + 1),
          _ => continue,
      }
  }
  assert_eq!(answer, [2, 7]);
}
```
**Dart:**
```dart
import 'package:rust_core/rust_core.dart';

void main() {
  String string = "kl!sd!?!";
  List<int> answer = [];
  Peekable<(int, Arr<String>)> iter = string
      .chars()
      .mapWindows(2, identity)
      .enumerate()
      .peekable();
  while (iter.moveNext()) {
    final (index, window) = iter.current;
    switch (window) {
      case ["!", "?"]:
        break;
      case ["!", _]:
        answer.add(index);
      case [_, "!"] when iter.peek().isNone():
        answer.add(index + 1);
    }
  }
  expect(answer, [2, 7]);
}
```

# Project Goals
***
rust_core's primary goal is to bring Rust's features and ergonomics to Dart.

To accomplish this, Rust's functionalities are carefully adapted to Dart's paradigms, focusing on a smooth idiomatic language-compatible integration.
The result is developers now have access to powerful tools previously only available to Rust developers.

True to the Rust philosophy, rust_core strives to bring reliability and performance in every feature. Every feature is robustly tested. Over 500 meaningful test suites and counting.