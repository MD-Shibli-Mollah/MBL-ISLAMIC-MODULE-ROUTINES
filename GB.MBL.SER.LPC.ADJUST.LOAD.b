* @ValidationCode : MjotMTI4MzU4NDU0OkNwMTI1MjoxNTg2MjU1NjU2Njc1OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 07 Apr 2020 16:34:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.SER.LPC.ADJUST.LOAD
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine adjust LPC due
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
    $INSERT I_F.GB.MBL.SER.LPC.ADJUST.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ARRANGEMENT
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
    Y.COUNT = ''
    FN.LPC.CRG = 'F.BD.MBL.LPC.CHARGE.REC'
    F.LPC.CRG = ''
    Y.CHARGE = 0
    Y.DUE.AMT = 0
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.LPC.CRG, F.LPC.CRG)
RETURN

END
