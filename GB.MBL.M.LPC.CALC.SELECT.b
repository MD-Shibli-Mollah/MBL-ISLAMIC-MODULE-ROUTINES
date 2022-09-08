* @ValidationCode : MjoxNzAyNDEzOTA3OkNwMTI1MjoxNTkxMjc2ODUwNjI4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 04 Jun 2020 19:20:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.M.LPC.CALC.SELECT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine calculate LPC due amount
*Subroutine Type       : Service
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
    $INSERT I_F.GB.MBL.M.LPC.CALC.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.BD.MBL.LPC.CHARGE.REC
     
    $USING EB.Service
    $USING EB.DataAccess
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    GOSUB SELECT.LIST
RETURN
   
SELECT.LIST:
    Y.MNEMONIC = FN.AA[2,3]
    IF Y.MNEMONIC EQ 'BNK' THEN
        SEL.CMD = 'SELECT ':FN.AA:' WITH ACTIVE.PRODUCT EQ MBL.MSS.DP AND ARR.STATUS EQ CURRENT'
        EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, EB.ERR)
    END
    IF Y.MNEMONIC EQ 'ISL' THEN
        SEL.CMD = 'SELECT ':FN.AA:' WITH PRODUCT.GROUP EQ IS.MBL.MMSP.DP AND ARR.STATUS EQ CURRENT'
        EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, EB.ERR)
    END
    GOSUB BATCH.RUN
RETURN

BATCH.RUN:
    EB.Service.BatchBuildList('', SEL.LIST)
RETURN
END
