// Author: Ashok Kumar Pant <asokpant@gmail.com>
// Date: July 19, 2026

package npflag

import (
	"fmt"
	"math"
	"strings"
)

const (
	crimson   = "#DC143C"
	deepBlue  = "#003893"
	white     = "#FFFFFF"
	ink       = "#111111"
	imaginary = "#888888"
)

var Modes = []string{"color", "skeleton", "landmark"}
type pt struct{ x, y float64 }

type edge struct{ a, b pt }

type arc struct {
	c         pt
	r, t0, dt float64
}

type Geom struct {
	baseLength, borderWidth      float64
	points                       map[string]pt
	border, inner, moon, sun     []pt
	moonRays, sunRays, imaginary []edge
	arcs                         map[string]arc
	circles                      map[string][3]float64 // cx, cy, r
}

func (g *Geom) bounds() (minX, minY, maxX, maxY float64) {
	minX, minY = math.Inf(1), math.Inf(1)
	maxX, maxY = math.Inf(-1), math.Inf(-1)
	expand := func(p pt) {
		minX = math.Min(minX, p.x)
		minY = math.Min(minY, p.y)
		maxX = math.Max(maxX, p.x)
		maxY = math.Max(maxY, p.y)
	}
	for _, poly := range [][]pt{g.border, g.inner, g.moon, g.sun} {
		for _, p := range poly {
			expand(p)
		}
	}
	for _, p := range g.points {
		expand(p)
	}
	pad := g.baseLength * 0.02
	if g.borderWidth > 0 {
		pad = g.borderWidth * 0.5
	}
	return minX - pad, minY - pad, maxX + pad, maxY + pad
}

func dist(a, b pt) float64 { return math.Hypot(b.x-a.x, b.y-a.y) }

func mid(a, b pt) pt { return pt{(a.x + b.x) / 2, (a.y + b.y) / 2} }

func parallelEdge(a, b pt, d float64) (pt, pt) {
	dx, dy := b.x-a.x, b.y-a.y
	len := math.Hypot(dx, dy)
	nx, ny := dy/len, -dx/len
	return pt{a.x + d*nx, a.y + d*ny}, pt{b.x + d*nx, b.y + d*ny}
}

func intersectLines(p1, d1, p2, d2 pt) pt {
	denom := d1.x*d2.y - d1.y*d2.x
	s := ((p2.x-p1.x)*d2.y - (p2.y-p1.y)*d2.x) / denom
	return pt{p1.x + s*d1.x, p1.y + s*d1.y}
}

func intersectEdges(a1, a2, b1, b2 pt) pt {
	return intersectLines(a1, pt{a2.x - a1.x, a2.y - a1.y}, b1, pt{b2.x - b1.x, b2.y - b1.y})
}

func intersectLineCircle(origin, dir, center pt, radius float64) []pt {
	dpx, dpy := origin.x-center.x, origin.y-center.y
	a := dir.x*dir.x + dir.y*dir.y
	b := 2 * (dpx*dir.x + dpy*dir.y)
	c := dpx*dpx + dpy*dpy - radius*radius
	delta := b*b - 4*a*c
	if math.Abs(delta) < 1e-14 {
		delta = 0
	}
	if delta < 0 {
		return nil
	}
	sqrtD := math.Sqrt(delta)
	u1 := (-b - sqrtD) / (2 * a)
	u2 := (-b + sqrtD) / (2 * a)
	return []pt{
		{origin.x + u1*dir.x, origin.y + u1*dir.y},
		{origin.x + u2*dir.x, origin.y + u2*dir.y},
	}
}

func intersectCircles(c1 pt, r1 float64, c2 pt, r2 float64) []pt {
	d := dist(c1, c2)
	a := (r1*r1 - r2*r2 + d*d) / (2 * d)
	h2 := r1*r1 - a*a
	if math.Abs(h2) < 1e-12 {
		h2 = 0
	}
	h := math.Sqrt(h2)
	midPt := pt{c1.x + a/d*(c2.x-c1.x), c1.y + a/d*(c2.y-c1.y)}
	dx, dy := c2.x-c1.x, c2.y-c1.y
	rx, ry := -dy*(h/d), dx*(h/d)
	return []pt{{midPt.x + rx, midPt.y + ry}, {midPt.x - rx, midPt.y - ry}}
}

