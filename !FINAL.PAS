{ KLATKI PRZECIWNIK‡W

1-7 chodzenie
8  trup
9 dostal
10 strzela

}

Uses fast13h, games, FXms, SMix;

Const
     klatek_animacji = 32;
     potworow = 5;
     ikonek = 10;
     sounds = 10;
     dzwieki : array[1..3] of byte=(3,1,5);
     kody : Array[1..7] of string[5]=('12345',
                                      '98765',
                                      '32514',
                                      '82645',
                                      '78963',
                                      '35214',
                                      '79465');

type
    TRyj = array[1..16,1..16] of byte;
    Tplatforma = array[1..50,1..45] of byte;
    Titem = Array[1..20,1..20] of byte;
    TMap = Array[0..300,1..4] of byte;
    TItems = Array[1..300,1..4] of byte;
    TKlatka = Array[0..29,0..39] of byte;
    TLudek = array[1..klatek_animacji] of TKlatka;
    TMonst = array[1..10] of TKlatka;
    TGracz = record
              imie : String[30];
              Y: integer;  {wysokosc gracza w pixelach}
              klatka : single; {numer klatki animacji po zaokr•gleniu}
              anim : byte; {numer animacji:  1-chodzenie 2-oberwaà 3-skacze 4-strzela 5-trup}
              stoi : boolean; {czy ma grunt pod nogami czyli stoi na platformie}
              skok : word; {taki licznik skoku}
              skacze: boolean; {czy jest w trakcie lotu}
              do_tylu : boolean; {czy idzie do tylu}
              szybkostrzelnosc : byte; {wiadomo o co chodzi}
              strzal : byte; {zmienna pomocnicza do szybkoòci strzelania}
              zyje : boolean;
              wys_skoku : byte;
              sila : byte;
              zycie : integer;
              maxzycie : integer;
              zyc : byte; {ilosc zyc}
              maxmagazynek : byte; {ile nabojowsie mieòci w magazynku}
              magazynek : byte; {ile jest nabojow w magazynku}
              ammo : word; {ile jest nabojow}
              dz_trup:boolean;
              death : word; {zmienna pomocnicza}
              points : longint; {ilosc punktow}
             end;
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
    TPocisk = record
               x:real;
               y:word;
               wx:single;{wektor przesuni©cia}
               leci:boolean;
               damage : byte;
               typ : byte; {1-naboje 2-bazooka 3-laser}
              end;
    TKrew =   record
               x:word;
               y:single;
               leci:boolean;
               kolor:byte;
              end;
    Potwory = Array[1..100] of TMonster;

var
   Sound : Array[1..sounds] of PSound;
   platforma : ^Tplatforma;

   ikony: Array[1..ikonek] of ^Titem;

   mon : Array[1..potworow] of word;

   Pocisk : Array[1..100] of Tpocisk;
   Krew : Array[1..100] of TKrew;

   tlo:^TScreen;

   Map : ^TMap;
   items : ^Titems;
   Ludek : ^Tludek;
   Monster : ^TMonst;
   Ryj : ^TRyj;
   Ammo : ^TRyj;
   FPS : Word;
   FPSC : FpsCounter;
   a,x,krokx:integer;
   gracz : TGracz;
   Przeciwnik : Potwory;
   i: integer;
   game_speed : byte;
   anim_speed : single;

   Licznik: ^TFont;
   Small: ^TFont;

   koniec,endlevel:boolean;

   przeciwnikow : byte;
   r,g,b:byte;

   szybkosc_gry,ilosc_krwi,glupota : byte;
   level_poczatkowy : byte;


Function GAME(mapa:string;ai,blood,level,speed:byte): boolean;

procedure przekaz_gfx(plik : string);
var
   xx,yy,a : integer;
   f : file;
   b : array[0..319] of byte;
begin
     assign(f,plik);
     reset(f,1);
     for xx:=0 to 319 do
     begin
          blockread(f,b,200,i);
          for yy:=0 to 199 do tlo^[yy,xx]:=b[yy];
     end;
     close(f);
end;

procedure load_ludek;
var f:file of Tludek;
begin
     assign(f,'gfx\ludek\animacje.dat');
     reset(f);
     read(f,ludek^);
     close(f);
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
           platforma^[xx+1,yy+1]:=b;
      end;
     close(F);
     for xx:=0 to 50-1 do platforma^[xx+1,18]:=254;
     for xx:=0 to 50-1 do if random(3)=1 then platforma^[xx+1,18]:=253;
     for xx:=0 to 50-1 do platforma^[xx+1,17]:=254;
     for xx:=0 to 50-1 do if random(3)=1 then platforma^[xx+1,17]:=253;
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
           item[xx+1,yy+1]:=b;
      end;
     close(F);
end;

procedure load_ryj(plik : string;var r:TRyj);
var xx,yy:integer;
    f:file of byte;
    b:byte;
begin
     assign(f,plik);
     reset(f);
     for xx:=0 to 16-1 do
     for yy:=0 to 16-1 do
      begin
           read(f,b);
           r[xx+1,yy+1]:=b;
      end;
     close(F);
end;

procedure loadmapfile(name : string);
type Tsave = record
              mapa : Tmap;
              item : TItems;
              mons : Potwory;
              ilosc: byte;
             end;
var
   f : file of Tsave;
   s : Tsave;
