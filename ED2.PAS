
uses fast13h, fxms, games;

const
     ileludkow = 5;
     ileitems = 10;
     max = ileludkow;
     lufy : array[1..ileludkow] of byte=(38,33,36,33,36);
     bronie : array[1..ileludkow] of byte=(1,1,2,3,1);
     shootspeed : array[1..ileludkow] of byte=(75,40,100,10,15);
     speed : array[1..ileludkow] of single=(0.3,0.35,0.2,0.5,0.5);

type
    TRyj = array[1..16,1..16] of byte;
    Tplatforma = array[1..50,1..45] of byte;
    Titem = Array[1..20,1..20] of byte;
    TMap = Array[0..300,1..4] of byte;
    TItems = Array[1..300,1..4] of byte;
    TKlatka = Array[0..29,0..39] of byte;
    TLudek = array[1..32] of TKlatka;
    TMonst = array[1..10] of TKlatka;
    TMonster = record
                numer : byte; {numer wygl•du potworka}
                X,Y : word; {numer platformy na kt¢rej znajduje si© potworek}
                krokx : shortint; {x potworka na platformie}
                rkrokx : single; {pomocnik}
                kierunek : shortint; {-1 = idzie w lewo  |  1 = idzie w prawo}
                klatka : single; {klatka animacji}
                speed : Single; {szybkosc poruszania sie}
                szybkostrzelnosc : byte; {wiadomo o co chodzi}
                strzal : word; {zmienna pomocnicza do szybkoòci strzelania}
                lufaY : byte; {wysokosc trzymanej lufy}
                sila:byte;
                zycie : integer;
                maxzycie : integer;
                bron : byte; {1-pistolet 2-bazooka 3-laser}
               end;
    Potwory = Array[1..100] of TMonster;
    Tsave = record
             mapa : Tmap;
             item : TItems;
             mons : Potwory;
             ilosc: byte;
            end;
    Tsave2 = record
             mapa : Tmap;
             item : TItems;
            end;