func distancePointEdge(p, a, b pt) float64 {
	abx, aby := b.x-a.x, b.y-a.y
	t := ((p.x-a.x)*abx + (p.y-a.y)*aby) / (abx*abx + aby*aby)
	t = math.Max(0, math.Min(1, t))
	return dist(p, pt{a.x + t*abx, a.y + t*aby})
}

func arcPolyline(c pt, r, t0Deg, dtDeg float64, n int) []pt {
	pts := make([]pt, n)
	t0 := t0Deg * math.Pi / 180
	t1 := t0 + dtDeg*math.Pi/180
	for i := 0; i < n; i++ {
		t := t0 + (t1-t0)*float64(i)/float64(n-1)
		pts[i] = pt{c.x + r*math.Cos(t), c.y + r*math.Sin(t)}
	}
	return pts
}

func circlePolygon(c pt, r float64, n int) []pt {
	pts := make([]pt, n+1)
	for i := 0; i <= n; i++ {
		t := 2 * math.Pi * float64(i) / float64(n)
		pts[i] = pt{c.x + r*math.Cos(t), c.y + r*math.Sin(t)}
	}
	return pts
}

func Construct(b float64) *Geom {
	A := pt{0, 0}
	B := pt{b, 0}
	C := pt{0, b + b/3}
	D := pt{0, b}

	ePts := intersectLineCircle(B, pt{D.x - B.x, D.y - B.y}, B, b)
	E := ePts[1]
	F := pt{0, E.y}
	G := pt{b, E.y}

	H := pt{b / 4, 0}
	I := intersectEdges(H, pt{H.x, C.y}, C, G)
	J := mid(C, F)
	K := intersectEdges(J, pt{J.x + b, J.y}, C, G)
	L := intersectEdges(J, K, H, I)
	M := intersectEdges(J, G, H, I)
	N := pt{M.x, M.y - distancePointEdge(M, B, D)}
	O := pt{A.x, M.y}
	O1 := intersectEdges(O, M, C, G)

	radiusL := dist(L, N)
	pq := intersectLineCircle(O, pt{M.x - O.x, M.y - O.y}, L, radiusL)
	P, Q := pq[0], pq[1]
	radiusM := dist(M, Q)
	radiusN := dist(N, M)
	rs := intersectCircles(L, radiusL, N, radiusN)
	R, S := rs[0], rs[1]
	if R.x > S.x {
		R, S = S, R
	}
	T := intersectEdges(R, S, H, I)
	radiusTU := dist(T, S)
	radiusTL := dist(T, M)

	xu := arcPolyline(T, radiusTU, 180, -180, 38)
	xl := arcPolyline(T, radiusTL, 195, -210, 11)

	U := mid(A, F)
	V := intersectEdges(U, pt{U.x + b, U.y}, B, E)
	W := intersectEdges(U, V, H, I)

	radiusWI := dist(M, N)
	radiusWO := dist(L, N)
	pi := circlePolygon(W, radiusWI, 24)
	po := circlePolygon(W, radiusWO, 48)

	borderWidth := dist(T, N)
	g := &Geom{
		baseLength:  b,
		borderWidth: borderWidth,
		points: map[string]pt{
			"A": A, "B": B, "C": C, "D": D, "E": E, "F": F, "G": G,
			"H": H, "I": I, "J": J, "K": K, "L": L, "M": M, "N": N,
			"O": O, "O1": O1, "P": P, "Q": Q, "R": R, "S": S, "T": T,
			"U": U, "V": V, "W": W,
		},
		inner: []pt{A, B, E, G, C},
		arcs: map[string]arc{
			"crescent_outer": {L, radiusL, -159, 138},
			"crescent_inner": {M, radiusM, -180, 180},
			"moon_upper":     {T, radiusTU, 180, -180},
			"moon_lower":     {T, radiusTL, 195, -210},
			"n_arc":          {N, radiusN, 180, -180},
		},
		circles: map[string][3]float64{
			"sun_inner": {W.x, W.y, radiusWI},
			"sun_outer": {W.x, W.y, radiusWO},
		},
	}

	ab0, ab1 := parallelEdge(A, B, borderWidth)
	ac0, ac1 := parallelEdge(A, C, -borderWidth)
	cg0, cg1 := parallelEdge(C, G, -borderWidth)
	eg0, eg1 := parallelEdge(E, G, borderWidth)
	be0, be1 := parallelEdge(B, E, borderWidth)
	aBi := intersectLines(ab0, pt{ab1.x - ab0.x, ab1.y - ab0.y}, ac0, pt{ac1.x - ac0.x, ac1.y - ac0.y})
	cBi := intersectLines(ac0, pt{ac1.x - ac0.x, ac1.y - ac0.y}, cg0, pt{cg1.x - cg0.x, cg1.y - cg0.y})
	gBi := intersectLines(cg0, pt{cg1.x - cg0.x, cg1.y - cg0.y}, eg0, pt{eg1.x - eg0.x, eg1.y - eg0.y})
	eBi := intersectLines(eg0, pt{eg1.x - eg0.x, eg1.y - eg0.y}, be0, pt{be1.x - be0.x, be1.y - be0.y})
	bBi := intersectLines(ab0, pt{ab1.x - ab0.x, ab1.y - ab0.y}, be0, pt{be1.x - be0.x, be1.y - be0.y})
	g.border = []pt{aBi, bBi, eBi, gBi, cBi}

	n, m := len(xu), len(xl)
	g.moonRays = []edge{
		{xu[0], xl[1]}, {xu[n-1], xl[m-2]},
		{xl[1], xu[4]}, {xu[4], xl[2]},
		{xl[m-2], xu[n-5]}, {xu[n-5], xl[m-3]},
		{xl[2], xu[8]}, {xu[8], xl[3]},
		{xl[m-3], xu[n-9]}, {xu[n-9], xl[m-4]},
		{xl[3], xu[12]}, {xu[12], xl[4]},
		{xl[m-4], xu[n-13]}, {xu[n-13], xl[m-5]},
		{xl[4], xu[16]}, {xu[16], xl[5]},
		{xl[m-5], xu[n-17]}, {xu[n-17], xl[m-6]},
	}

	sunOrder := []int{1, 4, 3, 8, 5, 12, 7, 16, 9, 20, 11, 24, 13, 28, 15, 32, 17, 36, 19, 40, 21, 44, 23, 0}
	for i := 0; i < len(sunOrder); i += 2 {
		g.sun = append(g.sun, pi[sunOrder[i]], po[sunOrder[i+1]])
	}
	g.sunRays = []edge{
		{pi[1], po[0]}, {pi[1], po[4]}, {po[4], pi[3]}, {pi[3], po[8]},
		{po[8], pi[5]}, {pi[5], po[12]}, {po[12], pi[7]}, {pi[7], po[16]},
		{po[16], pi[9]}, {pi[9], po[20]}, {po[20], pi[11]}, {pi[11], po[24]},
		{po[24], pi[13]}, {pi[13], po[28]}, {po[28], pi[15]}, {pi[15], po[32]},
		{po[32], pi[17]}, {pi[17], po[36]}, {po[36], pi[19]}, {pi[19], po[40]},
		{po[40], pi[21]}, {pi[21], po[44]}, {po[44], pi[23]}, {pi[23], po[0]},
	}

	arcPqu := arcPolyline(L, radiusL, -159, 138, 65)
	arcPql := arcPolyline(M, radiusM, -180, 180, 65)
	crispL := []pt{xu[0], xl[1], xu[4], xl[2], xu[8], xl[3], xu[12], xl[4], xu[16], xl[5]}
	crispR := []pt{xu[n-1], xl[m-2], xu[n-5], xl[m-3], xu[n-9], xl[m-4], xu[n-13], xl[m-5], xu[n-17], xl[m-6]}
	for _, p := range arcPqu {
		if p.x <= R.x {
			g.moon = append(g.moon, p)
		}
	}
	g.moon = append(g.moon, crispL...)
	for i := len(crispR) - 1; i >= 0; i-- {
		g.moon = append(g.moon, crispR[i])
	}
	for _, p := range arcPqu {
		if p.x >= S.x {
			g.moon = append(g.moon, p)
		}
	}
	for i := len(arcPql) - 1; i >= 0; i-- {
		g.moon = append(g.moon, arcPql[i])
	}

	g.imaginary = []edge{{H, I}, {J, K}, {J, G}, {O, O1}, {R, S}, {F, G}, {U, V}, {B, D}}
	return g
}

