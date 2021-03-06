// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -enable-experimental-differentiable-programming %s -emit-module -parse-as-library -o %t
// RUN: llvm-bcanalyzer %t/transpose_attr.swiftmodule | %FileCheck %s -check-prefix=BCANALYZER
// RUN: %target-sil-opt -enable-experimental-differentiable-programming -disable-sil-linking -enable-sil-verify-all %t/transpose_attr.swiftmodule -o - | %FileCheck %s

// BCANALYZER-NOT: UnknownCode
// REQUIRES: differentiable_programming

// SWIFT_ENABLE_TENSORFLOW
// This test is enabled on `tensorflow` branch.
// `@differentiable` attribute serialization does not yet work on `master`
// branch only.

// TODO(TF-838): Enable this test.
// Blocked by TF-830: `@transpose` attribute type-checking.
// FAIL: *

import _Differentiation

// Dummy `Differentiable`-conforming type.
struct S: Differentiable & AdditiveArithmetic {
  static var zero: S { S() }
  static func + (_: S, _: S) -> S { S() }
  static func - (_: S, _: S) -> S { S() }
  typealias TangentVector = S
}

// Test top-level functions.

func top1(_ x: S) -> S {
  x
}
// CHECK: @transpose(of: top1, wrt: 0)
@transpose(of: top1, wrt: 0)
func transposeTop1(v: S) -> S {
  v
}

func top2<T, U>(_ x: T, _ i: Int, _ y: U) -> U {
  y
}
// CHECK: @transpose(of: top2, wrt: (0, 2))
@transpose(of: top2, wrt: (0, 2))
func transposeTop2<T, U>(_ int: Int, v: U) -> (T, U)
where T: Differentiable, U: Differentiable,
      T == T.TangentVector, U == U.TangentVector {
  (.zero, v)
}

// Test instance methods.

extension S {
  func instanceMethod(_ other: S) -> S {
    self + other
  }

  // CHECK: @transpose(of: instanceMethod, wrt: 0)
  @transpose(of: instanceMethod, wrt: 0)
  func transposeInstanceMethod(t: S) -> S {
    self + t
  }

  // CHECK: @transpose(of: instanceMethod, wrt: self)
  @transpose(of: instanceMethod, wrt: self)
  static func transposeInstanceMethodWrtSelf(_ other: S, t: S) -> S {
    other + t
  }
}

// Test static methods.

extension S {
  static func staticMethod(x: S) -> S {
    x
  }

  // CHECK: @transpose(of: staticMethod, wrt: 0)
  @transpose(of: staticMethod, wrt: 0)
  static func transposeStaticMethod(t: S) -> S {
    t
  }
}

// Test computed properties.
extension S {
  var computedProperty: S { self }

  // CHECK: @transpose(of: computedProperty, wrt: self)
  @transpose(of: computedProperty, wrt: self)
  static func transposeProperty(t: Self) -> Self {
    t
  }
}

// Test subscripts.
extension S {
  subscript<T: Differentiable>(x: T) -> Self { self }

  // CHECK: @transpose(of: subscript, wrt: self)
  @transpose(of: subscript(_:), wrt: self)
  static func transposeSubscript<T: Differentiable>(x: T, t: Self) -> Self {
    t
  }
}
