<!---
Title:       |  Flag of Nepal
Subtitle:    |  The most mathematical flag in the world
Project:     |  nepali_national_flag
Author:      Ashok Kumar Pant 
Affiliation: Tribhuvan University, Kathmandu 
Web:         http://ashokpant.github.io
Date:        September 20, 2015 
-->

## **National Flag of Nepal** (*The most mathematical flag in the world*)
The national flag of Nepal (Fig. 1) is the most mathematical and world's only non-quadrilateral flag. It consists of two juxtaposed triangular architecture with a white emblem of the crescent moon having eight rays visible out of sixteen in the upper triangle and a white emblem of a twelve-rayed sun in the lower triangle. The flag is bordered with a deep blue color representing the peace and harmony, and rectangles are filled with crimson red (the color of rhododendron- Nepal's national flower) representing the victory and bravery. The two triangles symbolized the Himalayan Mountains; the moon represents the serenity of the Nepalese people and the shade and cool weather in the Himalayas, while the sun stands for the fierce tenacity of the Nepalese people, and, the heat and higher temperatures of the lower parts of Nepal. The moon and the sun are also said to express the hope that the nation will endure as long as these heavenly bodies. This modern architecture of the flag was come into existence after December 16, 1962. Before that, the sun and the crescent moon had human faces.


## Prerequisites
* [MATLAB](http://www.mathworks.com/products/matlab/)
* [geom2d](http://www.mathworks.com/matlabcentral/fileexchange/7844-geom2d)


## Installation
	$ git clone https://github.com/ashokpant/flag-of-nepal.git
	$ cd flag-of-nepal
	Add *geom2d-2015.05.13* to matlab search path.

## Examples

### Flag of Nepal
	>> flagOfNepal();
	>> OR
	>> baseLength = 920;
	>> flagOfNepal(baseLength);
	>> OR
	>> baseLength = 920;
	>> drawingMode = 'fillcolor';
	>> flagOfNepal(baseLength,drawingMode)
![Fig.1 The national flag of Nepal.](https://github.com/ashokpant/flag-of-nepal/blob/master/images/flag_of_nepal.png)

### Skeleton of the flag
	>> baseLength = 920;
	>> drawingMode = 'skeleton';
	>> flagOfNepal(baseLength,drawingMode)
![Fig.2 Skeleton of the flag.](https://github.com/ashokpant/flag-of-nepal/blob/master/images/flag_of_nepal_skeleton.png)

### Flag with the landmarks
	>> baseLength = 920;
	>> drawingMode = 'landmarks';
	>> flagOfNepal(baseLength,drawingMode)
![Fig.3 Flag of Nepal with the landmarks.](https://github.com/ashokpant/flag-of-nepal/blob/master/images/flag_of_nepal_landmarks.png)

### Flag with all the imaganary drawings
	>> baseLength = 920;
	>> drawingMode = 'alldrawings';
	>> flagOfNepal(baseLength,drawingMode)
![Fig.4 Flag of Nepal with all the drawings.](https://github.com/ashokpant/flag-of-nepal/blob/master/images/flag_of_nepal_alldrawings.gif)

### Flag - step-by-step (animated)
	>> baseLength = 920;
	>> drawingMode = 'animate';
	>> flagOfNepal(baseLength,drawingMode)
![Fig.5 Flag of Nepal - step-by-step.](https://github.com/ashokpant/flag-of-nepal/blob/master/images/flag_of_nepal_alldrawings.gif)

## Flag drawing procedure
From the Constitution of Nepal, Schedule 1, Article 8, adopted on September 20, 2015 (Asoj 3, 2072).

### (A) Method of Making the Shape inside the Border
1. On the lower portion of a crimson cloth draw a line AB of the required length from left to right.
2. From A draw a line AC perpendicular to AB making AC equal to AB plus one third AB. From AC mark off D making line AD equal to line AB. Join BD.
3. From BD mark off E making BE equal to AB.
4. Touching E draw a line FG, starting from the point F on line AC, parallel to, AB to the right hand-side. Mark off FG equal to AB.
5. Join CG.
### (B) Method of Making the Moon
6. From AB mark off AH making AH equal to one-fourth of line AB and starting from H draw a line HI parallel to line AC touching line CG at point I.
7. Bisect CF at J and draw a line JK parallel to AB touching CG at point K.
8. Let L be the point where lines JK and HI cut one another.
9. Join JG.
10. Let M be the point where line JG and HI cut one another.
11. With centre M and with a distance shortest from M to BD mark off N on the lower portion of line HI.
12. Touching M and starting from O, a point on AC, draw a line from left to right parallel to AB.
13. With centre L and radius LN draw a semi-circle on the lower portion and let P and Q be the points where it touches the line OM respectively.
14. With centre M and radius MQ draw a semi-circle on the lower portion touching P and Q.
15. With centre N and radius NM draw an arc touching PNQ [sic] at R and S. Join RS. Let T be the point where RS and HI cut one another.
16. With Centre T and radius TS draw a semi-circle on the upper portion of PNQ touching it at two points.
17. With centre T and radius TM draw an arc on the upper portion of PNQ touching at two points.
18. Eight equal and similar triangles of the moon are to be made in the space lying inside the semi-circle of No. (16) and outside the arc of No. (17) of this Schedule.
### (C) Method of making the Sun
19. Bisect line AF at U and draw a line UV parallel to line AB touching line BE at V.
20. With centre W, the point where HI and UV cut one another and radius MN draw a circle.
21. With centre W and radius LN draw a circle
22. Twelve equal and similar triangles of the sun are to be made in the space enclosed by the circles of No. (20) and of No. (21) with the two apexes of two triangles touching line HI.
### (D) Method of Making the Border.
23. The width of the border will be equal to the width TN. This will be of deep blue colour and will be provided on all the sides of the flag. However, on the five angles of the flag the external angles will be equal to the internal angles.
24. The above mentioned border will be provided if the flag is to be used with a rope. On the other hand, if it is to be hoisted on a pole, the hole on the border on the side AC can be extended according to requirements.

[Explanation: The lines HI, RS, FE, ED, JG, OQ, JK and UV are imaginary. Similarly, the external and internal circles of the sun and the other arcs except the crescent moon are also imaginary. These are not shown on the flag.]


## References
1. http://www.servat.unibe.ch/icl/np01000_.html
2. http://en.wikipedia.org/wiki/Flag_of_Nepal
3. https://rossellacoletto.wordpress.com/2012/08/05/nepals-national-flag-secrets-when-geometry-and-math-make-unique-a-flag/
4. http://0xc.de/flags/nepal/
5. https://www.youtube.com/watch?v=f2Gne3UHKHs


--- Last Update : September 20, 2015
