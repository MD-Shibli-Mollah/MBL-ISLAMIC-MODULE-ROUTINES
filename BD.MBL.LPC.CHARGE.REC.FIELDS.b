* @ValidationCode : MjoxNjU0MTc0OTI3OkNwMTI1MjoxNTkyNzUzMDcyOTQyOkRFTEw6LTE6LTE6MDowOnRydWU6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Jun 2020 21:24:32
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
SUBROUTINE BD.MBL.LPC.CHARGE.REC.FIELDS
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: TEMPLATE for LPC cherge
*Subroutine Type       : TEMPLATE for LPC cherge
*Attached To           :
*Attached As           :
*Developed by          : S.M. Sayeed
*Designation           : Technical Consultant
*Email                 : s.m.sayeed@fortress-global.com
*Incoming Parameters   :
*Outgoing Parameters   :
*-----------------------------------------------------------------------------
* Modification History :
* 1)
*    Date :
*    Modification Description :
*    Modified By  :
*
*-----------------------------------------------------------------------------
*
*1/S----Modification Start
*
*1/E----Modification End
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("LPC.ADJUST.ID", T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
    CALL Table.addFieldDefinition('XX<DUE.DATE','8', 'D', '')
    CALL Table.addFieldDefinition('XX>AMT.THIS.DATE', '19','AMT','')
    CALL Table.addFieldDefinition('TOT.CHRG.AMT', '19','AMT','')
    CALL Table.addFieldDefinition('TOT.REALIZE.AMT', '19','AMT','')
    CALL Table.addFieldDefinition('TOT.DUE.AMT', '19','AMT','')
    CALL Table.addFieldDefinition('COM.CODE', '35','A', '')
*-----------------------------------------------------------------------------
    CALL Table.addReservedField('RESERVED.5')
    CALL Table.addReservedField('RESERVED.4')
    CALL Table.addReservedField('RESERVED.3')
    CALL Table.addReservedField('RESERVED.2')
    CALL Table.addReservedField('RESERVED.1')
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition
RETURN
*-----------------------------------------------------------------------------
END
