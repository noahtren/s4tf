# swift_build_support/products/__init__.py ----------------------*- python -*-
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
# See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
#
# ----------------------------------------------------------------------------

from .benchmarks import Benchmarks
from .cmark import CMark
from .foundation import Foundation
from .indexstoredb import IndexStoreDB
from .libcxx import LibCXX
from .libdispatch import LibDispatch
from .libicu import LibICU
from .llbuild import LLBuild
from .lldb import LLDB
from .llvm import LLVM
from .ninja import Ninja
from .playgroundsupport import PlaygroundSupport
from .pythonkit import PythonKit
from .skstresstester import SKStressTester
from .sourcekitlsp import SourceKitLSP
from .swift import Swift
from .swiftevolve import SwiftEvolve
from .swiftpm import SwiftPM
from .swiftsyntax import SwiftSyntax
# SWIFT_ENABLE_TENSORFLOW
from .tensorflow import TensorFlow
# SWIFT_ENABLE_TENSORFLOW END
from .tensorflow import TensorFlowSwiftAPIs
from .tsan_libdispatch import TSanLibDispatch
from .xctest import XCTest

__all__ = [
    'CMark',
    'Ninja',
    'Foundation',
    'LibCXX',
    'LibDispatch',
    'LibICU',
    'LLBuild',
    'LLDB',
    'LLVM',
    'Ninja',
    'PlaygroundSupport',
    'PythonKit',
    'Swift',
    'SwiftPM',
    'TensorFlowSwiftAPIs',
    'XCTest',
    'SwiftSyntax',
    'SKStressTester',
    'SwiftEvolve',
    'IndexStoreDB',
    'SourceKitLSP',
    'Benchmarks',
    'TSanLibDispatch',
    # SWIFT_ENABLE_TENSORFLOW
    'TensorFlow',
]
