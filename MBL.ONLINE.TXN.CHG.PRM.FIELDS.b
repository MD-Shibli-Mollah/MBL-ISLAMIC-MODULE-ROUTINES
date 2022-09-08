*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE MBL.ONLINE.TXN.CHG.PRM.FIELDS
*-----------------------------------------------------------------------------
* Subroutine Description:
* THIS TEMPALTE IS USE FOR ONLINE TXN PARAMETER
*-----------------------------------------------------------------------------
* Modification History :
* 07/04/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*------------------------------------------------------------------------------
*<doc>
* Template for field definitions routine MBL.ONLINE.TXN.CHG.PRM.FIELDS
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
    CALL Table.defineId("ONLINE.CATG.ID", T24_String)
    ID.CHECKFILE ='AA.PRODUCT.GROUP'
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition("XX<FROM.AMT","20","AMT","")
    CALL Table.addFieldDefinition("XX-TO.AMT","20","AMT","")
    CALL Table.addFieldDefinition("XX>CHG.AMT","5","AMT","")
    CALL Table.addField("XX.EXCLUDE.PRODUCT.ID", T24_String, "", "")
    CALL Field.setCheckFile('AA.PRODUCT.DESIGNER')
    CALL Table.addField("XX<EXCEPTION.PRODUCT.ID", T24_String, "", "")
    CALL Field.setCheckFile('AA.PRODUCT.DESIGNER')
    CALL Table.addFieldDefinition("XX-XX<EXCEPTION.FROM.AMT","20","AMT","")
    CALL Table.addFieldDefinition("XX-XX-EXCEPTION.TO.AMT","20","AMT","")
    CALL Table.addFieldDefinition("XX>XX>EXCEPTION.CHG.AMT","5","AMT","")
*    CALL Table.addField("MIN.CHARG.AMT",T24_Numeric, Field_Mandatory, "")
    CALL Table.addFieldDefinition("MIN.CHARG.AMT","5","AMT","")
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
