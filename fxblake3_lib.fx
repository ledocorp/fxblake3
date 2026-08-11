// fxblake3_lib — BLAKE3 file/tree hash under FsCap (--cli auto-host).
// Public design: docs/FXBLAKE3.md (this tree) · fxlang host/cli + host/cap
module fxblake3_lib;

using core;
import std/io;
import std/string;
import std/strutil;

extern "c" {
    fn fx_cli_argc() -> i32;
    fn fx_cli_arg(i: i32) -> string;
    effects { alloc } fn fx_guest_begin(root: string, arena_bytes: i64) -> i64;
    effects { alloc } fn fx_guest_end(ctx_handle: i64) -> i32;
    effects { alloc } fn fx_guest_mint_fscap(ctx_handle: i64, root: string) -> i64;
    fn fx_blake3_hash_file_cap(fs_handle: i64, path: string) -> i32;
    fn fx_blake3_hash_tree_cap(fs_handle: i64, root: string) -> i32;
    fn fx_blake3_last_hex() -> string;
}

fn eq(a: string, b: string) -> bool {
    return string.compare(a, b);
}

fn usage() -> i32 effects { io } {
    let _u = io.write_err("usage: fxblake3 --allow <dir> [--tree] <path>");
    return 1;
}

fn path_has_dotdot(s: string) -> bool {
    return strutil.contains(s, "..");
}

fn resolve_under(allow: string, rel: string) -> Result<string, core_Err> effects { alloc } {
    let al = string.len(allow);
    let dl = string.len(rel);
    if (dl > al) {
        if (strutil.starts_with(rel, allow) == true) {
            let c = string.byte_at(rel, al);
            if (c == 47) {
                return Ok(rel);
            }
            if (c == 92) {
                return Ok(rel);
            }
        }
    }
    let mid = string.concat(allow, "/")?;
    return string.concat(mid, rel);
}

fn map_st(st: i32) -> i32 effects { io } {
    if (st == 0) {
        return 0;
    }
    if (st == -5) {
        let _d = io.write_err("fxblake3: path outside allow / denied");
        return 2;
    }
    if (st == -6) {
        let _m = io.write_err("fxblake3: path missing or unreadable");
        return 2;
    }
    let _f = io.write_err("fxblake3: hash failed");
    return 3;
}

fn run_hash(allow: string, path: string, tree: i32) -> Result<i32, core_Err> effects { alloc, io } {
    let g = fx_guest_begin(allow, 65536);
    if (g == 0) {
        let _g = io.write_err("fxblake3: guest begin failed");
        return Ok(2);
    }
    let fs = fx_guest_mint_fscap(g, "");
    if (fs == 0) {
        let _e0 = fx_guest_end(g);
        let _f = io.write_err("fxblake3: mint_fs failed");
        return Ok(2);
    }
    let st: i32 = 0;
    if (tree != 0) {
        st = fx_blake3_hash_tree_cap(fs, path);
    } else {
        st = fx_blake3_hash_file_cap(fs, path);
    }
    if (st != 0) {
        let _en = fx_guest_end(g);
        return Ok(map_st(st));
    }
    let hex = fx_blake3_last_hex();
    let line0 = string.concat(hex, "  ")?;
    let line = string.concat(line0, path)?;
    let _w = io.write_line(line);
    let _en2 = fx_guest_end(g);
    return Ok(0);
}

fn cli_main() -> Result<i32, core_Err> effects { alloc, io } {
    let allow = "";
    let path = "";
    let tree: i32 = 0;
    let argc = fx_cli_argc();
    let i: i32 = 1;
    while (i < argc) {
        let a = fx_cli_arg(i);
        if (eq(a, "--help") == true) {
            return Ok(usage());
        }
        if (eq(a, "-h") == true) {
            return Ok(usage());
        }
        if (eq(a, "--tree") == true) {
            tree = 1;
            i = i + 1;
        } else {
            if (eq(a, "--allow") == true) {
                i = i + 1;
                if (i >= argc) {
                    let _m = io.write_err("fxblake3: --allow requires a directory");
                    return Ok(1);
                }
                allow = fx_cli_arg(i);
                i = i + 1;
            } else {
                if (string.len(a) > 0) {
                    if (string.byte_at(a, 0) == 45) {
                        let _u = io.write_err("fxblake3: unknown flag");
                        return Ok(1);
                    }
                }
                if (string.len(path) == 0) {
                    path = a;
                    i = i + 1;
                } else {
                    let _e = io.write_err("fxblake3: extra arguments");
                    return Ok(1);
                }
            }
        }
    }
    if (string.len(allow) == 0) {
        let _a = io.write_err("fxblake3: --allow <dir> is required");
        return Ok(1);
    }
    if (string.len(path) == 0) {
        let _p = io.write_err("fxblake3: missing <path>");
        return Ok(1);
    }
    if (path_has_dotdot(allow) == true) {
        let _pa = io.write_err("fxblake3: path outside allow / denied");
        return Ok(2);
    }
    if (path_has_dotdot(path) == true) {
        let _pb = io.write_err("fxblake3: path outside allow / denied");
        return Ok(2);
    }

    let full = resolve_under(allow, path)?;
    return run_hash(allow, full, tree);
}
