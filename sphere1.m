function sphere1(X,Y,Z,R)
[x,y,z]=sphere(20);
%surf(x,y,z);
%hold on
x0=X+R*x;
y0=Y+R*y;
z0=Z+R*z;
h = surf(x0,y0,z0,'FaceColor','yellow','EdgeColor','blue');
end