WITH res AS (
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
	FROM EDM.NON_MED_ORDERS_RESULTS nmor
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
																															'COVID-19 PCR/Swab Symptomatic � Quest',
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
																															'COVID-19 PCR/Swab Source � Quest',
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
																										)
),

vis AS (
	SELECT ed.MRN
		, ed.NATIVEACCTNUMID AS NativeVisitID
	    , ed.PATIENTID
		, ed.ARRIVALDATETIME AS SEEN
		, dep.DEPTDESC
	FROM EDM.ERVISITS ed
	LEFT JOIN EDM.LOOKUPFACILITY fac ON fac.FACILITYID = ed.FACILITYID
	--LEFT JOIN res ON ed.NATIVEACCTNUMID = res.NATIVE_ACCT_NUM_ID
	LEFT JOIN EDM.LOOKUPDEPARTMENT dep ON dep.DEPTID = ed.ARRIVALEVENTDEPTID
	WHERE 1=1
		AND ed.ARRIVALEVENTDEPTID = '400004065' -- ARMON

	UNION ALL

	SELECT o.MRN
		, o.ACCTNUMIDSTR AS NativeVisitID
	    , o.PATIENTID
		, o.SEEN
		, dep.DEPTDESC
	FROM WHITEPLAINS.OPVISITS o
	LEFT JOIN EDM.LOOKUPFACILITY fac ON fac.FACILITYID = o.FACILITYMASTERID
	--LEFT JOIN res ON o.ACCTNUMIDSTR = res.NATIVE_ACCT_NUM_ID
	LEFT JOIN EDM.LOOKUPDEPARTMENT dep ON dep.DEPTID = o.DEPARTMENTID
	WHERE dep.DEPTDESC = 'WPH BUSINESS PARK DRIVE AT 99 COVID TENT'
)

/*
 * Return only yesterday's results
 */
SELECT v.*
	, p.LASTNAME
	, p.FIRSTNAME
	, p.DOB
	, TRUNC(months_between(sysdate, p.DOB) / 12) AS CurrentAge
	, r.RESULT_VALUE
	, RESULT_DTTM
	, r.RESULT_COMPONENT_EXTERNAL_NAME
	, CASE WHEN lower(r.RESULT_VALUE)  LIKE 'detected%' OR lower(r.RESULT_VALUE)  LIKE 'positive%' THEN 'Positive'
					WHEN r.RESULT_VALUE  IS NOT NULL THEN 'Negative'
					ELSE r.RESULT_VALUE
					END AS RESULT_SHORT
FROM vis v
INNER JOIN res r ON v.NativeVisitID = r.NATIVE_ACCT_NUM_ID
INNER JOIN EDM.PATIENTS p ON p.PATIENTID = v.PATIENTID
WHERE TO_DATE(RESULT_DTTM) = TO_DATE(SYSDATE - 1)
	AND TRUNC(months_between(sysdate, p.DOB) / 12) <=18
