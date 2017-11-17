/* Create cutpoints for continuous variables (250 bins) */
options mlogic mprint merror;

%macro bin(invar);

proc univariate data=Raw noprint;
  var &invar;
  weight exposure;
  output out=bin pctlpre=P_ pctlpts=.4 to 100 by .4;
run;

proc transpose data=bin out=bin (drop=_name_ _label_);
run;

proc sort data=bin nodupkey force noequals;
  by col1;
run;

data bin;
  retain fmtname 'bin' type 'n';
  if _n_ = 1 then start=-1;
    else start = end;
  retain end;
  set bin (rename=(col1=end));
  label = _n_;
run;

proc format cntlin=bin;
run;

data Raw;
  set Raw;
  grp = put(&invar, bin.);
run;

proc means data=Raw nway missing noprint;
  class grp;
  var &invar;
  weight exposure;
  output out=Avg (drop=_type_ _freq_) mean=&invar._g;
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
  drop &invar;
run;

%mend;

data Raw;
  set PNCACTM.REN_GLM_NEW 
    (keep=ID
          CovC_Broad
          CovC_Special
          CovC_Tot
          CPSC
          Avg_HP_CW
          exposure);

  /* Use -1 for levels that should not be grouped */
  if CovC_Broad = 0 then CovC_Broad = .;
  if CovC_Special = 0 then CovC_Special = .;
  if CovC_Tot = 0 then CovC_Tot = .;
  if CPSC = -1 then CPSC_1 = .;
  if CPSC in (998,999) then CPSC_1 = .; else CPSC_1 = CPSC;
run;


%bin(CovC_Broad);
%bin(CovC_Special);
%bin(CovC_Tot);
%bin(CPSC_1);
%bin(Avg_HP_CW);


proc sort data=raw;  by ID;  run;
proc sort data=PNCACTM.REN_GLM_NEW;  by ID;  run;

data PNCACTM.REN_GLM_NEW;
  merge PNCACTM.REN_GLM_NEW raw;
  by ID;
  drop grp CPSC_1;

  CPSC_g = round(CPSC_1_g,1);
  CovC_Broad_g = round(CovC_Broad_g,1);
  CovC_Special_g = round(CovC_Special_g,1);
  CovC_Tot_g = round(CovC_Tot_g,1);
  Avg_HP_CW_g = round(Avg_HP_CW_g,.01);

  if CovC_Broad = 0 then CovC_Broad_g = -1;
  if CovC_Special = 0 then CovC_Special_g = -1;
  if CovC_Tot = 0 then CovC_Tot_g = -1;
  if CPSC in(998,999) then CPSC_g = CPSC;
  if CPSC = . then CPSC_g = -1;

run;

proc sql;
  drop table raw;
  drop table bin;
  drop table avg;
quit;
