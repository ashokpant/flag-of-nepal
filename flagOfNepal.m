% National Flag of Nepal(The most mathematial flag in the world)
%==============================================================
%
%Author: Ashok Kumar Pant (ashokpant87@gmail.com)
%Central Dept. of Computer Science & IT, TU, Nepal
%Date: 2013-12-16
%Update: 2015-9-20
%
%
%Required Toolbox
%   geom2d
%   (http://www.mathworks.com/matlabcentral/fileexchange/7844-geom2d)
%
%
%Examples:
%   % Flag of Nepal
%   flagOfNepal();
%
%   % Flag of Nepal given base lengh. Base length is only the
%   input for creating the National flag of Nepal.
%   flagOfNepal(600);
%
%   % Flag of Nepal in drawing mode. Available drawing modes are
%   {'skeleton','landmarks','alldrawings','fillcolor','animate'}
%   baseLength = 600;
%   drawingMode = 'animate';
%   flagOfNepal(baseLength,drawingMode)
%
%===============================================================

function flagOfNepal(baseLength,drawingMode)
modeArray={'skeleton','landmarks','alldrawings','fillcolor','animate'};
switch(nargin)
    case 2
        bLength=baseLength;
        mode=drawingMode;
    case 1
        bLength=baseLength;
        mode=modeArray(4);
    case 0
        bLength=800;
        mode=modeArray(4);
    otherwise
        bLength=800;
        mode=modeArray(4);
end
close all;
hold on; axis equal;axis off;
% axis([-400 bLength+400 -400 bLength+400]);
% set(gca,'title',text(0,0,'Nepali National Flag (The most mathematial flag in the world)'))

x=0;y=0;
% (A) Method of Making the Shape inside the Border
% (1) On the lower portion of a crimson cloth draw a line AB of the required length from left to right.
A.x=x;
A.y=y;

B.x=x+bLength;
B.y=y;

% (2) From A draw a line AC perpendicular to AB making AC equal to AB plus one third AB. From AC mark off D making line AD equal to line AB. Join BD.
C.x=x;
C.y=y+bLength+(bLength/3);

D.x=x;
D.y=y+bLength;

% (3) From BD mark off E making BE equal to AB.
center = [B.x B.y];
edge = [center D.x D.y];
l1 = edgeToLine(edge);

% Circle
c1 = [center bLength];
pts = intersectLineCircle(l1, c1);

E.x=pts(2,1);
E.y=pts(2,2);

% (4) Touching E draw a line FG, starting from the point F on line AC, parallel to AB to the right hand-side. Mark off FG equal to AB.
F.x=x;
F.y=E.y;

G.x=x+bLength;
G.y=E.y;

% (5) Join CG.
% (B)Method of Making the Moon
% (6) From AB mark off AH making AH equal to one-fourth of line AB and starting from H draw a line HI parallel to line AC touching line CG at point I.
AB.length=bLength;

H.x=AB.length*1/4;
H.y=A.y;

AH.length=edgeLength([A.x A.y H.x H.y]);

edge=parallelEdge([A.x A.y C.x C.y],AH.length);

intersect=intersectEdges([H.x H.y edge(1,3:4)],[C.x C.y G.x G.y]);
I.x=intersect(1,1);
I.y=intersect(1,2);

clear edge intersect
% (7) Bisect CF at J and draw a line JK parallel to AB touching CG at point K.
mid=midPoint([C.x C.y F.x F.y]);
J.x=mid(1,1);
J.y=mid(1,2);

AJ.length=edgeLength([A.x A.y J.x J.y]);

edge=parallelEdge([A.x A.y B.x B.y],-AJ.length);
intersect=intersectEdges([J.x J.y edge(1,3:4)],[C.x C.y G.x G.y]);
K.x=intersect(1,1);
K.y=intersect(1,2);

% (8) Let L be the point where lines JK and HI cut one another.
intersect=intersectEdges([J.x J.y K.x K.y],[H.x H.y I.x I.y]);
L.x=intersect(1,1);
L.y=intersect(1,2);

% (9) Join JG.
% (10) Let M be the point where line JG and HI cut one another.
intersect=intersectEdges([J.x J.y G.x G.y],[H.x H.y I.x I.y]);
M.x=intersect(1,1);
M.y=intersect(1,2);

% (11) With centre M and with a distance shortest from M to BD mark off N on the lower portion of line HI.
distance= distancePointEdge([M.x M.y], [B.x B.y D.x D.y]);

N.x=M.x;
N.y=M.y-distance;

% (12) Touching M and starting from O, a point on AC, draw a line from left to right parallel to AB.

O.x=A.x;
O.y=M.y;

intersect=intersectLineEdge(edgeToLine([O.x O.y M.x M.y]),[C.x C.y G.x G.y]);
O1.x=intersect(1);
O1.y=intersect(2);

% (13) With centre L and radius LN draw a semi-circle on the lower portion and let P and Q be the points where it touches the line OM respectively.
centerL=[L.x L.y];
radiusL=edgeLength([L.x L.y N.x N.y]);

edge = [O.x O.y M.x M.y];
line = edgeToLine(edge);

circle = [centerL radiusL];
lcIntersection = intersectLineCircle(line, circle);
P.x=lcIntersection(1,1);
P.y=lcIntersection(1,2);

Q.x=lcIntersection(2,1);
Q.y=lcIntersection(2,2);

% (14) With centre M and radius MQ draw a semi-circle on the lower portion touching P and Q.
centerM=[M.x M.y];
radiusM=edgeLength([M.x M.y Q.x Q.y]);

% (15) With centre N and radius NM draw an arc touching PNQ [sic] at R and S. Join RS. Let T be the point where RS and HI cut one another.
centerN=[N.x N.y];
radiusN=edgeLength([N.x N.y M.x M.y]);

circleL=[centerL radiusL];
circleN=[centerN radiusN];
circleLNIntersect=intersectCircles(circleL,circleN);

R.x=circleLNIntersect(1,1);
R.y=circleLNIntersect(1,2);

S.x=circleLNIntersect(2,1);
S.y=circleLNIntersect(2,2);


intersect=intersectEdges([R.x R.y S.x S.y],[H.x H.y I.x I.y]);
T.x=intersect(1,1);
T.y=intersect(1,2);

% (16) With Centre T and radius TS draw a semi-circle on the upper portion of PNQ touching it at two points.
centerTU=[T.x T.y];
radiusTU=edgeLength([T.x T.y S.x S.y]);

% (17) With centre T and radius TM draw an arc on the upper portion of PNQ touching at two points.
centerTL=[T.x T.y];
radiusTL=edgeLength([T.x T.y M.x M.y]);

% (18) Eight equal and similar triangles of the moon are to be made in the space lying inside the semi-circle of No. (16) and outside the arc of No. (17) of this Schedule.
arcU=[centerTU radiusTU +180 -180];
arcL=[centerTL radiusTL +195 -210];
[XU, YU] = circleArcToPolyline(arcU, 38);

[XL, YL] = circleArcToPolyline(arcL, 11);

%(C) Method of Making Sun
% (19) Bisect line AF at U and draw a line UV parallel to line AB touching line BE at V.

mid=midPoint([A.x A.y F.x F.y]);
U.x=mid(1,1);
U.y=mid(1,2);

AU.length=edgeLength([A.x A.y U.x U.y]);

edge=parallelEdge([A.x A.y B.x B.y],-AU.length);
intersect=intersectEdges([U.x U.y edge(1,3:4)],[B.x B.y E.x E.y]);
V.x=intersect(1,1);
V.y=intersect(1,2);

% (20) With centre W, the point where HI and UV cut one another and radius MN draw a circle.
intersect=intersectEdges([U.x U.y V.x V.y],[H.x H.y I.x I.y]);
W.x=intersect(1,1);
W.y=intersect(1,2);

centerW=[W.x W.y];
radiusWI=edgeLength([M.x M.y N.x N.y]);
circleWI=[centerW radiusWI];

% (21) With centre W and radius LN draw a circle
radiusWO=edgeLength([L.x L.y N.x N.y]);
circleWO=[centerW radiusWO];

% (22) Twelve equal and similar triangles of the sun are to be made in the space enclosed by the circles of No. (20) and of No. (21) with the two apexes of two triangles touching line HI.
PI = circleToPolygon(circleWI, 24);
PO = circleToPolygon(circleWO, 48);

% (D) Method of Making the Border
% (23) The width of the border will be equal to the width TN. This will be of deep blue colour and will be provided on all the sides of the flag. However, on the five angles of the flag the external angles will be equal to the internal angles.
% (24) The above mentioned border will be provided if the flag is to be used with a rope. On the other hand, if it is to be hoisted on a pole, the hole on the border on the side AC can be extended according to requirements.
% Explanation: The lines HI, RS, FE, ED, JG, OQ, JK and UV are imaginary. Similarly, the external and internal circles of the sun and the other arcs except the crescent moon are also imaginary. These are not shown on the flag.
border.length=edgeLength([T.x T.y N.x N.y]);
ABBorder=parallelEdge([A.x A.y B.x B.y],border.length);
ACBorder=parallelEdge([A.x A.y C.x C.y],-border.length);
CGBorder=parallelEdge([C.x C.y G.x G.y],-border.length);
EGBorder=parallelEdge([E.x E.y G.x G.y],border.length);
BEBorder=parallelEdge([B.x B.y E.x E.y],border.length);

ABorderI=intersectLines(edgeToLine(ABBorder),edgeToLine(ACBorder));
CBorderI=intersectLines(edgeToLine(ACBorder),edgeToLine(CGBorder));
GBorderI=intersectLines(edgeToLine(CGBorder),edgeToLine(EGBorder));
EBorderI=intersectLines(edgeToLine(EGBorder),edgeToLine(BEBorder));
BBorderI=intersectLines(edgeToLine(ABBorder),edgeToLine(BEBorder));

ABBorder=[ABorderI BBorderI];
ACBorder=[ABorderI CBorderI];
CGBorder=[CBorderI GBorderI];
EGBorder=[EBorderI GBorderI];
BEBorder=[BBorderI EBorderI];

%Drawing
if(strcmp(mode,'skeleton'))
    drawEdge([A.x, A.y, B.x, B.y]);
    drawEdge([A.x, A.y, C.x, C.y]);
    drawEdge([E.x, E.y, G.x, G.y]); %- edge FE is imaginary
    drawEdge([C.x, C.y, G.x, G.y]);
    drawCircleArc([centerL radiusL -159 +138]);
    drawCircleArc([centerM radiusM -180 +180]);
    drawCircleArc([centerTL radiusTL +195 -210]);
    
    drawEdge([XU(1) YU(1) XL(2) YL(2) ]);
    drawEdge([XU(end) YU(end) XL(end-1) YL(end-1) ]);
    
    drawEdge([XL(2) YL(2) XU(5) YU(5) ]);
    drawEdge([XU(5) YU(5) XL(3) YL(3) ]);
    
    drawEdge([XL(end-1) YL(end-1) XU(end-4) YU(end-4) ]);
    drawEdge([XU(end-4) YU(end-4) XL(end-2) YL(end-2) ]);
    
    drawEdge([XL(3) YL(3) XU(9) YU(9) ]);
    drawEdge([XU(9) YU(9) XL(4) YL(4) ]);
    
    drawEdge([XL(end-2) YL(end-2) XU(end-8) YU(end-8) ]);
    drawEdge([XU(end-8) YU(end-8) XL(end-3) YL(end-3) ]);
    
    drawEdge([XL(4) YL(4) XU(13) YU(13) ]);
    drawEdge([XU(13) YU(13) XL(5) YL(5) ]);
    
    drawEdge([XL(end-3) YL(end-3) XU(end-12) YU(end-12) ]);
    drawEdge([XU(end-12) YU(end-12) XL(end-4) YL(end-4) ]);
    
    drawEdge([XL(5) YL(5) XU(17) YU(17) ]);
    drawEdge([XU(17) YU(17) XL(6) YL(6) ]);
    
    drawEdge([XL(end-4) YL(end-4) XU(end-16) YU(end-16) ]);
    drawEdge([XU(end-16) YU(end-16) XL(end-5) YL(end-5) ]);
    
    drawCircle(circleWI);
    
    drawEdge([PI(2,:) PO(1,:)]);
    
    drawEdge([PI(2,:) PO(5,:)]);
    drawEdge([PO(5,:) PI(4,:)]);
    
    drawEdge([PI(4,:) PO(9,:)]);
    drawEdge([PO(9,:) PI(6,:)]);
    
    drawEdge([PI(6,:) PO(13,:)]);
    drawEdge([PO(13,:) PI(8,:)]);
    
    drawEdge([PI(8,:) PO(17,:)]);
    drawEdge([PO(17,:) PI(10,:)]);
    
    drawEdge([PI(10,:) PO(21,:)]);
    drawEdge([PO(21,:) PI(12,:)]);
    
    drawEdge([PI(12,:) PO(25,:)]);
    drawEdge([PO(25,:) PI(14,:)]);
    
    drawEdge([PI(14,:) PO(29,:)]);
    drawEdge([PO(29,:) PI(16,:)]);
    
    drawEdge([PI(16,:) PO(33,:)]);
    drawEdge([PO(33,:) PI(18,:)]);
    
    drawEdge([PI(18,:) PO(37,:)]);
    drawEdge([PO(37,:) PI(20,:)]);
    
    drawEdge([PI(20,:) PO(41,:)]);
    drawEdge([PO(41,:) PI(22,:)]);
    
    drawEdge([PI(22,:) PO(45,:)]);
    drawEdge([PO(45,:) PI(24,:)]);
    
    drawEdge([PI(24,:) PO(1,:)]);
    
    drawEdge(ABBorder);
    drawEdge(ACBorder);
    drawEdge(CGBorder);
    drawEdge(EGBorder);
    drawEdge(BEBorder);
    
    drawEdge([B.x, B.y, E.x, E.y]);
end

if(strcmp(mode,'landmarks'))
    % (A) Method of Making the Shape inside the Border
    % (1) On the lower portion of a crimson cloth draw a line AB of the required length from left to right.
    drawEdge([A.x, A.y, B.x, B.y]);
    drawLabels([A.x,A.y],'A');
    drawLabels([B.x,B.y],'B');
    % (2) From A draw a line AC perpendicular to AB making AC equal to AB plus one third AB. From AC mark off D making line AD equal to line AB. Join BD.
    drawEdge([A.x, A.y, C.x, C.y]);
    drawLabels([C.x,C.y],'C');
    %drawLabels([D.x,D.y],'D');
    % drawEdge([B.x, B.y, D.x, D.y]); -drawn at last section
    % (3) From BD mark off E making BE equal to AB.
    drawLabels([E.x,E.y],'E');
    % (4) Touching E draw a line FG, starting from the point F on line AC, parallel to AB to the right hand-side. Mark off FG equal to AB.
    % drawEdge([F.x, F.y, G.x, G.y]);
    drawEdge([E.x, E.y, G.x, G.y]); %- edge FE is imaginary
    drawLabels([F.x,F.y],'F');
    drawLabels([G.x,G.y],'G');
    % (5) Join CG.
    drawEdge([C.x, C.y, G.x, G.y]);
    % (B)Method of Making the Moon
    % (6) From AB mark off AH making AH equal to one-fourth of line AB and starting from H draw a line HI parallel to line AC touching line CG at point I.
    %drawEdge([H.x H.y I.x I.y]); -imaginary edge
    drawLabels([H.x H.y],'H');
    drawLabels([I.x I.y],'I');
    % (7) Bisect CF at J and draw a line JK parallel to AB touching CG at point K.
    %drawEdge([J.x J.y K.x K.y]); -imaginary
    drawLabels([J.x J.y],'J');
    drawLabels([K.x K.y],'K');
    % (8) Let L be the point where lines JK and HI cut one another.
    drawLabels([L.x L.y],'L');
    % (9) Join JG.
    %drawEdge([J.x J.y G.x G.y]);-imaginary
    % (10) Let M be the point where line JG and HI cut one another.
    drawLabels([M.x M.y],'M');
    % (11) With centre M and with a distance shortest from M to BD mark off N on the lower portion of line HI.
    drawLabels([N.x N.y],'N');
    % (12) Touching M and starting from O, a point on AC, draw a line from left to right parallel to AB.
    %drawEdge([O.x O.y O1.x O1.y]); -imaginary
    drawLabels([O.x O.y],'O');
    %drawLabels([O1.x O1.y],'O1');
    % (13) With centre L and radius LN draw a semi-circle on the lower portion and let P and Q be the points where it touches the line OM respectively.
    drawCircleArc([centerL radiusL -159 +138]);
    drawLabels([P.x P.y],'P');
    drawLabels([Q.x Q.y],'Q');
    % (14) With centre M and radius MQ draw a semi-circle on the lower portion touching P and Q.
    drawCircleArc([centerM radiusM -180 +180]);
    % (15) With centre N and radius NM draw an arc touching PNQ [sic] at R and S. Join RS. Let T be the point where RS and HI cut one another.
    %drawCircleArc([centerN radiusN +180 -180]); -imaginary
    %drawEdge([R.x R.y S.x S.y]); -imaginary edge
    drawLabels([R.x R.y],'R');
    drawLabels([S.x S.y],'S');
    drawLabels([T.x T.y],'T');
    % (16) With Centre T and radius TS draw a semi-circle on the upper portion of PNQ touching it at two points.
    %drawCircleArc([centerTU radiusTU +180 -180]); -imaginary
    % (17) With centre T and radius TM draw an arc on the upper portion of PNQ touching at two points.
    drawCircleArc([centerTL radiusTL +195 -210]);
    % (18) Eight equal and similar triangles of the moon are to be made in the space lying inside the semi-circle of No. (16) and outside the arc of No. (17) of this Schedule.
    drawEdge([XU(1) YU(1) XL(2) YL(2) ]);
    drawEdge([XU(end) YU(end) XL(end-1) YL(end-1) ]);
    
    drawEdge([XL(2) YL(2) XU(5) YU(5) ]);
    drawEdge([XU(5) YU(5) XL(3) YL(3) ]);
    
    drawEdge([XL(end-1) YL(end-1) XU(end-4) YU(end-4) ]);
    drawEdge([XU(end-4) YU(end-4) XL(end-2) YL(end-2) ]);
    
    drawEdge([XL(3) YL(3) XU(9) YU(9) ]);
    drawEdge([XU(9) YU(9) XL(4) YL(4) ]);
    
    drawEdge([XL(end-2) YL(end-2) XU(end-8) YU(end-8) ]);
    drawEdge([XU(end-8) YU(end-8) XL(end-3) YL(end-3) ]);
    
    drawEdge([XL(4) YL(4) XU(13) YU(13) ]);
    drawEdge([XU(13) YU(13) XL(5) YL(5) ]);
    
    drawEdge([XL(end-3) YL(end-3) XU(end-12) YU(end-12) ]);
    drawEdge([XU(end-12) YU(end-12) XL(end-4) YL(end-4) ]);
    
    drawEdge([XL(5) YL(5) XU(17) YU(17) ]);
    drawEdge([XU(17) YU(17) XL(6) YL(6) ]);
    
    drawEdge([XL(end-4) YL(end-4) XU(end-16) YU(end-16) ]);
    drawEdge([XU(end-16) YU(end-16) XL(end-5) YL(end-5) ]);
    %(C) Method of Making Sun
    % (19) Bisect line AF at U and draw a line UV parallel to line AB touching line BE at V.
    %drawEdge([U.x U.y V.x V.y]); -imaginary
    drawLabels([U.x U.y],'U');
    drawLabels([V.x V.y],'V')
    % (20) With centre W, the point where HI and UV cut one another and radius MN draw a circle.
    drawCircle(circleWI);
    drawLabels([W.x W.y],'W')
    % (21) With centre W and radius LN draw a circle
    %drawCircle(circleWO); -imaginary
    % (22) Twelve equal and similar triangles of the sun are to be made in the space enclosed by the circles of No. (20) and of No. (21) with the two apexes of two triangles touching line HI.
    drawEdge([PI(2,:) PO(1,:)]);
    
    drawEdge([PI(2,:) PO(5,:)]);
    drawEdge([PO(5,:) PI(4,:)]);
    
    drawEdge([PI(4,:) PO(9,:)]);
    drawEdge([PO(9,:) PI(6,:)]);
    
    drawEdge([PI(6,:) PO(13,:)]);
    drawEdge([PO(13,:) PI(8,:)]);
    
    drawEdge([PI(8,:) PO(17,:)]);
    drawEdge([PO(17,:) PI(10,:)]);
    
    drawEdge([PI(10,:) PO(21,:)]);
    drawEdge([PO(21,:) PI(12,:)]);
    
    drawEdge([PI(12,:) PO(25,:)]);
    drawEdge([PO(25,:) PI(14,:)]);
    
    drawEdge([PI(14,:) PO(29,:)]);
    drawEdge([PO(29,:) PI(16,:)]);
    
    drawEdge([PI(16,:) PO(33,:)]);
    drawEdge([PO(33,:) PI(18,:)]);
    
    drawEdge([PI(18,:) PO(37,:)]);
    drawEdge([PO(37,:) PI(20,:)]);
    
    drawEdge([PI(20,:) PO(41,:)]);
    drawEdge([PO(41,:) PI(22,:)]);
    
    drawEdge([PI(22,:) PO(45,:)]);
    drawEdge([PO(45,:) PI(24,:)]);
    
    drawEdge([PI(24,:) PO(1,:)]);
    
    % (D) Method of Making the Border
    % (23) The width of the border will be equal to the width TN. This will be of deep blue colour and will be provided on all the sides of the flag. However, on the five angles of the flag the external angles will be equal to the internal angles.
    % (24) The above mentioned border will be provided if the flag is to be used with a rope. On the other hand, if it is to be hoisted on a pole, the hole on the border on the side AC can be extended according to requirements.
    % Explanation: The lines HI, RS, FE, ED, JG, OQ, JK and UV are imaginary. Similarly, the external and internal circles of the sun and the other arcs except the crescent moon are also imaginary. These are not shown on the flag.
    drawEdge(ABBorder);
    drawEdge(ACBorder);
    drawEdge(CGBorder);
    drawEdge(EGBorder);
    drawEdge(BEBorder);
    drawEdge([B.x, B.y, E.x, E.y]);
end

if(strcmp(mode,'alldrawings'))
    % (A) Method of Making the Shape inside the Border
    % (1) On the lower portion of a crimson cloth draw a line AB of the required length from left to right.
    drawEdge([A.x, A.y, B.x, B.y]);
    drawLabels([A.x,A.y],'A');
    drawLabels([B.x,B.y],'B');
    % (2) From A draw a line AC perpendicular to AB making AC equal to AB plus one third AB. From AC mark off D making line AD equal to line AB. Join BD.
    drawEdge([A.x, A.y, C.x, C.y]);
    drawLabels([C.x,C.y],'C');
    drawLabels([D.x,D.y],'D');
    % drawEdge([B.x, B.y, D.x, D.y]); -drawn at last section
    % (3) From BD mark off E making BE equal to AB.
    drawLabels([E.x,E.y],'E');
    % (4) Touching E draw a line FG, starting from the point F on line AC, parallel to AB to the right hand-side. Mark off FG equal to AB.
    drawEdge([F.x, F.y, G.x, G.y]);
    drawEdge([E.x, E.y, G.x, G.y]); %- edge FE is imaginary
    drawLabels([F.x,F.y],'F');
    drawLabels([G.x,G.y],'G');
    % (5) Join CG.
    drawEdge([C.x, C.y, G.x, G.y]);
    % (B)Method of Making the Moon
    % (6) From AB mark off AH making AH equal to one-fourth of line AB and starting from H draw a line HI parallel to line AC touching line CG at point I.
    drawEdge([H.x H.y I.x I.y]); %-imaginary edge
    drawLabels([H.x H.y],'H');
    drawLabels([I.x I.y],'I');
    % (7) Bisect CF at J and draw a line JK parallel to AB touching CG at point K.
    drawEdge([J.x J.y K.x K.y]); %-imaginary
    drawLabels([J.x J.y],'J');
    drawLabels([K.x K.y],'K');
    % (8) Let L be the point where lines JK and HI cut one another.
    drawLabels([L.x L.y],'L');
    % (9) Join JG.
    drawEdge([J.x J.y G.x G.y]);%-imaginary
    % (10) Let M be the point where line JG and HI cut one another.
    drawLabels([M.x M.y],'M');
    % (11) With centre M and with a distance shortest from M to BD mark off N on the lower portion of line HI.
    drawLabels([N.x N.y],'N');
    % (12) Touching M and starting from O, a point on AC, draw a line from left to right parallel to AB.
    drawEdge([O.x O.y O1.x O1.y]); %-imaginary
    drawLabels([O.x O.y],'O');
    % drawLabels([O1.x O1.y],'O1');
    % (13) With centre L and radius LN draw a semi-circle on the lower portion and let P and Q be the points where it touches the line OM respectively.
    drawCircleArc([centerL radiusL -159 +138]);
    drawLabels([P.x P.y],'P');
    drawLabels([Q.x Q.y],'Q');
    % (14) With centre M and radius MQ draw a semi-circle on the lower portion touching P and Q.
    drawCircleArc([centerM radiusM -180 +180]);
    % (15) With centre N and radius NM draw an arc touching PNQ [sic] at R and S. Join RS. Let T be the point where RS and HI cut one another.
    drawCircleArc([centerN radiusN +180 -180]); %-imaginary
    drawEdge([R.x R.y S.x S.y]); %-imaginary edge
    drawLabels([R.x R.y],'R');
    drawLabels([S.x S.y],'S');
    drawLabels([T.x T.y],'T');
    % (16) With Centre T and radius TS draw a semi-circle on the upper portion of PNQ touching it at two points.
    drawCircleArc([centerTU radiusTU +180 -180]); %-imaginary
    % (17) With centre T and radius TM draw an arc on the upper portion of PNQ touching at two points.
    drawCircleArc([centerTL radiusTL +195 -210]);
    % (18) Eight equal and similar triangles of the moon are to be made in the space lying inside the semi-circle of No. (16) and outside the arc of No. (17) of this Schedule.
    drawEdge([XU(1) YU(1) XL(2) YL(2) ]);
    drawEdge([XU(end) YU(end) XL(end-1) YL(end-1) ]);
    
    drawEdge([XL(2) YL(2) XU(5) YU(5) ]);
    drawEdge([XU(5) YU(5) XL(3) YL(3) ]);
    
    drawEdge([XL(end-1) YL(end-1) XU(end-4) YU(end-4) ]);
    drawEdge([XU(end-4) YU(end-4) XL(end-2) YL(end-2) ]);
    
    drawEdge([XL(3) YL(3) XU(9) YU(9) ]);
    drawEdge([XU(9) YU(9) XL(4) YL(4) ]);
    
    drawEdge([XL(end-2) YL(end-2) XU(end-8) YU(end-8) ]);
    drawEdge([XU(end-8) YU(end-8) XL(end-3) YL(end-3) ]);
    
    drawEdge([XL(4) YL(4) XU(13) YU(13) ]);
    drawEdge([XU(13) YU(13) XL(5) YL(5) ]);
    
    drawEdge([XL(end-3) YL(end-3) XU(end-12) YU(end-12) ]);
    drawEdge([XU(end-12) YU(end-12) XL(end-4) YL(end-4) ]);
    
    drawEdge([XL(5) YL(5) XU(17) YU(17) ]);
    drawEdge([XU(17) YU(17) XL(6) YL(6) ]);
    
    drawEdge([XL(end-4) YL(end-4) XU(end-16) YU(end-16) ]);
    drawEdge([XU(end-16) YU(end-16) XL(end-5) YL(end-5) ]);
    %(C) Method of Making Sun
    % (19) Bisect line AF at U and draw a line UV parallel to line AB touching line BE at V.
    drawEdge([U.x U.y V.x V.y]); %-imaginary
    drawLabels([U.x U.y],'U');
    drawLabels([V.x V.y],'V')
    % (20) With centre W, the point where HI and UV cut one another and radius MN draw a circle.
    drawCircle(circleWI);
    drawLabels([W.x W.y],'W')
    % (21) With centre W and radius LN draw a circle
    drawCircle(circleWO); %-imaginary
    % (22) Twelve equal and similar triangles of the sun are to be made in the space enclosed by the circles of No. (20) and of No. (21) with the two apexes of two triangles touching line HI.
    drawEdge([PI(2,:) PO(1,:)]);
    
    drawEdge([PI(2,:) PO(5,:)]);
    drawEdge([PO(5,:) PI(4,:)]);
    
    drawEdge([PI(4,:) PO(9,:)]);
    drawEdge([PO(9,:) PI(6,:)]);
    
    drawEdge([PI(6,:) PO(13,:)]);
    drawEdge([PO(13,:) PI(8,:)]);
    
    drawEdge([PI(8,:) PO(17,:)]);
    drawEdge([PO(17,:) PI(10,:)]);
    
    drawEdge([PI(10,:) PO(21,:)]);
    drawEdge([PO(21,:) PI(12,:)]);
    
    drawEdge([PI(12,:) PO(25,:)]);
    drawEdge([PO(25,:) PI(14,:)]);
    
    drawEdge([PI(14,:) PO(29,:)]);
    drawEdge([PO(29,:) PI(16,:)]);
    
    drawEdge([PI(16,:) PO(33,:)]);
    drawEdge([PO(33,:) PI(18,:)]);
    
    drawEdge([PI(18,:) PO(37,:)]);
    drawEdge([PO(37,:) PI(20,:)]);
    
    drawEdge([PI(20,:) PO(41,:)]);
    drawEdge([PO(41,:) PI(22,:)]);
    
    drawEdge([PI(22,:) PO(45,:)]);
    drawEdge([PO(45,:) PI(24,:)]);
    
    drawEdge([PI(24,:) PO(1,:)]);
    
    % (D) Method of Making the Border
    % (23) The width of the border will be equal to the width TN. This will be of deep blue colour and will be provided on all the sides of the flag. However, on the five angles of the flag the external angles will be equal to the internal angles.
    % (24) The above mentioned border will be provided if the flag is to be used with a rope. On the other hand, if it is to be hoisted on a pole, the hole on the border on the side AC can be extended according to requirements.
    % Explanation: The lines HI, RS, FE, ED, JG, OQ, JK and UV are imaginary. Similarly, the external and internal circles of the sun and the other arcs except the crescent moon are also imaginary. These are not shown on the flag.
    drawEdge(ABBorder);
    drawEdge(ACBorder);
    drawEdge(CGBorder);
    drawEdge(EGBorder);
    drawEdge(BEBorder);
    drawEdge([B.x, B.y, E.x, E.y]);
end

if(strcmp(mode,'fillcolor'))
    BorderX=[A.x;B.x;E.x;G.x;C.x;A.x;...
        ABorderI(1);BBorderI(1);EBorderI(1);GBorderI(1);CBorderI(1);ABorderI(1)];
    BorderY=[A.y;B.y;E.y;G.y;C.y;A.y;...
        ABorderI(2);BBorderI(2);EBorderI(2);GBorderI(2);CBorderI(2);ABorderI(2)];
    
    patch(BorderX, BorderY,[0,0,0.8]); %deep blue color code [0, 0, 0.8]
    
    InsideX=[A.x;B.x;E.x;G.x;C.x;A.x];
    InsideY=[A.y;B.y;E.y;G.y;C.y;A.y];
    
    patch(InsideX, InsideY,[0.73,0.0667,0.20]); %crimsom red color code rgb(220, 20, 60) [0.73,0.0667,0.20]
    
    mColor='w';
    
    [arcPQUX,arcPQUY]=circleArcToPolyline([centerL radiusL -159 +138]);
    [arcPQLX,arcPQLY]=circleArcToPolyline([centerM radiusM -180 +180]);
    
    mCrispLX=[XU(1);XL(2);XU(5);XL(3);XU(9);XL(4);XU(13);XL(5);XU(17);XL(6)];
    mCrispLY=[YU(1);YL(2);YU(5);YL(3);YU(9);YL(4);YU(13);YL(5);YU(17);YL(6)];
    
    mCrispRX=[XU(end);XL(end-1);XU(end-4);XL(end-2);XU(end-8);XL(end-3);XU(end-12);XL(end-4);XU(end-16);XL(end-5)];
    mCrispRY=[YU(end);YL(end-1);YU(end-4);YL(end-2);YU(end-8);YL(end-3);YU(end-12);YL(end-4);YU(end-16);YL(end-5)];
    
    indx=((arcPQUX(:)<=R.x));
    mCrispRangeLX=arcPQUX(indx);
    mCrispRangeLY=arcPQUY(indx);
    
    indx=((arcPQUX(:)>=R.x) & (arcPQUX(:)<=S.x ));
    mCrispRangeX=arcPQUX(indx);
    mCrispRangeY=arcPQUY(indx);
    
    indx=((arcPQUX(:)>=S.x ));
    mCrispRangeRX=arcPQUX(indx);
    mCrispRangeRY=arcPQUY(indx);
    
    patch([mCrispRangeLX;mCrispLX;mCrispRX(end:-1:1);mCrispRangeRX;arcPQLX(end:-1:1)],[mCrispRangeLY;mCrispLY;mCrispRY(end:-1:1);mCrispRangeRY;arcPQLY(end:-1:1)],mColor);
    
    sCrisp=[PI(2,:);PO(5,:); PI(4,:);PO(9,:); PI(6,:);PO(13,:); PI(8,:)...
        ;PO(17,:); PI(10,:);PO(21,:); PI(12,:);PO(25,:); PI(14,:)...
        ;PO(29,:); PI(16,:);PO(33,:); PI(18,:);PO(37,:); PI(20,:)...
        ;PO(41,:); PI(22,:);PO(45,:); PI(24,:);PO(1,:)];
    
    patch(sCrisp(:,1),sCrisp(:,2),mColor);
end

if(strcmp(mode,'animate'))
    filename='flag.gif';
    axis([-1000 bLength+1000 -1000 bLength+1000]);
    pTime=0.7;
    % (A) Method of Making the Shape inside the Border
    % (1) On the lower portion of a crimson cloth draw a line AB of the required length from left to right.
    drawEdge([A.x, A.y, B.x, B.y]);
    pause(pTime);writeFigure1(filename)
    drawLabels([A.x,A.y],'A');
    pause(pTime);writeFigureN(filename)
    drawLabels([B.x,B.y],'B');
    pause(pTime);writeFigureN(filename)
    % (2) From A draw a line AC perpendicular to AB making AC equal to AB plus one third AB. From AC mark off D making line AD equal to line AB. Join BD.
    drawEdge([A.x, A.y, C.x, C.y]);
    pause(pTime);writeFigureN(filename)
    drawLabels([C.x,C.y],'C');
    pause(pTime);writeFigureN(filename)
    drawLabels([D.x,D.y],'D');
    pause(pTime);writeFigureN(filename)
    % drawEdge([B.x, B.y, D.x, D.y]); -drawn at last section
    % (3) From BD mark off E making BE equal to AB.
    drawLabels([E.x,E.y],'E');
    pause(pTime);writeFigureN(filename)
    % (4) Touching E draw a line FG, starting from the point F on line AC, parallel to AB to the right hand-side. Mark off FG equal to AB.
    drawEdge([F.x, F.y, G.x, G.y]);
    pause(pTime);writeFigureN(filename)
    drawEdge([E.x, E.y, G.x, G.y]); %- edge FE is imaginary
    pause(pTime);writeFigureN(filename)
    drawLabels([F.x,F.y],'F');
    pause(pTime);writeFigureN(filename)
    drawLabels([G.x,G.y],'G');
    pause(pTime);writeFigureN(filename)
    % (5) Join CG.
    drawEdge([C.x, C.y, G.x, G.y]);
    pause(pTime);writeFigureN(filename)
    % (B)Method of Making the Moon
    % (6) From AB mark off AH making AH equal to one-fourth of line AB and starting from H draw a line HI parallel to line AC touching line CG at point I.
    drawEdge([H.x H.y I.x I.y]); %-imaginary edge
    pause(pTime);writeFigureN(filename)
    drawLabels([H.x H.y],'H');
    pause(pTime);writeFigureN(filename)
    drawLabels([I.x I.y],'I');
    pause(pTime);writeFigureN(filename)
    % (7) Bisect CF at J and draw a line JK parallel to AB touching CG at point K.
    drawEdge([J.x J.y K.x K.y]); %-imaginary
    pause(pTime);writeFigureN(filename)
    drawLabels([J.x J.y],'J');
    pause(pTime);writeFigureN(filename)
    drawLabels([K.x K.y],'K');
    pause(pTime);writeFigureN(filename)
    % (8) Let L be the point where lines JK and HI cut one another.
    drawLabels([L.x L.y],'L');
    pause(pTime);writeFigureN(filename)
    % (9) Join JG.
    drawEdge([J.x J.y G.x G.y]);%-imaginary
    pause(pTime);writeFigureN(filename)
    % (10) Let M be the point where line JG and HI cut one another.
    drawLabels([M.x M.y],'M');
    pause(pTime);writeFigureN(filename)
    % (11) With centre M and with a distance shortest from M to BD mark off N on the lower portion of line HI.
    drawLabels([N.x N.y],'N');
    pause(pTime);writeFigureN(filename)
    % (12) Touching M and starting from O, a point on AC, draw a line from left to right parallel to AB.
    drawEdge([O.x O.y O1.x O1.y]); %-imaginary
    pause(pTime);writeFigureN(filename)
    drawLabels([O.x O.y],'O');
    pause(pTime);writeFigureN(filename)
    % drawLabels([O1.x O1.y],'O1');
    % (13) With centre L and radius LN draw a semi-circle on the lower portion and let P and Q be the points where it touches the line OM respectively.
    drawCircleArc([centerL radiusL -159 +138]);
    pause(pTime);writeFigureN(filename)
    drawLabels([P.x P.y],'P');
    pause(pTime);writeFigureN(filename)
    drawLabels([Q.x Q.y],'Q');
    pause(pTime);writeFigureN(filename)
    % (14) With centre M and radius MQ draw a semi-circle on the lower portion touching P and Q.
    drawCircleArc([centerM radiusM -180 +180]);
    pause(pTime);writeFigureN(filename)
    % (15) With centre N and radius NM draw an arc touching PNQ [sic] at R and S. Join RS. Let T be the point where RS and HI cut one another.
    drawCircleArc([centerN radiusN +180 -180]); %-imaginary
    pause(pTime);writeFigureN(filename)
    drawEdge([R.x R.y S.x S.y]); %-imaginary edge
    pause(pTime);writeFigureN(filename)
    drawLabels([R.x R.y],'R');
    pause(pTime);writeFigureN(filename)
    drawLabels([S.x S.y],'S');
    pause(pTime);writeFigureN(filename)
    drawLabels([T.x T.y],'T');
    pause(pTime);writeFigureN(filename)
    % (16) With Centre T and radius TS draw a semi-circle on the upper portion of PNQ touching it at two points.
    drawCircleArc([centerTU radiusTU +180 -180]); %-imaginary
    pause(pTime);writeFigureN(filename)
    % (17) With centre T and radius TM draw an arc on the upper portion of PNQ touching at two points.
    drawCircleArc([centerTL radiusTL +195 -210]);
    pause(pTime);writeFigureN(filename)
    % (18) Eight equal and similar triangles of the moon are to be made in the space lying inside the semi-circle of No. (16) and outside the arc of No. (17) of this Schedule.
    drawEdge([XU(1) YU(1) XL(2) YL(2) ]);
    
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([XU(end) YU(end) XL(end-1) YL(end-1) ]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([XL(2) YL(2) XU(5) YU(5) ]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([XU(5) YU(5) XL(3) YL(3) ]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([XL(end-1) YL(end-1) XU(end-4) YU(end-4) ]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([XU(end-4) YU(end-4) XL(end-2) YL(end-2) ]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([XL(3) YL(3) XU(9) YU(9) ]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([XU(9) YU(9) XL(4) YL(4) ]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([XL(end-2) YL(end-2) XU(end-8) YU(end-8) ]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([XU(end-8) YU(end-8) XL(end-3) YL(end-3) ]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([XL(4) YL(4) XU(13) YU(13) ]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([XU(13) YU(13) XL(5) YL(5) ]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([XL(end-3) YL(end-3) XU(end-12) YU(end-12) ]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([XU(end-12) YU(end-12) XL(end-4) YL(end-4) ]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([XL(5) YL(5) XU(17) YU(17) ]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([XU(17) YU(17) XL(6) YL(6) ]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([XL(end-4) YL(end-4) XU(end-16) YU(end-16) ]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([XU(end-16) YU(end-16) XL(end-5) YL(end-5) ]);
    pause(pTime-0.5);writeFigureN(filename)
    %(C) Method of Making Sun
    % (19) Bisect line AF at U and draw a line UV parallel to line AB touching line BE at V.
    drawEdge([U.x U.y V.x V.y]); %-imaginary
    pause(pTime);writeFigureN(filename)
    drawLabels([U.x U.y],'U');
    pause(pTime);writeFigureN(filename)
    drawLabels([V.x V.y],'V')
    pause(pTime);writeFigureN(filename)
    % (20) With centre W, the point where HI and UV cut one another and radius MN draw a circle.
    drawCircle(circleWI);
    pause(pTime);writeFigureN(filename)
    drawLabels([W.x W.y],'W')
    pause(pTime);writeFigureN(filename)
    % (21) With centre W and radius LN draw a circle
    drawCircle(circleWO); %-imaginary
    pause(pTime);writeFigureN(filename)
    % (22) Twelve equal and similar triangles of the sun are to be made in the space enclosed by the circles of No. (20) and of No. (21) with the two apexes of two triangles touching line HI.
    drawEdge([PI(2,:) PO(1,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(2,:) PO(5,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(5,:) PI(4,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(4,:) PO(9,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(9,:) PI(6,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(6,:) PO(13,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(13,:) PI(8,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(8,:) PO(17,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(17,:) PI(10,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(10,:) PO(21,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(21,:) PI(12,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(12,:) PO(25,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(25,:) PI(14,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(14,:) PO(29,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(29,:) PI(16,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(16,:) PO(33,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(33,:) PI(18,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(18,:) PO(37,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(37,:) PI(20,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(20,:) PO(41,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(41,:) PI(22,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(22,:) PO(45,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    drawEdge([PO(45,:) PI(24,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    drawEdge([PI(24,:) PO(1,:)]);
    pause(pTime-0.5);writeFigureN(filename)
    
    % (D) Method of Making the Border
    % (23) The width of the border will be equal to the width TN. This will be of deep blue colour and will be provided on all the sides of the flag. However, on the five angles of the flag the external angles will be equal to the internal angles.
    % (24) The above mentioned border will be provided if the flag is to be used with a rope. On the other hand, if it is to be hoisted on a pole, the hole on the border on the side AC can be extended according to requirements.
    % Explanation: The lines HI, RS, FE, ED, JG, OQ, JK and UV are imaginary. Similarly, the external and internal circles of the sun and the other arcs except the crescent moon are also imaginary. These are not shown on the flag.
    
    drawEdge(ABBorder);
    pause(pTime);writeFigureN(filename)
    drawEdge(ACBorder);
    pause(pTime);writeFigureN(filename)
    drawEdge(CGBorder);
    pause(pTime);writeFigureN(filename)
    drawEdge(EGBorder);
    pause(pTime);writeFigureN(filename)
    drawEdge(BEBorder);
    pause(pTime);writeFigureN(filename)
    drawEdge([B.x, B.y, E.x, E.y]);
    pause(pTime);writeFigureN(filename)
    
    %Filling color
    BorderX=[A.x;B.x;E.x;G.x;C.x;A.x;...
        ABorderI(1);BBorderI(1);EBorderI(1);GBorderI(1);CBorderI(1);ABorderI(1)];
    
    BorderY=[A.y;B.y;E.y;G.y;C.y;A.y;...
        ABorderI(2);BBorderI(2);EBorderI(2);GBorderI(2);CBorderI(2);ABorderI(2)];
    
    patch(BorderX, BorderY,[0,0,0.8]); %deep blue color code [0, 0, 0.8]
    pause(pTime);writeFigureN(filename)
    InsideX=[A.x;B.x;E.x;G.x;C.x;A.x];
    InsideY=[A.y;B.y;E.y;G.y;C.y;A.y];
    
    patch(InsideX, InsideY,[0.73,0.0667,0.20]); %crimsom red color code srgb(220, 20, 60) [0.73,0.0667,0.20]
    pause(pTime);writeFigureN(filename)
    mColor='w';
    
    [arcPQUX,arcPQUY]=circleArcToPolyline([centerL radiusL -159 +138]);
    [arcPQLX,arcPQLY]=circleArcToPolyline([centerM radiusM -180 +180]);
    
    mCrispLX=[XU(1);XL(2);XU(5);XL(3);XU(9);XL(4);XU(13);XL(5);XU(17);XL(6)];
    mCrispLY=[YU(1);YL(2);YU(5);YL(3);YU(9);YL(4);YU(13);YL(5);YU(17);YL(6)];
    
    mCrispRX=[XU(end);XL(end-1);XU(end-4);XL(end-2);XU(end-8);XL(end-3);XU(end-12);XL(end-4);XU(end-16);XL(end-5)];
    mCrispRY=[YU(end);YL(end-1);YU(end-4);YL(end-2);YU(end-8);YL(end-3);YU(end-12);YL(end-4);YU(end-16);YL(end-5)];
    
    indx=((arcPQUX(:)<=R.x));
    mCrispRangeLX=arcPQUX(indx);
    mCrispRangeLY=arcPQUY(indx);
    
    indx=((arcPQUX(:)>=R.x) & (arcPQUX(:)<=S.x ));
    mCrispRangeX=arcPQUX(indx);
    mCrispRangeY=arcPQUY(indx);
    
    indx=((arcPQUX(:)>=S.x ));
    mCrispRangeRX=arcPQUX(indx);
    mCrispRangeRY=arcPQUY(indx);
    
    patch([mCrispRangeLX;mCrispLX;mCrispRX(end:-1:1);mCrispRangeRX;arcPQLX(end:-1:1)],[mCrispRangeLY;mCrispLY;mCrispRY(end:-1:1);mCrispRangeRY;arcPQLY(end:-1:1)],mColor);
    pause(pTime);writeFigureN(filename)
    
    sCrisp=[PI(2,:);PO(5,:); PI(4,:);PO(9,:); PI(6,:);PO(13,:); PI(8,:)...
        ;PO(17,:); PI(10,:);PO(21,:); PI(12,:);PO(25,:); PI(14,:)...
        ;PO(29,:); PI(16,:);PO(33,:); PI(18,:);PO(37,:); PI(20,:)...
        ;PO(41,:); PI(22,:);PO(45,:); PI(24,:);PO(1,:)];
    
    patch(sCrisp(:,1),sCrisp(:,2),mColor);
    pause(pTime);writeFigureN(filename)
    pause(2);
end
hold off;
end

function writeFigure1(filename)
frame = getframe(1);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
end

function writeFigureN(filename)
frame = getframe(1);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,filename,'gif','WriteMode','append');
end

function writeText(string,pos)
colwidth = 100;
ht = uicontrol('Style','Text','Position',pos,'HorizontalAlignment','left','FontSize',14);
[outstring, newpos] = textwrap(ht,string,colwidth);
set(ht,'String',outstring,'Position',newpos)
end

function flag = flagDrawingProcedure()
flag={'National Flag of Nepal (drawing procedure)';
    '---------------------------';
    '(A) Method of Making the Shape inside the Border';
    '  (1) On the lower portion of a crimson cloth draw a line AB of the required length from left to right.';
    '  (2) From A draw a line AC perpendicular to AB making AC equal to AB plus one third AB. From AC mark off D making line AD equal to line AB. Join BD.';
    '  (3) From BD mark off E making BE equal to AB.';
    '  (4) Touching E draw a line FG, starting from the point F on line AC, parallel to, AB to the right hand-side. Mark off FG equal to AB.'
    '  (5) Join CG.';
    '(B) Method of Making the Moon';
    '  (6) From AB mark off AH making AH equal to one-fourth of line AB and starting from H draw a line HI parallel to line AC touching line CG at point I.';
    '  (7) Bisect CF at J and draw a line JK parallel to AB touching CG at point K.';
    '  (8) Let L be the point where lines JK and HI cut one another.';
    '  (9) Join JG.';
    '  (10) Let M be the point where line JG and HI cut one another.';
    '  (11) With centre M and with a distance shortest from M to BD mark off N on the lower portion of line HI.';
    '  (12) Touching M and starting from O, a point on AC, draw a line from left to right parallel to AB.';
    '  (13) With centre L and radius LN draw a semi-circle on the lower portion and let P and Q be the points where it touches the line OM respectively.';
    '  (14) With centre M and radius MQ draw a semi-circle on the lower portion touching P and Q.';
    '  (15) With centre N and radius NM draw an arc touching PNQ [sic] at R and S. Join RS. Let T be the point where RS and HI cut one another.';
    '  (16) With Centre T and radius TS draw a semi-circle on the upper portion of PNQ touching it at two points.';
    '  (17) With centre T and radius TM draw an arc on the upper portion of PNQ touching at two points.';
    '  (18) Eight equal and similar triangles of the moon are to be made in the space lying inside the semi-circle of No. (16) and outside the arc of No. (17) of this Schedule.';
    '(C) Method of making the Sun';
    '  (19) Bisect line AF at U and draw a line UV parallel to line AB touching line BE at V.';
    '  (20) With centre W, the point where HI and UV cut one another and radius MN draw a circle.';
    '  (21) With centre W and radius LN draw a circle';
    '  (22) Twelve equal and similar triangles of the sun are to be made in the space enclosed by the circles of No. (20) and of No. (21) with the two apexes of two triangles touching line HI.';
    '(D) Method of Making the Border.';
    '  (23) The width of the border will be equal to the width TN. This will be of deep blue colour and will be provided on all the sides of the flag. However, on the five angles of the flag the external angles will be equal to the internal angles.';
    '  (24) The above mentioned border will be provided if the flag is to be used with a rope. On the other hand, if it is to be hoisted on a pole, the hole on the border on the side AC can be extended according to requirements.';
    ' Explanation: The lines HI, RS, FE, ED, JG, OQ, JK and UV are imaginary. Similarly, the external and internal circles of the sun and the other arcs except the crescent moon are also imaginary. These are not shown on the flag.'
    };
end
