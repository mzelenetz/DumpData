/*
* Get the stroke team notifcations from yesterday
* This replaces the "code grey report"
* Look to see if they documented stroke team activation = yes in stroke flowsheet
*/

select DISTINCT a.mrn,
    a.NATIVEACCTNUMID AS HAR,
    FINDINGDATETIME AS DocumentedDate,
    nativefinding AS Response
from edm.findings_all@edwprod a
    LEFT JOIN edm.lookupfinding@edwprod b ON a.findingtypeid = b.findingtypeid
    LEFT JOIN
    (
		        SELECT NATIVEACCTNUMID, FACILITYID
        FROM edm.INPATIENTS@edwprod i
    UNION ALL
        SELECT NATIVEACCTNUMID, FACILITYID
        FROM edm.ERVISITS@edwprod e 
	)i ON i.NATIVEACCTNUMID = a.NATIVEACCTNUMID
    LEFT JOIN edm.LOOKUPFACILITY fac ON fac.FACILITYID = i.FACILITYID
where a.findingtypeid in (400000611, 400000824) -- Stroke team activation
    and findingdatetime >= '01-may-21'
    AND REGEXP_LIKE(fac.FACILITYDESC, '(wph)|(white plains)', 'i')
    AND NATIVEFINDING != 'No'
    AND TRUNC(FINDINGDATETIME) = TRUNC(SYSDATE) - 1