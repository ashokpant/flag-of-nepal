// Author: Ashok Kumar Pant <asokpant@gmail.com>
// Date: July 19, 2026

package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"

	"github.com/ashokpant/flag-of-nepal/npflag"
)

func main() {
	base := 800.0
	outDir := "output"
	if len(os.Args) > 1 {
		v, err := strconv.ParseFloat(os.Args[1], 64)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		base = v
	}
	if len(os.Args) > 2 {
		outDir = os.Args[2]
	}
	if err := os.MkdirAll(outDir, 0o755); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	g := npflag.Construct(base)
	for _, mode := range npflag.Modes {
		path := filepath.Join(outDir, "np_flag_"+mode+".svg")
		if err := os.WriteFile(path, []byte(npflag.ToSVG(g, mode)), 0o644); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Println(path)
	}
	htmlPath := filepath.Join(outDir, "np_flag.html")
	if err := os.WriteFile(htmlPath, []byte(npflag.ToHTML(g)), 0o644); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(htmlPath)
}
