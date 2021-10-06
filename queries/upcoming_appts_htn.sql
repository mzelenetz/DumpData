SELECT DISTINCT
    pt.FIRSTNAME 
      , pt.LASTNAME 
      , pt.EMAILADDRESS 
      , pt.HOMEPHONE 
      , pt.CELLPHONE 
      , pt.ADDRESS1 
      , pt.ADDRESS2 
      , pt.CITY 
      , pt.ZIPCODE 
      , pt.DOB 
      , lp.PROVIDERDESC AS ProviderName
      , lp.LASTNAME AS PROVIDERLASTNAME
      , aa.APPOINTMENTDATETIME
FROM EDM.APPOINTMENTS_ALL@EDWPROD aa
    INNER JOIN EDM.LOOKUPAPPTSCHEDPROVIDER@EDWPROD ls ON ls.APPTSCHPROVIDERID = aa.APPTSCHPROVIDERID
    INNER JOIN EDM.LOOKUPPROVIDER@EDWPROD lp ON lp.PROVIDERID = ls.PROVIDERID
    INNER JOIN EDM.PROBLEMLIST@EDWPROD p ON p.PATIENTID = aa.PATIENTID AND p.PROBLEMCLOSEDATE IS NULL
    INNER JOIN EDM.LOOKUPPROBLEMDESC@EDWPROD  pd ON pd.PROBLEMDESCID = p.PROBLEMDESCID AND PROBLEMDESC LIKE '%hypertension%'
    INNER JOIN EDM.PATIENTS pt ON pt.PATIENTID = aa.PATIENTID
WHERE 1=1
    AND ls.PROVIDERID IN (
        112434, 400004653, 400054254, 92200, 45527, 400052770, 263, 86548, 18535, 18534, 400089728, 1681, 94467, 10615, 7844
    )
    AND TRUNC(APPOINTMENTDATETIME) BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 30)
    AND aa.APPTCANCELBUMPDATE IS NULL
    AND aa.APPTCANCELREASONID IS NOT NULL
ORDER BY lp.LASTNAME, aa.APPOINTMENTDATETIME

