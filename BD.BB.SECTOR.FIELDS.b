*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE BD.BB.SECTOR.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine EXIM.CB.SEC.CODE.FIELDS
*
* @author mortoza@datasoft-bd.com
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
    CALL Table.defineId("BB.SEC.ID", T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
*    CALL Table.addField("DESCRIPTION", T24_String, "", "")
    CALL Table.addFieldDefinition("DESCRIPTION","65","A","")
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
