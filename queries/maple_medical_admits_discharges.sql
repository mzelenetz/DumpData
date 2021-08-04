WITH
       PCPHist
       AS
       (
              SELECT *
              FROM (
       SELECT
                            PATIENTID
              , MRN
              , PATIENTPCPID 
              , PCPID 
              , PCPTYPEID 
              , ACTIVEDATE
              , INACTIVEDATE
              , prov.PROVIDERDESC
              , prov.FIRSTNAME AS PROVIDER_FIRSTNAME
              , prov.LASTNAME AS PROVIDER_LASTNAME
              , prov.OFFICE_PHONE_NUM AS PROVIDER_OFFICE_PHONE_NUM
              , prov.PROVIDER_TITLE_ID 
              , prov.NPI AS PROVIDER_NPI
              , SPECIALTYGROUP.SPECIALTYDESC
              , pt.PROVIDERTYPEDESC
              , row_number() over (partition by o.PATIENTID, o.PCPID order by ACTIVEDATE desc) as seqnum
                     FROM EDM.PATIENTPCPHISTORY@EDWPROD o
                            LEFT JOIN EDM.LOOKUPPROVIDER@EDWPROD prov ON prov.PROVIDERID = o.PCPID
                            LEFT JOIN EDM.LOOKUPDEPARTMENT@EDWPROD fac ON fac.DEPTID  = prov.PROVIDERDEPTID
                            LEFT JOIN EDM.LOOKUPDEPARTMENTRPTGROUP@EDWPROD dg ON dg.DEPARTMENTRPTGROUPID = fac.DEPTRPTGROUPMMGID
                            LEFT JOIN EDM.LOOKUPSPECIALTY@EDWPROD specialtygroup ON SPECIALTYGROUP.SPECIALTYID = fac.SPECIALTYID
                            LEFT JOIN EDM.LOOKUPPROVIDERTYPE@EDWPROD pt ON pt.PROVIDERTYPEID = o.PCPTYPEID
                     WHERE INACTIVEDATE IS NULL
                            AND prov.NPI IN ('1194797316', '1578716262', '1093787418', '1679545628', '1538333653', '1104886530', '1578625935', '1407082506', '1205926003', '1861655128', '1891180964', '1447760699', 
                                                '1245552785', '1881944189', '1215935408', '1497727606', '1982994836', '1033181250', '1720168842', '1831161819') 
) pcp
              WHERE 1=1
                     AND seqnum = 1
       )

SELECT distinct i.mrn, pat.PATIENTDISPLAYNAME, pat.FIRSTNAME, pat.LASTNAME, i.ADMITTED, prov.NPI "ADMITATTENDNPI", fac.FACILITYDESC, p.PROVIDER_FIRSTNAME, p.PROVIDER_LASTNAME
FROM EDM.INPATIENTS i
       LEFT JOIN EDM.Patients@EDWPROD pat ON pat.mrn = i.mrn
       INNER JOIN PCPHist p ON p.mrn = i.mrn AND p.patientid = i.PATIENTID
       LEFT JOIN EDM.INPATIENTSCENSUS cen2 ON cen2.PATIENTID = i.PATIENTID AND cen2.mrn = i.mrn AND cen2.FACILITYID = i.FACILITYID AND TRUNC(cen2.TRANSFERINDATETIME) = TRUNC(i.ADMITTED)
       LEFT JOIN EDM.LOOKUPFACILITY fac ON fac.facilityid = i.facilityid
       LEFT JOIN EDM.LOOKUPPROVIDER prov ON prov.PROVIDERID = i.ADMITATTENDID
WHERE i.DISCHARGED IS NULL
       AND fac.FACILITYDESC != 'Burke Rehab Hospital'
ORDER BY i.ADMITTED desc