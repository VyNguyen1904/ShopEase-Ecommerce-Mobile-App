# Module 3: OOP & Asynchronous Dart (Sessions 11–15)

> **Course:** Flutter & Dart — From Zero to Production  
> **Module:** 3 of 6  
> **Sessions Covered:** 11 – 15  
> **Prerequisites:** Module 1 (Dart Fundamentals), Module 2 (Flutter Widgets & Layouts)  
> **Estimated Study Time:** 12–18 hours

---

Welcome back! If you made it through Modules 1 and 2, you know the basics of Dart syntax and how to compose UIs with Flutter widgets. In this module, we go **deeper into the engine room**. We're going to talk about how Dart actually *runs* code, how time and asynchrony work, how to build clean data layers, and how to think reactively.

By the end of this module, you will:

- Understand Dart's event loop, microtask queue, and event queue at a deep level
- Write and consume Streams confidently
- Use `StreamBuilder` to create reactive Flutter UIs
- Apply the Repository Pattern to separate concerns cleanly
- Understand reactive programming concepts and how Flutter's state management tools fit together

Buckle up — this is where Flutter developers go from "I can make an app" to "I can architect an app."

---

## Table of Contents

1. [Session 11 – Future-based Async Programming (Deep Dive)](#session-11)
2. [Session 12 – Streams & StreamController](#session-12)
3. [Session 13 – StreamBuilder in Flutter](#session-13)
4. [Session 14 – Repository Pattern](#session-14)
5. [Session 15 – Reactive Patterns (Concepts)](#session-15)
6. [Module Summary](#module-summary)
7. [Review Questions](#review-questions)

---

<a name="session-11"></a>
# Session 11 – Future-based Async Programming (Deep Dive)

## 11.1 Review: What Is a Future?

Before we go deep, let's establish a shared foundation. A `Future<T>` in Dart is an object that represents a value that will be available *at some point in the future*. It is Dart's primary mechanism for modeling a single asynchronous result.

```dart
// A Future that completes with an integer after 2 seconds
Future<int> fetchProductCount() async {
  await Future.delayed(Duration(seconds: 2));
  return 42;
}

void main() async {
  print('Fetching...');
  int count = await fetchProductCount();
  print('Product count: $count'); // prints after 2 seconds
}
```

Think of a `Future` like an *order ticket* at a restaurant. You place your order (start the async operation), receive a ticket (the `Future` object), and continue doing other things. When the food is ready, the kitchen notifies you (the future completes).

---

## 11.2 Future Scheduling and Execution Order

One of the most misunderstood aspects of Dart is *when* and *in what order* futures actually run. This confusion causes real bugs in production apps.

### Dart's Single-Threaded Concurrency Model

Dart runs on a **single thread** (in a single isolate). It is *not* multi-threaded by default. Instead, it uses an **event loop** to handle concurrency. The event loop continuously checks two queues:

1. **The Microtask Queue** — highest priority, processed before any event queue item
2. **The Event Queue** — standard priority, handles I/O events, timers, `Future` completions, etc.

```
┌─────────────────────────────────────────────┐
│               Dart Isolate                   │
│                                             │
│   ┌──────────────────────────────────────┐  │
│   │           Event Loop                  │  │
│   │                                      │  │
│   │  1. Run all microtasks               │  │
│   │  2. Run next event queue item        │  │
│   │  3. Repeat                           │  │
│   └──────────────────────────────────────┘  │
│                                             │
│   Microtask Queue: [task1, task2, ...]      │
│   Event Queue:     [event1, event2, ...]    │
└─────────────────────────────────────────────┘
```

### Synchronous Code Always Runs First

```dart
void main() {
  print('1 - synchronous start');

  Future(() => print('4 - event queue Future'));

  Future.microtask(() => print('2 - microtask'));

  Future.value(42).then((_) => print('3 - resolved Future.then'));

  print('5 - synchronous end'); // wait, this prints before 2!
}
```

**Output:**
```
1 - synchronous start
5 - synchronous end
2 - microtask
3 - resolved Future.then
4 - event queue Future
```

Let's break this down step by step:
- `1` and `5` print immediately — they are synchronous code running to completion first.
- `2` is a microtask — scheduled to run immediately after the current synchronous frame.
- `3` is `Future.value(42).then(...)` — `Future.value` completes *synchronously*, but `.then()` callbacks are always scheduled as microtasks.
- `4` is a `Future(() => ...)` — this wraps a callback in an event queue entry (timer with 0 duration essentially).

> 💡 **Pro Tip:** `.then()` callbacks on an *already-completed* Future are still asynchronous — they are placed into the microtask queue, not executed immediately. Never assume a `.then()` runs synchronously even if the Future is resolved.

---

## 11.3 Microtask Queue vs Event Queue

### The Microtask Queue

The microtask queue has **higher priority** than the event queue. The event loop will drain the **entire** microtask queue before processing even one event.

```dart
import 'dart:async';

void main() {
  // Schedule events on the event queue
  Timer(Duration.zero, () => print('Event: Timer 1'));
  Timer(Duration.zero, () => print('Event: Timer 2'));

  // Schedule microtasks
  scheduleMicrotask(() => print('Microtask: 1'));
  scheduleMicrotask(() => print('Microtask: 2'));
  scheduleMicrotask(() => print('Microtask: 3'));

  print('Sync: main body');
}
```

**Output:**
```
Sync: main body
Microtask: 1
Microtask: 2
Microtask: 3
Event: Timer 1
Event: Timer 2
```

### Why Does This Matter?

If you schedule too many microtasks recursively, you can **starve the event queue** — preventing I/O, timers, and user input from being processed.

```dart
// DANGER: Infinite microtask loop — will freeze your app!
void badCode() {
  scheduleMicrotask(() {
    print('microtask');
    scheduleMicrotask(badCode); // This schedules another before the event loop can breathe
  });
}
```

> 💡 **Pro Tip:** Reserve microtasks (`scheduleMicrotask`, `Future.microtask`) for truly critical high-priority work. For most async operations, use regular `Future` (event queue). Starving the event queue means your Flutter UI will freeze.

### Future.microtask() vs Future()

```dart
import 'dart:async';

void main() {
  // Future() — schedules on the EVENT queue
  Future(() => print('Event queue'));

  // Future.microtask() — schedules on the MICROTASK queue
  Future.microtask(() => print('Microtask queue'));

  // Future.value() — already complete; .then() goes to microtask
  Future.value(1).then((_) => print('Resolved future .then'));

  print('Synchronous');
}
```

**Output:**
```
Synchronous
Microtask queue
Resolved future .then
Event queue
```

---

## 11.4 Error Propagation in Future Chains

Errors in async code behave differently than synchronous exceptions. Understanding error propagation is critical for writing robust apps.

### The `.catchError()` Chain

```dart
Future<String> step1() async {
  throw Exception('Step 1 failed!');
}

Future<String> step2(String input) async {
  return 'Step 2 result from: $input';
}

void main() async {
  // Method 1: try/catch with async/await (RECOMMENDED)
  try {
    final result1 = await step1();
    final result2 = await step2(result1);
    print(result2);
  } catch (e) {
    print('Caught: $e'); // prints: Caught: Exception: Step 1 failed!
  }

  // Method 2: .then().catchError() chaining
  step1()
      .then((value) => step2(value))
      .then((result) => print(result))
      .catchError((e) {
        print('Chain caught: $e');
        return 'fallback value'; // Must return the same type as the Future
      });
}
```

### Error Propagation Through Chains

When an error occurs in a `.then()` callback, it propagates **down the chain** until something catches it:

```dart
Future<int> riskyOperation() async => throw Exception('Oops!');

void main() async {
  riskyOperation()
      .then((value) {
        // This is SKIPPED when an error occurs
        print('This never runs: $value');
        return value * 2;
      })
      .then((value) {
        // This is also SKIPPED
        print('Also never runs: $value');
      })
      .catchError((error) {
        // This CATCHES the error from riskyOperation()
        print('Final catch: $error');
      });
}
```

### The `onError` Parameter

`.then()` accepts an optional `onError` parameter to handle errors at a specific point in the chain:

```dart
Future<int> getValue() async => throw Exception('failed');

void main() {
  getValue().then(
    (value) => print('Got: $value'),
    onError: (e) {
      print('Handled in then: $e');
      // If you don't return a value here, the error is considered handled
      // and the next .then() will receive null
    },
  );
}
```

### The `.whenComplete()` Method

Similar to `finally` in try/catch — runs regardless of success or failure:

```dart
Future<void> fetchData() async {
  // Simulate work
  await Future.delayed(Duration(seconds: 1));
  throw Exception('Network error');
}

void main() async {
  bool isLoading = true;

  await fetchData()
      .then((_) => print('Success!'))
      .catchError((e) => print('Error: $e'))
      .whenComplete(() {
        isLoading = false;
        print('Loading complete (isLoading: $isLoading)');
      });
}
```

### ⚠️ Common Mistakes: Error Propagation

```dart
// ❌ WRONG: Swallowing errors silently
Future<void> badErrorHandling() async {
  try {
    await riskyOperation();
  } catch (e) {
    // Empty catch — error disappears! Very hard to debug.
  }
}

// ❌ WRONG: catchError returns wrong type
Future<int> badCatchError() {
  return Future<int>.error('fail').catchError((e) {
    print('Error: $e');
    // Missing return! Returns null implicitly, but Future<int> expects int.
    // This causes a type error at runtime.
  });
}

// ✅ CORRECT: Always return something in catchError for typed futures
Future<int> goodCatchError() {
  return Future<int>.error('fail').catchError((e) {
    print('Error: $e');
    return 0; // A valid fallback integer
  });
}
```

---

## 11.5 Unawaited Futures and the Bugs They Cause

This is one of the most common sources of subtle bugs in Flutter apps.

### What Is an Unawaited Future?

When you call an `async` function but don't `await` it and don't attach a `.then()/.catchError()`, you have an **unawaited future**. The operation runs, but you have no way to know when it completes, or if it succeeded.

```dart
// ❌ DANGER: Unawaited future
void saveToDatabase(String data) async {
  await Future.delayed(Duration(seconds: 1));
  if (data.isEmpty) throw Exception('Data cannot be empty');
  print('Saved!');
}

void main() async {
  saveToDatabase(''); // Returns a Future<void> — we throw it away!
  print('Continuing without waiting...');
  // The exception thrown inside saveToDatabase will be an
  // UNHANDLED EXCEPTION that can crash your app silently
  // or print an ugly error to the console.
}
```

**Output (with unhandled exception):**
```
Continuing without waiting...
Unhandled exception:
Exception: Data cannot be empty
...
```

### How to Fix Unawaited Futures

```dart
import 'dart:async';

// Option 1: await it (most common)
Future<void> main() async {
  await saveToDatabase('some data');
}

// Option 2: Attach error handling
void main2() {
  saveToDatabase('some data').catchError((e) {
    print('Save failed: $e');
  });
}

// Option 3: Use unawaited() from dart:async to make it explicit and
// suppress the lint warning when you INTENTIONALLY fire-and-forget
void main3() {
  unawaited(saveToDatabase('some data'));
  // Now the linter knows you intentionally didn't await this
  // But you still lose error handling!
}
```

### The `unawaited_futures` Lint Rule

In your `analysis_options.yaml`, you can enable this lint:

```yaml
linter:
  rules:
    - unawaited_futures
```

This will warn you any time you call an async function without awaiting it. **Highly recommended** for all projects.

> 💡 **Pro Tip:** Always ask yourself: "If this async operation fails, what happens?" If the answer is "nothing visible," you almost certainly have an unawaited future bug.

---

## 11.6 The Completer Class — Manually Completing Futures

Sometimes you need to create a `Future` that you will complete manually at some arbitrary later point. This is what `Completer<T>` is for.

### Basic Completer Usage

```dart
import 'dart:async';

// Imagine a dialog that waits for user input
Future<String?> showCustomDialog() {
  final completer = Completer<String?>();

  // Simulate user eventually clicking a button
  Future.delayed(Duration(seconds: 2), () {
    // The user "clicked OK" with "John" as input
    completer.complete('John');
    
    // If the user cancelled:
    // completer.complete(null);
    
    // If something went wrong:
    // completer.completeError(Exception('Dialog error'));
  });

  return completer.future; // Return the future to the caller
}

void main() async {
  print('Waiting for dialog...');
  final name = await showCustomDialog();
  print('User entered: $name');
}
```

### Real-World Use Case: Bridging Callback APIs

Many older APIs use callbacks. `Completer` lets you wrap them in `Future`:

```dart
import 'dart:async';

// Pretend this is a legacy callback-based API
void legacyFetchUser(String id, void Function(Map<String, dynamic> user) onSuccess,
    void Function(String error) onError) {
  // Simulate async work with a callback
  Future.delayed(Duration(milliseconds: 500), () {
    if (id == '42') {
      onSuccess({'id': '42', 'name': 'Alice'});
    } else {
      onError('User not found');
    }
  });
}

// Wrap it in a modern Future using Completer
Future<Map<String, dynamic>> fetchUser(String id) {
  final completer = Completer<Map<String, dynamic>>();

  legacyFetchUser(
    id,
    (user) => completer.complete(user),         // success
    (error) => completer.completeError(error),   // failure
  );

  return completer.future;
}

void main() async {
  try {
    final user = await fetchUser('42');
    print('Found user: ${user['name']}'); // Found user: Alice
    
    final missing = await fetchUser('99');
  } catch (e) {
    print('Error: $e'); // Error: User not found
  }
}
```

### ⚠️ Completer Pitfalls

```dart
// ❌ WRONG: Completing twice throws an error!
final completer = Completer<int>();
completer.complete(1);
completer.complete(2); // StateError: Future already completed

// ✅ CORRECT: Check isCompleted first
if (!completer.isCompleted) {
  completer.complete(1);
}
```

---

## 11.7 Isolates: What They Are and When to Use Them

### The Problem: Heavy Computation on the Main Isolate

Flutter renders at 60fps (or 120fps on newer devices). That means the main isolate has roughly **16ms** to do everything needed for each frame. If you do a heavy computation — parsing a 10MB JSON file, running a complex algorithm, processing an image — it will **block the UI** and cause jank (dropped frames).

```dart
// ❌ This will freeze your UI for several hundred milliseconds
List<int> computePrimes(int limit) {
  List<int> primes = [];
  for (int i = 2; i <= limit; i++) {
    bool isPrime = true;
    for (int j = 2; j * j <= i; j++) {
      if (i % j == 0) {
        isPrime = false;
        break;
      }
    }
    if (isPrime) primes.add(i);
  }
  return primes;
}

// Calling this in a button press handler: BAD IDEA
// onPressed: () { final primes = computePrimes(1000000); }
```

### Isolates to the Rescue

Dart **Isolates** are truly separate threads of execution with their own memory heap. They don't share memory — they communicate by **message passing**. This means no race conditions, no deadlocks. But it also means you can't pass arbitrary objects between isolates (they must be serializable).

```
Main Isolate              Background Isolate
     │                          │
     │  sendPort.send(data)      │
     │ ─────────────────────────►│
     │                          │ (does heavy work)
     │  result via ReceivePort   │
     │ ◄─────────────────────────│
     │                          │
```

### Using `Isolate.spawn()`

```dart
import 'dart:isolate';

// This function runs in the background isolate.
// It MUST be a top-level function or static method — not a closure
// that captures variables from the outer scope.
void backgroundWorker(SendPort sendPort) {
  // Receive the data to work on
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort); // Send back our receive port

  receivePort.listen((message) {
    if (message is int) {
      // Do the heavy computation
      final result = _computePrimes(message);
      sendPort.send(result);
    }
  });
}

List<int> _computePrimes(int limit) {
  List<int> primes = [];
  for (int i = 2; i <= limit; i++) {
    bool isPrime = true;
    for (int j = 2; j * j <= i; j++) {
      if (i % j == 0) { isPrime = false; break; }
    }
    if (isPrime) primes.add(i);
  }
  return primes;
}

Future<List<int>> computePrimesInBackground(int limit) async {
  final receivePort = ReceivePort();
  
  // Spawn the isolate
  await Isolate.spawn(backgroundWorker, receivePort.sendPort);
  
  // Get the isolate's send port
  final sendPort = await receivePort.first as SendPort;
  
  // Create a response port for this specific request
  final responsePort = ReceivePort();
  sendPort.send(limit); // Send the limit to compute
  
  // Wait for the result — but this doesn't block the UI thread!
  final result = await responsePort.first;
  responsePort.close();
  
  return result as List<int>;
}

void main() async {
  print('Starting computation...');
  final primes = await computePrimesInBackground(100000);
  print('Found ${primes.length} primes up to 100,000');
}
```

---

## 11.8 The `compute()` Function — The Easy Way

Flutter's `compute()` function is a high-level wrapper around isolates, perfect for simple "run this function in the background" use cases.

```dart
import 'package:flutter/foundation.dart';

// The function MUST be a top-level function
List<int> _computePrimesEntryPoint(int limit) {
  List<int> primes = [];
  for (int i = 2; i <= limit; i++) {
    bool isPrime = true;
    for (int j = 2; j * j <= i; j++) {
      if (i % j == 0) { isPrime = false; break; }
    }
    if (isPrime) primes.add(i);
  }
  return primes;
}

// Example: Parse a large JSON string in the background
import 'dart:convert';

List<Map<String, dynamic>> _parseProducts(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded.cast<Map<String, dynamic>>();
}

// In your widget or service:
class ProductService {
  Future<List<Map<String, dynamic>>> loadProducts(String rawJson) async {
    // compute() takes: (function, argument) 
    // The function must accept exactly ONE argument
    return await compute(_parseProducts, rawJson);
  }
}
```

### When to Use `compute()` vs `Isolate.spawn()`

| Feature | `compute()` | `Isolate.spawn()` |
|---|---|---|
| Ease of use | ✅ Very simple | ❌ Verbose setup |
| One-shot tasks | ✅ Perfect | ⚠️ Overkill |
| Long-lived isolates | ❌ Not suitable | ✅ Perfect |
| Two-way communication | ❌ No | ✅ Yes |
| Multiple messages | ❌ No | ✅ Yes |

> 💡 **Pro Tip:** Use `compute()` for one-shot heavy tasks (JSON parsing, image processing). Use `Isolate.spawn()` when you need a persistent background worker that receives many messages over its lifetime.

---

## ✏️ Session 11 Exercises

**Exercise 11.1 — Event Loop Prediction**
Before running the following code, predict the exact output order. Then run it and verify.
```dart
import 'dart:async';
void main() {
  print('A');
  Future(() => print('B'));
  Future.microtask(() => print('C'));
  Future.value(1).then((_) => print('D'));
  Future(() => print('E'));
  print('F');
}
```
*Hint: Remember — sync first, then microtasks, then event queue in order.*

**Exercise 11.2 — Completer Wrapper**
Write a function `waitForButtonPress()` that returns a `Future<void>` using a `Completer`. Simulate the button being pressed after 3 seconds using `Future.delayed`. In `main()`, print "Waiting..." before calling it, and "Button pressed!" after the future completes.
*Hint: Create a `Completer<void>`, schedule the delayed completion, return `completer.future`.*

**Exercise 11.3 — Background Computation**
Use `compute()` to parse the following JSON string in a background isolate. Print the list of product names.
```dart
const jsonString = '[{"name":"Laptop","price":999},{"name":"Phone","price":699}]';
```
*Hint: Write a top-level function `List<String> parseNames(String json)` that decodes and extracts names.*

**Exercise 11.4 — Unawaited Future Bug Hunt**
Find all the bugs in the following code and fix them:
```dart
void saveUser(String name) async {
  await Future.delayed(Duration(seconds: 1));
  if (name.isEmpty) throw Exception('Name required');
  print('User saved: $name');
}
void main() {
  saveUser('Alice');
  saveUser('');
  print('Done');
}
```
*Hint: What happens to the exception from `saveUser('')`?*

---

<a name="session-12"></a>
# Session 12 – Streams & StreamController

## 12.1 What Is a Stream?

If a `Future<T>` is a single async value, a `Stream<T>` is a **sequence of async values over time**. Think of it as a pipeline or a river:

```
Stream<int>: ──●──●──●──●──●──✓──
               1  2  3  4  5  (done)

                       or

Stream<String>: ──●──────────●──✗──
                 "hello"   "world" (error)
```

Real-world analogies:
- **Stock price ticker** — a new price every second
- **Search results** — updates as the user types
- **File upload progress** — percentage updates as data sends
- **WebSocket messages** — messages arriving from a server

```dart
// Creating a simple stream and listening to it
Stream<int> countDown(int from) async* {
  for (int i = from; i >= 0; i--) {
    yield i;
    await Future.delayed(Duration(seconds: 1));
  }
}

void main() async {
  await for (final count in countDown(5)) {
    print(count); // Prints 5, 4, 3, 2, 1, 0 — one per second
  }
  print('Blast off!');
}
```

---

## 12.2 Single-Subscription vs Broadcast Streams

### Single-Subscription Streams

The **default** type of stream. Can only be listened to **once**. This is the most common type for operations like reading a file or making an HTTP request.

```dart
Stream<int> singleSubStream = Stream.fromIterable([1, 2, 3, 4, 5]);

// First listen — works fine
singleSubStream.listen((v) => print('Listener 1: $v'));

// Second listen — throws StateError!
// singleSubStream.listen((v) => print('Listener 2: $v')); // ❌ ERROR
```

### Broadcast Streams

Can be listened to by **multiple subscribers** simultaneously. Events are broadcast to all current listeners.

```dart
import 'dart:async';

// Convert a single-sub stream to broadcast
final broadcastStream = Stream.fromIterable([1, 2, 3]).asBroadcastStream();

broadcastStream.listen((v) => print('Listener A: $v'));
broadcastStream.listen((v) => print('Listener B: $v'));

// Or create a broadcast StreamController directly
final controller = StreamController<int>.broadcast();
controller.stream.listen((v) => print('Sub 1: $v'));
controller.stream.listen((v) => print('Sub 2: $v'));

controller.add(10); // Both subscribers receive 10
controller.add(20); // Both subscribers receive 20
```

> ⚠️ **Important:** If you subscribe to a broadcast stream *after* events have been emitted, you miss those events. Broadcast streams don't buffer.

---

## 12.3 Creating Streams

### Stream.fromIterable()

```dart
// Create a stream from an existing collection
Stream<String> fruits = Stream.fromIterable(['apple', 'banana', 'cherry']);

fruits.listen(
  (fruit) => print('Got: $fruit'),
  onDone: () => print('All fruits delivered!'),
);
// Output:
// Got: apple
// Got: banana
// Got: cherry
// All fruits delivered!
```

### Stream.periodic()

```dart
import 'dart:async';

// Emits a value every 500ms, starting from 0
final ticker = Stream.periodic(
  Duration(milliseconds: 500),
  (count) => count, // Transform the count index into a value
).take(5); // Only take 5 events

ticker.listen(
  (value) => print('Tick: $value'),
  onDone: () => print('Done ticking'),
);
// Output: Tick: 0, Tick: 1, Tick: 2, Tick: 3, Tick: 4, Done ticking
```

### Stream.fromFuture()

```dart
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 1));
  return 'Hello from Future!';
}

// Create a stream that emits exactly one value from a Future
Stream<String> dataStream = Stream.fromFuture(fetchData());
dataStream.listen(
  (data) => print(data),    // 'Hello from Future!'
  onDone: () => print('Stream done'),
);
```

### Stream.value() and Stream.error()

```dart
// Stream that immediately emits a single value and closes
Stream<int> instant = Stream.value(42);

// Stream that immediately emits an error and closes
Stream<int> broken = Stream.error(Exception('Something went wrong'));
```

---

## 12.4 StreamController — Full Control

`StreamController<T>` lets you create and manage a stream imperatively — you decide exactly when to add data, errors, and when to close.

```dart
import 'dart:async';

class CounterService {
  // The controller manages the stream
  final _controller = StreamController<int>();
  int _count = 0;

  // Expose only the stream (not the controller itself)
  Stream<int> get counterStream => _controller.stream;

  void increment() {
    _count++;
    _controller.add(_count);       // Push a new value to the stream
  }

  void simulateError() {
    _controller.addError(Exception('Counter error!')); // Push an error
  }

  void dispose() {
    _controller.close();           // Always close when done!
  }
}

void main() async {
  final service = CounterService();

  service.counterStream.listen(
    (count) => print('Count: $count'),
    onError: (e) => print('Error: $e'),
    onDone: () => print('Stream closed!'),
  );

  service.increment(); // Count: 1
  service.increment(); // Count: 2
  service.increment(); // Count: 3
  service.simulateError(); // Error: Exception: Counter error!
  service.dispose();  // Stream closed!
}
```

### The Sink API

`StreamController.sink` is an alternative way to add data, often used when you want to expose only the "input" side:

```dart
import 'dart:async';

final controller = StreamController<String>();

// Two ways to add data — they are equivalent:
controller.add('via controller.add');
controller.sink.add('via sink.add');

// The sink is useful for passing as an argument to functions
// that should only be able to add data, not access the stream
void dataProducer(StreamSink<String> sink) {
  sink.add('produced value');
}

dataProducer(controller.sink);
controller.close();
```

---

## 12.5 Listening to Streams

The `listen()` method is the fundamental way to subscribe to a stream.

```dart
import 'dart:async';

final controller = StreamController<int>();

// Full listen() signature with all callbacks
final subscription = controller.stream.listen(
  (data) {
    print('Data: $data');           // Called for each new value
  },
  onError: (error, StackTrace stack) {
    print('Error: $error');         // Called when an error is added
    // Note: by default, stream continues after error
  },
  onDone: () {
    print('Stream complete');       // Called when stream closes
  },
  cancelOnError: false,             // If true, auto-cancel on first error
);

controller.add(1);
controller.add(2);
controller.addError(Exception('oops'));
controller.add(3); // Still received if cancelOnError is false
controller.close();

// Output:
// Data: 1
// Data: 2
// Error: Exception: oops
// Data: 3
// Stream complete
```

### StreamSubscription Management

```dart
import 'dart:async';

final controller = StreamController<int>.broadcast();
int value = 0;

// Start a periodic stream
final subscription = Stream.periodic(Duration(seconds: 1), (i) => i)
    .listen((i) => print('Received: $i'));

// Pause and resume
Future.delayed(Duration(seconds: 3), () {
  subscription.pause();
  print('Paused!');
});

Future.delayed(Duration(seconds: 5), () {
  subscription.resume();
  print('Resumed!');
});

// Cancel (clean up) after 8 seconds
Future.delayed(Duration(seconds: 8), () {
  subscription.cancel();
  print('Cancelled!');
});
```

---

## 12.6 Stream Transformers

Streams support a rich set of transformers that let you modify, filter, and reshape the data flowing through them.

### map()

```dart
// Transform each element
Stream<int> numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
Stream<String> strings = numbers.map((n) => 'Item #$n');

strings.listen(print);
// Item #1, Item #2, Item #3, Item #4, Item #5
```

### where()

```dart
// Filter elements
Stream<int> numbers = Stream.fromIterable([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
Stream<int> evens = numbers.where((n) => n % 2 == 0);

evens.listen(print); // 2, 4, 6, 8, 10
```

### take() and skip()

```dart
Stream<int> infinite = Stream.periodic(Duration(milliseconds: 100), (i) => i);

// Take only the first 5 values
infinite.take(5).listen(print); // 0, 1, 2, 3, 4

// Skip the first 3, then take 5
infinite.skip(3).take(5).listen(print); // 3, 4, 5, 6, 7
```

### distinct()

```dart
// Only emit when value changes
Stream<int> withDuplicates = Stream.fromIterable([1, 1, 2, 2, 3, 1, 1]);
Stream<int> deduplicated = withDuplicates.distinct();

deduplicated.listen(print); // 1, 2, 3, 1
```

### timeout()

```dart
import 'dart:async';

// Emit an error if no event received within the timeout
Stream<int> slowStream = Stream.periodic(Duration(seconds: 3), (i) => i);
Stream<int> withTimeout = slowStream.timeout(
  Duration(seconds: 2),
  onTimeout: (sink) {
    sink.addError(TimeoutException('Stream timed out!'));
    // or: sink.close(); to just close the stream
  },
);

withTimeout.listen(
  (v) => print('Got: $v'),
  onError: (e) => print('Error: $e'),
);
```

### asyncMap() — For Async Transformations

```dart
// When the transformation itself is async
Stream<String> productIds = Stream.fromIterable(['p1', 'p2', 'p3']);

Stream<Map<String, dynamic>> products = productIds.asyncMap((id) async {
  // Simulate fetching product details
  await Future.delayed(Duration(milliseconds: 100));
  return {'id': id, 'name': 'Product $id', 'price': 9.99};
});

products.listen((p) => print('Product: ${p['name']}'));
```

### Chaining Transformers

```dart
Stream.fromIterable([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    .where((n) => n % 2 == 0)    // [2, 4, 6, 8, 10]
    .map((n) => n * n)            // [4, 16, 36, 64, 100]
    .take(3)                      // [4, 16, 36]
    .listen(print);               // 4, 16, 36
```

---

## 12.7 async* and yield — Generator Functions

The `async*` keyword turns a function into a **stream generator**. Use `yield` to emit values and `yield*` to emit all values from another stream/iterable.

```dart
// Basic generator
Stream<int> fibonacci() async* {
  int a = 0, b = 1;
  while (true) {
    yield a;
    final next = a + b;
    a = b;
    b = next;
    await Future.delayed(Duration(milliseconds: 100)); // Non-blocking
  }
}

// Consume the first 10 Fibonacci numbers
void main() async {
  await for (final n in fibonacci().take(10)) {
    print(n); // 0, 1, 1, 2, 3, 5, 8, 13, 21, 34
  }
}
```

### yield* — Delegating to Another Stream

```dart
Stream<int> part1() async* {
  yield 1;
  yield 2;
  yield 3;
}

Stream<int> part2() async* {
  yield 4;
  yield 5;
}

// Combine two streams sequentially
Stream<int> combined() async* {
  yield* part1();  // Yields all of part1's values
  yield* part2();  // Then all of part2's values
}

void main() async {
  await for (final n in combined()) {
    print(n); // 1, 2, 3, 4, 5
  }
}
```

### Practical Example: Paginated API with async*

```dart
// Automatically fetch all pages of a paginated API
Stream<List<Map<String, dynamic>>> fetchAllProducts() async* {
  int page = 1;
  bool hasMore = true;

  while (hasMore) {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 500));
    
    final products = List.generate(
      10,
      (i) => {'id': (page - 1) * 10 + i + 1, 'name': 'Product ${(page-1)*10+i+1}'},
    );

    yield products; // Emit this page's products

    page++;
    hasMore = page <= 3; // Simulate 3 pages total
  }
}

void main() async {
  int total = 0;
  await for (final page in fetchAllProducts()) {
    total += page.length;
    print('Loaded page with ${page.length} products. Total so far: $total');
  }
  print('All $total products loaded!');
}
```

---

## 12.8 Memory Leaks: Always Cancel Subscriptions

This is critically important in Flutter. Widgets can be removed from the widget tree, but if they have active stream subscriptions, those subscriptions keep their listeners alive, causing **memory leaks** and potential errors when disposed widgets try to call `setState`.

```dart
import 'dart:async';
import 'package:flutter/material.dart';

// ❌ WRONG: StreamSubscription not cancelled on dispose
class LeakyWidget extends StatefulWidget {
  @override
  State<LeakyWidget> createState() => _LeakyWidgetState();
}

class _LeakyWidgetState extends State<LeakyWidget> {
  int _count = 0;
  // Never cancelled!
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Stream.periodic(Duration(seconds: 1), (i) => i).listen((i) {
      setState(() => _count = i);
      // If widget is disposed, setState throws an error!
    });
  }

  @override
  Widget build(BuildContext context) => Text('Count: $_count');
  
  // dispose() never called, _subscription leaks!
}

// ✅ CORRECT: Always cancel in dispose()
class SafeWidget extends StatefulWidget {
  @override
  State<SafeWidget> createState() => _SafeWidgetState();
}

class _SafeWidgetState extends State<SafeWidget> {
  int _count = 0;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Stream.periodic(Duration(seconds: 1), (i) => i).listen((i) {
      if (mounted) { // Check if still mounted before setState
        setState(() => _count = i);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // ✅ Clean up!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text('Count: $_count');
}
```

> 💡 **Pro Tip:** In Flutter, `StreamBuilder` handles subscription lifecycle for you automatically. It subscribes when built and cancels when disposed. This is one strong reason to prefer `StreamBuilder` over manually calling `.listen()` in widgets.

---

## ✏️ Session 12 Exercises

**Exercise 12.1 — Stream Pipeline**
Create a stream from `Stream.fromIterable([3, 7, 2, 9, 1, 4, 8, 5, 6])`. Using chained transformers (no loops), produce and print only the squares of the even numbers that are greater than 4. Expected output: `64, 36`.
*Hint: Chain `.where()` twice and `.map()` once.*

**Exercise 12.2 — StreamController Counter**
Build a `CounterBloc`-style class using `StreamController<int>`. It should expose:
- A `stream` getter for the count
- An `increment()` method
- A `decrement()` method
- A `dispose()` method to close the stream
*Hint: Keep the controller private. Expose only the stream.*

**Exercise 12.3 — async* Generator**
Write an `async*` function `Stream<String> typingEffect(String text)` that yields the text character by character with a 50ms delay between each character. Use it to print a "typing" animation in the console.
*Hint: Iterate over `text.characters` or use `text[i]`.*

**Exercise 12.4 — Broadcast Stream**
Using a `StreamController.broadcast()`, simulate a simple event bus. Write `EventBus` class with `post(String event)` and `on(String event, Function handler)` methods. Post 3 events and have 2 subscribers receive them.
*Hint: The stream can be filtered with `.where()` to only receive specific event types.*

---

<a name="session-13"></a>
# Session 13 – StreamBuilder in Flutter

## 13.1 The Problem StreamBuilder Solves

In Session 12, we saw that manually managing stream subscriptions in `StatefulWidget` requires:
1. Declaring a `StreamSubscription` field
2. Subscribing in `initState()`
3. Calling `setState()` on each event
4. Cancelling in `dispose()`

That's a lot of boilerplate. `StreamBuilder` encapsulates all of this for you, and gives you a clean declarative API.

```dart
StreamBuilder<T>(
  stream: yourStream,   // The stream to listen to
  builder: (context, snapshot) {
    // Rebuild whenever the stream emits
    // snapshot contains the current state
    return YourWidget();
  },
);
```

---

## 13.2 AsyncSnapshot and ConnectionState

The `builder` function receives a `BuildContext` and an `AsyncSnapshot<T>`. The snapshot is your window into the current state of the stream.

```dart
// AsyncSnapshot<T> properties:
// snapshot.connectionState — what phase the connection is in
// snapshot.hasData        — true if a value is available
// snapshot.data           — the current value (nullable)
// snapshot.hasError       — true if an error occurred
// snapshot.error          — the error object
// snapshot.stackTrace     — the stack trace for the error
```

### The 4 ConnectionState Values

| State | Meaning |
|---|---|
| `ConnectionState.none` | No stream connected (stream is null) |
| `ConnectionState.waiting` | Subscribed, but no data yet |
| `ConnectionState.active` | Data is flowing (stream is open) |
| `ConnectionState.done` | Stream has closed |

```dart
import 'package:flutter/material.dart';
import 'dart:async';

class StreamDemoWidget extends StatelessWidget {
  // A stream that emits 1..5 over 5 seconds
  final Stream<int> _myStream = Stream.periodic(
    Duration(seconds: 1),
    (i) => i + 1,
  ).take(5);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _myStream,
      builder: (context, snapshot) {
        // Handle all 4 ConnectionState cases
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Center(child: Text('No stream connected'));

          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());

          case ConnectionState.active:
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return Center(
              child: Text(
                'Current value: ${snapshot.data}',
                style: const TextStyle(fontSize: 48),
              ),
            );

          case ConnectionState.done:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Stream complete!'),
                  Text('Final value: ${snapshot.data}'),
                ],
              ),
            );
        }
      },
    );
  }
}
```

---

## 13.3 The `initialData` Parameter

By default, `StreamBuilder` starts in `ConnectionState.waiting` with no data. You can provide an `initialData` to have a value immediately:

```dart
StreamBuilder<int>(
  stream: counterStream,
  initialData: 0, // Starts with 0, no waiting state
  builder: (context, snapshot) {
    // snapshot.connectionState starts as .waiting but snapshot.hasData is true
    // because initialData is provided
    return Text('Count: ${snapshot.data ?? 0}');
  },
);
```

---

## 13.4 Real-World Example: Live Search Filter

This is a classic use case: filter a list of products as the user types, with a debounce to avoid making a network request on every keystroke.

```dart
import 'dart:async';
import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final double price;

  const Product({required this.id, required this.name, required this.price});
}

// Mock product list
const List<Product> _allProducts = [
  Product(id: '1', name: 'MacBook Pro', price: 1999.99),
  Product(id: '2', name: 'MacBook Air', price: 1299.99),
  Product(id: '3', name: 'iPhone 15 Pro', price: 999.99),
  Product(id: '4', name: 'iPad Pro', price: 799.99),
  Product(id: '5', name: 'AirPods Pro', price: 249.99),
  Product(id: '6', name: 'Apple Watch', price: 399.99),
];

class LiveSearchPage extends StatefulWidget {
  const LiveSearchPage({super.key});

  @override
  State<LiveSearchPage> createState() => _LiveSearchPageState();
}

class _LiveSearchPageState extends State<LiveSearchPage> {
  // The controller for the search stream
  final _searchController = StreamController<String>.broadcast();
  
  // The stream with debounce applied
  late Stream<List<Product>> _resultsStream;

  @override
  void initState() {
    super.initState();
    
    _resultsStream = _searchController.stream
        // Debounce: wait 300ms after the user stops typing
        .transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              // Simple debounce using Timer
              sink.add(data);
            },
          ),
        )
        .debounceTime(Duration(milliseconds: 300)) // requires rxdart or implement manually
        .map((query) {
          if (query.isEmpty) return _allProducts;
          return _allProducts
              .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
  }

  @override
  void dispose() {
    _searchController.close(); // ✅ Always close!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Product Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _searchController.add, // Push query to stream
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _resultsStream,
              initialData: _allProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Manual debounce implementation (without rxdart)
extension DebounceExtension<T> on Stream<T> {
  Stream<T> debounceTime(Duration duration) {
    Timer? debounceTimer;
    late StreamController<T> controller;
    StreamSubscription<T>? subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
          (data) {
            debounceTimer?.cancel();
            debounceTimer = Timer(duration, () => controller.add(data));
          },
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onCancel: () {
        debounceTimer?.cancel();
        subscription?.cancel();
      },
    );

    return controller.stream;
  }
}
```

---

## 13.5 Using StreamController with StreamBuilder for Live Updates

A common pattern is to have a service/bloc that exposes a stream, and widgets subscribe via `StreamBuilder`:

```dart
import 'dart:async';
import 'package:flutter/material.dart';

// ---- Shopping Cart Model ----
class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

// ---- Cart Service (the "source of truth") ----
class CartService {
  final _items = <String, CartItem>{};
  final _cartController = StreamController<List<CartItem>>.broadcast();

  Stream<List<CartItem>> get cartStream => _cartController.stream;
  List<CartItem> get currentItems => _items.values.toList();

  void addItem(String id, String name, double price) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
    } else {
      _items[id] = CartItem(productId: id, name: name, price: price);
    }
    _cartController.add(currentItems); // Broadcast the update
  }

  void removeItem(String id) {
    _items.remove(id);
    _cartController.add(currentItems);
  }

  void dispose() => _cartController.close();
}

// ---- Cart Badge Widget ----
class CartBadge extends StatelessWidget {
  final CartService cartService;

  const CartBadge({super.key, required this.cartService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CartItem>>(
      stream: cartService.cartStream,
      initialData: cartService.currentItems,
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return Stack(
          children: [
            const Icon(Icons.shopping_cart),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
```

---

## 13.6 Performance: Avoiding Unnecessary Rebuilds

`StreamBuilder` rebuilds its subtree on *every stream event*. This can be expensive if your tree is deep. Strategies to minimize rebuilds:

### Strategy 1: Push StreamBuilder Down the Tree

```dart
// ❌ BAD: The entire Scaffold rebuilds on each stream event
Scaffold(
  body: StreamBuilder<int>(
    stream: counterStream,
    builder: (context, snapshot) {
      return Column(
        children: [
          ExpensiveStaticWidget(), // Rebuilt needlessly every second!
          Text('Count: ${snapshot.data}'),
          AnotherExpensiveWidget(), // Also rebuilt needlessly!
        ],
      );
    },
  ),
);

// ✅ GOOD: Only the Text rebuilds
Scaffold(
  body: Column(
    children: [
      const ExpensiveStaticWidget(), // Never rebuilt
      StreamBuilder<int>(
        stream: counterStream,
        builder: (context, snapshot) => Text('Count: ${snapshot.data}'),
      ),
      const AnotherExpensiveWidget(), // Never rebuilt
    ],
  ),
);
```

### Strategy 2: Use distinct() on the Stream

```dart
// Only rebuild when value actually changes
StreamBuilder<int>(
  stream: myStream.distinct(), // Skip duplicate values
  builder: (context, snapshot) => Text('${snapshot.data}'),
);
```

---

## 13.7 BehaviorSubject Pattern (Preview of BLoC)

A `BehaviorSubject` (from the `rxdart` package) is a special broadcast `StreamController` that:
1. Replays the **last emitted value** to new subscribers immediately
2. Is a `broadcast` stream (multiple subscribers)

This solves the "late subscriber misses the first event" problem.

```yaml
# pubspec.yaml
dependencies:
  rxdart: ^0.27.7
```

```dart
import 'package:rxdart/rxdart.dart';

class ProductBloc {
  // BehaviorSubject: new subscribers immediately get the last value
  final _productsSubject = BehaviorSubject<List<String>>.seeded([]);

  // Expose as Stream<T>
  Stream<List<String>> get products => _productsSubject.stream;
  
  // Get current value synchronously (BehaviorSubject supports this!)
  List<String> get currentProducts => _productsSubject.value;

  void addProduct(String name) {
    final updated = [..._productsSubject.value, name];
    _productsSubject.add(updated);
  }

  void dispose() => _productsSubject.close();
}

// Usage in a widget — even if the widget subscribes AFTER the first 
// product is added, it will immediately receive the current list!
StreamBuilder<List<String>>(
  stream: productBloc.products,
  builder: (context, snapshot) {
    final products = snapshot.data ?? [];
    return ListView(
      children: products.map((p) => ListTile(title: Text(p))).toList(),
    );
  },
);
```

> 💡 **Pro Tip:** `BehaviorSubject` from `rxdart` is the workhorse of BLoC pattern implementations. It eliminates the `initialData` boilerplate in `StreamBuilder` and makes state management much cleaner.

---

## ✏️ Session 13 Exercises

**Exercise 13.1 — All 4 States**
Create a `StreamBuilder` widget that connects to `Stream.periodic(Duration(seconds: 1), (i) => i).take(5)`. Handle all 4 `ConnectionState` values with distinct UI: a loading indicator, a large number display, an error UI (simulate by adding `.map((i) { if(i == 3) throw Exception('Error!'); return i; })`), and a "finished" banner.
*Hint: Use a switch statement on `snapshot.connectionState`.*

**Exercise 13.2 — Cart Total**
Using the `CartService` from section 13.5, add a `CartTotal` widget that uses `StreamBuilder` to display the total price of all items in the cart. The total should update in real time as items are added/removed.
*Hint: Sum `item.total` for all items in `snapshot.data`.*

**Exercise 13.3 — Search Box**
Implement the live search from section 13.4 but with a local list of 10 country names. The search should be case-insensitive and should filter by prefix match (starts with). Do NOT use `rxdart` — implement the debounce manually using `Timer`.
*Hint: Keep a reference to the last `Timer` and cancel it before creating a new one.*

**Exercise 13.4 — Distinct Rebuild Test**
Add a print statement inside a `StreamBuilder`'s builder function. Create a stream that emits the sequence `[1, 1, 2, 2, 3, 3]`. First, observe how many rebuilds happen without `.distinct()`. Then add `.distinct()` to the stream. Observe the difference.
*Hint: Count the number of prints in each case.*

---

<a name="session-14"></a>
# Session 14 – Repository Pattern

## 14.1 What Is the Repository Pattern? Why Does It Matter?

Imagine you're building an e-commerce app. You need product data. Where does it come from? Maybe right now it's hardcoded. Tomorrow, it's from a REST API. Next week, you add local caching with SQLite. In a month, you switch from REST to GraphQL.

Without the Repository Pattern, each of these changes ripples through your entire codebase. Widgets directly call HTTP, business logic is mixed with UI code, and testing is a nightmare.

The **Repository Pattern** introduces a clean abstraction layer between your data sources and the rest of your application. The rest of your app talks to the Repository interface — it doesn't know or care where the data actually comes from.

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│    (Widgets, BLoC, ViewModels — the "UI" side)          │
└─────────────────────────┬───────────────────────────────┘
                          │ uses
┌─────────────────────────▼───────────────────────────────┐
│                     Domain Layer                         │
│    (Repository Interfaces, Domain Models, Use Cases)     │
└─────────────────────────┬───────────────────────────────┘
                          │ implemented by
┌─────────────────────────▼───────────────────────────────┐
│                      Data Layer                          │
│    (Concrete Repositories, Data Sources, DTOs)           │
│    ┌──────────────┐  ┌───────────┐  ┌────────────────┐  │
│    │  Remote API  │  │  SQLite   │  │  Shared Prefs  │  │
│    └──────────────┘  └───────────┘  └────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 14.2 Separating Data Layer from UI Layer

### The Bad Way — Direct Data Access in Widgets

```dart
// ❌ TERRIBLE: Network call directly in a widget
class ProductListScreen extends StatefulWidget {
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    // This is wrong on so many levels:
    // 1. Network code in UI
    // 2. No error handling
    // 3. Untestable
    // 4. Business logic mixed with presentation
    http.get(Uri.parse('https://api.example.com/products')).then((response) {
      final data = json.decode(response.body) as List;
      setState(() => _products = data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _products.map((p) => ListTile(title: Text(p['name']))).toList(),
    );
  }
}
```

The problem: if you want to test this widget, you need a real network connection. If you want to change the API, you change the widget. If you want to add caching, you change the widget. This is unmaintainable.

---

## 14.3 Domain Models — The Language of Your App

Domain models represent the core concepts of your business domain. They should be pure Dart objects with no knowledge of how they are stored or fetched.

```dart
// lib/domain/models/product.dart

/// Represents a product in the ShopEase application.
/// This is a DOMAIN MODEL — it knows nothing about databases or APIs.
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final bool isInStock;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.isInStock,
    required this.createdAt,
  });

  // Useful for state management — create modified copy
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    bool? isInStock,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      isInStock: isInStock ?? this.isInStock,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}
```

---

## 14.4 Data Transfer Objects (DTOs)

DTOs are objects whose sole purpose is to carry data from a data source to your domain layer. They know how to parse raw data (JSON, database rows) and convert to domain models.

```dart
// lib/data/dtos/product_dto.dart

/// ProductDTO — knows how to parse API JSON and convert to domain Product
class ProductDto {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final bool isInStock;
  final String createdAt; // API returns a string

  const ProductDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.isInStock,
    required this.createdAt,
  });

  /// Parse from API JSON response
  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      categoryId: json['category_id'] as String,
      isInStock: json['in_stock'] as bool? ?? true,
      createdAt: json['created_at'] as String,
    );
  }

  /// Convert to API JSON format (for PUT/POST requests)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'image_url': imageUrl,
    'category_id': categoryId,
    'in_stock': isInStock,
    'created_at': createdAt,
  };

  /// Convert DTO to Domain Model
  Product toDomain() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categoryId: categoryId,
      isInStock: isInStock,
      createdAt: DateTime.parse(createdAt), // Parse string to DateTime
    );
  }
}
```

### Why Separate DTOs from Domain Models?

| Concern | Domain Model | DTO |
|---|---|---|
| Business logic | ✅ Yes | ❌ No |
| JSON parsing | ❌ No | ✅ Yes |
| Database mapping | ❌ No | ✅ Yes |
| Stability | 🔒 Stable | 📝 Changes with API |
| Testing | Pure logic | Parsing logic |

---

## 14.5 Abstract Repository Interface

The interface (abstract class in Dart) defines the **contract** — what operations are available. The domain layer depends on this interface, not on any concrete implementation.

```dart
// lib/domain/repositories/product_repository.dart

/// Abstract contract for product data operations.
/// The domain and presentation layers depend ONLY on this interface.
abstract class ProductRepository {
  /// Fetch all products, optionally filtered by category
  Future<List<Product>> getProducts({String? categoryId});

  /// Fetch a single product by ID
  Future<Product> getProductById(String id);

  /// Search products by name or description
  Future<List<Product>> searchProducts(String query);

  /// Get products on sale
  Future<List<Product>> getSaleProducts();

  /// Create a new product (admin only)
  Future<Product> createProduct(Product product);

  /// Update an existing product
  Future<Product> updateProduct(Product product);

  /// Delete a product by ID
  Future<void> deleteProduct(String id);

  /// Watch product changes (returns a stream for real-time updates)
  Stream<List<Product>> watchProducts({String? categoryId});
}
```

---

## 14.6 Concrete Implementations

### Mock Implementation (for Development and Testing)

```dart
// lib/data/repositories/mock_product_repository.dart

class MockProductRepository implements ProductRepository {
  // In-memory "database"
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'iPhone 15 Pro',
      description: 'The latest iPhone with titanium frame',
      price: 999.99,
      imageUrl: 'https://example.com/iphone15pro.jpg',
      categoryId: 'electronics',
      isInStock: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    Product(
      id: '2',
      name: 'MacBook Air M3',
      description: 'Thin, light, and powerful',
      price: 1299.99,
      imageUrl: 'https://example.com/macbook-air-m3.jpg',
      categoryId: 'computers',
      isInStock: true,
      createdAt: DateTime(2024, 1, 15),
    ),
    Product(
      id: '3',
      name: 'AirPods Pro (2nd gen)',
      description: 'Adaptive Audio. Now in USB-C.',
      price: 249.99,
      imageUrl: 'https://example.com/airpods-pro-2.jpg',
      categoryId: 'audio',
      isInStock: false,
      createdAt: DateTime(2024, 2, 1),
    ),
  ];

  final _streamController = StreamController<List<Product>>.broadcast();

  @override
  Future<List<Product>> getProducts({String? categoryId}) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    if (categoryId != null) {
      return _products.where((p) => p.categoryId == categoryId).toList();
    }
    return List.unmodifiable(_products);
  }

  @override
  Future<Product> getProductById(String id) async {
    await Future.delayed(Duration(milliseconds: 200));
    final product = _products.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Product not found: $id'),
    );
    return product;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(Duration(milliseconds: 300));
    final lower = query.toLowerCase();
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(lower) ||
            p.description.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Future<List<Product>> getSaleProducts() async {
    // Mock: products over $500 are "on sale"
    await Future.delayed(Duration(milliseconds: 200));
    return _products.where((p) => p.price > 500).toList();
  }

  @override
  Future<Product> createProduct(Product product) async {
    await Future.delayed(Duration(milliseconds: 400));
    _products.add(product);
    _streamController.add(List.from(_products));
    return product;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await Future.delayed(Duration(milliseconds: 400));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) throw Exception('Product not found: ${product.id}');
    _products[index] = product;
    _streamController.add(List.from(_products));
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    _products.removeWhere((p) => p.id == id);
    _streamController.add(List.from(_products));
  }

  @override
  Stream<List<Product>> watchProducts({String? categoryId}) {
    return _streamController.stream.map((products) {
      if (categoryId != null) {
        return products.where((p) => p.categoryId == categoryId).toList();
      }
      return products;
    });
  }

  void dispose() => _streamController.close();
}
```

### Real API Implementation

```dart
// lib/data/repositories/api_product_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiProductRepository implements ProductRepository {
  final http.Client _client;
  final String _baseUrl;

  ApiProductRepository({
    required http.Client client,
    required String baseUrl,
  })  : _client = client,
        _baseUrl = baseUrl;

  @override
  Future<List<Product>> getProducts({String? categoryId}) async {
    final uri = Uri.parse(
      categoryId != null
          ? '$_baseUrl/products?category=$categoryId'
          : '$_baseUrl/products',
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load products: ${response.statusCode}');
    }

    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList
        .map((json) => ProductDto.fromJson(json as Map<String, dynamic>).toDomain())
        .toList();
  }

  @override
  Future<Product> getProductById(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/products/$id'));

    if (response.statusCode == 404) {
      throw Exception('Product not found: $id');
    }
    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final dto = ProductDto.fromJson(json.decode(response.body));
    return dto.toDomain();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/products/search?q=${Uri.encodeComponent(query)}'),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Search failed: ${response.statusCode}');
    }
    
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList
        .map((j) => ProductDto.fromJson(j).toDomain())
        .toList();
  }

  // ... other methods follow the same pattern

  @override
  Future<List<Product>> getSaleProducts() async {
    final response = await _client.get(Uri.parse('$_baseUrl/products/sale'));
    if (response.statusCode != 200) throw Exception('Failed');
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((j) => ProductDto.fromJson(j).toDomain()).toList();
  }

  @override
  Future<Product> createProduct(Product product) async {
    // Create a DTO from the domain model for serialization
    // (Simplified: in practice you'd have a toDto() method)
    final body = json.encode({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'image_url': product.imageUrl,
      'category_id': product.categoryId,
      'in_stock': product.isInStock,
    });

    final response = await _client.post(
      Uri.parse('$_baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('Create failed: ${response.statusCode}');
    }
    return ProductDto.fromJson(json.decode(response.body)).toDomain();
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/products/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': product.name, 'price': product.price}),
    );
    if (response.statusCode != 200) throw Exception('Update failed');
    return ProductDto.fromJson(json.decode(response.body)).toDomain();
  }

  @override
  Future<void> deleteProduct(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/products/$id'));
    if (response.statusCode != 204) throw Exception('Delete failed');
  }

  @override
  Stream<List<Product>> watchProducts({String? categoryId}) {
    // For a real-time stream, you'd use WebSocket or SSE
    // This is a simple polling fallback
    return Stream.periodic(Duration(seconds: 30))
        .asyncMap((_) => getProducts(categoryId: categoryId));
  }
}
```

---

## 14.7 Dependency Injection Basics

Dependency Injection (DI) means: instead of creating dependencies inside a class, you **pass them in from outside**. This makes your code testable and flexible.

```dart
// ❌ BAD: Hard-coded dependency — untestable
class ProductViewModel {
  final _repo = ApiProductRepository( // Hard-coded! Can't swap for tests.
    client: http.Client(),
    baseUrl: 'https://api.shopease.com',
  );

  Future<List<Product>> loadProducts() => _repo.getProducts();
}

// ✅ GOOD: Injected dependency — testable and flexible
class ProductViewModel {
  final ProductRepository _repository; // Interface, not concrete class!

  ProductViewModel({required ProductRepository repository})
      : _repository = repository;

  Future<List<Product>> loadProducts() => _repository.getProducts();
}

// In production:
final vm = ProductViewModel(
  repository: ApiProductRepository(
    client: http.Client(),
    baseUrl: 'https://api.shopease.com',
  ),
);

// In tests:
final vm = ProductViewModel(
  repository: MockProductRepository(), // No network needed!
);
```

### Simple DI Container

For small apps, a simple service locator pattern works well:

```dart
// lib/core/service_locator.dart

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  void register<T>(T service) {
    _services[T] = service;
  }

  T get<T>() {
    final service = _services[T];
    if (service == null) throw Exception('Service not registered: $T');
    return service as T;
  }
}

// In main.dart
void main() {
  final locator = ServiceLocator();

  // Register based on environment
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  if (isProduction) {
    locator.register<ProductRepository>(
      ApiProductRepository(
        client: http.Client(),
        baseUrl: 'https://api.shopease.com',
      ),
    );
  } else {
    locator.register<ProductRepository>(MockProductRepository());
  }

  runApp(const MyApp());
}

// In a widget:
final repo = ServiceLocator().get<ProductRepository>();
```

> 💡 **Pro Tip:** For larger apps, use `get_it` package which is a robust service locator, or use `provider`/`riverpod` which have built-in DI support. Don't roll your own for production apps.

---

## 14.8 Using the Repository in a Flutter Widget

```dart
import 'package:flutter/material.dart';

class ProductListPage extends StatefulWidget {
  final ProductRepository repository;

  const ProductListPage({super.key, required this.repository});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = widget.repository.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _productsFuture = widget.repository.getProducts();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(product.imageUrl),
          onBackgroundImageError: (_, __) {},
          child: const Icon(Icons.image),
        ),
        title: Text(product.name),
        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
        trailing: product.isInStock
            ? const Chip(label: Text('In Stock'), backgroundColor: Colors.green)
            : const Chip(label: Text('Out of Stock'), backgroundColor: Colors.red),
      ),
    );
  }
}
```

---

## ⚠️ Common Repository Mistakes

```dart
// ❌ MISTAKE 1: Returning raw JSON from repository
// Repositories should return domain models, not raw API data
abstract class BadRepository {
  Future<Map<String, dynamic>> getProduct(String id); // WRONG
}

// ✅ CORRECT
abstract class GoodRepository {
  Future<Product> getProduct(String id); // Domain model
}

// ❌ MISTAKE 2: Catching exceptions and swallowing them
class BadImpl implements ProductRepository {
  @override
  Future<List<Product>> getProducts({String? categoryId}) async {
    try {
      // ... fetch ...
      return [];
    } catch (e) {
      print('Error: $e');
      return []; // Silently returns empty list — caller doesn't know it failed!
    }
  }
}

// ✅ CORRECT: Let exceptions propagate, or convert to domain errors
class GoodImpl implements ProductRepository {
  @override
  Future<List<Product>> getProducts({String? categoryId}) async {
    try {
      // ... fetch ...
      return [];
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException catch (e) {
      throw ServerException(e.message);
    }
    // Let unexpected errors bubble up naturally
  }
}

// ❌ MISTAKE 3: Putting UI logic in repository
class AlsoBadRepository {
  Future<void> getProducts(BuildContext context) async { // ❌ BuildContext!!!
    // ...
    ScaffoldMessenger.of(context).showSnackBar(...); // UI in data layer!
  }
}
```

---

## ✏️ Session 14 Exercises

**Exercise 14.1 — Category Repository**
Define an abstract `CategoryRepository` interface with these methods: `getCategories()`, `getCategoryById(String id)`. Implement `MockCategoryRepository` with at least 4 hardcoded categories (Electronics, Fashion, Sports, Books).
*Hint: Define a `Category` domain model first with `id`, `name`, `iconCode` fields.*

**Exercise 14.2 — Repository in FutureBuilder**
Using `MockProductRepository` from section 14.6, build a `StatelessWidget` that accepts a `ProductRepository` as a constructor parameter and displays the list of products using `FutureBuilder`. Add a retry button for the error state.
*Hint: Since the widget is stateless, you'll need to use `late Future` carefully — consider StatefulWidget instead.*

**Exercise 14.3 — DTO Parsing**
Write unit tests (or main() tests) for `ProductDto.fromJson()`. Create 3 test cases:
1. Valid JSON with all fields
2. JSON with missing optional fields (`description`, `image_url`)
3. JSON with `price` as an integer (APIs sometimes return numbers as ints)
*Hint: Use `assert()` or `print()` to verify results in a simple main() program.*

**Exercise 14.4 — Stream Repository**
Add a `watchProductCount()` method to `MockProductRepository` that returns a `Stream<int>` emitting the total number of products. Make it update whenever `createProduct()` or `deleteProduct()` is called.
*Hint: Map the existing `_streamController.stream` using `.map((products) => products.length)`.*

---

<a name="session-15"></a>
# Session 15 – Reactive Patterns (Concepts)

## 15.1 What Is Reactive Programming?

Reactive programming is a programming paradigm centered around **data flows** and **propagation of change**. Instead of *asking* for data (pull), you *react* to data as it arrives (push).

### Pull vs Push

```dart
// PULL model (imperative)
// You ask for the value when you need it
int getTemperature() {
  return thermometer.read(); // Active: I am pulling the value
}

void main() {
  final temp = getTemperature();
  print('Temperature: $temp');
  // What if it changes? You have to ask again and again.
}

// PUSH model (reactive)
// The system notifies you when the value changes
Stream<int> temperatureStream = thermometer.stream; // Passive: it pushes to me

void main() {
  temperatureStream.listen((temp) {
    print('Temperature changed: $temp'); // I react to changes
  });
}
```

Reactive programming is powerful because:
- UI automatically reflects the latest state
- No manual synchronization
- Composable — you can combine and transform data flows
- Testable — you can inject controlled streams

---

## 15.2 setState — The Simplest Reactive Tool

`setState()` is Flutter's most basic reactivity mechanism. When called, it marks the widget as needing a rebuild.

```dart
class SimpleCounterPage extends StatefulWidget {
  const SimpleCounterPage({super.key});

  @override
  State<SimpleCounterPage> createState() => _SimpleCounterPageState();
}

class _SimpleCounterPageState extends State<SimpleCounterPage> {
  int _count = 0; // Local reactive state

  void _increment() {
    setState(() {
      _count++; // Update state → triggers rebuild → UI shows new value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Text(
          '$_count',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### When setState Is Not Enough

`setState()` only rebuilds the widget that calls it (and its subtree). This works great for local state. But when:
- Multiple unrelated widgets need the same state
- State needs to survive navigation
- Deep widget tree nesting makes `setState` require "prop drilling"

...you need something more powerful.

---

## 15.3 InheritedWidget — Sharing State Down the Tree

`InheritedWidget` is Flutter's built-in mechanism for sharing data down the widget tree without passing it through constructor arguments at every level.

```dart
// Define the InheritedWidget
class AppThemeData extends InheritedWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const AppThemeData({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required super.child,
  });

  // Static accessor — widgets call this to get the data
  static AppThemeData of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<AppThemeData>();
    assert(data != null, 'No AppThemeData found in context');
    return data!;
  }

  @override
  bool updateShouldNotify(AppThemeData oldWidget) {
    // Return true if widgets should rebuild when data changes
    return oldWidget.isDarkMode != isDarkMode;
  }
}

// Usage in a widget deep in the tree:
class ThemedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // No need to pass isDarkMode as a constructor argument!
    final themeData = AppThemeData.of(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: themeData.isDarkMode ? Colors.grey[800] : Colors.white,
      ),
      onPressed: themeData.toggleTheme,
      child: Text(themeData.isDarkMode ? 'Switch to Light' : 'Switch to Dark'),
    );
  }
}
```

> 💡 **Pro Tip:** `InheritedWidget` is the foundation that `Provider`, `Theme`, `MediaQuery`, and most of Flutter's built-in context-based APIs are built on. Understanding it helps you understand how Flutter itself works.

---

## 15.4 ChangeNotifier — Observable State

`ChangeNotifier` is a class that can hold mutable state and notify listeners when it changes. It's essentially the Observer pattern.

```dart
import 'package:flutter/material.dart';

// The state holder
class CartNotifier extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get total => _items.fold(0, (sum, item) => sum + item.price);

  void addItem(Product product) {
    _items.add(product);
    notifyListeners(); // ← This triggers a rebuild of all listening widgets
  }

  void removeItem(String productId) {
    _items.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
```

### ListenableBuilder — The Modern Way

In Flutter 3.7+, `ListenableBuilder` replaces the older `AnimatedBuilder`-as-general-listenable pattern:

```dart
class CartIconWidget extends StatelessWidget {
  final CartNotifier cart;

  const CartIconWidget({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart, // Rebuilds when cart.notifyListeners() is called
      builder: (context, child) {
        return Badge(
          label: Text('${cart.itemCount}'),
          isLabelVisible: cart.itemCount > 0,
          child: child!, // The child is NOT rebuilt — optimization!
        );
      },
      child: const Icon(Icons.shopping_cart), // Static child passed to builder
    );
  }
}
```

> 💡 **Pro Tip:** Pass static subtrees as the `child` parameter to `ListenableBuilder`. The builder gets the child as a pre-built widget, so it doesn't need to rebuild it. This is a significant performance optimization.

---

## 15.5 ValueNotifier and ValueListenableBuilder

`ValueNotifier<T>` is a lightweight `ChangeNotifier` that holds a single value. It's perfect for simple reactive values.

```dart
import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // No setState needed! ValueNotifier handles reactivity.
  final _counter = ValueNotifier<int>(0);

  @override
  void dispose() {
    _counter.dispose(); // Always dispose!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ValueNotifier Counter')),
      body: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: _counter,
          builder: (context, value, child) {
            // Only this widget rebuilds — not the entire Scaffold
            return Text(
              '$value',
              style: const TextStyle(fontSize: 72),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _counter.value++, // Triggers rebuild automatically
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### When to Use ValueNotifier vs ChangeNotifier

| Feature | ValueNotifier | ChangeNotifier |
|---|---|---|
| Single value | ✅ Perfect | ⚠️ Overkill |
| Multiple fields | ❌ Not suitable | ✅ Perfect |
| Custom logic | ❌ Limited | ✅ Full control |
| Boilerplate | 🟢 Minimal | 🟡 Some |
| Performance | 🟢 Excellent | 🟢 Good |

```dart
// Perfect ValueNotifier use cases:
final isLoading = ValueNotifier<bool>(false);
final selectedIndex = ValueNotifier<int>(0);
final searchQuery = ValueNotifier<String>('');

// Better as ChangeNotifier:
class UserNotifier extends ChangeNotifier {
  String _name = '';
  String _email = '';
  bool _isLoggedIn = false;
  
  // Multiple related fields — ChangeNotifier makes more sense
}
```

---

## 15.6 Overview of State Management Approaches

Here is your conceptual map of Flutter's state management ecosystem. We'll cover these in depth in Module 5, but you need to know the landscape.

### The Spectrum

```
Simple ◄──────────────────────────────────────► Complex
  │                                                │
setState  ValueNotifier  Provider  Riverpod  BLoC/GetX
  │            │            │         │          │
Local       Simple       Medium    Large       Enterprise
state        value       apps      apps         apps
```

### setState

- **Best for:** Local widget state (checkbox, text field, tabs)
- **Scale:** Widget-local only
- **Learning curve:** Zero
- **Problem:** Doesn't scale across widgets

### Provider (package)

- **Built on top of:** `InheritedWidget` + `ChangeNotifier`
- **Best for:** Small to medium apps, simple global state
- **Scale:** App-wide
- **Learning curve:** Low
- **Key concept:** Inject state into the widget tree; widgets consume it via `context.watch()` / `context.read()`

```dart
// Provider example (conceptual)
// In main.dart:
ChangeNotifierProvider(
  create: (_) => CartNotifier(),
  child: const MyApp(),
);

// In any widget:
final cart = context.watch<CartNotifier>(); // Rebuilds on change
final cart = context.read<CartNotifier>();  // Reads once, no rebuild
```

### Riverpod (package)

- **Built on top of:** Compile-safe, provider-independent
- **Best for:** Medium to large apps, complex async state
- **Scale:** App-wide, highly composable
- **Learning curve:** Medium
- **Key advantage:** No `BuildContext` needed to read providers; fully testable; no ProviderNotFoundException

```dart
// Riverpod example (conceptual)
// Define a provider:
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// In a widget (ConsumerWidget):
final cart = ref.watch(cartProvider); // Reactive
ref.read(cartProvider.notifier).addItem(product); // Trigger action
```

### BLoC (Business Logic Component)

- **Built on top of:** Streams + Dart events
- **Best for:** Enterprise apps, teams, strict architecture
- **Scale:** Large, complex apps
- **Learning curve:** High
- **Key concept:** Events go in → BLoC transforms them → States come out (via Streams)

```dart
// BLoC example (conceptual)
// Events (user actions):
abstract class CartEvent {}
class AddProduct extends CartEvent { final Product product; AddProduct(this.product); }
class RemoveProduct extends CartEvent { final String id; RemoveProduct(this.id); }

// States (UI representations):
abstract class CartState {}
class CartLoading extends CartState {}
class CartLoaded extends CartState { final List<Product> items; CartLoaded(this.items); }
class CartError extends CartState { final String message; CartError(this.message); }

// The BLoC:
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartLoading()) {
    on<AddProduct>((event, emit) {
      // handle add
    });
    on<RemoveProduct>((event, emit) {
      // handle remove
    });
  }
}
```

### GetX

- **Philosophy:** All-in-one (routing, DI, state management)
- **Best for:** Rapid prototyping, small teams who prefer less boilerplate
- **Learning curve:** Low to medium
- **Controversy:** Magic/implicit behavior; tight coupling to GetX ecosystem

```dart
// GetX state example (conceptual)
class CartController extends GetxController {
  var items = <Product>[].obs; // Observable list
  var total = 0.0.obs;

  void addItem(Product p) {
    items.add(p);
    total.value = items.fold(0, (sum, i) => sum + i.price);
  }
}

// In widget:
final cart = Get.find<CartController>();
Obx(() => Text('Items: ${cart.items.length}')); // Reacts to changes
```

### Choosing the Right Tool

```
Question 1: Is it local to one widget?
  YES → setState or ValueNotifier

Question 2: Shared across 2-3 widgets?
  YES → ValueNotifier + ListenableBuilder, or Provider

Question 3: App-wide complex state?
  YES → Riverpod (modern) or Provider (battle-tested)

Question 4: Enterprise team, strict separation required?
  YES → BLoC pattern

Question 5: Rapid prototype, solo developer?
  YES → GetX or Riverpod
```

---

## 15.7 Common Pitfalls in Reactive Programming

### Pitfall 1: Rebuilding Too Much

```dart
// ❌ BAD: context.watch in a large widget rebuilds everything
class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartNotifier>(); // Entire page rebuilds on cart change!
    
    return Scaffold(
      appBar: AppBar(
        actions: [
          CartBadge(count: cart.itemCount), // Small widget at the top
        ],
      ),
      body: ExpensiveProductList(), // This rebuilds too! Unnecessary!
    );
  }
}

// ✅ GOOD: Scope the rebuild to the smallest widget
class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Only CartBadge rebuilds when cart changes
          Consumer<CartNotifier>(
            builder: (_, cart, __) => CartBadge(count: cart.itemCount),
          ),
        ],
      ),
      body: const ExpensiveProductList(), // Never rebuilds due to cart
    );
  }
}
```

### Pitfall 2: Memory Leaks

```dart
// ❌ BAD: ChangeNotifier listener not removed
class BadWidget extends StatefulWidget {
  final CartNotifier cart;
  @override State<BadWidget> createState() => _BadWidgetState();
}

class _BadWidgetState extends State<BadWidget> {
  @override
  void initState() {
    super.initState();
    widget.cart.addListener(_onCartChange); // Added
    // Never removed in dispose! Memory leak.
  }

  void _onCartChange() => setState(() {});

  @override
  Widget build(BuildContext context) => Text('Items: ${widget.cart.itemCount}');
}

// ✅ GOOD: Always remove listeners in dispose
class GoodWidget extends StatefulWidget {
  final CartNotifier cart;
  @override State<GoodWidget> createState() => _GoodWidgetState();
}

class _GoodWidgetState extends State<GoodWidget> {
  @override
  void initState() {
    super.initState();
    widget.cart.addListener(_onCartChange);
  }

  void _onCartChange() => setState(() {});

  @override
  void dispose() {
    widget.cart.removeListener(_onCartChange); // ✅ Clean up!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text('Items: ${widget.cart.itemCount}');
}
```

### Pitfall 3: Stale State / Stale Closures

```dart
// ❌ Stale state: reading state inside an old callback
class StaleExample extends StatefulWidget {
  @override State<StaleExample> createState() => _StaleExampleState();
}

class _StaleExampleState extends State<StaleExample> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    // The closure captures count = 0, never updates
    Future.delayed(Duration(seconds: 5), () {
      // This prints 0 even if count has changed 10 times!
      print('Count after 5 seconds: $count'); // May be stale!
    });
  }

  // ...
}

// ✅ Access state at the time of execution, not capture
// Use a getter or read from the object directly:
class FixedExample extends StatefulWidget {
  @override State<FixedExample> createState() => _FixedExampleState();
}

class _FixedExampleState extends State<FixedExample> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      // Reading _count at the time of execution — not stale
      if (mounted) print('Count: $_count'); // Current value
    });
  }

  // ...
}
```

### Pitfall 4: Calling notifyListeners() in a Build Method

```dart
// ❌ TERRIBLE: Triggers infinite rebuild loop
class BadNotifier extends ChangeNotifier {
  void updateInBuild() {
    notifyListeners(); // Called during build → triggers rebuild → calls again
  }
}

// ✅ Only call notifyListeners() in response to user actions or async events
class GoodNotifier extends ChangeNotifier {
  void handleUserAction() {
    // Update state
    notifyListeners(); // Safe — called from event handler, not build
  }
}
```

---

## 15.8 Choosing the Right Reactive Tool

Here's a decision matrix:

| Scenario | Recommended Tool |
|---|---|
| Counter in a single widget | `setState` |
| Loading spinner | `ValueNotifier<bool>` |
| Form validation state | Local `setState` |
| Shopping cart across app | `ChangeNotifier` + `Provider` |
| User authentication state | `ChangeNotifier` + `Provider` or `Riverpod` |
| Real-time data (WebSocket) | `StreamBuilder` + Streams |
| Complex multi-step flows | `BLoC` |
| Timer/animation | `AnimationController` or `StreamBuilder` |
| Theme/locale | `InheritedWidget` or `Provider` |
| API cache with auto-refresh | `Riverpod` with `AsyncNotifier` |

> 💡 **Pro Tip:** Start simple. For a new feature, begin with `setState`. When you need to share state between widgets, move to `ChangeNotifier`. Only reach for `BLoC` or `Riverpod` when the complexity genuinely demands it. Over-engineering with heavy patterns early is a common mistake.

---

## ✏️ Session 15 Exercises

**Exercise 15.1 — ValueNotifier Form**
Build a simple form with a `TextField` for email. Use a `ValueNotifier<bool>` to track whether the email is valid (contains '@' and '.'). Use `ValueListenableBuilder` to enable/disable a "Submit" button based on validity. No `setState` allowed!
*Hint: Update `isValid.value` in the `onChanged` callback of the TextField.*

**Exercise 15.2 — ChangeNotifier Theme**
Create a `ThemeNotifier extends ChangeNotifier` with a `bool isDark` field and a `toggle()` method. Wrap your app's `MaterialApp` to use the theme from `ThemeNotifier`. Use `ListenableBuilder` at the root to rebuild `MaterialApp` when the theme changes.
*Hint: `ThemeData.dark()` and `ThemeData.light()` provide ready-made themes.*

**Exercise 15.3 — Reactive Map**
Build a shopping list widget using `ValueNotifier<List<String>>`. Support adding and removing items. The list should update reactively — no `setState`.
*Hint: When updating a list inside ValueNotifier, you must assign a **new** list: `notifier.value = [...notifier.value, newItem]` — not mutate the existing list.*

**Exercise 15.4 — State Management Comparison**
Implement the same feature — a favorite button that toggles between favorited/not favorited — using THREE different approaches:
1. `setState` in a `StatefulWidget`
2. `ValueNotifier<bool>` + `ValueListenableBuilder`
3. `ChangeNotifier` + `ListenableBuilder`
Reflect on the code length and readability of each.
*Hint: All three should produce identical UI behavior.*

---

<a name="module-summary"></a>
# Module Summary

Congratulations on completing Module 3! This was a substantial module covering the "engine" of Dart and Flutter application architecture. Let's consolidate what you've learned.

## Key Takeaways

### Session 11 — Future Deep Dive

| Concept | Key Insight |
|---|---|
| Event Loop | Dart is single-threaded; the event loop runs microtasks before events |
| Microtask Queue | Higher priority than event queue; drains completely before any event is processed |
| `.then()` callbacks | Always async (microtask), even on resolved futures |
| Error propagation | Errors skip `.then()` and flow to `.catchError()` |
| Unawaited Futures | Silent killers — enable the `unawaited_futures` lint |
| Completer | Use to manually complete a Future, or wrap callback APIs |
| `compute()` | Easy way to run a function in a background isolate |
| `Isolate.spawn()` | Full control for long-lived background workers |

### Session 12 — Streams

| Concept | Key Insight |
|---|---|
| Stream vs Future | Future: one value; Stream: many values over time |
| Single-sub vs Broadcast | Default is single-sub; use `.broadcast()` for multiple listeners |
| StreamController | Imperative control over a stream: add, addError, close |
| `async*` / `yield` | Declarative stream creation via generator functions |
| Transformers | map, where, take, skip, distinct, asyncMap — chain them for powerful pipelines |
| Memory leaks | Always cancel subscriptions in `dispose()` |

### Session 13 — StreamBuilder

| Concept | Key Insight |
|---|---|
| StreamBuilder | Automatically manages subscription lifecycle |
| ConnectionState | 4 states: none, waiting, active, done — handle all of them |
| AsyncSnapshot | Your window into the stream's current state |
| initialData | Provides data before first stream event |
| Performance | Push StreamBuilder down the tree to minimize rebuild scope |
| distinct() | Use to avoid unnecessary rebuilds on duplicate values |

### Session 14 — Repository Pattern

| Concept | Key Insight |
|---|---|
| Repository Pattern | Abstraction between data sources and domain |
| Abstract class | Defines the contract (interface) |
| Domain Model | Pure Dart — no knowledge of storage/API |
| DTO | Knows how to parse raw data; converts to domain model |
| Dependency Injection | Pass dependencies in, don't create them inside |
| Testability | Inject MockRepository in tests; no network needed |

### Session 15 — Reactive Patterns

| Concept | Key Insight |
|---|---|
| Pull vs Push | Reactive = push; the system notifies you of changes |
| setState | Local, simple; doesn't scale across widgets |
| InheritedWidget | Foundation of Flutter's context-based data sharing |
| ChangeNotifier | Observable state; call notifyListeners() to trigger rebuilds |
| ValueNotifier | Lightweight ChangeNotifier for a single value |
| ListenableBuilder | Modern, efficient way to listen to Listenables |
| State management ecosystem | setState → ValueNotifier → Provider → Riverpod → BLoC |

---

## Architecture Flow (Putting It All Together)

```
User Interaction (Widget)
        │
        ▼
  ChangeNotifier / BLoC / ViewModel
        │
        ▼  (calls Repository)
  Abstract Repository Interface
        │
        ▼  (implemented by)
  Concrete Repository (Mock or API)
        │
        ▼  (parses via)
  DTO.fromJson()  →  toDomain()
        │
        ▼
  Domain Model
        │
        ▼  (returned up through layers)
  ChangeNotifier.notifyListeners() / Stream event
        │
        ▼
  Widget rebuilds (StreamBuilder / ListenableBuilder / etc.)
```

---

<a name="review-questions"></a>
# Review Questions

## Conceptual Questions

**Q1.** Explain in your own words the difference between the microtask queue and the event queue in Dart. Which has higher priority, and what is a practical consequence of scheduling too many microtasks?

**Q2.** What is an "unawaited future" and why is it dangerous? How does the `unawaited_futures` lint rule help?

**Q3.** Explain the difference between a single-subscription stream and a broadcast stream. Give a real-world scenario where you would choose each.

**Q4.** What is the purpose of the `Completer` class? Describe a scenario where you would use it.

**Q5.** What are the 4 `ConnectionState` values of `AsyncSnapshot`, and what should your UI show in each state?

**Q6.** Explain the difference between a Domain Model and a DTO. Why do we keep them separate?

**Q7.** What does "dependency injection" mean in the context of the Repository Pattern? Why does it make code more testable?

**Q8.** What is the difference between `ChangeNotifier` and `ValueNotifier`? When would you choose one over the other?

**Q9.** Explain the "pull vs push" distinction in reactive programming. Which model does Flutter's `setState` use? Which does a `Stream` use?

**Q10.** Why is it dangerous to call `notifyListeners()` inside a `build()` method?

---

## Code Reading Questions

**Q11.** What is the output of the following code? Explain each line's output:
```dart
import 'dart:async';
void main() {
  print('1');
  Future.microtask(() => print('2'));
  Future(() => print('3'));
  Future.value(0).then((_) {
    print('4');
    scheduleMicrotask(() => print('5'));
  });
  print('6');
}
```

**Q12.** What is wrong with this code? How would you fix it?
```dart
class ProductBloc {
  final controller = StreamController<List<Product>>();
  
  void loadProducts() async {
    final products = await repository.getProducts();
    controller.add(products);
  }
}
```

**Q13.** Identify the memory leak in this widget and provide a fix:
```dart
class PriceWidget extends StatefulWidget {
  final Stream<double> priceStream;
  const PriceWidget({required this.priceStream});
  @override State<PriceWidget> createState() => _PriceWidgetState();
}
class _PriceWidgetState extends State<PriceWidget> {
  double _price = 0;
  @override
  void initState() {
    super.initState();
    widget.priceStream.listen((p) => setState(() => _price = p));
  }
  @override
  Widget build(BuildContext context) => Text('\$$_price');
}
```

**Q14.** What is wrong with this repository method, and what are two ways to fix it?
```dart
Future<List<Product>> getProducts() async {
  try {
    final response = await http.get(Uri.parse('https://api.example.com/products'));
    return json.decode(response.body);
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## Design Questions

**Q15.** You are building a real-time chat application. Each chat room has a stream of messages. Design:
- The `Message` domain model
- The `ChatRepository` abstract interface with appropriate methods (including a stream for live messages)
- The signature of the `StreamBuilder` you would use to display messages

**Q16.** Your app has a shopping cart that needs to be accessible from the product list page, the product detail page, the cart page, and the app bar. Which state management approach would you choose and why? Sketch the architecture.

**Q17.** A teammate wrote this code and it's causing jank (dropped frames). Identify the problem and propose a solution:
```dart
ElevatedButton(
  onPressed: () {
    final results = json.decode(File('large_file.json').readAsStringSync());
    setState(() => _data = results);
  },
  child: Text('Load Data'),
)
```

---

## Applied Questions

**Q18.** You have a `UserRepository` with a `getUserById(String id)` method. Write a complete `FutureBuilder` widget that:
- Shows a `CircularProgressIndicator` while loading
- Shows user name and email when data arrives
- Shows an error message with a retry button if the request fails

**Q19.** Write an `async*` generator function `Stream<int> countdown(int from, Duration interval)` and use it in a Flutter widget with `StreamBuilder` to display a countdown timer that shows "Go!" when it reaches 0.

**Q20.** You are switching from a `MockProductRepository` to a real `ApiProductRepository`. Your app currently does this:
```dart
final repo = MockProductRepository();
```
in 15 different files. Propose a refactoring strategy using dependency injection that would allow you to make this switch in one place only.

---

*End of Module 3: OOP & Asynchronous Dart*

---

> **Next Up:** Module 4 — HTTP, REST APIs, and Local Storage  
> We'll put the Repository Pattern to full use by connecting `ApiProductRepository` to a real REST API, implementing JWT authentication, and adding offline support with SQLite and SharedPreferences.

---

*© Flutter University Course — Module 3 Study Guide*  
*Version 1.0 | Last Updated: May 2026*
