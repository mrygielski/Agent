Program SUPER_UNIWERSALNY_KONWERTER;{!!!!!!!!!!!!!!!!!!!!!!}

Uses Dos,FGraphB;


var d:SearchRec;
    p:TPaleta;
    ss:string;
    x,y,mx:integer;
    r,g,b,rgb:byte;
    resx,resy:integer;


Procedure ReadRes(plik:string);
var f:file;
    r:real;
    i:integer;
begin
     assign(f,plik);
     reset(f,1);
     blockread(f,r,6,i);
     blockread(f,resx,2,i);
     blockread(f,resy,2,i);
     close(f);
end;




Procedure SaveASGFXFile(plik:String);
var xx,yy:integer;
    F:File of byte;
    b:Byte;
begin
     assign(f,plik);
     rewrite(f);
     for xx:=0 to resx-1 do
     for yy:=0 to resy-1 do
      begin
       b:=getpixel(xx,yy,1);
       write(f,b);
      end;
     close(F);
end;
var i:byte;

begin
     InitFGraph;
     for i:= 254-32 to 254 do setcol(i,0,i * 4+18,0);
     for i:= 254-32 to 254-17 do setcol(i,i*4+15,0,0);
     setcol(255,0,63,63);
     setcol(254-17,176 div 4,96 div 4,64 div 4);
     loadpalfromfile('..\paleta.pal');
     setcol(255,0,63,63);
     getpal(p);
     newlayer;
     FindFirst('*.gif',archive,d);
     repeat
           filllayer(255,1);
           ss:=d.name;
           delete(ss,length(ss)-3,4);
           readres(ss+'.gif');
           loadgif(ss+'.gif',1);
           movebuf2screen;
           ekran2pal(0,0,resx-1,resy-1,p,1);
           setpal(p);
           for x:=0 to resx do for y:= 0 to resy do
           begin
            getcol(getpixel(x,y,1),r,g,b);
            rgb:=r+g+b;
            if rgb>160 then putpixel(x,y,31,1);
           end;

           movebuf2screen;
           saveasGFXfile(ss);
           movebuf2screen;
           findnext(d);
     until doserror<>0;
     CloseFGraph;
end.