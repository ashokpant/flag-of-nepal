function flagOfNepal(baseLength, drawingMode)
%FLAGOFNEPAL  Draw the National Flag of Nepal from constitutional geometry.
%
%   Construction follows Schedule 1, Article 8 of the Constitution of Nepal.
%
%   flagOfNepal()
%   flagOfNepal(baseLength)
%   flagOfNepal(baseLength, drawingMode)
%
%   baseLength   Length of base AB (default: 800).
%   drawingMode  One of:
%                  'color'     coloured flag (default)
%                  'skeleton'  wireframe outline
%                  'landmark'  labels + imaginary construction lines
%   Examples
%     flagOfNepal
%     flagOfNepal(920)
%     flagOfNepal(920, 'skeleton')
%     flagOfNepal(920, 'landmark')
%
%   Author: Ashok Kumar Pant (asokpant@gmail.com)

    if nargin < 1 || isempty(baseLength)
        baseLength = 800;
    end
    if nargin < 2 || isempty(drawingMode)
        drawingMode = 'color';
    end

    mode = drawingMode;
    if iscell(mode)
        mode = mode{1};
    end
    if ~ischar(mode)
        mode = char(mode);
    end
    mode = lower(strtrim(mode));
    switch mode
        case {'fillcolor', 'colour'}
            mode = 'color';
        case {'landmarks', 'alldrawings', 'alldrawing'}
            mode = 'landmark';
        case {'color', 'skeleton', 'landmark'}
            % ok
        otherwise
            error('flagOfNepal:InvalidMode', ...
                'Unknown mode ''%s''. Use color, skeleton, or landmark.', mode);
    end

    g = constructFlag(baseLength);

    figure('Color', 'w', 'Name', sprintf('Flag of Nepal (%s)', mode));
    ax = axes('Parent', gcf);
    hold(ax, 'on');
    axis(ax, 'equal');
    axis(ax, 'off');

    switch mode
        case 'color'
            drawColor(ax, g);
        case 'skeleton'
            drawSkeleton(ax, g, false);
        case 'landmark'
            drawSkeleton(ax, g, true);
    end

    title(ax, sprintf('National Flag of Nepal — %s (AB = %.0f)', mode, baseLength), ...
        'FontWeight', 'normal');
    hold(ax, 'off');
end

