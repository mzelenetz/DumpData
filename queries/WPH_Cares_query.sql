WITH
    response
    AS
    (
        SELECT *
        FROM
            (
			SELECT PAT_MRN_ID, ANSWER, ELEMENT_ID
            FROM JSEGE.CLARITY_HP_WPHCARES_SMARTTEXT_FIELDS_CSV smrtxt
		)
		PIVOT
		(
		 max(ANSWER) FOR ELEMENT_ID IN (

		'MMC#7087'
		, 'MMC#7044'
		, 'MMC#7046'
		, 'MMC#7026'
		, 'MMC#7034'
		, 'MMC#7050'
		, 'MMC#7051'
		, 'MMC#7089'
		, 'MMC#7058'
		, 'MMC#7061'
		, 'MMC#7023'
		, 'MMC#7024'
		, 'MMC#7088'
		, 'MMC#7018'
		, 'MMC#7060'
		, 'MMC#7043'
		, 'MMC#7045'
		, 'MMC#7019'
		, 'MMC#7086'
		, 'MMC#7031'
		, 'MMC#7021'
		, 'MMC#7042'
		, 'MMC#7047'
		, 'MMC#7022'
		, 'MMC#7063'
		, 'MMC#7035'
		, 'MMC#7048'
		, 'MMC#7041'
		, 'MMC#7059'
		, 'MMC#7030'
		, 'MMC#7025'
		, 'MMC#7028'
		, 'MMC#7085'
		, 'MMC#7020'
        --,'MMC#7024'
    )
		)
)



-- INPATIENTS
SELECT
    DISTINCT
    ind.PATIENTID
		, ind.MRN
		, ind.INPATIENTID
		, ind.ADMITTED
		, ind.DISCHARGED
		, ind.DISPOSITIONID
		, l.DISPOSITIONDESC
		, fac.FACILITYDESC
		, serv.SERVICEDESC
		, ns.DEPTDESC
		, prov.LASTNAME
		, SMRTXT.PRINT_GROUP
		, res."'MMC#7018'" AS FOLLOWUP_WITH_PCP
		, res."'MMC#7019'" AS FOLLOWUP_WHY_NOT
		, res."'MMC#7021'" AS FOLLOWUP_RESOLVED
		, res."'MMC#7022'" AS DC_QUESTIONS
		, res."'MMC#7023'" AS DC_QUESTIONS_TYPES
		, res."'MMC#7025'" AS DC_DEMONSTRATED_UNDERSTANDING
		, res."'MMC#7026'" AS RX_STARTED
		, res."'MMC#7028'" AS RX_RESOLVED
		, res."'MMC#7030'" AS RX_INHALER
		, res."'MMC#7031'" AS RX_INHALER_FREQ
		, res."'MMC#7034'" AS RX_HOME_OXYGEN
		, res."'MMC#7035'" AS RX_HOME_OXYGEN_FREQ
		, res."'MMC#7041'" AS CHF_SOB
		, res."'MMC#7042'" AS CHF_ORTHOPNEA
		, res."'MMC#7043'" AS CHF_TIRED
		, res."'MMC#7044'" AS CHF_SWELLING
		, res."'MMC#7045'" AS CHF_WEIGHT_GAIN
		, res."'MMC#7085'" AS CHF_KNOWS_TARGET_WEIGHT
		, res."'MMC#7048'" AS WOUND_HEALING
		, res."'MMC#7050'" AS NAUESA_VOMITING
		, res."'MMC#7051'" AS RX_AS_PRESCRIBED
		, res."'MMC#7058'" AS PAIN_SCALE
		, res."'MMC#7087'" AS FIVE_PLUS_MEDICATIONS
		, res."'MMC#7088'" AS HIGH_RISK_MEDICATIONS
		, res."'MMC#7089'" AS TELEPHARM_CONSULT
FROM EDM.INPATIENTS ind --@EDWPROD ind
    LEFT JOIN EDM.LOOKUPDISPOSITION l ON l.DISPOSITIONID = ind.DISPOSITIONID
    LEFT JOIN EDM.LOOKUPFACILITY fac ON fac.FACILITYID = ind.FACILITYID
    LEFT JOIN EDM.LOOKUPSERVICE serv ON ind.SERVICEID = serv.SERVICEID
    --	LEFT JOIN EDM.LOOKUPDEPARTMENT dep ON dep.DEPTID = ind
    LEFT JOIN EDM.LOOKUPPROVIDER prov ON ind.DISCHATTENDID = prov.PROVIDERID
    LEFT JOIN EDM.LOOKUPNURSINGSTATION ns ON ns.NURSINGSTATIONID = ind.DISCHNSID
    LEFT JOIN response res ON res.PAT_MRN_ID = ind.MRN
    LEFT JOIN JSEGE.CLARITY_HP_WPHCARES_SMARTTEXT_FIELDS_CSV smrtxt ON SMRTXT.PAT_MRN_ID = ind.MRN
