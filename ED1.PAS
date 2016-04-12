
uses fast13h, fxms, games;

const
     ileitems = 10;
     max = ileitems+1;

type
    TMap = Array[0..300,1..4] of byte;
    TItems = Array[1..300,1..4] of byte;
    Tplatforma = array[1..50,1..45] of byte;
    Titem = Array[1..20,1..20] of byte;
    Tsave = record
             mapa : Tmap;
             item : Titems;
            end;

var
   map : ^Tmap;
   items : ^Titems;
   platforma : ^Tplatforma;
   ikony : Array[1..ileitems] of ^Titem;
   krokx : integer;
   mx, my : integer;
   font : ^Tfont;
   nazwa : array[1..max] of string;
   nritem : byte;
   kasuj : array[1..3] of boolean;

procedure load_to_mem;

procedure load_platforma(plik : string);
var xx,yy:integer;
    f:file of byte;
    b:byte;
begin
     assign(f,plik);
     reset(f);
     for xx:=0 to 50-1 do
     for yy:=0 to 45-1 do
      begin
           read(f,b);
           platforma^[xx+1,yy+1]:=b
      end;
     close(F);
     for xx:=0 to 50-1 do platforma^[xx+1,18]:=254;
     for xx:=0 to 50-1 do if random(3)=1 then platforma^[xx+1,18]:=253;
     for xx:=0 to 50-1 do platforma^[xx+1,17]:=254;
     for xx:=0 to 50-1 do if random(3)=1 then platforma^[xx+1,17]:=253
end;
procedure load_item(plik : string;var item:titem);
var xx,yy:integer;
    f:file of byte;
    b:byte;
begin
     assign(f,plik);
     reset(f);
     for xx:=0 to 20-1 do
     for yy:=0 to 20-1 do
      begin
           read(f,b);
           item[xx+1,yy+1]:=b
      end;
     close(F)
end;

begin
     load_platforma('gfx\platforma');
     load_item('gfx\health',ikony[1]^);
     load_item('gfx\exit',ikony[2]^);
     load_item('gfx\magnum',ikony[3]^);
     load_item('gfx\uzi',ikony[4]^);
     load_item('gfx\kasa',ikony[5]^);
     load_item('gfx\armor',ikony[6]^);
     load_item('gfx\quad',ikony[7]^);
     load_item('gfx\ammo20',ikony[8]^);
     load_item('gfx\life',ikony[9]^);
     load_item('gfx\kapcie',ikony[10]^);
end;

procedure init;
var i : integer;
begin
     new(map);new(items);
     new(platforma);new(font);
     for i:=1 to ileitems do new(ikony[i]);
     loadfont('data/licznik.fn2',font^);
     load_to_mem;
     initnewkeyint;
     init13h;
     loadpalfromfile('paleta.pal');
     setcol(254,0,30,0);
     setcol(253,0,35,10);

     nazwa[1]:='PLATFORMA';
     nazwa[2]:='½YCIE';
     nazwa[3]:='KONIEC LEVELU';
     nazwa[4]:='MAGNUM';
     nazwa[5]:='UZI';
     nazwa[6]:='KASA';
     nazwa[7]:='ARMOR';
     nazwa[8]:='QUAD';
     nazwa[9]:='AMUNICJA';
     nazwa[10]:='LIFE';
     nazwa[11]:='BUTY';
end;

procedure done;
var i: integer;
begin
     close13h;
     setoldkeyint;
     for i:=1 to ileitems do dispose(ikony[i]);
     dispose(map);dispose(items);
     dispose(platforma);dispose(font);
end;

procedure EDYTOR;

procedure set_map;
var i : integer;
begin
     for i:=0 to 300 do map^[i,1]:=0;
     for i:=0 to 300 do map^[i,2]:=0;
     for i:=0 to 300 do map^[i,3]:=0;
     for i:=0 to 300 do map^[i,4]:=0;
{     for i:=0 to 300 do if random(4)=1 then map^[i,1]:=1;
     for i:=0 to 300 do if random(4)=1 then map^[i,2]:=1;
     for i:=0 to 300 do if random(4)=1 then map^[i,3]:=1;
     for i:=0 to 300 do if random(4)=1 then map^[i,4]:=1;}
     for i:=1 to 300 do items^[i,1]:=0;
     for i:=1 to 300 do items^[i,2]:=0;
     for i:=1 to 300 do items^[i,3]:=0;
     for i:=1 to 300 do items^[i,4]:=0;
end;

procedure draw_platf(x,y:integer);
var xx,yy:integer;
begin
     for xx:=0 to 49 do
     for yy:=0 to 44 do if platforma^[xx+1,yy+1]<255 then putpixel(xx+x,yy+y,platforma^[xx+1,yy+1])
end;
procedure draw_item(x,y:integer;item:Titem);
var xx,yy:integer;
begin
     for xx:=1 to 20 do
     for yy:=1 to 20 do if item[xx,yy]<255 then putpixel(xx+x,yy+y,item[xx,yy])
end;

Procedure Draw_Platforms(X:word);
var i,j,li,lj,ik:integer;
begin
     for i:=0 to 7 do
       for j:=0 to 3 do
        begin
          if map^[x+i,j+1]=1 then draw_platf(i*41,32+j*41);
          ik:=items^[x+i,j+1];
          if ik>0 then draw_item(i*41+15,15+j*41,ikony[ik]^)
        end
end;

