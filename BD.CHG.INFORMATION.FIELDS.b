* @ValidationCode : MjoxNzQzNTEwOTMzOkNwMTI1MjoxNTkyNTUwMzQ5MTU1OkRFTEw6LTE6LTE6MDowOnRydWU6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Jun 2020 13:05:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201710.0
*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE BD.CHG.INFORMATION.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine BD.CHG.INFORMATION.FIELDS
*
* @author tcoleman@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package infra.eb
* </doc>
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
* 1)
*    Date :
*    Modification Description :
*    Modified By  :
*
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("CHG.ID", T24_String) ;* Define Table id
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    CALL Table.addField('XX<CHG.TXN.DATE', T24_Date, Field_NoInput, '')
    CALL Table.addAmountField('XX-CHG.BASE.AMT', 'CURRENCY',Field_NoInput, '')
    CALL Table.addAmountField('XX-CHG.SLAB.AMT', 'CURRENCY',Field_NoInput, '')
    CALL Table.addField('XX-CHG.TXN.REFNO', T24_String, Field_NoInput, '')
    CALL Table.addAmountField('XX-CHG.TXN.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addAmountField('XX-CHG.TXN.DUE.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addOptionsField('XX>CHG.TXN.FLAG', 'SCHEDULE_SERVICE', Field_NoInput, '')
    CALL Table.addAmountField('TOTAL.CHG.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addAmountField('TOTAL.REALIZE.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addAmountField('OS.DUE.AMT', 'CURRENCY', Field_NoInput, '')
    CALL Table.addOptionsField('CHG.WAVE', 'YES_NO', '', '')
    CALL Table.addField('REMARKS', T24_String, '', '')
    CALL Table.addField('PRODUCT.GROUP', T24_String, Field_NoInput, '')
    CALL Table.addField('XX.LOCAL.REF', T24_String, Field_NoInput,'')
*-----------------------------------------------------------------------------
    CALL Table.addReservedField('RESERVED.5')
    CALL Table.addReservedField('RESERVED.4')
    CALL Table.addReservedField('RESERVED.3')
    CALL Table.addReservedField('RESERVED.2')
    CALL Table.addReservedField('RESERVED.1')
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
