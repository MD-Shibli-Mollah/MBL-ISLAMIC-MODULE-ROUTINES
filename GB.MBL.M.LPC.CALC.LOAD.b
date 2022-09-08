* @ValidationCode : MjotMzYxNTg5NTQ2OkNwMTI1MjoxNTg2MjU1Mzc4Njc3OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 07 Apr 2020 16:29:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.M.LPC.CALC.LOAD
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
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.BD.MBL.LPC.CHARGE.REC
    
    $USING AA.Account
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING EB.DataAccess
    $USING EB.LocalReferences
    $USING AA.TermAmount
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
RETURN

INIT:
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    FN.AA.AC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.AC = ''
    Y.COUNT = ''
    FN.AA.ARR.ACC='F.AA.ARR.ACCOUNT'
    F.AA.ARR.ACC=''
    FN.LPC.CRG = 'F.BD.MBL.LPC.CHARGE.REC'
    F.LPC.CRG = ''
    Y.CHARGE = 0
    Y.DUE.AMT = 0
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.AA.AC, F.AA.AC)
    EB.DataAccess.Opf(FN.AA.ARR.ACC, F.AA.ARR.ACC)
    EB.DataAccess.Opf(FN.LPC.CRG, F.LPC.CRG)
RETURN

END
