function f = distancedifference(XorY)
%does distance travelled in one dimension (x or y)

v1 = [XorY, 0];
v2 = [0, XorY];

v3 = v2 - v1;
v3 = v3(2:end-1);
f = abs(v3);