% Construction (Schedule 1)
function g = constructFlag(b)
%CONSTRUCTFLAG  Compute all points / polygons for base length b.

    A = [0, 0];
    B = [b, 0];
    C = [0, b + b / 3];
    D = [0, b];

    % (3) E on BD with BE = AB
    pts = intersectLineCircle(B, D - B, B, b);
    E = pts(2, :);

    F = [0, E(2)];
    G = [b, E(2)];

    % (B) Moon
    H = [b / 4, 0];
    I = intersectEdges(H, [H(1), C(2)], C, G);

    J = midPoint(C, F);
    K = intersectEdges(J, [J(1) + b, J(2)], C, G);
    L = intersectEdges(J, K, H, I);
    M = intersectEdges(J, G, H, I);

    distMBD = distancePointEdge(M, B, D);
    N = [M(1), M(2) - distMBD];

    O = [A(1), M(2)];
    O1 = intersectEdges(O, M, C, G); %#ok<NASGU>

    radiusL = dist(L, N);
    pq = intersectLineCircle(O, M - O, L, radiusL);
    P = pq(1, :); %#ok<NASGU>
    Q = pq(2, :);

    radiusM = dist(M, Q);
    radiusN = dist(N, M);
    rs = intersectCircles(L, radiusL, N, radiusN);
    if rs(1, 1) <= rs(2, 1)
        R = rs(1, :);
        S = rs(2, :);
    else
        R = rs(2, :);
        S = rs(1, :);
    end

    T = intersectEdges(R, S, H, I);
    radiusTU = dist(T, S);
    radiusTL = dist(T, M);

    [XU, YU] = circleArcPolyline(T, radiusTU, 180, -180, 38);
    [XL, YL] = circleArcPolyline(T, radiusTL, 195, -210, 11);

    % Moon ray index pairs (1-based, matching historical MATLAB / geom2d sampling)
    moonRays = [
        XU(1),  YU(1),  XL(2),  YL(2);
        XU(end), YU(end), XL(end-1), YL(end-1);
        XL(2),  YL(2),  XU(5),  YU(5);
        XU(5),  YU(5),  XL(3),  YL(3);
        XL(end-1), YL(end-1), XU(end-4), YU(end-4);
        XU(end-4), YU(end-4), XL(end-2), YL(end-2);
        XL(3),  YL(3),  XU(9),  YU(9);
        XU(9),  YU(9),  XL(4),  YL(4);
        XL(end-2), YL(end-2), XU(end-8), YU(end-8);
        XU(end-8), YU(end-8), XL(end-3), YL(end-3);
        XL(4),  YL(4),  XU(13), YU(13);
        XU(13), YU(13), XL(5),  YL(5);
        XL(end-3), YL(end-3), XU(end-12), YU(end-12);
        XU(end-12), YU(end-12), XL(end-4), YL(end-4);
        XL(5),  YL(5),  XU(17), YU(17);
        XU(17), YU(17), XL(6),  YL(6);
        XL(end-4), YL(end-4), XU(end-16), YU(end-16);
        XU(end-16), YU(end-16), XL(end-5), YL(end-5);
    ];

    % (C) Sun
    U = midPoint(A, F);
    V = intersectEdges(U, [U(1) + b, U(2)], B, E);
    W = intersectEdges(U, V, H, I);

    radiusWI = dist(M, N);
    radiusWO = dist(L, N);
    PI = circlePolygon(W, radiusWI, 24);  % (N+1) x 2, 1-based closed
    PO = circlePolygon(W, radiusWO, 48);

    sunPoly = [
        PI(2,:); PO(5,:); PI(4,:); PO(9,:); PI(6,:); PO(13,:);
        PI(8,:); PO(17,:); PI(10,:); PO(21,:); PI(12,:); PO(25,:);
        PI(14,:); PO(29,:); PI(16,:); PO(33,:); PI(18,:); PO(37,:);
        PI(20,:); PO(41,:); PI(22,:); PO(45,:); PI(24,:); PO(1,:);
    ];

    sunRays = [
        PI(2,:), PO(1,:);
        PI(2,:), PO(5,:);
        PO(5,:), PI(4,:);
        PI(4,:), PO(9,:);
        PO(9,:), PI(6,:);
        PI(6,:), PO(13,:);
        PO(13,:), PI(8,:);
        PI(8,:), PO(17,:);
        PO(17,:), PI(10,:);
        PI(10,:), PO(21,:);
        PO(21,:), PI(12,:);
        PI(12,:), PO(25,:);
        PO(25,:), PI(14,:);
        PI(14,:), PO(29,:);
        PO(29,:), PI(16,:);
        PI(16,:), PO(33,:);
        PO(33,:), PI(18,:);
        PI(18,:), PO(37,:);
        PO(37,:), PI(20,:);
        PI(20,:), PO(41,:);
        PO(41,:), PI(22,:);
        PI(22,:), PO(45,:);
        PO(45,:), PI(24,:);
        PI(24,:), PO(1,:);
    ];

    % Moon fill polygon
    [arcPQUX, arcPQUY] = circleArcPolyline(L, radiusL, -159, 138, 65);
    [arcPQLX, arcPQLY] = circleArcPolyline(M, radiusM, -180, 180, 65);

    mCrispL = [
        XU(1), YU(1); XL(2), YL(2); XU(5), YU(5); XL(3), YL(3);
        XU(9), YU(9); XL(4), YL(4); XU(13), YU(13); XL(5), YL(5);
        XU(17), YU(17); XL(6), YL(6);
    ];
    mCrispR = [
        XU(end), YU(end); XL(end-1), YL(end-1); XU(end-4), YU(end-4);
        XL(end-2), YL(end-2); XU(end-8), YU(end-8); XL(end-3), YL(end-3);
        XU(end-12), YU(end-12); XL(end-4), YL(end-4); XU(end-16), YU(end-16);
        XL(end-5), YL(end-5);
    ];

    leftMask = arcPQUX <= R(1);
    rightMask = arcPQUX >= S(1);
    moonPoly = [
        arcPQUX(leftMask), arcPQUY(leftMask);
        mCrispL;
        flipud(mCrispR);
        arcPQUX(rightMask), arcPQUY(rightMask);
        flipud([arcPQLX, arcPQLY]);
    ];

    % (D) Border
    borderWidth = dist(T, N);
    [ab1, ab2] = parallelEdge(A, B, borderWidth);
    [ac1, ac2] = parallelEdge(A, C, -borderWidth);
    [cg1, cg2] = parallelEdge(C, G, -borderWidth);
    [eg1, eg2] = parallelEdge(E, G, borderWidth);
    [be1, be2] = parallelEdge(B, E, borderWidth);

    ABorder = intersectLines(ab1, ab2 - ab1, ac1, ac2 - ac1);
    CBorder = intersectLines(ac1, ac2 - ac1, cg1, cg2 - cg1);
    GBorder = intersectLines(cg1, cg2 - cg1, eg1, eg2 - eg1);
    EBorder = intersectLines(eg1, eg2 - eg1, be1, be2 - be1);
    BBorder = intersectLines(ab1, ab2 - ab1, be1, be2 - be1);

    g = struct();
    g.baseLength = b;
    g.borderWidth = borderWidth;
    g.A = A; g.B = B; g.C = C; g.D = D; g.E = E;
    g.F = F; g.G = G; g.H = H; g.I = I; g.J = J; g.K = K;
    g.L = L; g.M = M; g.N = N; g.O = O; g.P = P; g.Q = Q;
    g.R = R; g.S = S; g.T = T; g.U = U; g.V = V; g.W = W;
    g.inner = [A; B; E; G; C];
    g.border = [ABorder; BBorder; EBorder; GBorder; CBorder];
    g.moonPoly = moonPoly;
    g.sunPoly = sunPoly;
    g.moonRays = moonRays;
    g.sunRays = sunRays;
    g.centerL = L; g.radiusL = radiusL;
    g.centerM = M; g.radiusM = radiusM;
    g.centerT = T; g.radiusTU = radiusTU; g.radiusTL = radiusTL;
    g.centerN = N; g.radiusN = radiusN;
    g.centerW = W; g.radiusWI = radiusWI; g.radiusWO = radiusWO;
    g.XU = XU; g.YU = YU; g.XL = XL; g.YL = YL;
    g.imaginary = [
        H, I; J, K; J, G; O, O1; R, S; F, G; U, V; B, D
    ];
