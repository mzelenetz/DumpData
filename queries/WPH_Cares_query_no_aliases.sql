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

      'MMC#7018'
    , 'MMC#7019'
    , 'MMC#7020'
    , 'MMC#7021'
    , 'MMC#7022'
    , 'MMC#7023'
    , 'MMC#7024'
    , 'MMC#7025'
    , 'MMC#7026'
    , 'MMC#7028'
    , 'MMC#7030'
    , 'MMC#7031'
    , 'MMC#7034'
    , 'MMC#7035'
    , 'MMC#7041'
    , 'MMC#7042'
    , 'MMC#7043'
    , 'MMC#7044'
    , 'MMC#7045'
    , 'MMC#7046'
    , 'MMC#7047'
    , 'MMC#7048'
    , 'MMC#7050'
    , 'MMC#7051'
    , 'MMC#7058'
    , 'MMC#7059'
    , 'MMC#7060'
    , 'MMC#7061'
    , 'MMC#7063'
    , 'MMC#7071'
    , 'MMC#7085'
    , 'MMC#7086'
    , 'MMC#7087'
    , 'MMC#7088'
    , 'MMC#7089'

		--   'MMC#7087'
		-- , 'MMC#7044'
		-- , 'MMC#7046'
		-- , 'MMC#7026'
		-- , 'MMC#7034'
		-- , 'MMC#7050'
		-- , 'MMC#7051'
		-- , 'MMC#7089'
		-- , 'MMC#7058'
		-- , 'MMC#7061'
		-- , 'MMC#7023'
		-- , 'MMC#7024'
		-- , 'MMC#7088'
		-- , 'MMC#7018'
		-- , 'MMC#7060'
		-- , 'MMC#7043'
		-- , 'MMC#7045'
		-- , 'MMC#7019'
		-- , 'MMC#7086'
		-- , 'MMC#7031'
		-- , 'MMC#7021'
		-- , 'MMC#7042'
		-- , 'MMC#7047'
		-- , 'MMC#7022'
		-- , 'MMC#7063'
		-- , 'MMC#7035'
		-- , 'MMC#7048'
		-- , 'MMC#7041'
		-- , 'MMC#7059'
		-- , 'MMC#7030'
		-- , 'MMC#7025'
		-- , 'MMC#7028'
		-- , 'MMC#7085'
		-- , 'MMC#7020'
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
    , res.'MMC#7018'
    , res.'MMC#7019'
    , res.'MMC#7020'
    , res.'MMC#7021'
    , res.'MMC#7022'
    , res.'MMC#7023'
    , res.'MMC#7024'
    , res.'MMC#7025'
    , res.'MMC#7026'
    , res.'MMC#7028'
    , res.'MMC#7030'
    , res.'MMC#7031'
    , res.'MMC#7034'
    , res.'MMC#7035'
    , res.'MMC#7041'
    , res.'MMC#7042'
    , res.'MMC#7043'
    , res.'MMC#7044'
    , res.'MMC#7045'
    , res.'MMC#7046'
    , res.'MMC#7047'
    , res.'MMC#7048'
    , res.'MMC#7050'
    , res.'MMC#7051'
    , res.'MMC#7058'
    , res.'MMC#7059'
    , res.'MMC#7060'
    , res.'MMC#7061'
    , res.'MMC#7063'
    , res.'MMC#7071'
    , res.'MMC#7085'
    , res.'MMC#7086'
    , res.'MMC#7087'
    , res.'MMC#7088'
    , res.'MMC#7089'
FROM EDM.INPATIENTS@EDWPROD ind
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
    , res."'MMC#7018'" AS "MMC#7018"
		, res."'MMC#7019'" AS "MMC#7019"
		, res."'MMC#7021'" AS "MMC#7021"
		, res."'MMC#7022'" AS "MMC#7022"
		, res."'MMC#7023'" AS "MMC#7023"
		, res."'MMC#7025'" AS "MMC#7025"
		, res."'MMC#7026'" AS "MMC#7026"
		, res."'MMC#7028'" AS "MMC#7028"
		, res."'MMC#7030'" AS "MMC#7030"
		, res."'MMC#7031'" AS "MMC#7031"
		, res."'MMC#7034'" AS "MMC#7034"
		, res."'MMC#7035'" AS "MMC#7035"
		, res."'MMC#7041'" AS "MMC#7041"
		, res."'MMC#7042'" AS "MMC#7042"
		, res."'MMC#7043'" AS "MMC#7043"
		, res."'MMC#7044'" AS "MMC#7044"
		, res."'MMC#7045'" AS "MMC#7045"
		, res."'MMC#7085'" AS "MMC#7085"
		, res."'MMC#7048'" AS "MMC#7048"
		, res."'MMC#7050'" AS "MMC#7050"
		, res."'MMC#7051'" AS "MMC#7051"
		, res."'MMC#7058'" AS "MMC#7058"
		, res."'MMC#7087'" AS "MMC#7087"
		, res."'MMC#7088'" AS "MMC#7088"
		, res."'MMC#7089'" AS "MMC#7089"
FROM EDM.ERVISITS@EDWPROD ind
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