var
   map : ^Tmap;
   items : ^Titems;
   platforma : ^Tplatforma;
   ikony : Array[1..ileitems] of ^Titem;
   mon : Array[1..ileludkow] of word;
   Przeciwnik : Potwory;
   krokx : integer;
   mx, my : integer;
   font : ^Tfont;
   nritem : byte;
   Monster : ^TMonst;
   ilosc : byte;
   nazwy : array[1..ileludkow] of string[10];

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
procedure load_monster(nazwa:string;var mons:TMonst;numer:byte);
var f:file of Tmonst;
begin
     assign(f,'gfx\monsters\'+nazwa+'.dat');
     reset(f);
     read(f,mons);
     close(f);
     movetoxms(mon[numer],12000,mons);
end;

begin
     load_monster('soldier',monster^,1);
     load_monster('robak',monster^,2);
     load_monster('robak2',monster^,3);
     load_monster('robak3',monster^,4);
     load_monster('cyborg2',monster^,5);
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
     For i:=1 to ileludkow do Xgetmem(mon[i],sizeof(tmonst));
     new(monster);
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
     nazwy[1]:='ΩOùNIERZ';
     nazwy[2]:='robak 1';
     nazwy[3]:='robak 2';
     nazwy[4]:='CYBORG';
     nazwy[5]:='CYBORG 2';
end;

procedure done;
var i: integer;
begin
     close13h;
     setoldkeyint;
     For i:=1 to ileludkow do Xfreemem(mon[i]);
     for i:=1 to ileitems do dispose(ikony[i]);
     dispose(map);dispose(items);
     dispose(platforma);dispose(font);
     dispose(monster);
end;

procedure EDYTOR;

procedure set_map;
var i : integer;
begin
     for i:=0 to 300 do map^[i,1]:=0;
     for i:=0 to 300 do map^[i,2]:=0;
     for i:=0 to 300 do map^[i,3]:=0;
     for i:=0 to 300 do map^[i,4]:=0;
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
procedure draw_mon(x,y,kier:integer;kl:Tklatka);
var i, j : integer;
begin
     if (kier=-1) then
      begin
       for i:= 0 to 29 do
       for j:= 0 to 39 do if kl[i,j]<255 then putpixel((30-i)+x,j+y,kl[i,j])
      end else
      begin
       for i:= 0 to 29 do
       for j:= 0 to 39 do if kl[i,j]<255 then putpixel(i+x,j+y,kl[i,j])
      end
end;

Procedure Draw_Platforms(X:word);
var i,j,li,lj,ik:integer;
begin
     for i:=0 to 7 do
       for j:=0 to 3 do
         begin
          if map^[x+i,j+1]=1 then draw_platf(i*41,32+j*45);
          ik:=items^[x+i,j+1];
          if ik>0 then draw_item(i*41+15,15+j*45,ikony[ik]^)
         end;
end;

procedure minimapa;
var i, j : integer;
begin
     hlinefast(8,308,4-2,59);
     hlinefast(8,308,9-2,59);
     for i:= 0 to 300 do
     for j:= 1 to 4 do putpixel(8+i,2+j,(3*map^[i,j])+57);
     vline(8,4-2,9-2,59);
     vline(310-2,4-2,9-2,59);
     putpixel(krokx+8,3-2,6);
     putpixel(krokx+8,10-2,6)
end;

procedure draw_lines;
var i, j : integer;
begin
     for i:= 0 to 7 do
     for j:= 1 to 4 do
     begin
          line(i*41,45,i*41,199,57);
          line(0,j*45,319,j*45,57)
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
end;


Procedure Draw_Monsters;
var xx,yy,life,i:integer;
begin
     for i:=1 to ilosc do
      if (przeciwnik[i].x>=krokx-1)and(przeciwnik[i].x<=krokx+8) then
       begin
            getfromxms(mon[przeciwnik[i].numer],12000,monster^);
            yy:=przeciwnik[i].y-33;
            draw_mon(longmul(przeciwnik[i].x-krokx,41),yy,przeciwnik[i].kierunek,monster^[round(przeciwnik[i].klatka)]);
       end;
end;

Procedure Postaw(x,y:integer;rodzaj,numer:byte);
begin
     przeciwnik[numer].strzal:=0;
     przeciwnik[numer].x:=x;
     przeciwnik[numer].y:=y*45;
     przeciwnik[numer].numer:=rodzaj;
     przeciwnik[numer].rkrokx:=0;
     przeciwnik[numer].klatka:=1;
     przeciwnik[numer].kierunek:=-1;
     przeciwnik[numer].lufay:=lufy[rodzaj];
     przeciwnik[numer].bron:=bronie[rodzaj];
     przeciwnik[numer].szybkostrzelnosc:=shootspeed[rodzaj];
     przeciwnik[numer].speed:=speed[rodzaj];
     przeciwnik[numer].sila:=10;
     przeciwnik[numer].maxzycie:=50;
     przeciwnik[numer].zycie:=przeciwnik[numer].maxzycie;
end;

Function Sprawdz(x,y:integer):boolean;
var i:integer;
begin
     sprawdz:=false;
     for i:=1 to ilosc do
      if (przeciwnik[i].x=x)and(przeciwnik[i].y div 45 =y) then sprawdz:=true;
end;

Function Podaj(x,y:integer):byte;
var i:integer;
begin
     podaj:=0;
     for i:=1 to ilosc do
      if (przeciwnik[i].x=x)and(przeciwnik[i].y div 45 =y) then begin podaj:=i;break; end;
end;

procedure load(name : string);
var
   f : file of Tsave2;
   s : Tsave2;
begin
     if name='' then exit;
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
     outtextxyfnt(0,194,10,4,'LOAD MAP...',font^);
     outtextxyfnt(100,9,10,4,'Podaj nazw©:',font^);
     plik:=readstrfnt(150,9,12,10,58,0,4,font^);
     initnewkeyint;
     plik:='maps\'+plik;
     load(plik);
end;

procedure loadfi(name : string);
var
   f : file of Tsave;
   s : Tsave;
begin
     if name='' then exit;
     assign(f,name);
     {$i-}
     reset(f);
     read(f,s);
     close(f);
     {$i+}
     if ioresult<>0 then exit;
     ilosc:=s.ilosc;
     map^:=s.mapa;
     items^:=s.item;
     przeciwnik:=s.mons;
end;


procedure loadfile;
var plik:string;
begin
     setoldkeyint;
     outtextxyfnt(0,194,10,4,'LOAD ALL...',font^);
     outtextxyfnt(100,9,10,4,'Podaj nazw©:',font^);
     plik:=readstrfnt(150,9,12,10,58,0,4,font^);
     initnewkeyint;
     plik:='maps\'+plik;
     loadfi(plik);
end;
procedure save(name : string);
var
   f : file of Tsave;
   s : Tsave;
begin
     s.mapa:=map^;
     s.item:=items^;
     s.mons:=przeciwnik;
     s.ilosc:=ilosc;
     if name='' then exit;
     assign(f,name);
     rewrite(f);
     write(f,s);
     close(f)
end;


procedure savefile;
var plik:string;
begin
     setoldkeyint;
     outtextxyfnt(0,194,10,4,'SAVE ALL...',font^);
     outtextxyfnt(100,9,10,4,'Podaj nazw©:',font^);
     plik:=readstrfnt(150,9,12,10,58,0,4,font^);
     initnewkeyint;
     plik:='maps\'+plik;
     save(plik);
end;


Procedure Draw_info(nr:byte);
begin
     barfast(70,50,250,150,133);
     rectangle(70,50,250,150,135);
     outtextxyfnt(75,52,15,4,'STATYSTYKI PRZECIWNIKA NUMER '+num2str(nr)+
      ': '+nazwy[przeciwnik[nr].numer],font^);
     hlinefast(70,250,58,135);

     outtextxyfnt(75,80,15,4,'KIERUNEK: '+num2str(przeciwnik[nr].kierunek),font^);
     outtextxyfnt(75,90,15,4,'SZYBKOóè: '+real2str(przeciwnik[nr].speed,4),font^);
     outtextxyfnt(75,100,15,4,'SZYBKOSTRZELNOóè: '+num2str(przeciwnik[nr].szybkostrzelnosc),font^);
     outtextxyfnt(75,110,15,4,'SIùA: '+num2str(przeciwnik[nr].sila),font^);
     outtextxyfnt(75,120,15,4,'ΩYCIE: '+num2str(przeciwnik[nr].maxzycie),font^);
     rectangle(75,131,89,139,135);
     outtextxyfnt(79,133,15,4,'OK',font^);

     rectangle(220,80,230,86,135);
     rectangle(235,80,245,86,135);
     rectangle(220,90,230,96,135);
     rectangle(235,90,245,96,135);
     rectangle(220,100,230,106,135);
     rectangle(235,100,245,106,135);
     rectangle(220,110,230,116,135);
     rectangle(235,110,245,116,135);
     rectangle(220,120,230,126,135);
     rectangle(235,120,245,126,135);
     outtextxyfnt(224,81,15,4,'-',font^);
     outtextxyfnt(224,91,15,4,'-',font^);
     outtextxyfnt(224,101,15,4,'-',font^);
     outtextxyfnt(224,111,15,4,'-',font^);
     outtextxyfnt(224,121,15,4,'-',font^);
     outtextxyfnt(239,81,15,4,'+',font^);
     outtextxyfnt(239,91,15,4,'+',font^);
     outtextxyfnt(239,101,15,4,'+',font^);
     outtextxyfnt(239,111,15,4,'+',font^);
     outtextxyfnt(239,121,15,4,'+',font^);
end;

Procedure Info(nr:byte);
begin
     repeat
           mx:=mousex;my:=mousey;
           clearscreen(58);
           Draw_Platforms(krokx);
           Draw_Monsters;
           minimapa;
           draw_lines;
           draw_buttons;
           outtextxyfntrainbow(9,9,17,4,'('+num2str(nritem)+'/'+num2str(max)+'): '+nazwy[nritem],font^);
           outtextxyfntrainbow(9,15,17,4,'iloòÜ: '+num2str(ilosc),font^);
           Draw_Info(nr);
           cursor(10);
           movebuf2screen;

           if (mousein(220,80,230,86))and(button=1) then przeciwnik[nr].kierunek:=-1;
           if (mousein(235,80,245,86))and(button=1) then przeciwnik[nr].kierunek:=1;
           if (mousein(220,90,230,96))and(button=1)and(przeciwnik[nr].speed>0.1)  then
                                                   begin przeciwnik[nr].speed:=przeciwnik[nr].speed-0.1;delay(50); end;
           if (mousein(235,90,245,96))and(button=1) then begin przeciwnik[nr].speed:=przeciwnik[nr].speed+0.1;delay(50);end;
           if (mousein(220,100,230,106))and(button=1)and(przeciwnik[nr].szybkostrzelnosc>0) then
             begin przeciwnik[nr].szybkostrzelnosc:=przeciwnik[nr].szybkostrzelnosc-1;delay(30); end;
           if (mousein(235,100,245,106))and(button=1) then
             begin przeciwnik[nr].szybkostrzelnosc:=przeciwnik[nr].szybkostrzelnosc+1;delay(30); end;
           if (mousein(220,110,230,116))and(button=1)and(przeciwnik[nr].sila>0) then
             begin przeciwnik[nr].sila:=przeciwnik[nr].sila-5;delay(50); end;
           if (mousein(235,110,245,116))and(button=1) then
             begin przeciwnik[nr].sila:=przeciwnik[nr].sila+5;delay(50); end;
           if (mousein(220,120,230,126))and(button=1)and(przeciwnik[nr].maxzycie>0) then
             begin przeciwnik[nr].maxzycie:=przeciwnik[nr].maxzycie-5;delay(50); end;
           if (mousein(235,120,245,126))and(button=1) then
             begin przeciwnik[nr].maxzycie:=przeciwnik[nr].maxzycie+5;delay(50); end;
           przeciwnik[nr].zycie:=przeciwnik[nr].maxzycie;
     until (mousein(75,131,89,139))and(button=1);
     delay(100);
end;

{pocz•tek}
begin
     set_map;
     krokx:=1;
     nritem:=1;
     ilosc:=0;

     repeat
          mx:=mousex;my:=mousey;
          clearscreen(58);
          Draw_Platforms(krokx);
          Draw_Monsters;
          minimapa;
          draw_lines;

          draw_buttons;

          outtextxyfntrainbow(9,9,17,4,'('+num2str(nritem)+'/'+num2str(max)+'): '+nazwy[nritem],font^);
          outtextxyfntrainbow(9,15,17,4,'iloòÜ: '+num2str(ilosc),font^);

          cursor(10);

          movebuf2screen;

          if keydown[77] and (krokx<292) then begin krokx:=krokx+1;delay(30);end;
          if keydown[75] and (krokx>1) then begin krokx:=krokx-1; delay(30);end;
          if mousein(0,47,319,199) and (button=1)and(ilosc<100) then
          begin
            mx:=(mx div 41);
            my:=(my div 45);
            if my>1 then
            if sprawdz(mx+krokx,my)=false then {jeòli nie ma potowrka to stawiamy!}
             begin
              ilosc:=ilosc+1;
              Postaw(mx+krokx,my,nritem,ilosc);
              delay(100);
             end else Info(podaj(mx+krokx,my));
          end;
          if mousein(0,47,319,199) and (button=2) then
          begin
            mx:=(mx div 41);
            my:=(my div 45);
            if ilosc>0 then
            if podaj(mx+krokx,my)>0 then {jeòli jest jakiò to kasujemy!}
             begin
                  przeciwnik[podaj(mx+krokx,my)]:=przeciwnik[ilosc];
                  ilosc:=ilosc-1;
             end;
          end;
          if mousein(285,9,295,13)and(button=1) then if nritem>1 then
          begin
           dec(nritem);delay(80)
          end;
          if mousein(299,9,309,13)and(button=1) then if nritem<max then
          begin
           inc(nritem);delay(80)
          end;
          if keydown[f1scan] then loadmap;
          if keydown[f2scan] then savefile;
          if keydown[f3scan] then loadfile;
     until keydown[1];
end;

begin
     init;

{!!!}edytor;{!!!}

     done
end.