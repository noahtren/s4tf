// SWIFT_ENABLE_TENSORFLOW
// Note: this test is disabled on `tensorflow` branch because `tensorflow`
// branch adds various public APIs to the stdlib without `@available`
// attributes. Some of these APIs will be usptreamed to the
// UNSUPPORTED: tensorflow

// REQUIRES: OS=macosx
// REQUIRES: swift_stdlib_no_asserts
// RUN: %empty-directory(%t.tmp)
// mkdir %t.tmp/module-cache && mkdir %t.tmp/dummy.sdk
// RUN: %api-digester -diagnose-sdk -module Swift -o %t.tmp/changes.txt -module-cache-path %t.tmp/module-cache -sdk %t.tmp/dummy.sdk -abi -avoid-location -v
// RUN: %clang -E -P -x c %S/Outputs/stability-stdlib-abi.without.asserts.swift.expected -o - | sed '/^\s*$/d' | sort > %t.tmp/stability-stdlib-abi.swift.expected
// RUN: %clang -E -P -x c %t.tmp/changes.txt -o - | sed '/^\s*$/d' | sort > %t.tmp/changes.txt.tmp
// RUN: diff -u %t.tmp/stability-stdlib-abi.swift.expected %t.tmp/changes.txt.tmp

// The digester can incorrectly register a generic signature change when
// declarations are shuffled. rdar://problem/46618883
// UNSUPPORTED: swift_evolve