end

% Drawing

function drawColor(ax, g)
    deepBlue = [0, 0, 0.8];
    crimson = [0.73, 0.0667, 0.20];

    bx = [g.border(:, 1); g.border(1, 1)];
    by = [g.border(:, 2); g.border(1, 2)];
    patch(ax, bx, by, deepBlue, 'EdgeColor', 'none');

    ix = [g.inner(:, 1); g.inner(1, 1)];
    iy = [g.inner(:, 2); g.inner(1, 2)];
    patch(ax, ix, iy, crimson, 'EdgeColor', 'none');

    patch(ax, g.moonPoly(:, 1), g.moonPoly(:, 2), 'w', 'EdgeColor', 'none');
    patch(ax, g.sunPoly(:, 1), g.sunPoly(:, 2), 'w', 'EdgeColor', 'none');
end

function drawSkeleton(ax, g, withLandmarks)
    ink = [0.1, 0.1, 0.1];
    imagCol = [0.55, 0.55, 0.55];

    drawEdge(ax, g.A, g.B, ink);
    drawEdge(ax, g.A, g.C, ink);
    drawEdge(ax, g.E, g.G, ink);
    drawEdge(ax, g.C, g.G, ink);
    drawEdge(ax, g.B, g.E, ink);

    for k = 1:size(g.border, 1)
        a = g.border(k, :);
        b = g.border(mod(k, size(g.border, 1)) + 1, :);
        drawEdge(ax, a, b, ink);
    end

    plotArc(ax, g.centerL, g.radiusL, -159, 138, ink);
    plotArc(ax, g.centerM, g.radiusM, -180, 180, ink);
    plotArc(ax, g.centerT, g.radiusTL, 195, -210, ink);

    for k = 1:size(g.moonRays, 1)
        drawEdge(ax, g.moonRays(k, 1:2), g.moonRays(k, 3:4), ink);
    end
    for k = 1:size(g.sunRays, 1)
        drawEdge(ax, g.sunRays(k, 1:2), g.sunRays(k, 3:4), ink);
    end

    th = linspace(0, 2 * pi, 97);
    plot(ax, g.centerW(1) + g.radiusWI * cos(th), ...
        g.centerW(2) + g.radiusWI * sin(th), 'Color', ink, 'LineWidth', 1);

    if ~withLandmarks
        return;
    end

    % Imaginary construction geometry
    plotArc(ax, g.centerT, g.radiusTU, 180, -180, imagCol, '--');
    plotArc(ax, g.centerN, g.radiusN, 180, -180, imagCol, '--');
    plot(ax, g.centerW(1) + g.radiusWO * cos(th), ...
        g.centerW(2) + g.radiusWO * sin(th), '--', 'Color', imagCol, 'LineWidth', 0.8);

    for k = 1:size(g.imaginary, 1)
        drawEdge(ax, g.imaginary(k, 1:2), g.imaginary(k, 3:4), imagCol, '--');
    end

    labels = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N', ...
        'O','P','Q','R','S','T','U','V','W'};
    pts = {g.A,g.B,g.C,g.D,g.E,g.F,g.G,g.H,g.I,g.J,g.K,g.L,g.M,g.N, ...
        g.O,g.P,g.Q,g.R,g.S,g.T,g.U,g.V,g.W};
    fs = max(8, g.baseLength * 0.025);
    for i = 1:numel(labels)
        p = pts{i};
        plot(ax, p(1), p(2), 'o', 'MarkerSize', 4, 'MarkerFaceColor', ink, ...
            'MarkerEdgeColor', ink);
        text(ax, p(1) + 6, p(2) + 6, labels{i}, 'FontSize', fs, 'Color', ink);
    end
