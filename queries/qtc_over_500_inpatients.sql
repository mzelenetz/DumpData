WITH QTc AS (
SELECT res.RESULT_DATE 
		, res.PAT_ENC_CSN_ID
		, res.COMPONENT_ID
		, res.ORD_NUM_VALUE
		, res.REFERENCE_UNIT
		, res.RESULT_TIME
		, ser.PROV_NAME AS ProviderName
		, comp.NAME AS COMPONENET_DESC
		--, ROW_NUMBER() OVER (PARTITION BY res.PAT_ENC_CSN_ID ORDER BY res.RESULT_TIME DESC) AS ResultOrder
	FROM ORDER_RESULTS@CLRPROD res
	INNER JOIN CLARITY_COMPONENT@CLRPROD comp ON comp.COMPONENT_ID = res.COMPONENT_ID
	LEFT JOIN HSP_ATND_PROV@CLRPROD atnd ON atnd.PAT_ENC_CSN_ID = res.PAT_ENC_CSN_ID AND res.RESULT_DATE BETWEEN atnd.ATTEND_FROM_DATE AND atnd.ATTEND_TO_DATE
	INNER JOIN CLARITY_SER@CLRPROD ser ON ser.PROV_ID = atnd.PROV_ID
	WHERE res.RESULT_TIME >= TO_DATE('2021-05-01', 'YYYY-MM-DD')
		AND res.COMPONENT_ID = '7238' 
		--AND res.ORD_NUM_VALUE >= 450
),



departments AS 
(SELECT 
	 DEPARTMENT_ID
	,DEPARTMENT_NAME
	,DEPT_ABBREVIATION
	,SPECIALTY_DEP_C
	,SPECIALTY
	,REV_LOC_ID
	,revLoc.LOC_NAME as REV_LOC
	,parentLocName.LOC_ID as PARENT_LOC_ID
	,parentLocName.LOC_NAME AS PARENT_LOC
	,dep.SERV_AREA_ID
	,servArea.SERV_AREA_NAME
	,ADT_UNIT_TYPE_C
	,dep.CENTER_C
	,center.NAME as CENTER
	,DEP_ED_TYPE_C
	,CARE_AREA_C
FROM CLARITY_DEP@CLRPROD dep
LEFT JOIN CLARITY_LOC@CLRPROD revLoc
	ON dep.REV_LOC_ID = revLoc.LOC_ID
LEFT JOIN CLARITY_LOC@CLRPROD parentLoc
	ON dep.REV_LOC_ID = parentLoc.LOC_ID
LEFT JOIN CLARITY_LOC@CLRPROD parentLocName
	ON parentLoc.ADT_PARENT_ID = parentLocName.LOC_ID AND parentLocName.LOC_ID <> 1
LEFT JOIN CLARITY_SA@CLRPROD servArea
	ON dep.SERV_AREA_ID = servArea.SERV_AREA_ID
LEFT JOIN ZC_CENTER@CLRPROD center
	ON dep.CENTER_C = center.CENTER_C
),

TELEMETRY AS ( 
	
	SELECT PAT_ID, PAT_ENC_CSN_ID, ORDERING_DATE, PROC_START_TIME, COALESCE(PROC_ENDING_TIME, SYSDATE) AS PROC_ENDING_TIME, DESCRIPTION--,
	--ROW_NUMBER() OVER (PARTITION BY PAT_ENC_CSN_ID ORDER BY PROC_START_TIME DESC) AS RN
	FROM ORDER_PROC@CLRPROD 
	WHERE DESCRIPTION = 'CONTINUOUS TELEMETRY MONITORING' 
		AND ORDERING_DATE > TO_DATE('2021-05-01', 'YYYY-MM-DD')
)

SELECT DISTINCT MAX(q.ORD_NUM_VALUE) AS MAX_QTc , q.COMPONENET_DESC, q.PAT_ENC_CSN_ID, q.ProviderName, i.CHIEFCOMPLAINT, i.MRN, i.ADMITTED, i.DISCHARGED, 
	CASE WHEN t.PAT_ENC_CSN_ID IS NULL THEN 0 ELSE 1 END AS HasTelemOrder
FROM QTc q 
LEFT JOIN EDM.INPATIENTS i ON i.NATIVEINPATIENTID = q.PAT_ENC_CSN_ID
LEFT JOIN EDM.LOOKUPFACILITY fac ON fac.FACILITYID = i.FACILITYID 
LEFT JOIN TELEMETRY t ON t.PAT_ENC_CSN_ID = q.PAT_ENC_CSN_ID
WHERE REGEXP_LIKE(fac.FACILITYDESC, '(white plains)|(wph)', 'i') 
	AND q.ORD_NUM_VALUE >= 500
	AND i.DISCHARGED IS NULL
GROUP BY q.COMPONENET_DESC, q.PAT_ENC_CSN_ID, q.ProviderName, i.CHIEFCOMPLAINT, i.MRN,i.ADMITTED, i.DISCHARGED, 
	CASE WHEN t.PAT_ENC_CSN_ID IS NULL THEN 0 ELSE 1 END