*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE MBL.SMS.TXN.INFO.FIELDS
*-----------------------------------------------------------------------------
* Subroutine Description:
* THIS TEMPALTE IS USE FOR SMS TXN INFORMATION STORE
*-----------------------------------------------------------------------------
* Modification History :
* 08/04/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*------------------------------------------------------------------------------
*<doc>
* Template for field definitions routine MBL.SMS.TXN.INFO.FIELDS
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
    CALL Table.defineId("SMS.TXN.AC.ID", T24_String)
*    ID.N = '18'
*    ID.CHECKFILE = 'ACCOUNT'
*-----------------------------------------------------------------------------
    CALL Table.addField("CUSTOMER.NO", T24_Customer, "", "")
    CALL Table.addField("ACCOUNT.NO", T24_Account, "", "")
    CALL Table.addFieldDefinition("SMS.QTY","8","","")
    CALL Table.addFieldDefinition("DATE", "8", "D", "")
    CALL Table.addField("AC.CO.CODE", T24_String, "", "")
    CALL Field.setCheckFile('COMPANY')
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