begin
     assign(f,'maps\'+name);
     {$i-}
     reset(f);
     read(f,s);
     close(f);
     {$i+}
     if ioresult<>0 then exit;
     przeciwnikow:=s.ilosc;
     map^:=s.mapa;
     items^:=s.item;
     przeciwnik:=s.mons;
end;


procedure draw_item(x,y:integer;item:Titem);
var xx,yy:integer;
begin
     for xx:=1 to 20 do
     for yy:=1 to 20 do if item[xx,yy]<255 then putpixel(xx+x,yy+y,item[xx,yy])
end;
procedure draw_platf(x,y:integer);
var xx,yy:integer;
begin
     for xx:=0 to 49 do
     for yy:=0 to 44 do if platforma^[xx+1,yy+1]<255 then putpixel(xx+x,yy+y,platforma^[xx+1,yy+1])
end;
procedure draw_ludek(x,y,nr:integer);
var i, j : integer;
begin
     if (gracz.do_tylu) then
      begin
       for i:= 0 to 29 do
       for j:= 0 to 39 do if ludek^[nr,i,j]<255 then putpixel((30-i)+x,j+y,ludek^[nr,i,j])
      end else
      begin
       for i:= 0 to 29 do
       for j:= 0 to 39 do if ludek^[nr,i,j]<255 then putpixel(i+x,j+y,ludek^[nr,i,j])
      end
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


procedure init;
begin
     For i:=1 to potworow do Xgetmem(mon[i],sizeof(tmonst));
     new(tlo);
     new(ryj);
     new(ammo);
     new(platforma);
     new(items);
     new(map);
     new(ludek);
     new(monster);
     for i:=1 to ikonek do new(ikony[i]);
     {loading}
     load_ryj('gfx\ryj',ryj^);
     load_ryj('gfx\ammo',ammo^);
     load_ludek;
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
     load_monster('soldier',monster^,1);
     load_monster('robak',monster^,2);
     load_monster('robak2',monster^,3);
     load_monster('robak3',monster^,4);
     load_monster('cyborg2',monster^,5);
     przekaz_gfx('gfx\tla\tlo4');
     loadfont('data\licznik.fn2',licznik^);
     loadfont('data\small.fn2',small^);

     initnewkeyint;
     randomize;
     loadpalfromfile('paleta.pal');
     getcol(platforma^[5,16],r,g,b);setcol(254,r,g,b);
     getcol(platforma^[10,16],r,g,b);setcol(253,r,g,b);
     loadmapfile(mapa);
end;

procedure close__;
begin
     setoldkeyint;
     dispose(ammo);
     dispose(platforma);
     dispose(map);
     dispose(items);
     dispose(ludek);
     dispose(monster);
     dispose(tlo);
     dispose(ryj);
     For i:=1 to potworow do Xfreemem(mon[i]);
     for i:=1 to ikonek do dispose(ikony[i]);
end;

Procedure Draw_Platforms(X:word);
var i,j,li,lj,ik:integer;
begin
     for i:=-1 to 8 do
       for j:=0 to 3 do
        begin
         li:=longmul(i,41)-krokx;
         lj:=longmul(j,45)+5;
         if map^[x+i,j+1]=1 then draw_platf(li,lj+15);
         ik:=items^[x+i,j+1];
         if ik>0 then draw_item(li+15,lj,ikony[ik]^)
        end
end;

Procedure Draw_Monsters;
var xx,yy,life:integer;
begin
     for i:=1 to przeciwnikow do
      if (przeciwnik[i].x>=x-1)and(przeciwnik[i].x<=x+8) then
       begin
            getfromxms(mon[przeciwnik[i].numer],12000,monster^);
            xx:=longmul(przeciwnik[i].x-x,41)+5+przeciwnik[i].krokx-krokx;
            yy:=przeciwnik[i].y;
            draw_mon(xx,yy-48,przeciwnik[i].kierunek,monster^[round(przeciwnik[i].klatka)]);
            if przeciwnik[i].zycie>0 then begin
             life:=longdiv(longmul((przeciwnik[i].zycie),100),przeciwnik[i].maxzycie);
             life:=round(life / 3.33);
             rectangle(xx-1,yy-52,xx+31,yy-50,15);
             hlinefast(xx,xx+life,yy-51,71);
            end;
       end;
end;

Procedure Wez_ikonke(nr:byte);
begin
     startsound(sound[7],7,false);
     if nr=1 then {zdrowie} if gracz.zycie<gracz.maxzycie then
      begin
           gracz.zycie:=gracz.zycie+(gracz.maxzycie shr 2);
           if gracz.zycie>gracz.maxzycie then gracz.zycie:=gracz.maxzycie;
      end;
     if nr=2 then {koniec planszy}
      begin
           endlevel:=true;
      end;
     if nr=3 then {magnum}
      if gracz.szybkostrzelnosc=50 then
      begin
           gracz.szybkostrzelnosc:=25;
           gracz.maxmagazynek:=16;
           gracz.magazynek:=gracz.maxmagazynek;
      end;
     if nr=4 then {uzi}
      if gracz.szybkostrzelnosc>5 then
      begin
           gracz.maxmagazynek:=32;
           gracz.szybkostrzelnosc:=5;
           gracz.magazynek:=gracz.maxmagazynek;
      end;
     if nr=5 then {kasa}
      begin
           inc(gracz.points,100);
      end;
     if nr=6 then {armour}
      begin
           gracz.zycie:=gracz.zycie+gracz.maxzycie;
      end;
     if nr=7 then {siàa}
      begin
           gracz.sila:=gracz.sila*2;
      end;
     if nr=8 then {ammo}
      begin
           gracz.ammo:=gracz.ammo+gracz.maxmagazynek;
      end;
     if nr=9 then {life}
      begin
           gracz.zyc:=gracz.zyc+1;
      end;
     if nr=10 then {dæumper}
      begin
           gracz.wys_skoku:=50;
      end;
end;


Procedure Zbieranie_ikonek;
begin
     if (items^[x+4,1]>0)and(gracz.y+40<30+10)and(gracz.y+40>5+10)and(krokx>=15)
     then begin wez_ikonke(items^[x+4,1]);items^[x+4,1]:=0; end;
     if (items^[x+4,2]>0)and(gracz.y+40<75+10)and(gracz.y+40>50+10)and(krokx>=15)
     then begin wez_ikonke(items^[x+4,2]);items^[x+4,2]:=0; end;
     if (items^[x+4,3]>0)and(gracz.y+40<120+10)and(gracz.y+40>95+10)and(krokx>=15)
     then begin wez_ikonke(items^[x+4,3]);items^[x+4,3]:=0; end;
     if (items^[x+4,4]>0)and(gracz.y+40<165+10)and(gracz.y+40>140+10)and(krokx>=15)
     then begin wez_ikonke(items^[x+4,4]);items^[x+4,4]:=0; end;
end;

Procedure Animacja_Smierci(var kl:Tklatka);
var x,y:integer;
begin
      for x:=0 to 29 do
      for y:=39 downto 1 do
       begin
        if kl[x,y]=255 then
         begin
          kl[x,y]:=kl[x,y-1];
          kl[x,y-1]:=255
         end else
        if random(2)=1 then begin
        if kl[x-1,y]=255 then
         begin
          kl[x-1,y]:=kl[x,y-1];
          kl[x,y-1]:=255
         end end else
        if kl[x+1,y]=255 then
         begin
          kl[x+1,y]:=kl[x,y-1];
          kl[x,y-1]:=255
         end
       end;
      gracz.klatka:=1;
end;

Procedure Animacja_Dostal;
begin
     if (gracz.zyje)and(gracz.anim in[0,1,4]) then {wtedy gdy oberwie}
      begin gracz.klatka:=12;gracz.anim:=2;end;
end;

Procedure Shoot(x,y:integer;kier:single;sila,typ,dzwiek:byte);
var ii:integer;
begin
     for ii:=1 to 100 do
      if pocisk[ii].leci=false then break;
     startsound(sound[dzwiek],dzwiek,false);
     pocisk[ii].x:=x;
     pocisk[ii].y:=y;
     pocisk[ii].wx:=kier*3;
     pocisk[ii].leci:=true;
     pocisk[ii].damage:=sila;
     pocisk[ii].typ:=typ;
end;

Procedure DodajKrew(x,y:integer;kolor:byte);
var ii:integer;
begin
     for ii:=1 to 100 do
      if krew[ii].leci=false then break;
     krew[ii].x:=x;
     krew[ii].y:=y;
     krew[ii].leci:=true;
     krew[ii].kolor:=kolor;
end;

Procedure Animacje_gracza;
var aa:byte;
begin
           if (gracz.anim=1) then {chodzenie}
            begin
             gracz.klatka:=gracz.klatka+anim_speed;
             if gracz.klatka>12 then gracz.klatka:=1;
            end;

           if (gracz.anim=2) then {gracz oberwaà}
            begin
             gracz.klatka:=gracz.klatka+anim_speed;
             if gracz.klatka>16 then gracz.anim:=0;
            end;

           if (gracz.anim=3) then {gracz skacze}
            begin
             gracz.klatka:=gracz.klatka+anim_speed;
             if (gracz.skok<gracz.wys_skoku) then gracz.skok:=gracz.skok+1;
             if gracz.skok=gracz.wys_skoku then begin gracz.skacze:=false;gracz.anim:=0;gracz.skok:=0; end;
             if gracz.klatka>22 then gracz.klatka:=22;
            end;

           if (gracz.anim=4) then {gracz strzela}
            begin
             gracz.klatka:=gracz.klatka+anim_speed;
             if keydown[scanof('d')] and (gracz.klatka>25)and(gracz.strzal=0) then gracz.klatka:=26;
             if (gracz.klatka>32) then gracz.anim:=0;
             if (gracz.klatka>=26)and(gracz.klatka<26+(anim_speed*2)) then
               if gracz.strzal=0 then if gracz.magazynek>0 then
                begin
               if gracz.do_tylu then begin Shoot(150,gracz.y+9,-1,gracz.sila,1,3);
                                           gracz.strzal:=gracz.szybkostrzelnosc; end
                                else begin Shoot(170,gracz.y+9,1,gracz.sila,1,3);
                                           gracz.strzal:=gracz.szybkostrzelnosc; end;
                dec(gracz.magazynek);
                end else
                 begin
                  {DZWIEK MAGAZYNKA}
                  if gracz.ammo>=gracz.maxmagazynek then
                   begin
                    gracz.magazynek:=gracz.maxmagazynek;
                    gracz.ammo:=gracz.ammo-gracz.maxmagazynek;
                   end else
                   begin
                    gracz.magazynek:=gracz.ammo;
                    gracz.ammo:=0;
                   end;
                 end;
            end;

      if (gracz.anim=0)and(gracz.klatka<>1)and
         (gracz.stoi) then gracz.klatka:=1;
      if (gracz.anim=0)and(not gracz.stoi) then gracz.klatka:=22;
      if gracz.zyje then gracz.dz_trup:=false;
      if gracz.zyje=false then begin Animacja_smierci(ludek^[1]);
        if gracz.dz_trup=false then startsound(sound[2],2,false);gracz.dz_trup:=true; end;
end;

Procedure Fizyka_gracza;
var bl:byte;
begin
     gracz.stoi:=false;
     if (not (getpixel(157,gracz.y+40) in[253..254])) and
        (not (getpixel(163,gracz.y+40) in[253..254])) and
        (gracz.anim<>3) then gracz.y:=gracz.y+2 else
         if gracz.skok=0 then gracz.stoi:=true;
     if gracz.skacze then gracz.y:=gracz.y-2;
     if gracz.y>170 then
      begin
       gracz.y:=-550;{DEATH}
       startsound(sound[6],6,false);
      end;
     if (gracz.y=-100)then
     if (gracz.zyc>0) then
      begin
       gracz.y:=-10;
       gracz.zyc:=gracz.zyc-1;
      end else koniec:=true;
     if gracz.strzal>0 then dec(gracz.strzal);
     for i:=1 to 100 do
      if pocisk[i].leci then
      if (round(pocisk[i].x)>150)and(round(pocisk[i].x)<170)and(pocisk[i].y>gracz.y)and(pocisk[i].y<gracz.y+30)and
         (gracz.zycie>0)
       then
        begin
         gracz.zycie:=gracz.zycie-pocisk[i].damage;
         startsound(sound[9],9,false);
         Animacja_dostal;
         pocisk[i].leci:=false;
         for bl:=1 to blood do
          dodajkrew(155+random(10),gracz.y+random(blood shr 2),133+random(5));
        end;
      if gracz.death>0 then dec(gracz.death);
      if (gracz.death=0)and(gracz.zyje=false)and(gracz.zyc>0) then
       begin
        gracz.zyje:=true;
        load_ludek;
        gracz.anim:=1;
        gracz.zycie:=gracz.maxzycie;
        gracz.zyc:=gracz.zyc-1;
       end;
      if (gracz.zycie<=0) and (gracz.klatka=1) and (gracz.death=0) then
       begin
        gracz.zyje:=false;
        gracz.anim:=5;
        gracz.death:=200;
       end;
      if keydown[80] and ((getpixel(157,gracz.y+40) in[253..254]) or
        (getpixel(163,gracz.y+40) in[253..254])) and (gracz.zyje) then gracz.y:=gracz.y+1;
      if (gracz.zyc<=0)and(gracz.zyje=false)then Koniec:=true;
end;

Procedure SetGameSpeed(speed:word);
begin
     game_speed:=speed;
     anim_speed:=0.2;
end;

Procedure Show_Pociski;
var r:integer;
begin
     for i:=1 to 100 do if pocisk[i].leci then
      case pocisk[i].typ of
       1 : putpixel(round(pocisk[i].x),pocisk[i].y,255);
       2 : if pocisk[i].wx<0 then begin
            r:=round(pocisk[i].x);
            hlinefast(r-1,r+3,pocisk[i].y,235);
            hlinefast(r,r+3,pocisk[i].y-1,232);
            hlinefast(r,r+3,pocisk[i].y+1,232);
            vline(r+4,pocisk[i].y-1,pocisk[i].y+1,40);
           end else begin
            r:=round(pocisk[i].x);
            hlinefast(r,r+4,pocisk[i].y,235);
            hlinefast(r,r+3,pocisk[i].y-1,232);
            hlinefast(r,r+3,pocisk[i].y+1,232);
            vline(r,pocisk[i].y-1,pocisk[i].y+1,40);
           end;
       3 : begin
            r:=round(pocisk[i].x);
            hlinefast(r,r+3,pocisk[i].y,255);
           end;
      end;
end;

Procedure Show_Krew;
var r:integer;
begin
     for i:=1 to 100 do if krew[i].leci then
      putpixel(krew[i].x,round(krew[i].y),krew[i].kolor)
end;

Procedure Show_Zycie;
var pr:integer;
    s:string[5];
begin
     rectangle(110,4,211,10,15);
     pr:=longdiv(longmul(gracz.zycie,100),gracz.maxzycie);
     s:=num2str(pr)+'%';
     if pr>100 then pr:=100;
     if pr<0 then pr:=0;
     if gracz.zycie>0 then barfast(111,5,111+pr-1,9,71);
     outtextxyfnt(160-((length(s)shl 2)shr 1),5,3,4,s,licznik^);
end;

Procedure Show_Status;
var x,y:byte;
begin
     for x:=1 to 16 do for y:=1 to 16 do if ryj^[x,y]<255 then putpixel(x+5,y+10,ryj^[x,y]);
     outtextxyfnt(27,11,14,6,'x '+num2str(gracz.zyc),small^);

     for x:=1 to 16 do for y:=1 to 16 do if ammo^[x,y]<255 then putpixel(x+5,y+30,ammo^[x,y]);
     outtextxyfnt(27,31,14,6,'x '+num2str(gracz.magazynek),small^);

     outtextxyfnt(10,55,14,4,'AMMO: '+num2str(gracz.ammo),licznik^);

     outtextxyfnt(10,62,14,4,'POINTS: '+num2str(gracz.points),licznik^);

     outtextxyfnt(0,195,15,4,num2str(fps),licznik^);
end;

Procedure Rysuj_ekran;
begin
     move386(tlo^,bufor^,64000);
     Draw_Platforms(x);
     Draw_Monsters;
     draw_ludek(145,gracz.y,round(gracz.klatka));
     show_krew;
     Show_Zycie;
     Show_Pociski;
     Show_Status;
end;


Procedure Przesun_pociski;
begin
     for i:=1 to 100 do
      if pocisk[i].leci then
       begin
        pocisk[i].x:=pocisk[i].x+pocisk[i].wx;
        if round(pocisk[i].x)<-500 then pocisk[i].leci:=false;
        if round(pocisk[i].x)>800 then pocisk[i].leci:=false;
       end;
end;

Procedure Przesun_krew;
begin
     for i:=1 to 100 do
      if krew[i].leci then
       begin
        krew[i].y:=krew[i].y+1;
        if getpixel(krew[i].x,round(krew[i].y)) in[253..254] then krew[i].leci:=false;
       end;
end;

Procedure AI_Komputera;
var odlPL, odlKOM,odl,licznik,rx,px : longint;
    kr,rnd:byte;
    jest:boolean;
begin
     for i:=1 to przeciwnikow do
      if (przeciwnik[i].x>=x-1-ai)and(przeciwnik[i].x<=x+8+ai) then
       begin
        if przeciwnik[i].zycie>0 then begin
          if przeciwnik[i].klatka>=9 then przeciwnik[i].klatka:=przeciwnik[i].klatka+0.02;
          if przeciwnik[i].klatka>9.6 then przeciwnik[i].klatka:=1;
          if przeciwnik[i].klatka=10 then przeciwnik[i].klatka:=1;
          if przeciwnik[i].strzal>0 then dec(przeciwnik[i].strzal);

          odlPl:=longmul(x+4,41)+krokx;
          odlKOM:=longmul(przeciwnik[i].x,41)+przeciwnik[i].krokx;
          {-- ODWRACANIE SI® W ZALEΩNOóCI PO, KT‡REJ STRONIE STOI GRACZ --}
          if odlKOM+20<odlPL then
           przeciwnik[i].kierunek:=1 else przeciwnik[i].kierunek:=-1;

          {-- SPRAWDZANIE CZY POTWOREK NIE OBERWAù KULKI --}
          for licznik:=1 to 100 do
           begin
                rx:=round(pocisk[licznik].x);
                px:=longmul(przeciwnik[i].x-x,41)+5+przeciwnik[i].krokx-krokx;
                if (rx>px+10) and (rx<px+20) and (pocisk[licznik].leci) and
                   (pocisk[licznik].y>przeciwnik[i].y-46) and
                   (pocisk[licznik].y<przeciwnik[i].y) then
                 begin
                  przeciwnik[i].zycie:=przeciwnik[i].zycie-pocisk[licznik].damage;
                  przeciwnik[i].klatka:=9;
                  przeciwnik[i].strzal:=przeciwnik[i].szybkostrzelnosc-1;
                  pocisk[licznik].leci:=false;
                  if przeciwnik[i].numer>1 then startsound(sound[10],10,false)
                  else startsound(sound[9],9,false);

                  rnd:=blood;
                  for kr:=1 to rnd do
                   dodajkrew(px+random(10)+10,round(pocisk[licznik].y)+random(blood shr 1)-2,133+random(5))
                 end;
           end;

          {-- JEóLI GRACZ JEST DALEKO TO IDZEMY SOBIE ELSE STRZELAMY--}
          if (x+4)>przeciwnik[i].x then
          odl:=(x+4)-przeciwnik[i].x else odl:=przeciwnik[i].x-(x+4);
          if (odl>1) and
          ( ((map^[przeciwnik[i].x,przeciwnik[i].y div 45]>0)and
             (przeciwnik[i].kierunek<0))
             or
             ((map^[przeciwnik[i].x+1,przeciwnik[i].y div 45]>0)and
             (przeciwnik[i].kierunek>0)) )
             then
           begin
              jest:=false;
              for licznik:=1 to przeciwnikow do
               if licznik<>i then
                begin
                 if (przeciwnik[licznik].zycie>0)and(przeciwnik[licznik].x=przeciwnik[i].x-1)and
                    (przeciwnik[i].kierunek<0)and(przeciwnik[i].y=przeciwnik[licznik].y) then jest:=true;
                 if (przeciwnik[licznik].zycie>0)and(przeciwnik[licznik].x=przeciwnik[i].x+1)and
                    (przeciwnik[i].kierunek>0)and(przeciwnik[i].y=przeciwnik[licznik].y) then jest:=true;
                end;
              if not jest then
               begin
                przeciwnik[i].rkrokx:=przeciwnik[i].rkrokx+(przeciwnik[i].kierunek*przeciwnik[i].speed);
                przeciwnik[i].klatka:=przeciwnik[i].klatka+(przeciwnik[i].speed/5);
                if (przeciwnik[i].klatka>7) then przeciwnik[i].klatka:=1;
               end;
           end else
           if (odl<10)and (przeciwnik[i].klatka<8) and
            ((przeciwnik[i].y-49 = gracz.y)or(przeciwnik[i].y-48 = gracz.y))and
            (gracz.zycie>0) then
            begin {STRZAù OD KOMPA}
             przeciwnik[i].klatka:=10;
             if przeciwnik[i].strzal=0 then
                przeciwnik[i].strzal:=przeciwnik[i].szybkostrzelnosc;
            end;

           if przeciwnik[i].strzal=przeciwnik[i].szybkostrzelnosc
              then if przeciwnik[i].kierunek=-1 then
               shoot(longmul(przeciwnik[i].x-x,41)+5+przeciwnik[i].krokx-krokx+7,
                         przeciwnik[i].y-przeciwnik[i].lufay,
                         -1,przeciwnik[i].sila,przeciwnik[i].bron,dzwieki[przeciwnik[i].bron]) else
               shoot(longmul(przeciwnik[i].x-x,41)+20+przeciwnik[i].krokx-krokx+7,
                         przeciwnik[i].y-przeciwnik[i].lufay,
                         1,przeciwnik[i].sila,przeciwnik[i].bron,dzwieki[przeciwnik[i].bron]);


          {PRZESUWANIE PRZECIWNIKA - WAΩNE LECZ MAùO ISTOTNE}
          if przeciwnik[i].rkrokx>40 then begin przeciwnik[i].rkrokx:=1; inc(przeciwnik[i].x); end;
          if przeciwnik[i].rkrokx<1 then begin przeciwnik[i].rkrokx:=39; dec(przeciwnik[i].x); end;
          przeciwnik[i].krokx:=round(przeciwnik[i].rkrokx);

          if przeciwnik[i].zycie<1 then begin if
            items^[przeciwnik[i].x+1,przeciwnik[i].y div 45]=0 then
            items^[przeciwnik[i].x+1,przeciwnik[i].y div 45]:=5;
            if przeciwnik[i].numer>1 then startsound(sound[8],8,false) else
            startsound(sound[2],2,false);
            end;

        end else przeciwnik[i].klatka:=8;
       end;
end;

Procedure Dopasuj_krew(ile:shortint);
var a:integer;
begin
     for a:=1 to 100 do if krew[a].leci then krew[a].x:=krew[a].x+ile;
end;

Procedure Dopasuj_pociski(ile:shortint);
var a:integer;
begin
     for a:=1 to 100 do if pocisk[a].leci then pocisk[a].x:=pocisk[a].x+ile;
end;

Procedure Przesun_mape(ile:shortint);
begin
     krokx:=krokx+ile;
     dopasuj_krew(-ile);
     dopasuj_pociski(-ile);
end;

begin
     randomize;
     init;
     SetGameSpeed(speed);
     x:=2;
     krokx:=0;
     koniec:=false;
     endlevel:=false;
     gracz.y:=0;
     gracz.klatka:=1;
     gracz.anim:=0;
     gracz.skacze:=false;
     gracz.stoi:=false;
     gracz.do_tylu:=false;
     gracz.zyje:=true;
     gracz.wys_skoku:=60 div 2; {dzielone na 2 bo skacze co 2 pixele}
     gracz.szybkostrzelnosc:=50;
     gracz.sila:=10;
     gracz.strzal:=0;
     gracz.maxzycie:=60;
     gracz.zycie:=gracz.maxzycie;
     gracz.zyc:=5;
     gracz.ammo:=50;
     gracz.maxmagazynek:=6;
     gracz.magazynek:=6;


     for i:=1 to 100 do krew[i].leci:=false;
     for i:=1 to 100 do pocisk[i].leci:=false;

     startsound(sound[4],4,true);
     a:=200;
     repeat
        Rysuj_Ekran;
        barfast(0,0,319,a div 2,0);
        barfast(0,199,319,200-(a div 2),0);
        hlinefast(0,319,a div 2,16);
        hlinefast(0,319,200-(a div 2),16);
        if level>0 then outtextxyscale(88,70,20,3,4,'LEVEL');
        if level>0 then outtextxyscale(160-(length(num2str(level))*24),105,20,3,4,num2str(level));
        if level>0 then outtextxyscale(113,175,20,2,2,kody[level]);
        movebuf2screen;
        delay(game_speed div 3);
        a:=a-1;
     until a=0;
     fpsc.start;
     repeat
           fpsc.nextframe;
           fps:=fpsc.fps;

           Rysuj_Ekran;

           Fizyka_gracza;

        {!}movebuf2screen;{!}

           if game_speed>0 then delay(game_speed);

           if keydown[scanof('s')]and(gracz.stoi)and(gracz.zyje)and(gracz.anim<>2)and(gracz.zycie>0) then {wtedy gdy skacze}
            begin gracz.klatka:=17;gracz.anim:=3;gracz.skacze:=true;end;

           {STRZAù}
           if keydown[scanof('d')] and (gracz.klatka=1)and(gracz.zycie>0)and
            (gracz.strzal=0) then {wtedy gdy strzela}
            begin
             gracz.klatka:=24;
             gracz.anim:=4;
            end;


           if (keydown[75] or keydown[77]) and(gracz.stoi=true)and(gracz.klatka<13)and(gracz.zyje)and(gracz.anim<>2)
             {sprawdzanie czy gracz sie rusza i czy ma grunt pod nogami}
             then gracz.anim:=1 else if gracz.anim=1 then gracz.anim:=0; {jesli tak to animacja chodzenia else brak animacji}

           if keydown[75] and ((gracz.anim in[1,0,3])or(gracz.skacze))
                          and (gracz.zyje)and(gracz.anim<>2) {obracanie sie gracza}
            then gracz.do_tylu:=true;
           if keydown[77] and ((gracz.anim in[1,0,3])or(gracz.skacze))
                          and (gracz.zyje)and(gracz.anim<>2) {obracanie sie gracza}
            then gracz.do_tylu:=false;

           if keydown[75]and(x>0)and(gracz.klatka<24)and(gracz.zyje)and(gracz.anim<>2)and
            (gracz.y>-100) then Przesun_mape(-1);
           if keydown[77]and(x<293)and(gracz.klatka<24)and(gracz.zyje)and(gracz.anim<>2)and
            (gracz.y>-100) then Przesun_mape(1);
           if krokx>41 then begin krokx:=1; x:=x+1; end;
           if krokx<1 then begin krokx:=41; x:=x-1; end;


           Zbieranie_Ikonek;

           Animacje_Gracza;
           Przesun_Pociski;
           Przesun_krew;
           AI_Komputera;


     until keydown[1] or koniec or endlevel;
     if keydown[1] then koniec:=true;
     stopsound(4);
     if koniec then
      begin
       a:=0;
       Rysuj_Ekran;
       repeat
        for i:=1 to 5000 do putpixel(random(320),random(200),0);
        outtextxyscale(33,88,15,3,4,'GAME OVER');
        outtextxyscale(30,85,20,3,4,'GAME OVER');
        movebuf2screen; delay(game_speed);
        a:=a+1;
       until a=200;
      end;

     if endlevel then
      begin
       a:=0;
       Rysuj_Ekran;
       repeat
        hlinefast(0,319,a div 2,16);
        hlinefast(0,319,200-(a div 2),16);
        if level>0 then outtextxyscale(25,70,20,3,4,'NEXT LEVEL');
        if level>0 then outtextxyscale(160-(length(num2str(level+1))*24),105,20,3,4,num2str(level+1));
        movebuf2screen; delay(game_speed div 2);
        hlinefast(0,319,a div 2,0);
        hlinefast(0,319,200-(a div 2),0);
        a:=a+1;
       until a=200;
      end;
     game:=false;
     if endlevel then game:=true;
     close__;
end;

(****************************************************************************
 - SOUNDS
****************************************************************************)
Var OldExitProc : pointer;
    BaseIO : word;
    IRQ, DMA, DMA16 : byte;
procedure OurExitProc; far;
var
   i: byte;
begin
     for i := 1 to sounds do
       if Sound[i] <> nil then FreeSound(Sound[i]);
     ShutdownSharing;
     ExitProc := OldExitProc; {Chain to next exit procedure}
end;
procedure initsounds;
begin
      GetSettings(BaseIO, IRQ, DMA, DMA16);
      InitSB(BaseIO, IRQ, DMA, DMA16);
      InitMixing;
      InitXMS;
      InitSharing;
      if not(OpenSoundResourceFile('SFX\SOUND.DAT'))
      then
           begin
                writeln('Brak pliku SOUND.DAT!');
                Halt(0);
           end;
      LoadSound(Sound[1], 'BAZOOKA');
      LoadSound(Sound[2], 'CRUSH');
      LoadSound(Sound[3], 'GUN');
      LoadSound(Sound[4], 'MUSIC');
      LoadSound(Sound[5], 'LASER');
      LoadSound(Sound[6], 'SCREAM');
      LoadSound(Sound[7], 'SWITCH');
      LoadSound(Sound[8], 'DEATH');
      LoadSound(Sound[9], 'PAIN1');
      LoadSound(Sound[10], 'PAIN2');
      CloseSoundResourceFile;
      OldExitProc := ExitProc;
      ExitProc := @OurExitProc;
end;
procedure closesounds;
var i:integer;
begin
      ShutdownMixing;
      ShutdownSB;
      for i := 1 to sounds do FreeSound(Sound[i]);
      ShutdownSharing;
end;
(****************************************************************************
 - END OF SOUNDS
****************************************************************************)


procedure show_gfx(plik : string);
var
   xx,yy,a : integer;
   f : file;
   b : array[0..199] of byte;
begin
     assign(f,plik);
     reset(f,1);
     for xx:=0 to 319 do
     begin
          blockread(f,b,200,i);
          for yy:=0 to 199 do putpixel(xx,yy,b[yy]);
     end;
     close(f);
end;

procedure Outtextxyfntbold(x,y,kol,ods:integer;txt:string;font:Tfont);
begin
     outtextxyfnt(x,y,kol,ods,txt,font);
     outtextxyfnt(x+1,y,kol,ods,txt,font);
end;

Procedure Draw_Menu;
begin
     loadrawfile('gfx\menu.raw');
     setcol(0,0,0,0);
     loadfont('data\small.fn2',small^);
     loadfont('data\licznik.fn2',licznik^);
end;

Procedure About;
begin
     Draw_Menu;
     outtextxyfntbold(145,80,0,7,'EXECUTION',small^);
     outtextxyfntbold(138,100,30,7,'GOLDEN GATE',small^);
     outtextxyfntbold(158,115,30,7,'GROUP',small^);
     outtextxyfntbold(113,135,30,7,'HTTP://GGATE.PRV.PL',small^);
     outtextxyfntbold(85,150,30,7,'EMAIL: GGATE@POCZTA.ONET.PL',small^);
     outtextxyfntbold(175,170,0,7,'PRESS ANY KEY...',small^);

     movebuf2screen;
     repeat until keypressed;readkey;
     Draw_Menu;
end;


procedure opcje;
var
  ch2 : char;
  opcja, ai, speed, blood : byte;
  poziom, krew : array[1..3] of string[10];
begin
     draw_menu;
     speed:=szybkosc_gry;
     ai:=(glupota div 30) +1;
     blood:=ilosc_krwi div 15;
     opcja:=1;
     poziom[1]:='NORMAL';
     poziom[2]:='HARD';
     poziom[3]:='IMPOSSIBLE';
     krew[1]:='NONE';
     krew[2]:='FEW';
     krew[3]:='MANY';
     repeat
           outtextxyfntbold(155,80,0,7,'OPTIONS',small^);
           outtextxyfntbold(115,100,0,7,'SPEED GAME: '+num2str(speed),small^);
           outtextxyfntbold(115,115,0,7,'AI LEVEL: '+poziom[ai],small^);
           outtextxyfntbold(115,130,0,7,'BLOOD: '+krew[blood],small^);
           outtextxyfntbold(115,160,0,7,'BACK',small^);
           case opcja of
            1 : outtextxyfntbold(115,100,30,7,'SPEED GAME: '+num2str(speed),small^);
            2 : outtextxyfntbold(115,115,30,7,'AI LEVEL: '+poziom[ai],small^);
            3 : outtextxyfntbold(115,130,30,7,'BLOOD: '+krew[blood],small^);
            4 : outtextxyfntbold(115,160,30,7,'BACK',small^);
           end;
           movebuf2screen;
           if keypressed then
           begin
            ch2:=readkey;
            if ch2=#80 then if opcja<4 then opcja:=opcja+1;
            if ch2=#72 then if opcja>1 then opcja:=opcja-1;

            if (opcja=1)and(ch2=#75)then if speed>0 then begin speed:=speed-1; draw_menu; end;
            if (opcja=1)and(ch2=#77)then if speed<20 then begin speed:=speed+1; draw_menu; end;
            if (opcja=2)and(ch2=#75)then if ai>1 then begin ai:=ai-1; draw_menu; end;
            if (opcja=2)and(ch2=#77)then if ai<3 then begin ai:=ai+1; draw_menu; end;
            if (opcja=3)and(ch2=#75)then if blood>1 then begin blood:=blood-1; draw_menu; end;
            if (opcja=3)and(ch2=#77)then if blood<3 then begin blood:=blood+1; draw_menu; end;
           end;
     until (ch2=#13)and(opcja=4);
     draw_menu;
     szybkosc_gry:=speed;
     ilosc_krwi:=blood*15;
     glupota:=((ai-1)*30);
end;

procedure password;
var kod : string;
    a:byte;
    b,jest:boolean;
begin
     draw_menu;
     outtextxyfntbold(150,100,0,7,'PASSWORD:',small^);
     bar(150,120,205,135,0);
     kod:=readstrfnt(160,120,5,80,0,20,7,small^);
     jest:=false;
     for a:=1 to 7 do if kod=kody[a] then begin level_poczatkowy:=a;jest:=true;break; end;
     if jest then
     begin
      clearscreen(0);
      movebuf2screen;
      b:=true;
      repeat
         if game('level'+num2str(level_poczatkowy),glupota,ilosc_krwi,level_poczatkowy,szybkosc_gry)then b:=true else b:=false;
         if b then level_poczatkowy:=level_poczatkowy+1;
      until (i=7) or (not b);
     end;
     draw_menu;
end;


procedure Trening;
begin
     clearscreen(0);
     movebuf2screen;
     Game('trening',glupota,ilosc_krwi,0,szybkosc_gry);
     draw_menu;
end;

procedure newgame;
var b : boolean;
begin
     clearscreen(0);
     movebuf2screen;
     b:=true;
     repeat
        if game('level'+num2str(level_poczatkowy),glupota,ilosc_krwi,level_poczatkowy,szybkosc_gry)then b:=true else b:=false;
        if b then level_poczatkowy:=level_poczatkowy+1;
     until (i=7) or (not b);
     draw_menu;
end;

Procedure Menu;
var opcja : byte;
    ch:char;
begin
     Draw_Menu;
     opcja:=1;
     repeat
      Outtextxyfntbold(150,70,0,7, 'NEW GAME',small^);
      Outtextxyfntbold(150,85,0,7, 'PASSWORD',small^);
      Outtextxyfntbold(150,100,0,7, 'TRAINING',small^);
      Outtextxyfntbold(154,115,0,7,'OPTIONS',small^);
      Outtextxyfntbold(161,130,0,7,'ABOUT',small^);
      Outtextxyfntbold(164,145,0,7,'EXIT',small^);
      if opcja=1 then Outtextxyfntbold(150,70,30,7, 'NEW GAME',small^);
      if opcja=2 then Outtextxyfntbold(150,85,30,7, 'PASSWORD',small^);
      if opcja=3 then Outtextxyfntbold(150,100,30,7, 'TRAINING',small^);
      if opcja=4 then Outtextxyfntbold(154,115,30,7,'OPTIONS',small^);
      if opcja=5 then Outtextxyfntbold(161,130,30,7,'ABOUT',small^);
      if opcja=6 then Outtextxyfntbold(164,145,30,7,'EXIT',small^);
      movebuf2screen;
      if keypressed then
       begin
        ch:=readkey;
        if (ch=#80)and(opcja<6) then opcja:=opcja+1;
        if (ch=#72)and(opcja>1) then opcja:=opcja-1;
        if (ch=#13)and(opcja=1) then NewGame;
        if (ch=#13)and(opcja=2) then Password;
        if (ch=#13)and(opcja=3) then Trening;
        if (ch=#13)and(opcja=4) then Opcje;
        if (ch=#13)and(opcja=5) then About;
       end;
     until (ch=#13) and (opcja=6);
end;

begin
     If not XmsInstalled then halt;
     If not MousePresent then halt;
     initsounds;
     init13h;
     new(licznik);
     new(small);

     szybkosc_gry:=10;
     ilosc_krwi:=30;
     glupota:=0;
     level_poczatkowy:=1;

     Menu;

     dispose(licznik);
     dispose(small);
     close13h;
     closesounds;
end.