CREATE TABLE myTicket(
    pnr_no INTEGER NOT NULL,
    number_train INTEGER NOT NULL,
    journey_date DATE NOT NULL,
    name_of_passenger varchar(100),
    type_b varchar(2),
    no_berth INTEGER NOT NULL,
    number_type_coach INTEGER NOT NULL,
    typeoftype_coach varchar(2),
    PRIMARY KEY(pnr_no,number_train,journey_date,no_berth,number_type_coach),
    FOREIGN KEY(number_train,journey_date) REFERENCES myTrains(number_train,journey_date)
);


CREATE TABLE myTrains(
    number_train INTEGER NOT NULL,
    journey_date DATE NOT NULL,
    num_of_AC INTEGER,
    num_of_SL INTEGER,
    AC_filled INTEGER,
    SL_filled INTEGER,

    PRIMARY KEY(number_train,journey_date)
);

CREATE OR REPLACE FUNCTION public.booking
(
	IN passenger_num integer,
	IN passenger_names character varying[],
	IN train_id integer,
	IN j_date date,
	IN type_coach character varying
)
	
RETURNS INT 
LANGUAGE 'plpgsql'
AS $BODY$
declare

tempSL int;
bookedAC int;
typeAC int;
RemainingAC int;
totalAC int;
tempAC int;
tempBerth varchar(2);
pnr_decl int;
pnrCheck int;
temp int;
bookedSleeper int;
typeSleeper int;
RemainingSL int;
totalSleepers int;

begin

 
  temp=0;

  bookedSleeper=(SELECT SL_filled from myTrains where train_id=myTrains.number_train and j_date=myTrains.journey_date);

  bookedAC=(SELECT AC_filled from myTrains where train_id=myTrains.number_train and j_date=myTrains.journey_date);

  totalAC=(SELECT num_of_AC from myTrains where train_id=myTrains.number_train and j_date=myTrains.journey_date);

  totalSleepers=(SELECT num_of_SL from myTrains where train_id=myTrains.number_train and j_date=myTrains.journey_date);
  
  totalAC=totalAC*18;

  totalSleepers=totalSleepers*24;
  
  RemainingAC=totalAC-bookedAC;
  RemainingSL=totalSleepers-bookedSleeper;
 
  
  tempAC = ( ( totalAC - RemainingAC ) % 18 ) + 1;
  typeAC = ( ( totalAC - RemainingAC ) / 18 ) + 1;
  tempSL = ( ( totalSleepers - RemainingSL ) % 24 ) + 1;
  typeSleeper=( ( totalSleepers - RemainingSL ) / 24 ) + 1; 
 
 
 
 
 if(not exists(SELECT number_train from myTrains where train_id=myTrains.number_train and j_date=myTrains.journey_date) or not exists(SELECT journey_date from myTrains where train_id=myTrains.number_train and j_date=myTrains.journey_date))
 then
 return 0;
 end if;
 



 if(exists(SELECT number_train from myTrains where train_id=myTrains.number_train and j_date=myTrains.journey_date))then
 
 if((type_coach = 'SL' and RemainingSL>=passenger_num) or (type_coach= 'AC' and RemainingAC>=passenger_num)) then
 
 

 pnr_decl:=(SELECT floor(random()*( 900000 - 1000000 + 1) + 1000000 ) ) :: int;
 
 for pnrCheck IN SELECT pnr_no from myTicket where train_id=myTicket.number_train and j_date=myTicket.journey_date
 loop
 if(pnrCheck=pnr_decl)then
 pnr_decl:=(SELECT floor(random()*( 900000 - 1000000 + 1 ) + 1000000 ) ) ::int;
 end if;
 end loop;
 

  if(type_coach='AC')then

  update myTrains

  set AC_filled=AC_filled+passenger_num

  where train_id=myTrains.number_train and j_date=myTrains.journey_date;
  
  
for i in 1..passenger_num
loop
 
 if(tempAC%6=0)then 

 tempBerth='SU';end if;

 if(tempAC%6=1 or tempAC%6=2 )THEN

 tempBerth='LB';end if;

 if(tempAC%6=3 or tempAC%6=4 )THEN

 tempBerth='UB';end if;

 if(tempAC%6=5)then

 tempBerth='SL';end if;
 

 insert into myTicket ( pnr_no, number_train, journey_date, name_of_passenger, type_b, no_berth, number_type_coach, typeoftype_coach ) values( pnr_decl, train_id, j_date, passenger_names[i], tempBerth, tempAC, typeAC, type_coach ) ;

 tempAC = tempAC + 1;

 if ( tempAC = 19 ) THEN

 tempAC = 1;

 typeAC = typeAC + 1;
 end if;

 end loop;
 end if;
  
  
 if ( type_coach = 'SL' ) then

  update myTrains

  set SL_filled=SL_filled+passenger_num

  where train_id=myTrains.number_train and j_date=myTrains.journey_date;

  
for i in 1..passenger_num
 loop
 
  if ( tempSL % 8 = 0 ) then

  tempBerth = 'SU'; end if ;

  if ( tempSL % 8 = 1 or tempSL % 8 = 4 ) then

  tempBerth = 'LB'; end if;

  if ( tempSL % 8 = 2 or tempSL % 8 = 5 ) then

  tempBerth = 'MB' ; end if ;

  if ( tempSL % 8 = 3 or tempSL % 8 = 6 ) then

  tempBerth = 'UB'; end if;

  if ( tempSL % 8 = 7 ) then

  tempBerth = 'SL';
  end if;
 

 insert into myTicket(pnr_no,number_train,journey_date,name_of_passenger,type_b,no_berth,number_type_coach,typeoftype_coach) values(pnr_decl,train_id,j_date,passenger_names[i],tempBerth,tempSL,typeSleeper,type_coach);

tempSL = tempSL + 1 ;

 if ( tempSL = 25 ) THEN

 tempSL = 1;

 typeSleeper = typeSleeper + 1;

 end if; 

 end loop;

 end if;

 temp = 1;
 end if;
 end if;
 
 
 
if ( temp = 0 ) then

return 1; 
end if;

if ( temp = 1 ) then 
return 2;
end if;


 end;
$BODY$;
ALTER FUNCTION public.booking
(integer, character varying[], integer, date, character varying)
    OWNER TO postgres;