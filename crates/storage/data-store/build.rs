// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

use std::path::PathBuf;

fn main() {
    let schema = find_graphql_schema();

    cynic_codegen::register_schema("rpc")
        .from_sdl_file(&schema)
        .expect("Failed to find GraphQL Schema")
        .as_default()
        .unwrap();
}

fn find_graphql_schema() -> PathBuf {
    [
        "../sui-indexer-alt-graphql/schema.graphql",
        "../../api/indexing/surfaces/indexer-graphql/schema.graphql",
        "../../../crates/api/indexing/surfaces/indexer-graphql/schema.graphql",
    ]
    .into_iter()
    .map(PathBuf::from)
    .find(|path| path.exists())
    .unwrap_or_else(|| PathBuf::from("../../api/indexing/surfaces/indexer-graphql/schema.graphql"))
}
