import 'package:rust_core/mpsc.dart';
import 'package:test/test.dart';

void main() {
  test("Single sender single reciever", () async {
    List<int> results1 = [];
    List<int> results2 = [];
    final (tx, rx) = channel<int>();
    tx.send(1);
    tx.send(2);
    tx.send(3);
    tx.send(4);
    tx.send(5);
    await Future.delayed(Duration(milliseconds: 100));
    for (int i = 0; i < 2; i++) {
      results1.add((await rx.recv()).unwrap());
      await Future.delayed(Duration(milliseconds: 100));
      results2.add((await rx.recv()).unwrap());
    }
    await Future.delayed(Duration(milliseconds: 100));
    tx.send(6);
    await Future.delayed(Duration(milliseconds: 100));
    results1.add((await rx.recv()).unwrap());
    await Future.delayed(Duration(milliseconds: 100));
    results2.add((await rx.recv()).unwrap());
    await Future.delayed(Duration(milliseconds: 100));
    tx.send(7);
    await Future.delayed(Duration(milliseconds: 100));
    results1.add((await rx.recv()).unwrap());

    expect(results1, [1, 3, 5, 7]);
    expect(results2, [2, 4, 6]);
  });

  test("Single sender multiple reciever", () async {
    List<int> results1 = [];
    List<int> results2 = [];
    final (tx, rx) = channel<int>();
    tx.send(1);
    tx.send(2);
    tx.send(3);
    tx.send(4);
    await Future.delayed(Duration(milliseconds: 100));
    for (int i = 0; i < 2; i++) {
      final r1 = rx.recv();
      final r2 = rx.recv();
      final rs = await Future.wait([r1, r2]);
      results1.add(rs[0].unwrap());
      await Future.delayed(Duration(milliseconds: 100));
      results2.add(rs[1].unwrap());
    }
    tx.send(5);
    block() async {
      final r1 = rx.recv();
      final r2 = rx.recv();
      final rs = await Future.wait([r1, r2]);
      results1.add(rs[0].unwrap());
      await Future.delayed(Duration(milliseconds: 100));
      results2.add(rs[1].unwrap());
      return;
    }
    final b = block();
    await Future.delayed(Duration(milliseconds: 100));
    tx.send(6);
    await Future.delayed(Duration(milliseconds: 100));
    await b;

    expect(results1, [1, 3, 5]);
    expect(results2, [2, 4, 6]);
  });
}