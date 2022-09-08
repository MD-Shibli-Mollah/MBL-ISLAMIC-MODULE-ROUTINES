*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE MBL.TXN.LIMIT.ACCTWISE.FIELDS
*-----------------------------------------------------------------------------
* Subroutine Description:
* THIS TEMPALTE IS USE FOR BB COMPLIANCE ACCOUT WISE TXN LIMIT
*-----------------------------------------------------------------------------
* Modification History :
* 31/03/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*------------------------------------------------------------------------------
*<doc>
* Template for field definitions routine MBL.TXN.LIMIT.ACCTWISE.FIELDS
*
* @author tcoleman@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package infra.eb
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*
* 19/10/07 - EN_10003543
*            New Template changes
*
* 14/11/07 - BG_100015736
*            Exclude routines that are not released
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("TXN.LIMIT.ID", T24_Account)
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition("DR.TXN.LMT","20","AMT","")
    CALL Table.addFieldDefinition("CR.TXN.LMT","20","AMT","")
    CALL Table.addFieldDefinition("ONLINE.DR.TXN.LMT","20","AMT","")
    CALL Table.addFieldDefinition("ONLINE.CR.TXN.LMT","20","AMT","")
    CALL Table.addField("REMARKS", T24_String, "", "")
    CALL Table.addReservedField('RESERVED.05')
    CALL Table.addReservedField('RESERVED.04')
    CALL Table.addReservedField('RESERVED.03')
    CALL Table.addReservedField('RESERVED.02')
    CALL Table.addReservedField('RESERVED.01')
    CALL Table.addLocalReferenceField('XX.LOCAL.REF')
    CALL Table.addOverrideField
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
