/* Equal width bins */

%macro bin2(invar, low_lmt=450, width=10, bin_num = 1);

data fmt;
  retain fmtname 'bin' type 'n';
  start = 200; end = &low_lmt; label = 1; output;
  do until (end=997);
    start = end;
    end = min(start + &width, 997);
    label = label + 1;
    output;
  end;
  start = 998; end = 998; label = label + 1; output;
  start = 999; end = 999; label = label + 1; output;
run;

proc format cntlin=fmt;
run;

data Raw;
  set Raw;
  grp = put(&invar, bin.);
run;

proc means data=Raw nway missing noprint;
  class grp;
  var &invar;
  weight exposure;
  output out=Avg (drop=_type_ _freq_) mean=&invar._g&bin_num;
run;

proc sort data=Avg;
  by grp;
run;

proc sort data=Raw;
  by grp;
run;

data Raw;
  merge Raw Avg;
  by grp;
run;

%mend;

data Raw;
  set PNCACTM.REN_GLM_NEW 
    (keep=ID
          CPSC
          exposure);

  if CPSC = -1 then CPSC = .;
run;

%bin2(invar=CPSC, low_lmt=500, width=10, bin_num = 1);
%bin2(invar=CPSC, low_lmt=300, width=20, bin_num = 2);
%bin2(invar=CPSC, low_lmt=400, width=50, bin_num = 3);


proc sort data=raw;  by ID;  run;
proc sort data=PNCACTM.REN_GLM_NEW;  by ID;  run;

data PNCACTM.REN_GLM_NEW;
  merge PNCACTM.REN_GLM_NEW raw;
  by ID;

  CPSC_g1 = round(CPSC_g1,1);
  CPSC_g2 = round(CPSC_g2,1);
  CPSC_g3 = round(CPSC_g3,1);
  
  if CPSC in(998,999) then CPSC_g1 = CPSC;
  if CPSC = . then CPSC_g1 = -1;
  if CPSC in(998,999) then CPSC_g2 = CPSC;
  if CPSC = . then CPSC_g2 = -1;
  if CPSC in(998,999) then CPSC_g3 = CPSC;
  if CPSC = . then CPSC_g3 = -1;

run;

proc sql;
  drop table raw;
  drop table bin;
  drop table avg;
quit;
