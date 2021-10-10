/*
Author			: Dona Bou Eid
Creation Date	: September 24, 2020
Description		:
Approx Run Time	:
Dependencies	:

Modified Date	:
Modified By		:
Modified Notes	:

TXPORT_REQ_INFO
ZC_TXPORT_TYPE
ZC_ASGN_STATUS
ZC_TXPORT_PRI
ZC_TXPORT_MODE
ZC_TXPORT_REQ_SRC


TXPORT_PAT_CSN is used to join to any table with csn id (clarity dictionary) but contains nulls so I added TXPORT_ADMIT_CSN & TXPORT_PAT_OUT_CSN
*/
----------
select tx.TRANSPORT_ID
, tx.TXPORT_DATE
, tx.TXPORT_TIME
, tx.REGION_ID
, tx.SECTOR_ID
, tx.PAT_ID
, tx_typ.NAME AS TXPORT_TYPE
, pat.PAT_MRN_ID
, tx.TXPORT_PAT_CSN -- JOIN ON F_ED_ENC
, tx.TXPORT_ADMIT_CSN -- added since txport_pat_csn has nulls
, tx.TXPORT_PAT_OUT_CSN
, tx.LOC_ID as SERVICE_AREA_ID
, tx.NUM_TRANSPORTERS
, tx.REQ_USER_ID
, tx.TOTAL_TIME_DELAYED_SECONDS
--, REV_LOC_ID -- unsure if that's the same as LOC_ID?
, tx.CURRENT_STATUS_C
, tx.PRIORITY_C
, tx.TXPORT_TYPE_C
, tx.REQUEST_SOURCE_C
, tx.PARENT_REQUEST_ID
, tx_mode.NAME TXPORT_MODE
, tx.TXPORT_FROM_TYPE_C
, TX.REQ_DEP_ID
, dep.DEPARTMENT_NAME
, adt.COMPLETION_HKR_ID
, adt.COMPLETION_HKR_NAME
--, pend.START_TIME as TXPORT_PEND_UTC_DTTM

from TXPORT_REQ_INFO@CLRPROD tx
inner join PATIENT@CLRPROD pat on pat.PAT_ID = tx.PAT_ID
-- inner join TXPORT_XFER_PND_ID pend on pend.pat_enc_csn_id = tx.TXPORT_PAT_CSN
inner join ZC_TXPORT_TYPE@CLRPROD tx_typ on tx_typ.TXPORT_TYPE_C = tx.TXPORT_TYPE_C
inner join ZC_TXPORT_MODE@CLRPROD tx_mode on tx_mode.TXPORT_MODE_C = tx.TXPORT_MODE_C
inner join CLARITY_DEP@CLRPROD dep on dep.DEPARTMENT_ID = tx.REQ_DEP_ID
inner join V_ADT_TRANSPORT@CLRPROD adt ON adt.TRANSPORT_ID = tx.TRANSPORT_ID
--inner join CLARITY_LOC loc on loc.LOC_ID = tx.rev_loc_id

where tx.PAT_ID is not null -- found lots of nulls
and tx.CURRENT_STATUS_C <> 6 -- remove cancelled
and tx.CANCEL_EVENT_DTTM is NULL
and REGEXP_LIKE(dep.DEPARTMENT_NAME, '(white plains)|(wph)', 'i')