func fmtF(v float64) string { return fmt.Sprintf("%.4f", v) }

func polyPoints(pts []pt, flip float64) string {
	parts := make([]string, len(pts))
	for i, p := range pts {
		parts[i] = fmtF(p.x) + "," + fmtF(flip-p.y)
	}
	return strings.Join(parts, " ")
}

func writeEdge(b *strings.Builder, a, c pt, flip float64, color string, width float64, dash string) {
	b.WriteString(`<line x1="` + fmtF(a.x) + `" y1="` + fmtF(flip-a.y) +
		`" x2="` + fmtF(c.x) + `" y2="` + fmtF(flip-c.y) +
		`" stroke="` + color + `" stroke-width="` + fmt.Sprintf("%g", width) + `"`)
	if dash != "" {
		b.WriteString(` stroke-dasharray="` + dash + `"`)
	}
	b.WriteString(" />\n")
}

func writeArc(b *strings.Builder, a arc, flip float64, color string, width float64, dash string) {
	pts := arcPolyline(a.c, a.r, a.t0, a.dt, 64)
	b.WriteString(`<path d="M ` + fmtF(pts[0].x) + "," + fmtF(flip-pts[0].y))
	for i := 1; i < len(pts); i++ {
		b.WriteString(" L " + fmtF(pts[i].x) + "," + fmtF(flip-pts[i].y))
	}
	b.WriteString(`" fill="none" stroke="` + color + `" stroke-width="` + fmt.Sprintf("%g", width) + `"`)
	if dash != "" {
		b.WriteString(` stroke-dasharray="` + dash + `"`)
	}
	b.WriteString(" />\n")
}

