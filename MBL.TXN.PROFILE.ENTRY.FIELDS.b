* @ValidationCode : MjotNzc1MTIyMTM0OkNwMTI1MjoxNTkyODAyMDY5NTgzOkRFTEw6LTE6LTE6MDowOnRydWU6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 22 Jun 2020 11:01:09
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
SUBROUTINE MBL.TXN.PROFILE.ENTRY.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine MBL.TXN.PROFILE.ENTRY.FIELDS
*
* @author tcoleman@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package infra.eb
* </doc>
*-----------------------------------------------------------------------------
* Developed By- s.azam@fortress-global.com
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
    CALL Table.defineId("TXN.ENTRY.ID", T24_String) ;* Define Table id
*-----------------------------------------------------------------------------
*------For Deposit---------------------------------------------------------------------
    CALL Table.addField("HDR.DEP.CSH", T24_String, "", "") ;* Add a new field
    CALL Table.addField("CASH.DEP.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("CASH.DEP.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("CASH.DEP.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("CASH.DEP.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "")

    CALL Table.addField("HDR.DEP.TRF", T24_String, "", "") ;* Add a new field
    CALL Table.addField("TRF.DEP.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("TRF.DEP.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("TRF.DEP.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("TRF.DEP.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.DEP.RMT", T24_String, "", "") ;* Add a new field
    CALL Table.addField("RMT.DEP.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("RMT.DEP.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("RMT.DEP.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("RMT.DEP.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.DEP.EXP", T24_String, "", "") ;* Add a new field
    CALL Table.addField("EXP.DEP.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("EXP.DEP.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("EXP.DEP.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("EXP.DEP.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.DEP.BOA", T24_String, "", "") ;* Add a new field
    CALL Table.addField("BOA.DEP.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("BOA.DEP.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("BOA.DEP.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("BOA.DEP.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.DEP.OTH", T24_String, "", "") ;* Add a new field
    CALL Table.addField("OTH.DEP.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("OTH.DEP.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("OTH.DEP.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("OTH.DEP.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.DEP.RES", T24_String, "", "") ;* Add a new field
    CALL Table.addField("RES.DEP.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("RES.DEP.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("RES.DEP.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("RES.DEP.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.DEP.TOT", T24_String, "", "") ;* Add a new field
    CALL Table.addField("TOT.DEP.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("TOT.DEP.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("TOT.DEP.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("TOT.DEP.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
*------End Deposit---------------------------------------------------------------------
*------For Withdraw--------------------------------------------------------------------
    CALL Table.addField("HDR.WDL.CSH", T24_String, "", "") ;* Add a new field
    CALL Table.addField("CASH.WITH.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("CASH.WITH.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("CASH.WITH.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("CASH.WITH.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.WDL.TRF", T24_String, "", "") ;* Add a new field
    CALL Table.addField("TRF.WITH.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addField("TRF.WITH.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("TRF.WITH.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("TRF.WITH.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.WDL.RMT", T24_String, "", "") ;* Add a new field
    CALL Table.addField("RMT.WITH.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("RMT.WITH.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("RMT.WITH.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("RMT.WITH.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.WDL.IMP", T24_String, "", "") ;* Add a new field
    CALL Table.addField("IMP.WITH.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("IMP.WITH.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("IMP.WITH.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("IMP.WITH.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.WDL.BOA", T24_String, "", "") ;* Add a new field
    CALL Table.addField("BOA.WITH.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("BOA.WITH.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("BOA.WITH.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("BOA.WITH.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.WDL.OTH", T24_String, "", "") ;* Add a new field
    CALL Table.addField("OTH.WITH.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("OTH.WITH.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("OTH.WITH.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("OTH.WITH.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.WDL.RES", T24_String, "", "") ;* Add a new field
    CALL Table.addField("RES.WITH.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("RES.WITH.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("RES.WITH.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("RES.WITH.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field

    CALL Table.addField("HDR.WDL.TOT", T24_String, "", "") ;* Add a new field
    CALL Table.addField("TOT.WITH.OCCPY.TXN", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("TOT.WITH.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
    CALL Table.addField("TOT.WITH.TXN.REF", T24_String, "", "") ;* Add a new field
    CALL Table.addAmountField("TOT.WITH.TOT.TXN.AMT", "CURRENCY", "Field_AllowNegative", "") ;* Add a new field
*------End Withdraw---------------------------------------------------------------------
    
    CALL Table.addReservedField('RESERVED.5')
    CALL Table.addReservedField('RESERVED.4')
    CALL Table.addReservedField('RESERVED.3')
    CALL Table.addReservedField('RESERVED.2')
    CALL Table.addReservedField('RESERVED.1')
    CALL Table.addOverrideField
    
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
