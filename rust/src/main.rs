// Author: Ashok Kumar Pant <asokpant@gmail.com>
// Date: July 19, 2026

use std::env;
use std::fs;
use std::path::Path;
use std::process;

use npflag::{construct, to_html, to_svg, MODES};

fn main() {
    let args: Vec<String> = env::args().collect();
    let base = args
        .get(1)
        .map(|s| {
            s.parse::<f64>().unwrap_or_else(|_| {
                eprintln!("invalid base length");
                process::exit(1);
            })
        })
        .unwrap_or(800.0);
    let out_dir = args.get(2).map(String::as_str).unwrap_or("output");

    if let Err(e) = fs::create_dir_all(out_dir) {
        eprintln!("{e}");
        process::exit(1);
    }

    let g = construct(base);
    for mode in MODES {
        let path = Path::new(out_dir).join(format!("np_flag_{mode}.svg"));
        if let Err(e) = fs::write(&path, to_svg(&g, mode)) {
            eprintln!("{e}");
            process::exit(1);
        }
        println!("{}", path.display());
    }
    let html_path = Path::new(out_dir).join("np_flag.html");
    if let Err(e) = fs::write(&html_path, to_html(&g)) {
        eprintln!("{e}");
        process::exit(1);
    }
    println!("{}", html_path.display());
}