WHERE 1=1
    AND fac.FACILITYDESC = 'White Plains Hospital'
    AND SERVICEDESC NOT IN ('Obstetrics', 'Gynecology', 'Newborn')

    AND IND.DISPOSITIONID  IN (2, 7, 8)
		--AND TO_DATE(ind.DISCHARGED) >= TO_DATE(current_date - 14)

 UNION ALL

 -- ED
 SELECT
    DISTINCT
    ind.PATIENTID
		, ind.MRN
		, ind.ERVISITID
		, ind.ARRIVALDATETIME
		, ind.DISCHARGED
		, ind.ERDISPOSITIONID
		, l.ERDISPOSITIONDESC
		, fac.FACILITYDESC
		, NULL AS SERVICEDESC
		, 'ER' AS DEPTDESC
		, NULL AS LASTNAME
		, SMRTXT.PRINT_GROUP
		, res."'MMC#7018'" AS FOLLOWUP_WITH_PCP
		, res."'MMC#7019'" AS FOLLOWUP_WHY_NOT
		, res."'MMC#7021'" AS FOLLOWUP_RESOLVED
		, res."'MMC#7022'" AS DC_QUESTIONS
		, res."'MMC#7023'" AS DC_QUESTIONS_TYPES
		, res."'MMC#7025'" AS DC_DEMONSTRATED_UNDERSTANDING
		, res."'MMC#7026'" AS RX_STARTED
		, res."'MMC#7028'" AS RX_RESOLVED
		, res."'MMC#7030'" AS RX_INHALER
		, res."'MMC#7031'" AS RX_INHALER_FREQ
		, res."'MMC#7034'" AS RX_HOME_OXYGEN
		, res."'MMC#7035'" AS RX_HOME_OXYGEN_FREQ
		, res."'MMC#7041'" AS CHF_SOB
		, res."'MMC#7042'" AS CHF_ORTHOPNEA
		, res."'MMC#7043'" AS CHF_TIRED
		, res."'MMC#7044'" AS CHF_SWELLING
		, res."'MMC#7045'" AS CHF_WEIGHT_GAIN
		, res."'MMC#7085'" AS CHF_KNOWS_TARGET_WEIGHT
		, res."'MMC#7048'" AS WOUND_HEALING
		, res."'MMC#7050'" AS NAUESA_VOMITING
		, res."'MMC#7051'" AS RX_AS_PRESCRIBED
		, res."'MMC#7058'" AS PAIN_SCALE
		, res."'MMC#7087'" AS FIVE_PLUS_MEDICATIONS
		, res."'MMC#7088'" AS HIGH_RISK_MEDICATIONS
		, res."'MMC#7089'" AS TELEPHARM_CONSULT
FROM EDM.ERVISITS ind --@EDWPROD ind
    LEFT JOIN EDM.LOOKUPERDISPOSITION l ON l.ERDISPOSITIONID = ind.ERDISPOSITIONID
    LEFT JOIN EDM.LOOKUPFACILITY fac ON fac.FACILITYID = ind.FACILITYID
    -- LEFT JOIN EDM.LOOKUPSERVICE serv ON ind.SERVICEID = serv.SERVICEID
    --	LEFT JOIN EDM.LOOKUPDEPARTMENT dep ON dep.DEPTID = ind
    -- LEFT JOIN EDM.LOOKUPPROVIDER prov ON ind.SEENBYMD = prov.PROVIDERID
    LEFT JOIN response res ON res.PAT_MRN_ID = ind.MRN
    LEFT JOIN JSEGE.CLARITY_HP_WPHCARES_SMARTTEXT_FIELDS_CSV smrtxt ON SMRTXT.PAT_MRN_ID = ind.MRN
WHERE 1=1
    AND fac.FACILITYDESC = 'White Plains Hospital'
    -- AND SERVICEDESC NOT IN ('Obstetrics', 'Gynecology', 'Newborn')

    AND IND.ERDISPOSITIONID  IN (3, 8)
		--AND TO_DATE(ind.DISCHARGED) >= TO_DATE(current_date - 14)
