/***************
exports serials data to json format
legend:
case(def)
1: { before + quotes
2: } after + quotes
3: [ after
4: ] after + quotes
5: no quotes
6: ] after
7: { before
***************/
LINK SERIAL TO :$.PAR;
ERRMSG 999 WHERE :RETVAL <= 0;
LINK MES_EXPORT_SERIALS TO :$.STK;
ERRMSG 999 WHERE :RETVAL <= 0;
DECLARE SERIALS CURSOR FOR
SELECT SERIAL.SERIAL,SERIAL.SERIALNAME,SERIALDES,
ROUND(REALQUANT(SERIAL.QUANT)),
SERIAL.PART,PART.PARTNAME, PARTDES,REVISIONS.REV AS REVID,
REVISIONS.REVNUM AS REV, CMT_REVDET.REVNAME AS REVDET,PROCNAME
FROM
SERIAL,SERIALA,PART,SERIALSTATUS,REVISIONS?,CMT_REVDET?,PROCESS?
WHERE SERIALA.SERIAL = SERIAL.SERIAL
AND SERIALSTATUS.SERIALSTATUS = SERIALA.SERIALSTATUS
AND RELEASED = 'Y'
AND PART.PART = SERIAL.PART
AND REVISIONS.REV = SERIAL.REV
AND CMT_REVDET.REVDET = SERIAL.CMT_REVDET
AND PROCESS.PROC = PRODSERIAL;
OPEN SERIALS;
GOTO 999 WHERE :RETVAL <= 0;
/*----*/
:ORD = 1;
LABEL 10;
:SERIAL = :SQUANT = :PROC = :PART = :REVID = 0;
:SN = :SD =  :REV = :REVDET = :PROCNAME = :PARTNAME = :PD = '';
/*--*/
FETCH SERIALS INTO :SERIAL, :SN, :SD, :SQUANT, :PART,
:PARTNAME, :PD, :REVID, :REV, :REVDET, :PROCNAME;
GOTO 980 WHERE :RETVAL <= 0;
/*-----*/
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'SERIAL','',7);
:ORD = :ORD + 1;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'SERIALNAME',:SN,1);
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES((:ORD + 1),'SERIALQUANT',ITOA(:SQUANT));
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES(:ORD + 2,'SERIALDES',:SD);
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD + 3,'PROCNAME',:PROCNAME,2);
:ORD = :ORD + 4;
/*--------EXPORT KIT---------*/
DECLARE KIT CURSOR FOR
SELECT PARTNAME,SERIALNAME,ROUND(REALQUANT(TRANSORDER.QUANT))
FROM TRANSORDER,PART,SERIAL
WHERE TRANSORDER.FORSERIAL = :SERIAL
AND TRANSORDER.TYPE = 'K'
AND SERIAL.SERIAL = TRANSORDER.SERIAL
AND PART.PART = TRANSORDER.PART
AND TRANSORDER.QUANT > 0;
OPEN KIT;
GOTO 99 WHERE :RETVAL <= 0;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'KIT','',3);
:ORD = :ORD + 1;
LABEL 20;
:PN = :LOT = '';
:KITQ = 0;
FETCH KIT INTO :PN,:LOT,:KITQ;
GOTO 98 WHERE :RETVAL <= 0;
/*-----------------*/
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'PARTNAME',:PN,1);
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES(:ORD + 1,'LOT',:LOT);
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD + 2,'QUANT',ITOA(:KITQ),2);
:ORD = :ORD + 3;
/*------------------*/
LOOP 20;
LABEL 98;
CLOSE KIT;
:ORD = :ORD + 1;
INSERT INTO MES_EXPORT_SERIALS(ORD,DEF)
VALUES(:ORD,4);
LABEL 99;
:ORD = :ORD + 1;
/*--------EXPORT ACTIONS---------*/
DECLARE SA CURSOR FOR
SELECT ACTNAME,SERACT.POS
FROM SERACT,ACT
WHERE SERACT.SERIAL = :SERIAL
AND ACT.ACT = SERACT.ACT
AND ACT.ACT > 0
AND ACT.ACT  <> 35
ORDER BY POS;
OPEN SA;
GOTO 199 WHERE :RETVAL <= 0;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'SERACT','',3);
:ORD = :ORD + 1;
LABEL 110;
:AN = '';
:POS = 0;
FETCH SA INTO :AN,:POS;
GOTO 198 WHERE :RETVAL <= 0;
/*-----------------*/
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'ACTNAME',:AN,1);
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES(:ORD + 1,'POS',ITOA(:POS));
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD + 2,'QUANT',ITOA(:SQUANT),2);
/*------------------*/
:ORD = :ORD + 3;
LOOP 110;
LABEL 198;
CLOSE SA;
:ORD = :ORD + 1;
INSERT INTO MES_EXPORT_SERIALS(ORD,DEF)
VALUES(:ORD,4);
LABEL 199;
/*------------------------*/
:ORD = :ORD + 1;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'PART','',5);
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD + 1,'PARTNAME',:PARTNAME,1);
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES(:ORD + 2,'PARTDES',:PD);
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES(:ORD + 3,'REVISION',:REV);
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD + 4,'DOCREV',:REVDET,2);
/*----------------------*/
:ORD = :ORD + 5;
DECLARE BOM CURSOR FOR
SELECT PARTNAME,COEF
FROM PART,PARTARC
WHERE PART.PART = PARTARC.SON
AND PARTARC.PART = :PART
AND SQL.DATE BETWEEN FROMDATE AND TILLDATE;
OPEN BOM;
GOTO 299 WHERE :RETVAL <= 0;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'BOM','',3);
:ORD = :ORD + 1;
LABEL 210;
:PN = '';
:COEF = 0.0;
FETCH BOM INTO :PN,:COEF;
GOTO 298 WHERE :RETVAL <= 0;
/*-----------------*/
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'PARTNAME',:PN,1);
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD + 1,'COEF',RTOA(:COEF,2),2);
/*------------------*/
:ORD = :ORD + 2;
LOOP 210;
LABEL 298;
CLOSE BOM;
:ORD = :ORD + 1;
INSERT INTO MES_EXPORT_SERIALS(ORD,DEF)
VALUES(:ORD,4);
LABEL 299;
:ORD = :ORD + 1;
/*------------------------*/
DECLARE LOC CURSOR FOR
SELECT LOCATION, X, Y, Z, QUANT,
PARTNAME, ACTNAME
FROM PART,LOCATIONS,ACT?
WHERE LOCATIONS.PART = :PART
AND PART.PART = LOCATIONS.SON
AND ACT.ACT = LOCATIONS.CMT_ACT
AND LOCATIONS.REV = :REVID;
OPEN LOC;
GOTO 399 WHERE :RETVAL <= 0;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'LOC','',3);
:ORD = :ORD + 1;
LABEL 310;
:PN = :LOC = :ACTNAME = '';
:QUANT = 0;
:X = :Y = :Z = 0.0;
FETCH LOC INTO :LOC,:X,:Y,:Z,:QUANT,:PN,:ACTNAME;
GOTO 398 WHERE :RETVAL <= 0;
/*-----------------*/
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD,'LOCATION',:LOC,1);
GOTO 311 WHERE :X = 0.0;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES(:ORD + 1,'X',RTOA(:X,2));
LABEL 311;
GOTO 312 WHERE :Y = 0.0;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES(:ORD + 2,'Y',RTOA(:Y,2));
LABEL 312;
GOTO 313 WHERE :Z = 0.0;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES(:ORD + 3,'Z',RTOA(:Z,2));
LABEL 313;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES(:ORD + 4,'QUANT',ITOA(:QUANT));
GOTO 314 WHERE :ACTNAME = '';
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE)
VALUES(:ORD + 5,'ACTNAME',:ACTNAME);
LABEL 314;
INSERT INTO MES_EXPORT_SERIALS(ORD,FIELD,VALUE,DEF)
VALUES(:ORD + 6,'PARTNAME',:PN,2);
/*------------------*/
:ORD = :ORD + 7;
LOOP 310;
LABEL 398;
CLOSE LOC;
:ORD = :ORD + 1;
INSERT INTO MES_EXPORT_SERIALS(ORD,DEF)
VALUES(:ORD,4);
LABEL 399;
:ORD = :ORD + 1;
/*------------------------*/
INSERT INTO MES_EXPORT_SERIALS(ORD,DEF)
VALUES(:ORD,6);
:ORD = :ORD + 1;
LOOP 10;
LABEL 980;
CLOSE SERIALS;
LABEL 990;
/*---------TRNSFORM TO JSON---------*/
:FILE = 'E:\Priority\mesConnector/TEST.JSON';
SELECT ORD,FIELD,VALUE,DEF
FROM MES_EXPORT_SERIALS
ORDER BY ORD TABS :FILE;
GOTO 998;
DECLARE JSON CURSOR FOR
SELECT ORD,FIELD,VALUE,DEF
FROM MES_EXPORT_SERIALS
ORDER BY ORD ;
OPEN JSON;
GOTO 999 WHERE :RETVAL <= 0;
EXECUTE DELWINDOW 'f',:FILE;
SELECT '[' FROM DUMMY ASCII ADDTO :FILE;
/*-----*/
LABEL 991;
FETCH JSON INTO :ORD,:FIELD,:VALUE,:DEF;
GOTO 998 WHERE :RETVAL <= 0;
/*-----*/
:Q1 = (:DEF IN(1,7) ? '{' : '');
:Q2 = (:DEF IN(2,6) ? '},' : '');
:Q3 = (:DEF = 3 ? '[' : '');
:Q4 = (:DEF = 4 ? '],' : '');
:QUOTE = (:DEF IN(3,5,6,7) ? '' : '"');
:COMMA = (:DEF > 1 ? '' : ',');
:PAIR =  (:FIELD > ''  ? STRCAT
('"',:FIELD,'":',:QUOTE,:VALUE,:QUOTE,:COMMA) : '');
SELECT STRCAT(:Q1,:PAIR,:Q2,:Q3,:Q4) FROM DUMMY ASCII ADDTO :FILE;
/*-----*/
LOOP 991;
LABEL 998;
/*SELECT ']' FROM DUMMY ASCII ADDTO :FILE;
CLOSE JSON;*/
EXECUTE WINAPP 'E:\Priority\mesConnector','sendexe';
LABEL 999;
/*----------------------------------*/
UNLINK MES_EXPORT_SERIALS;
UNLINK SERIAL;
