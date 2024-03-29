#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/gprolog/bin/gprolog --consult-file
% $Id: functions.pl,v 1.3 2016-11-08 15:04:13-08 - - $
% aparab ehobbs

:- initialization(main).

not(X) :- X, !, fail.
not(_).

mathfns( X, List ) :-
   S is sin( X ),
   C is cos( X ),
   Q is sqrt( X ),
   List = [S, C, Q].

constants( List ) :-
   Pi is pi,
   E is e,
   Epsilon is epsilon,
   List = [Pi, E, Epsilon].

sincos( X, Y ) :-
   Y is sin( X ) ** 2 + cos( X ) ** 2.

convert_to_radians( degmin( Deg, Min), Rad) :-
   Rad is ((Deg + (Min/60)) * (pi / 180)).

haversine_radians( Lat1, Lon1, Lat2, Lon2, Distance ) :-
   Dlon is Lon2 - Lon1,
   Dlat is Lat2 - Lat1,
   A is sin( Dlat / 2 ) ** 2
      + cos( Lat1 ) * cos( Lat2 ) * sin( Dlon / 2 ) ** 2,
   Dist is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
   Distance is Dist * 3961.

%arrival_time( Start, Dest, time(FromH, FromM), time(ArrivalH, ArrivalM)) :-
%   airport( Start, _,degmin(FLatD, FLatM), degmin(FLonD, FLonM)),
%   airport( Dest, _,degmin(ALatD, ALatM), degmin(ALonD, ALonM)),
%   convert_to_radians(degmin(FLatD, FLatM), FLat),
%   convert_to_radians(degmin(ALatD, ALatM), ALat),
%   convert_to_radians(degmin(FLonD, FLonM), FLon),
%   convert_to_radians(degmin(ALonD, ALonM), ALon),
%   haversine_radians( FLat, FLon, ALat, ALon, Dist ),
%   ArrivalH is floor((Dist / 500) + FromH + (FromM / 60)) ,
%   ArrivalM is (((Dist/500)+ FromH + (FromM / 60)) - ArrivalH) * 60.

arrival_time(Start, Dest, DTime, ATime) :-
   airport( Start, _, degmin(FLatD, FLatM), degmin(FLonD, FLonM)),
   airport( Dest, _, degmin(ALatD, ALatM), degmin(ALonD, ALonM)),
   convert_to_radians(degmin(FLatD, FLatM), FLat),
   convert_to_radians(degmin(ALatD, ALatM), ALat),
   convert_to_radians(degmin(FLonD, FLonM), FLon),
   convert_to_radians(degmin(ALonD, ALonM), ALon),
   haversine_radians( FLat, FLon, ALat, ALon, Dist ),
   ATime is (Dist/500) + DTime. 

HMtoH( time(Hours, Mins), Hours1) :-
   Hours1 is Hours + Mins / 60.

findpath(To, To, _,[To], _).
findpath(From, To, BeenTo, [[From, Dtime, Atime] | List], DtimeHM) :-
   flight(From, To, DtimeHM),
   not(member(To, BeenTo)),
   HMtoH(DtimeHM, Dtime),
   arrival_time(From, To, Dtime, Atime),
   Atime < 24.0,
   findpath (To, To, [To | BeenTo], List, _).
findpath(From, To, BeenTo, [[From, Dtime, Atime] | List], DtimeHM) :-
   flight( From, X, DtimeHM),
   not( member( X, BeenTo)),
   HMtoH(DtimeHM, Dtime),
   arrival_time(From, To, Dtime, Atime),
   Atime < 24.0,

   flight( X, _, XDtimeHM),
   HMtoH(XDtimeHM, XDtime),
   Ytime is XDtime - Atime - 0.5,
   Ytime >= 0,
   findpath(X, To, [X | BeenTo], List, XDtimeHM).   

%findpath(From, To, BeenTo, [[From, Dtime, Atime] | List], time(DHour, DMin)) :-
%   nl,
%   write( 'in shorter find path: '),
%   flight(From, To, time(DHour, DMin)),
%   not(member(To, BeenTo)),
%   Dtime is DHour + DMin/60,
%   arrival_time(From, To, time(DHour, DMin), time(ArrivalH, ArrivalM)),
%   Atime is Dtime + (ArrivalH + ArrivalM/60),
%   Atime < 24.0,
%   findpath( To, To, [To | BeenTo], List, _).

%findpath(From, To, BeenTo, [[From, Dtime, Atime] | List], time(DHour, DMin)) :-
%   write( 'in findpath'),
%   flight( From, X, time(DHour, DMin)),
%   nl,
%   write( 'X is: '),
%   write( X),
%   not( member( X, BeenTo)),
%   Dtime is DHour + DMin/60,
%   nl,
%   write( 'Dtime is: '),
%   write( Dtime),
%   arrival_time( From, X, time(DHour, DMin), time(ArrivalH, ArrivalM)),
%   Atime is Dtime + (ArrivalH + ArrivalM/60),
%   Atime < 24.0,
%   flight( X, _, time(YHour, YMin)),
%   nl,
%   write( 'YHM are: '),
%   write( YHour),
%   write( YMin),
%   Ytime is YHour + YMin/60,
%   (Ytime - Atime - 0.5) >= 0,
%   findpath(X, To, [X | BeenTo], List, time(YHour, YMin)).

%print two digits when printing time
%prints like 15 if greater than 9, and 09 if less than 9.
print_nums( Nums ) :-
    Nums < 10, print( 0 ), print( Nums ).

print_nums( Nums ) :-
    Nums >= 10, print( Nums ).

print_time( Hours1 ) :-
    Mins1 is floor( Hours1 * 60 ),
    Hours is Mins1 // 60,
    Mins is Mins1 mod 60,
    print_nums( Hours ),
    print( ':' ),
    print_nums( Mins ).

%This will do all of the writing
writepath( [] ) :-
   nl.
writepath( [[From, Dtime1, Atime1], To | []]) :-
   airport( From, From_name, _, _),
   airport( To, To_name, _,_),
   write( '     ' ), write( 'depart  ' ),
   write( From ), write( '  ' ),
   write( From_name ),
   print_time( DTime1 ), nl,

   write( '     ' ), write( 'arrive  ' ),
   write( To ), write( '  ' ),
   write( To_name ),
   print_time( ATime1 ), nl,
   !, true.
writepath( [[From, Dtime1, Atime1], [To, DTime2, ATime2] | Cdr]) :-
   airport( From, From_name, _, _),
   airport( To, To_name, _,_),
   write( '     ' ), write( 'depart  ' ),
   write( From ), write( '  ' ),
   write( From_name ),
   print_time( DTime1 ), nl,

   write( '     ' ), write( 'arrive  ' ),
   write( To ), write( '  ' ),
   write( To_name ),
   print_time( ATime1 ), nl,
   !, writepath( [[To, DTime2, ATime2] | Cdr]).
   

%Main function
fly( From, From ) :-
   write( 'You\'re departing from where you already are! Dummy!.' ),
   nl,
   !, fail.

fly( From, To ) :-
    airport( From, _, _, _ ),
    airport( To, _, _, _ ),

    findpath( From, To, [From], List, _ ),
    !, nl,
    writepath( List ),
    true.

fly( From, To ) :-
    airport( From, _, _, _ ),
    airport( To, _, _, _ ),
    write( 'Your search did not return any results.' ),
    !, fail.
fly( _, _) :-
    write( 'Airports do not match those in our database.' ), nl,
    !, fail. 

main :-
        [database],
        fly( lax,sjc),
        halt.