end

function drawEdge(ax, a, b, color, style)
    if nargin < 5
        style = '-';
    end
    plot(ax, [a(1), b(1)], [a(2), b(2)], style, 'Color', color, 'LineWidth', 1);
end

function plotArc(ax, center, radius, theta0, dtheta, color, style)
    if nargin < 7
        style = '-';
    end
    [x, y] = circleArcPolyline(center, radius, theta0, dtheta, 64);
    plot(ax, x, y, style, 'Color', color, 'LineWidth', 1);
end

% Helpers
function d = dist(a, b)
    d = hypot(b(1) - a(1), b(2) - a(2));
end

function m = midPoint(a, b)
    m = (a + b) / 2;
end

function [p1, p2] = parallelEdge(a, b, signedDist)
% Positive distance = right side of directed edge a→b (geom2d convention).
    dx = b(1) - a(1);
    dy = b(2) - a(2);
    len = hypot(dx, dy);
    nx = dy / len;
    ny = -dx / len;
    offset = signedDist * [nx, ny];
    p1 = a + offset;
    p2 = b + offset;
end

function p = intersectLines(p1, d1, p2, d2)
    denom = d1(1) * d2(2) - d1(2) * d2(1);
    if abs(denom) < 1e-14
        error('flagOfNepal:Parallel', 'Lines are parallel.');
    end
    s = ((p2(1) - p1(1)) * d2(2) - (p2(2) - p1(2)) * d2(1)) / denom;
    p = p1 + s * d1;
end

function p = intersectEdges(a1, a2, b1, b2)
    p = intersectLines(a1, a2 - a1, b1, b2 - b1);
end

function pts = intersectLineCircle(origin, direction, center, radius)
    dp = origin - center;
    a = dot(direction, direction);
    b = 2 * dot(dp, direction);
    c = dot(dp, dp) - radius^2;
    delta = b^2 - 4 * a * c;
    if abs(delta) < 1e-14
        delta = 0;
    end
    if delta < 0
        pts = zeros(0, 2);
        return;
    end
    sqrtD = sqrt(delta);
    u1 = (-b - sqrtD) / (2 * a);
    u2 = (-b + sqrtD) / (2 * a);
    pts = [origin + u1 * direction; origin + u2 * direction];
end

function pts = intersectCircles(c1, r1, c2, r2)
    d = dist(c1, c2);
    if d > r1 + r2 || d < abs(r1 - r2) || d == 0
        pts = zeros(0, 2);
        return;
    end
    a = (r1^2 - r2^2 + d^2) / (2 * d);
    h2 = r1^2 - a^2;
    if abs(h2) < 1e-12
        h2 = 0;
    end
    if h2 < 0
        pts = zeros(0, 2);
        return;
    end
    h = sqrt(h2);
    mid = c1 + a / d * (c2 - c1);
    dx = c2(1) - c1(1);
    dy = c2(2) - c1(2);
    rx = -dy * (h / d);
    ry = dx * (h / d);
    pts = [mid + [rx, ry]; mid - [rx, ry]];
end

function d = distancePointEdge(p, a, b)
    ab = b - a;
    t = dot(p - a, ab) / dot(ab, ab);
    t = min(1, max(0, t));
    proj = a + t * ab;
    d = dist(p, proj);
end

function [x, y] = circleArcPolyline(center, radius, theta0Deg, dthetaDeg, n)
    if nargin < 5
        n = 65;
    end
    t0 = theta0Deg * pi / 180;
    t1 = t0 + dthetaDeg * pi / 180;
    t = linspace(t0, t1, n).';
    x = center(1) + radius * cos(t);
    y = center(2) + radius * sin(t);
end

function pts = circlePolygon(center, radius, n)
% Closed polygon with n+1 vertices (last equals first).
    t = linspace(0, 2 * pi, n + 1).';
    pts = [center(1) + radius * cos(t), center(2) + radius * sin(t)];
end
