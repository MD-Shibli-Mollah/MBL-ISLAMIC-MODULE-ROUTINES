*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE BD.SME.CODE.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine BD.SME.CODE.FIELDS
*
* @author tcoleman@temenos.com
*                FDS Pvt Ltd
*                09/10/2019
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
    CALL Table.defineId("BD.SME.ID", T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
    CALL Table.addField("ENTERPRISE", T24_String, "", "")
    CALL Table.addField("FIXED.ASSET", T24_String, "", "")
    CALL Table.addField("NO.OF.EMPLOYEE", T24_String, "", "")
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
