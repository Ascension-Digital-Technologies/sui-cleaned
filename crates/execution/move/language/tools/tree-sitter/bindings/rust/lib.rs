use tree_sitter::Language;

unsafe extern "C" {
    fn tree_sitter_move() -> Language;
}

/// Returns the tree-sitter language descriptor for Move.
pub fn language() -> Language {
    unsafe { tree_sitter_move() }
}

#[cfg(test)]
mod tests {
    #[test]
    fn language_loads() {
        let _ = super::language();
    }
}
