fn main() {
    cc::Build::new()
        .include("src")
        .file("src/parser.c")
        .compile("tree-sitter-move");

    println!("cargo:rerun-if-changed=src/parser.c");
    println!("cargo:rerun-if-changed=src/grammar.json");
}
