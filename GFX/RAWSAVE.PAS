uses fgraphb;

Procedure SaveRAWFile(plik:string);
var pal:^Tpaleta;
    f:File;
    w,i:word;
    buf: array[0..320] of byte;
begin
     new(pal);
     assign(f,plik);
     reset(F,1);
     blockread(F,pal^,sizeof(tpaleta));
     setpal(pal^);
     for w:=0 to 319 do
      begin
           for i:=0 to 199 do buf[i]:=warstwy[1]^[w,i];
           blockwrite(f,buf,200);
      end;
     close(F);
     freemem(pal,sizeof(pal));
end;


begin
     initfgraph;
     loadgif('menu.gif',1);
     movebuf2screen2;
     saverawfile('menu.raw');
     readln;

     closefgraph;
end.