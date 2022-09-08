*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE MBL.ONLINE.TXN.INFO.FIELDS
*-----------------------------------------------------------------------------
* Subroutine Description:
* THIS TEMPALTE IS USE AFTER ONLINE TT TRANSACTION IS AUTHORIZE THEN IT WRITE INTO
* LOCAL TABLE MBL.ONLINE.TXN.INFO
*-----------------------------------------------------------------------------
* Modification History :
* 07/04/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*<doc>
* Template for field definitions routine MBL.ONLINE.TXN.INFO.FIELDS
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
    CALL Table.defineId("ONLINE.TXN.AC.ID", T24_String)
*-----------------------------------------------------------------------------
    CALL Table.addField("AC.CATEGORY", T24_String, "", "")
    CALL Table.addField("XX<REF.NO", T24_String, "", "")
    CALL Table.addFieldDefinition("XX-DATE", "8", "D", "")
    CALL Table.addField("XX-DR.OR.CR", T24_String, "", "")
    CALL Table.addFieldDefinition("XX-AMOUNT","20","AMT","")
    CALL Table.addField("XX>OP.CO.CODE", T24_String, "", "")
    CALL Table.addField("AC.CO.CODE", T24_String, "", "")
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