func ToSVG(g *Geom, mode string) string {
	minX, minY, maxX, maxY := g.bounds()
	width, height := maxX-minX, maxY-minY
	flip := maxY

	var b strings.Builder
	b.WriteString(`<?xml version="1.0" encoding="UTF-8"?>` + "\n")
	b.WriteString(fmt.Sprintf(
		`<svg xmlns="http://www.w3.org/2000/svg" viewBox="%s 0 %s %s" width="%d" height="%d" role="img" aria-label="National Flag of Nepal">`+"\n",
		fmtF(minX), fmtF(width), fmtF(height), int(math.Round(width)), int(math.Round(height))))
	b.WriteString("<title>National Flag of Nepal (" + mode + ")</title>\n")

	if mode == "color" {
		border := append(append([]pt{}, g.border...), g.border[0])
		inner := append(append([]pt{}, g.inner...), g.inner[0])
		sun := append(append([]pt{}, g.sun...), g.sun[0])
		b.WriteString(`<polygon points="` + polyPoints(border, flip) + `" fill="` + deepBlue + `" stroke="none" />` + "\n")
		b.WriteString(`<polygon points="` + polyPoints(inner, flip) + `" fill="` + crimson + `" stroke="none" />` + "\n")
		b.WriteString(`<polygon points="` + polyPoints(g.moon, flip) + `" fill="` + white + `" stroke="none" />` + "\n")
		b.WriteString(`<polygon points="` + polyPoints(sun, flip) + `" fill="` + white + `" stroke="none" />` + "\n")
	} else {
		p := g.points
		writeEdge(&b, p["A"], p["B"], flip, ink, 1.5, "")
		writeEdge(&b, p["A"], p["C"], flip, ink, 1.5, "")
		writeEdge(&b, p["E"], p["G"], flip, ink, 1.5, "")
		writeEdge(&b, p["C"], p["G"], flip, ink, 1.5, "")
		writeEdge(&b, p["B"], p["E"], flip, ink, 1.5, "")
		for i := range g.border {
			writeEdge(&b, g.border[i], g.border[(i+1)%len(g.border)], flip, ink, 1.5, "")
		}
		for _, key := range []string{"crescent_outer", "crescent_inner", "moon_lower"} {
			writeArc(&b, g.arcs[key], flip, ink, 1.5, "")
		}
		for _, e := range g.moonRays {
			writeEdge(&b, e.a, e.b, flip, ink, 1.5, "")
		}
		for _, e := range g.sunRays {
			writeEdge(&b, e.a, e.b, flip, ink, 1.5, "")
		}
		ci := g.circles["sun_inner"]
		b.WriteString(fmt.Sprintf(
			`<circle cx="%s" cy="%s" r="%s" fill="none" stroke="%s" stroke-width="1.5" />`+"\n",
			fmtF(ci[0]), fmtF(flip-ci[1]), fmtF(ci[2]), ink))

		if mode == "landmark" {
			fs := g.baseLength * 0.035
			for _, name := range []string{
				"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
				"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W",
			} {
				pt := g.points[name]
				b.WriteString(fmt.Sprintf(
					`<circle cx="%s" cy="%s" r="3" fill="%s" />`+"\n",
					fmtF(pt.x), fmtF(flip-pt.y), ink))
				b.WriteString(fmt.Sprintf(
					`<text x="%s" y="%s" font-family="Helvetica, Arial, sans-serif" font-size="%.1f" fill="%s">%s</text>`+"\n",
					fmtF(pt.x+6), fmtF(flip-pt.y-6), fs, ink, name))
			}
			writeArc(&b, g.arcs["moon_upper"], flip, imaginary, 1, "6 4")
			writeArc(&b, g.arcs["n_arc"], flip, imaginary, 1, "6 4")
			co := g.circles["sun_outer"]
			b.WriteString(fmt.Sprintf(
				`<circle cx="%s" cy="%s" r="%s" fill="none" stroke="%s" stroke-width="1" stroke-dasharray="6 4" />`+"\n",
				fmtF(co[0]), fmtF(flip-co[1]), fmtF(co[2]), imaginary))
			for _, e := range g.imaginary {
				writeEdge(&b, e.a, e.b, flip, imaginary, 1, "6 4")
			}
		}
	}
	b.WriteString("</svg>\n")
	_ = minY
	return b.String()
}

