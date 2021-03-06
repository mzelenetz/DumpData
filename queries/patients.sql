WITH wph_contacts AS (

	-- Appointments
	SELECT
		  PATIENTID
		, SUM(1) AS TOTAL_APPOINTMENTS
		, SUM(CASE WHEN APPTSTATUSID = 14 THEN 1 ELSE 0 END) AS COMPLETED_APPOINTMENTS
		, MIN(APPOINTMENTDATETIME) AS FIRST_APPOINTMENT
		, MAX(CASE WHEN APPOINTMENTDATETIME < SYSDATE THEN APPOINTMENTDATETIME END) AS LAST_APPOINTMENT
		, MIN(CASE WHEN APPOINTMENTDATETIME >= SYSDATE THEN APPOINTMENTDATETIME END) AS NEXT_APPOINTMENT
		, 0 AS INPATIENT_ADMISSIONS
		, NULL AS FIRST_ADMISSION
		, NULL AS LAST_ADMISSION
		, 0 AS ER_VISITS
		, NULL AS FIRST_ER_VISIT
		, NULL AS LAST_ER_VISIT
		, 0 AS PROCEDURES
		, NULL AS FIRST_PROCEDURE
		, NULL AS LAST_PROCEDURE
	FROM EDM.APPOINTMENTS_ALL@EDWPROD aa
	INNER JOIN EDM.LOOKUPFACILITY@EDWPROD fac ON fac.FACILITYID = aa.FACILITYID
	INNER JOIN EDM.LOOKUPSERVICEAREA@EDWPROD s ON s.SERVICEAREAID = fac.SERVICEAREAID
	WHERE 1=1
		AND REGEXP_LIKE(s.SERVICEAREADESC, '(WHITE PLAINS)|(WPH)', 'i')
		AND APPTSTATUSID NOT IN (2, 3, 4, 6) -- NOT cancelled, bumped, NO-show
		AND APPTCANCELREASONID <> 113 -- NOT cancelled because OF error
	GROUP BY
		PATIENTID
	
	UNION ALL
	
	-- Inpatient admissions
	SELECT
		  PATIENTID
		, 0 AS TOTAL_APPOINTMENTS
		, 0 AS COMPLETED_APPOINTMENTS
		, NULL AS FIRST_APPOINTMENT
		, NULL AS LAST_APPOINTMENT
		, NULL AS NEXT_APPOINTMENT
		, SUM(1) AS INPATIENT_ADMISSIONS
		, MIN(ADMITTED) AS FIRST_ADMISSION
		, MAX(ADMITTED) AS LAST_ADMISSION
		, 0 AS ER_VISITS
		, NULL AS FIRST_ER_VISIT
		, NULL AS LAST_ER_VISIT
		, 0 AS PROCEDURES
		, NULL AS FIRST_PROCEDURE
		, NULL AS LAST_PROCEDURE
	FROM EDM.INPATIENTS@EDWPROD ind
	INNER JOIN EDM.LOOKUPFACILITY@EDWPROD fac ON fac.FACILITYID = ind.FACILITYID
	INNER JOIN EDM.LOOKUPSERVICEAREA@EDWPROD s ON s.SERVICEAREAID = fac.SERVICEAREAID
	WHERE 1=1
		AND REGEXP_LIKE(s.SERVICEAREADESC, '(WHITE PLAINS)|(WPH)', 'i')
	GROUP BY
		PATIENTID
		
	UNION ALL
	
	-- ER visits
	SELECT
		  PATIENTID
		, 0 AS TOTAL_APPOINTMENTS
		, 0 AS COMPLETED_APPOINTMENTS
		, NULL AS FIRST_APPOINTMENT
		, NULL AS LAST_APPOINTMENT
		, NULL AS NEXT_APPOINTMENT
		, 0 AS INPATIENT_ADMISSIONS
		, NULL AS FIRST_ADMISSION
		, NULL AS LAST_ADMISSION
		, SUM(1) AS ER_VISITS
		, MIN(ARRIVALDATETIME) AS FIRST_ER_VISIT
		, MAX(ARRIVALDATETIME) AS LAST_ER_VISIT
		, 0 AS PROCEDURES
		, NULL AS FIRST_PROCEDURE
		, NULL AS LAST_PROCEDURE
	FROM EDM.ERVISITS@EDWPROD er
	INNER JOIN EDM.LOOKUPFACILITY@EDWPROD fac ON fac.FACILITYID = er.FACILITYID
	INNER JOIN EDM.LOOKUPSERVICEAREA@EDWPROD s ON s.SERVICEAREAID = fac.SERVICEAREAID
	WHERE 1=1
		AND REGEXP_LIKE(s.SERVICEAREADESC, '(WHITE PLAINS)|(WPH)', 'i')
	GROUP BY
		PATIENTID
		
	UNION ALL
	
	-- Procedures
	SELECT
		  PATIENTID
		, 0 AS TOTAL_APPOINTMENTS
		, 0 AS COMPLETED_APPOINTMENTS
		, NULL AS FIRST_APPOINTMENT
		, NULL AS LAST_APPOINTMENT
		, NULL AS NEXT_APPOINTMENT
		, 0 AS INPATIENT_ADMISSIONS
		, NULL AS FIRST_ADMISSION
		, NULL AS LAST_ADMISSION
		, 0 AS ER_VISITS
		, NULL AS FIRST_ER_VISIT
		, NULL AS LAST_ER_VISIT
		, SUM(1) AS PROCEDURES
		, MIN(ORCASEDATE) AS FIRST_PROCEDURE
		, MAX(ORCASEDATE) AS LAST_PROCEDURE
	FROM EDM.ORCASES@EDWPROD o
	INNER JOIN EDM.LOOKUPFACILITY@EDWPROD fac ON fac.FACILITYID = o.FACILITYID
	INNER JOIN EDM.LOOKUPSERVICEAREA@EDWPROD s ON s.SERVICEAREAID = fac.SERVICEAREAID
	WHERE 1=1
		AND REGEXP_LIKE(s.SERVICEAREADESC, '(WHITE PLAINS)|(WPH)', 'i')
	GROUP BY
		PATIENTID
),

