//===-------- AbstractSourceFileDepGraphFactory.cpp -----------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#include "swift/AST/AbstractSourceFileDepGraphFactory.h"

// may not all be needed
#include "swift/AST/DiagnosticEngine.h"
#include "swift/AST/DiagnosticsFrontend.h"
#include "swift/AST/FileSystem.h"
#include "swift/AST/FineGrainedDependencies.h"
#include "swift/Basic/FileSystem.h"
#include "swift/Basic/LLVM.h"
#include "swift/Basic/ReferenceDependencyKeys.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/YAMLParser.h"

using namespace swift;
using namespace fine_grained_dependencies;

//==============================================================================
// MARK: AbstractSourceFileDepGraphFactory - client interface
//==============================================================================

AbstractSourceFileDepGraphFactory::AbstractSourceFileDepGraphFactory(
    bool includePrivateDeps, bool hadCompilationError, StringRef swiftDeps,
    StringRef fileFingerprint, bool emitDotFileAfterConstruction,
    DiagnosticEngine &diags)
    : includePrivateDeps(includePrivateDeps),
      hadCompilationError(hadCompilationError), swiftDeps(swiftDeps.str()),
      fileFingerprint(fileFingerprint.str()),
      emitDotFileAfterConstruction(emitDotFileAfterConstruction), diags(diags) {
}

SourceFileDepGraph AbstractSourceFileDepGraphFactory::construct() {
  addSourceFileNodesToGraph();
  if (!hadCompilationError) {
    addAllDefinedDecls();
    addAllUsedDecls();
  }
  assert(g.verify());
  if (emitDotFileAfterConstruction)
    g.emitDotFile(swiftDeps, diags);
  return std::move(g);
}

//==============================================================================
// MARK: AbstractSourceFileDepGraphFactory - adding a defined or used Decl
//==============================================================================
void AbstractSourceFileDepGraphFactory::addSourceFileNodesToGraph() {
  g.findExistingNodePairOrCreateAndAddIfNew(
      DependencyKey::createKeyForWholeSourceFile(DeclAspect::interface,
                                                 swiftDeps),
      StringRef(fileFingerprint));
}

void AbstractSourceFileDepGraphFactory::addADefinedDecl(
    const DependencyKey &interfaceKey, Optional<StringRef> fingerprint) {

  auto nodePair =
      g.findExistingNodePairOrCreateAndAddIfNew(interfaceKey, fingerprint);
  // Since the current type fingerprints only include tokens in the body,
  // when the interface hash changes, it is possible that the type in the
  // file has changed.
  g.addArc(g.getSourceFileNodePair().getInterface(), nodePair.getInterface());
}

void AbstractSourceFileDepGraphFactory::addAUsedDecl(
    const DependencyKey &defKey, const DependencyKey &useKey) {
  auto *defNode =
      g.findExistingNodeOrCreateIfNew(defKey, None, false /* = !isProvides */);
  auto nullableUse = g.findExistingNode(useKey);
  assert(nullableUse.isNonNull() && "Use must be an already-added provides");
  auto *useNode = nullableUse.get();
  assert(useNode->getIsProvides() && "Use (using node) must be a provides");
  g.addArc(defNode, useNode);
}
