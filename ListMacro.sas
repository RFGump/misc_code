/* Run a list of variables through the same procedure */

%macro array();

%let i = 1;
%let list = stn_typ stn_st /*dst_drv dst_str dst_man*/ prot_stat_id prot_stat resp_ind /*muni*/ muni_stat mut_aid fst_alrm dispatch
            dispatch_bkp avl_911 radio pers_tot pers_ft pers_pt pers_hazmat Hazmat_Awar Hazmat_Oper Hazmat_Tech EMS_1 EMS EMS_BLS EMS_ALS 
            EMS_ALS_Para EMS_Collapse Hazmat_Chem pers_wild tank_tenders tenders tankers ladders pumpers gens gens_alt gens_alt_crit power_mnt
            water_250_120 water_250_20 survey_resp hazmat_comb ems_comb Backup_Power_comb Water_GPM_comb HPWater FireSafe;

%let item = %scan(&list, &i);
/*%put &item;*/

%do %until(%scan(&list, &i) = );
  %let item = %scan(&list, &i);

  proc means data=work.glm1206_fir nway missing sum;
    class &item;
    var earn_expos;
  run;

  %let i = %eval(&i + 1);
%end;

%mend;

%array();