procedure minimapa;
var i, j : integer;
begin
     hlinefast(8,308,4-2,59);
     hlinefast(8,308,9-2,59);
     for i:= 0 to 300 do
     for j:= 1 to 4 do putpixel(8+i,2+j,(map^[i,j]*3)+57);
     vline(8,4-2,9-2,59);
     vline(308,4-2,9-2,59);
     putpixel(krokx+8,3-2,6);
     putpixel(krokx+8,10-2,6)
end;

procedure draw_lines;
var i, j : integer;
begin
     line(0,15,319,15,57);
     for i:= 0 to 7 do
     for j:= 1 to 4 do
     begin
          line(i*41,15,i*41,199,57);
          line(0,j*41,319,j*41,57)
     end
end;

procedure cursor(c : byte);
begin
     putpixel(mx,my,c);
     putpixel(mx+1,my+1,c);
     putpixel(mx+1,my,c);
     putpixel(mx+2,my,c);
     putpixel(mx,my+1,c);
     putpixel(mx,my+2,c)
end;

procedure draw_buttons;
begin
     line(280+5,9,290+5,9,57);
     line(280+5,13,290+5,13,57);
     line(280+5,9,280+5,13,57);
     line(290+5,9,290+5,13,57);
     line(282+5,11,288+5,11,17);
     line(280+19,9,290+19,9,57);
     line(280+19,13,290+19,13,57);
     line(280+19,9,280+19,13,57);
     line(290+19,9,290+19,13,57);
     line(282+19,11,288+19,11,17);
     line(285+19,10,285+19,12,17);
     line(271,9,281,9,57);
     line(271,13,281,13,57);
     line(271,9,271,13,57);
     line(281,9,281,13,57);
     line(271-10,9,281-10,9,57);
     line(271-10,13,281-10,13,57);
     line(271-10,9,271-10,13,57);
     line(281-10,9,281-10,13,57);
     if kasuj[3] then
     begin
      outtextxyfntrainbow(195,9,17,4,'KASUJ PRATFORMY',font^);
      line(271,9,281,13,57);
      line(271,13,281,9,57)
     end;
     if kasuj[2] then
     begin
      outtextxyfntrainbow(191,9,17,4,'KASUJ PRZEDMIOTY',font^);
      line(271-10,9,281-10,13,57);
      line(271-10,13,281-10,9,57)
     end;
end;

procedure save(name : string);
var
   f : file of Tsave;
   s : Tsave;
begin
     s.mapa:=map^;
     s.item:=items^;
     assign(f,name);
     rewrite(f);
     write(f,s);
     close(f)
end;

procedure load(name : string);
var
   f : file of Tsave;
   s : Tsave;
begin
     assign(f,name);
     {$i-}
     reset(f);
     read(f,s);
     close(f);
     {$i+}
     if ioresult<>0 then exit;
     map^:=s.mapa;
     items^:=s.item;
end;

procedure loadmap;
var plik:string;
begin
     setoldkeyint;
     outtextxyfnt(100,9,10,4,'Podaj nazw©:',font^);
     plik:=readstrfnt(150,9,12,10,58,0,4,font^);
     initnewkeyint;
     plik:='maps\'+plik;
     load(plik);
end;

procedure savemap;
var plik:string;
begin
     setoldkeyint;
     outtextxyfnt(100,9,10,4,'Podaj nazw©:',font^);
     plik:=readstrfnt(150,9,12,10,58,0,4,font^);
     initnewkeyint;
     plik:='maps\'+plik;
     save(plik);
end;

begin
     set_map;
     krokx:=1;
     nritem:=1;
     kasuj[3]:=true;
     repeat
          mx:=mousex;my:=mousey;
          clearscreen(58);
          Draw_Platforms(krokx);
          minimapa;
          draw_lines;

          draw_buttons;

          outtextxyfntrainbow(9,9,17,4,'('+num2str(nritem)+
                    '/'+num2str(max)+'):'+nazwa[nritem],font^);

          cursor(10);

          movebuf2screen;
          if keydown[77] and (krokx<293) then begin krokx:=krokx+1;delay(20);end;
          if keydown[75] and (krokx>1) then begin krokx:=krokx-1; delay(20);end;
          if mousein(0,47,319,199) and (button=1) then
          begin
            mx:=(mx div 41);
            my:=(my div 41);
            if nritem=1 then map^[mx+krokx,my]:=1;
            if nritem in[2..max] then items^[mx+krokx,my]:=nritem-1;
          end;
          if mousein(0,47,319,199) and (button=2) then
          begin
            mx:=(mx div 41);
            my:=(my div 41);
            if kasuj[3] then map^[mx+krokx,my]:=0;
            if kasuj[2] then items^[mx+krokx,my]:=0;
          end;
          if mousein(285,9,295,13)and(button=1) then if nritem>1 then
          begin
           dec(nritem);delay(80)
          end;
          if mousein(299,9,309,13)and(button=1) then if nritem<max then
          begin
           inc(nritem);delay(80)
          end;
          if mousein(271+1,9,281+1,13)and(button=1)then
          begin
           delay(150);
           kasuj[3]:=true;kasuj[1]:=false;kasuj[2]:=false
          end;
          if mousein(271-11,9,281-11,13)and(button=1)then
          begin
           delay(150);
           kasuj[2]:=true;kasuj[3]:=false;kasuj[1]:=false
          end;
          if keydown[f2scan] then savemap;
          if keydown[f3scan] then loadmap;
     until keydown[1];
end;

begin
     init;

{!!!}edytor;{!!!}

     done
end.