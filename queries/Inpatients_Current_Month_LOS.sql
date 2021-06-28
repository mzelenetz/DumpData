/*
 * Author: Michael Zelenetz mzelenetz@wphospital.org
 * Description: Dataset for Inpatients data model.
 *
 * Included Logic
 *		 FINANCE_LOS = Number of midnights between Admission and Discharge, if 0 then LOS is 1
 *       OPERATIONAL_LOS = Number of midnights between admission and discharge
 * 		 ISCOVIDVISIT = flags yes when U07.1 is coded on the account
 *       AdmittedThroughED = Yes if there is an associated ER visit ID
 *       CMI Adjusted LOS = LOS (either Operational or Financial) / MSDRG_Weight
 *
 * Notes/Issues:
 *       Some accounts have facility of White Plains Hospital and others White Plains Service Area. Fix Lookup?
 * 		 Some accounts missing DRGs. Need to validate if they are coded or not.
 */

SELECT
		  ip.MRN
		, ip.PATIENTID
		, ip.INPATIENTID
		, ip.NATIVEACCTNUMID
		, ip.ADMITTED
		, ip.DISCHARGED
		, prov.PROVIDERID AS DischargeAttendingID
		, prov.LASTNAME AS DischargeAttendingFirstName
		, prov.FIRSTNAME AS DischargeAttendingLastName
		, ns.DEPTDESC
		, ns.NURSINGSTATIONID
		, serv.SERVICEDESC
		, CASE WHEN TO_DATE(ip.DISCHARGED) - TO_DATE(ip.ADMITTED) = 0 THEN 1 ELSE TO_DATE(ip.DISCHARGED) - TO_DATE(ip.ADMITTED) END as LOS
		, dispo.DISPOSITIONDESC
		, ip.ERVISITID
		, CASE WHEN ip.ERVISITID > 0 THEN 'Yes' ELSE 'No' END AS AdmittedThroughED
		, fac.FACILITYDESC
		, ip.ILLNESSSEVERITYID
		, sev.ILLNESSSEVERITYDESC
		, ip.MORTALITYRISKID
		, mort.MORTALITYRISKDESC
		, drg.DRG AS MSDRG
		, drg.MCWEIGHT AS MSDRG_Weight
		, drg.MCLOS AS MSDRG_GMLOS
		, pat.DOB
		, TRUNC(months_between(ADMITTED, pat.DOB) / 12) AS AdmitAge
		, CASE WHEN COVID.INPATIENTID IS NULL THEN 'No' ELSE 'YES' END AS ISCOVIDVISIT
		, CASE WHEN TO_DATE(ip.DISCHARGED) - TO_DATE(ip.ADMITTED) = 0 THEN 1 ELSE TO_DATE(ip.DISCHARGED) - TO_DATE(ip.ADMITTED) END * 1.0/drg.MCWEIGHT AS CMI_ADJ_LOS
		, CASE WHEN to_char(ip.DISCHARGED ,'HH24') < 11 THEN 'Yes' ELSE 'No' END AS DischargeBefore11
FROM EDM.INPATIENTS ip
INNER JOIN EDM.LOOKUPFACILITY fac ON fac.FACILITYID = ip.FACILITYID
INNER JOIN EDM.LOOKUPDISPOSITION dispo ON dispo.DISPOSITIONID = ip.DISPOSITIONID
LEFT JOIN EDM.LOOKUPMEDICAREDRGS drg ON drg.DRG = ip.DRGID
							AND ip.DISCHARGED BETWEEN drg.MCSTARTDATE AND drg.MCENDDATE
LEFT JOIN EDM.LOOKUPILLNESSSEVERITY sev ON sev.ILLNESSSEVERITYID = ip.ILLNESSSEVERITYID
LEFT JOIN EDM.LOOKUPMORTALITYRISK mort ON mort.MORTALITYRISKID = ip.MORTALITYRISKID
LEFT JOIN EDM.LOOKUPPROVIDER prov ON prov.PROVIDERID = ip.DISCHATTENDID
INNER JOIN EDM.PATIENTS pat ON pat.PATIENTID = ip.PATIENTID
LEFT JOIN EDM.LOOKUPNURSINGSTATION ns ON ns.NURSINGSTATIONID = ip.DISCHNSID
LEFT JOIN EDM.LOOKUPSERVICE serv ON serv.SERVICEID = ip.SERVICEID
LEFT JOIN EDM.INPATIENTSICD10DX COVID ON COVID.INPATIENTID = ip.INPATIENTID
							AND COVID.ICD10DXCODE = 'U07.1'
WHERE ip.DISCHARGED IS NOT NULL AND DISCHARGED >= TO_DATE('2021-05-01', 'YYYY-MM-DD') AND REGEXP_LIKE(fac.FACILITYDESC, '(white plains)|(wph)', 'i')-- (LOWER(fac.FACILITYDESC) LIKE '%white plains%' OR (LOWER(fac.FACILITYDESC) LIKE '%wph%'))
	AND EXTRACT(YEAR FROM DISCHARGED) = EXTRACT(YEAR FROM SYSDATE)
ORDER BY DISCHARGED
