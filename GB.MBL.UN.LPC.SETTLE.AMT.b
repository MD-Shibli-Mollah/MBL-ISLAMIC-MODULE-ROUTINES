* @ValidationCode : MjoxODI5NjIwNDQ2OkNwMTI1MjoxNTkyNTA1OTgxMzcyOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Jun 2020 00:46:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.UN.LPC.SETTLE.AMT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine update template for LPC
*Subroutine Type       : After auth
*Attached To           : version
*Attached As           : ROUTINE
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
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BD.MBL.LPC.CHARGE.REC
    
    $USING EB.SystemTables
    $USING FT.Contract
    $USING EB.DataAccess
    $USING AC.AccountOpening
    $USING EB.LocalReferences
    $USING EB.ErrorProcessing
    $USING EB.Updates
    $USING TT.Contract
    
*-----------------------------------------------------------------------------

*---------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*---------------------------------------------------------------------
******
INIT:
******
    FN.LPC.CRG = 'F.BD.MBL.LPC.CHARGE.REC'
    F.LPC.CRG = ''
    FN.ACC = 'F.ACCOUNT'
    F.ACC = ''
    FN.FT = 'F.FUNDS.TRANSFER'
    F.FT = ''
    
RETURN
**********
OPENFILES:
**********
*EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.LPC.CRG, F.LPC.CRG)
    EB.DataAccess.Opf(FN.ACC, F.ACC)
    EB.DataAccess.Opf(FN.FT, F.FT)
RETURN
********
PROCESS:
********
    Y.APPLICATION = EB.SystemTables.getApplication()
    IF Y.APPLICATION EQ 'FUNDS.TRANSFER' THEN
        Y.ARR.ACCT.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
        Y.LPC.ADJUST.AMT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAmount)
    END
    IF Y.APPLICATION EQ 'TELLER' THEN
        Y.ARR.ACCT.ID = EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
        Y.LPC.ADJUST.AMT = EB.SystemTables.getRNew(TT.Contract.Teller.TeAmountLocalOne)
    END

    EB.DataAccess.FRead(FN.ACC, Y.ARR.ACCT.ID, REC.ARR, F.ACC, ERR)
    Y.ARR.ID = REC.ARR<AC.AccountOpening.Account.ArrangementId>
    
    Y.LPC.CRG.ID = Y.ARR.ID
    EB.DataAccess.FRead(FN.LPC.CRG, Y.LPC.CRG.ID, REC.LPC, F.LPC.CRG, REC.ERROR)
    IF REC.LPC THEN
        Y.DUE.AMT = REC.LPC<LPC.TOT.DUE.AMT>
        Y.REALIZE.AMT = REC.LPC<LPC.TOT.REALIZE.AMT>
        REC.LPC<LPC.TOT.REALIZE.AMT> = Y.REALIZE.AMT+Y.LPC.ADJUST.AMT
        REC.LPC<LPC.TOT.DUE.AMT> =  (Y.DUE.AMT-Y.LPC.ADJUST.AMT)
        WRITE REC.LPC TO F.LPC.CRG,Y.LPC.CRG.ID
    END
  
RETURN
END
