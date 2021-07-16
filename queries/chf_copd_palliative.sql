select
hi.PAT_ID
,mrn.MRN
,hi.PAT_ENC_CSN_ID
,hi.NOTE_ID
,NVL(hi.IP_NOTE_TYPE_C, nei.NOTE_TYPE_C) AS Note_Type_C --get either inpatient or outpatient note ID
,NVL(znti.NAME, znt.NAME) AS Note_Type
,st.SMARTTEXT_ID
,st.SMARTTEXT_NAME
,hi.CRT_INST_LOCAL_DTTM AS Note_Created_Dttm
, nei.UPD_AUT_LOCAL_DTTM AS Note_Last_Updated_Dttm
, nei.COSIGN_INST_LOCAL_DTTM AS Note_Cosigned_Dttm
, nei.NOT_FILETM_LOC_DTTM AS Note_Filed_Dttm
,nei.NOTE_STATUS_C
, zns.NAME AS Note_Status
,nei.AUTHOR_USER_ID
, emp1.NAME AS Author_Name
, ser1.PROV_TYPE AS Author_Prov_Type
,nei.COSIGNUSER_ID
, emp2.NAME AS Cosign_Name
, ser2.PROV_TYPE AS Cosign_Prov_Type
, row_number() over (partition by hi.PAT_ID, hi.PAT_ENC_CSN_ID, hi.NOTE_ID, nei.NOTE_STATUS_C order by nei.UPD_AUT_LOCAL_DTTM) AS noteRowRank --need ranking to de-duplicate views
from HNO_INFO@CLRPROD hi
INNER JOIN NOTE_ENC_INFO@CLRPROD nei
	on nei.NOTE_ID = hi.NOTE_ID
left join CLARITY_EMP@CLRPROD emp1
	on emp1.USER_ID = nei.AUTHOR_USER_ID
left join CLARITY_SER@CLRPROD ser1
	on ser1.PROV_ID = emp1.PROV_ID
left join CLARITY_EMP@CLRPROD emp2
	on emp2.USER_ID = nei.COSIGNUSER_ID
left join CLARITY_SER@CLRPROD ser2
	on ser2.PROV_ID = emp2.PROV_ID
left join ZC_NOTE_TYPE_IP@CLRPROD znti
	on znti.TYPE_IP_C = hi.IP_NOTE_TYPE_C
left join ZC_NOTE_TYPE@CLRPROD znt
	on znt.NOTE_TYPE_C = nei.NOTE_TYPE_C
left join ZC_NOTE_STATUS@CLRPROD zns
	on zns.NOTE_STATUS_C = nei.NOTE_STATUS_C
left join NOTE_SMARTTEXT_IDS@CLRPROD nsi
	on nsi.NOTE_ID = hi.NOTE_ID
left join SMARTTEXT@CLRPROD st
	on st.SMARTTEXT_ID = nsi.SMARTTEXTS_ID
left join
	(
	select
	PAT_ID
	,IDENTITY_ID as MRN
	, IDENTITY_TYPE_ID
	, dense_rank() over (partition by PAT_ID order by LINE asc) AS rn
	from IDENTITY_ID@CLRPROD
	where IDENTITY_TYPE_ID = 14
	) mrn
	on mrn.PAT_ID = hi.PAT_ID
	and mrn.RN = 1
where hi.CRT_INST_LOCAL_DTTM is not null --exclude notes that do not have a creation time
and hi.PAT_ENC_CSN_ID is not null --exclude notes not linked to an encounter
and hi.CRT_INST_LOCAL_DTTM >= TO_DATE('2021-05-01', 'YYYY-MM-DD') --exclude notes created before WPH Epic go-live
AND MRN IN (
	'05860197'
,	'05860197'
,	'05553892'
,	'09033224'
,	'01178164'
,	'05995008'
,	'03954028'
,	'05952012'
,	'06373181'
,	'05848950'
,	'06633648'
,	'02658249'
,	'06684189'
,	'05666274'
,	'02627186'
,	'05501855'
,	'05502294'
,	'01348271'
,	'09045809'
,	'02354153'
,	'02158530'
,	'09044004'
,	'06135450'
,	'06184707'
,	'03046238'
,	'05655528'
,	'08012756'
,	'03835535'
,	'02076519'
,	'06002636'
,	'01290209'
,	'08000823'
,	'05698600'
,	'06616093'
,	'00547154'
,	'05502655'
,	'00501432'
,	'02039166'
,	'07335885'
,	'08002083'
,	'07599387'
,	'07273176'
,	'01331294'
,	'05664363'
,	'05844075'
,	'01017964'
,	'05648090'
,	'02680159'
,	'03509596'
,	'07375863'
,	'05581992'
,	'03691210'
,	'05924274'
,	'07896114'
,	'05968575'
,	'06523125'
,	'05929623'
,	'05789166'
,	'05613829'
,	'07461706'
,	'05559181'
,	'03400507'
,	'05826653'
,	'02512896'
,	'02342003'
,	'06691697'
,	'02866974'
,	'03894211'
,	'06170387'
,	'05609679'
,	'03750128'
,	'09034699'
,	'06605176'
,	'02053711'
)
AND REGEXP_LIKE(SMARTTEXT_NAME, 'PALL', 'i')
