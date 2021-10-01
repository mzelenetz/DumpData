WITH
    res
    AS
    (
        SELECT
            nmor.NATIVE_ACCT_NUM_ID,
            nmor.NON_MED_ORDER_ID ,
            nmor.RESULT_VALUE ,
            RESULT_DTTM,
            res.RESULT_COMPONENT_EXTERNAL_NAME,
            CASE WHEN lower(nmor.RESULT_VALUE)  LIKE 'detected%' OR lower(nmor.RESULT_VALUE)  LIKE 'positive%' THEN 'Positive' 
					WHEN nmor.RESULT_VALUE  IS NOT NULL THEN 'Negative'
					ELSE nmor.RESULT_VALUE
					END AS RESULT_SHORT
        FROM EDM.NON_MED_ORDERS_RESULTS@EDWPROD nmor
            LEFT JOIN EDM.LOOKUPNONMEDORDERTYPE nmorlu ON nmorlu.NONMEDORDERTYPEID = nmor.NON_MED_ORDER_TYPE_ID AND NONMEDORDERTYPEABBR = 'Microbiology'
            LEFT JOIN EDM.LOOKUPNONMEDORDERSTATUS nmorstat ON nmorstat.NONMEDORDERSTATUSID = nmor.LAB_STATUS_ID
            INNER JOIN EDM.LOOKUP_RESULT_COMPONENT res ON res.RESULT_COMPONENT_ID = nmor.RESULT_COMPONENT_ID
                AND (res.RESULT_COMPONENT_EXTERNAL_NAME IN ('SARS- COV-2'
																															,'POCT COVID'
																															,'SARS-COV2 (COVID 19)'
																															,'SARS-CoV-2 (COVID 19) by NAAT',
																															'SARS-COV-2, NAA',
																															'SARS Coronavirus 2',
																															'SARS-CoV-2 PCR/Swab (COVID-19)',
																															'COVID-19 PCR/Swab Overall Result',
																															'SARS-CoV-2 (COVID 19) by NAAT',
																															'SARS-CoV-2 RNA',
																															'SARS- COV-2',
																															'SARS-CoV-2 PCR/Stool (COVID-19)',
																															'SARS-COV2 (COVID 19)',
																															'POCT COVID',
																															'COVID-19 (NAAT)',
																															'SARS-COV-2, NAA',
																															'CepheidCovid',
																															'SARS-CoV-2 PCR/Swab (COVID-19) Nasopharynx',
																															'SARS COV2 RNA',
																															'IDNOWCOVID',
																															'SARS-COV2 (COVID-19)',
																															'SARS-CoV-2 (COVID19)',
																															'SARS-COV2 (COVID-19)',
																															'SALIVA - SARS-COV-2 COVID-19 (CORONAVIRUS) RT-PCR',
																															'SARS COV2 RNA (WPH - COVID19)')
                OR res.RESULT_COMPONENT_ID in
																										(78117,
																										76302,
																										81382,
																										81772,
																										72139,
																										72219,
																										72059,
																										72040,
																										72139,
																										71999,
																										72379,
																										71999,
																										81772,
																										79367,
																										81860,
																										72160,
																										72161,
																										72099,
																										72679,
																										72219,
																										79224,
																										82132,
																										72041,
																										81382,
																										72059,
																										72319,
																										72159,
																										79224,
																										72400,
																										72039,
																										74408,
																										72159,
																										72040,
																										72020,
																										72041,
																										79367,
																										82132,
																										81382,
																										72080,
																										72019,
																										72319,
																										81299,
																										72379,
																										81772,
																										81860,
																										72099,
																										72679)
                or res.RESULT_COMPONENT_EXTERNAL_NAME like 'COVID-19 PCR/Swab Symptomatic %Quest'
                or res.RESULT_COMPONENT_EXTERNAL_NAME like 'COVID-19 PCR/Swab Source %Quest'
																										)
    )


SELECT DISTINCT
    ip.INPATIENTID
		, ip.MRN
		, ip.NATIVEACCTNUMID
		, ip.ADMITTED
		, ip.DISCHARGED
		, dispo.DISPOSITIONDESC
		, ip.DISCHARGED-ip.ADMITTED AS LOS
		, CASE WHEN cov.INPATIENTID IS NOT NULL THEN 'Yes' ELSE 'No' END AS IsCOVID
FROM EDM.INPATIENTS@EDWPROD ip
    INNER JOIN EDM.LOOKUPFACILITY fac ON fac.FACILITYID = ip.FACILITYID AND REGEXP_LIKE(fac.FACILITYDESC, '(white plains)|(wph)', 'i')
    LEFT JOIN EDM.LOOKUPDISPOSITION dispo ON dispo.DISPOSITIONID = ip.DISPOSITIONID
    LEFT JOIN
    (
	                                SELECT DISTINCT ed.INPATIENTID
			, ed.MRN
			, ed.NATIVEACCTNUMID
			, ed.ADMITTED
			, ed.DISCHARGED
			, dispo.DISPOSITIONDESC
        FROM EDM.INPATIENTS@EDWPROD ed
            INNER JOIN EDM.LOOKUPFACILITY fac ON fac.FACILITYID = ed.FACILITYID AND REGEXP_LIKE(fac.FACILITYDESC, '(white plains)|(wph)', 'i')
            LEFT JOIN res ON ed.NATIVEACCTNUMID = res.NATIVE_ACCT_NUM_ID
            LEFT JOIN EDM.LOOKUPDISPOSITION dispo ON dispo.DISPOSITIONID = ed.DISPOSITIONID
        WHERE 1=1
            AND res.RESULT_SHORT = 'Positive'

    UNION ALL

        SELECT DISTINCT ed.INPATIENTID
			, ed.MRN
			, ed.NATIVEACCTNUMID
			, ed.ADMITTED
			, ed.DISCHARGED
			, dispo.DISPOSITIONDESC
        FROM EDM.INPATIENTS@EDWPROD ed
            INNER JOIN EDM.LOOKUPFACILITY fac ON fac.FACILITYID = ed.FACILITYID AND REGEXP_LIKE(fac.FACILITYDESC, '(white plains)|(wph)', 'i')
            LEFT JOIN EDM.INPATIENTSICD10DX@EDWPROD icd ON ed.INPATIENTID = icd.INPATIENTID
            INNER JOIN EDM.LOOKUPICD10DX icd10 ON icd10.ICD10DXID = icd.ICD10DXID AND icd10.ICD10DXCODEDECIMAL = 'U07.1'
            LEFT JOIN EDM.LOOKUPDISPOSITION dispo ON dispo.DISPOSITIONID = ed.DISPOSITIONID
        WHERE 1=1
) cov ON cov.INPATIENTID = ip.INPATIENTID
WHERE EXTRACT(YEAR FROM ip.DISCHARGED) = EXTRACT(YEAR FROM SYSDATE)