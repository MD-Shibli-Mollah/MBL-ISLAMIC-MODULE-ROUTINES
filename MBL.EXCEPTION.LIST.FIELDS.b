*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE MBL.EXCEPTION.LIST.FIELDS
*-----------------------------------------------------------------------------
* Subroutine Description
* This Template use for Exception list
*
* ----------------------------------------------------------------------------
* Developed By : Md. Sarowar Mortoza
*                FDS Pvt Ltd
*                03/11/2020
* -------------------------------------------------------------------------------
*<doc>
* Template for field definitions routine MBL.EXCEPTION.LIST.FIELDS
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
    CALL Table.defineId("EXCEP.ID", T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
    CALL Table.addField('XX.TT.ACCOUNT.NO',T24_Account,'','')
    CALL Table.addField('XX.FT.ACCOUNT.NO',T24_Account,'','')
    CALL Table.addField("XX.VERSION", T24_String, "", "")
    CALL Table.addField("XX.CATEGORY", T24_Numeric, "", "")
    CALL Table.addField("XX.PRODUCT", T24_String, "", "")
    CALL Table.addField("XX.INPUT.USER", T24_String, "", "")
    CALL Table.addField("XX.FUTUREWORK1", T24_String, "", "")
    CALL Table.addField("XX.FUTUREWORK2", T24_String, "", "")
    CALL Table.addField("XX.FUTUREWORK3", T24_String, "", "")
    CALL Table.addField("XX.FUTUREWORK4", T24_String, "", "")
    CALL Table.addField("XX.FUTUREWORK5", T24_String, "", "")
    CALL Table.addField("XX.FUTUREWORK6", T24_String, "", "")
    CALL Table.addReservedField('RESERVED.10')
    CALL Table.addReservedField('RESERVED.09')
    CALL Table.addReservedField('RESERVED.08')
    CALL Table.addReservedField('RESERVED.07')
    CALL Table.addReservedField('RESERVED.06')
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