func ToHTML(g *Geom) string {
	titles := []string{"Colour flag", "Skeleton", "Landmarks"}
	var body strings.Builder
	for i, mode := range Modes {
		svg := ToSVG(g, mode)
		if strings.HasPrefix(svg, "<?xml") {
			if idx := strings.IndexByte(svg, '\n'); idx >= 0 {
				svg = svg[idx+1:]
			}
		}
		body.WriteString("    <section class=\"flag\">\n      <h2>" + titles[i] + "</h2>\n")
		body.WriteString(svg)
		body.WriteString("    </section>\n\n")
	}
	return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>National Flag of Nepal</title>
  <style>
    body { margin: 0; font-family: Georgia, serif; background: #f6f4f1; color: #1a1a1a; }
    main { max-width: 900px; margin: 2rem auto; padding: 0 1.25rem 3rem; }
    h1 { font-weight: 400; }
    .meta { color: #555; margin: 0 0 2rem; }
    .flag { background: #fff; padding: 1.25rem 1.5rem 1.75rem; margin-bottom: 1.5rem; }
    .flag h2 { font-weight: 400; font-size: 1.15rem; margin: 0 0 1rem; }
    .flag svg { width: 100%; height: auto; display: block; }
  </style>
</head>
<body>
  <main>
    <h1>National Flag of Nepal</h1>
    <p class="meta">Base length AB = ` + fmt.Sprintf("%.0f", g.baseLength) +
		` · Border width TN = ` + fmt.Sprintf("%.4f", g.borderWidth) +
		` · Constitution of Nepal, Schedule 1, Article 8</p>
` + body.String() + `  </main>
</body>
</html>
`
}