agg AS (
	SELECT
		  PATIENTID
		, SUM(TOTAL_APPOINTMENTS) AS TOTAL_APPOINTMENTS
		, SUM(COMPLETED_APPOINTMENTS) AS COMPLETED_APPOINTMENTS
		, MIN(FIRST_APPOINTMENT) AS FIRST_APPOINTMENT
		, MAX(LAST_APPOINTMENT) AS LAST_APPOINTMENT
		, MIN(NEXT_APPOINTMENT) AS NEXT_APPOINTMENT
		, SUM(INPATIENT_ADMISSIONS) AS INPATIENT_ADMISSIONS
		, MIN(FIRST_ADMISSION) AS FIRST_ADMISSION
		, MAX(LAST_ADMISSION) AS LAST_ADMISSION
		, SUM(ER_VISITS) AS ER_VISITS
		, MIN(FIRST_ER_VISIT) AS FIRST_ER_VISIT
		, MAX(LAST_ER_VISIT) AS LAST_ER_VISIT
		, SUM(PROCEDURES) AS PROCEDURES
		, MIN(FIRST_PROCEDURE) AS FIRST_PROCEDURE
		, MAX(LAST_PROCEDURE) AS LAST_PROCEDURE
	FROM wph_contacts
	GROUP BY
		PATIENTID
)

SELECT
	  pm.*
	, agg.TOTAL_APPOINTMENTS
	, agg.COMPLETED_APPOINTMENTS
	, agg.FIRST_APPOINTMENT
	, agg.LAST_APPOINTMENT
	, agg.NEXT_APPOINTMENT
	, agg.INPATIENT_ADMISSIONS
	, agg.FIRST_ADMISSION
	, agg.LAST_ADMISSION
	, agg.ER_VISITS
	, agg.FIRST_ER_VISIT
	, agg.LAST_ER_VISIT
	, agg.PROCEDURES
	, agg.FIRST_PROCEDURE
	, agg.LAST_PROCEDURE
FROM JSEGE.PATIENT_META pm
INNER JOIN agg ON agg.PATIENTID = pm.PATIENTID