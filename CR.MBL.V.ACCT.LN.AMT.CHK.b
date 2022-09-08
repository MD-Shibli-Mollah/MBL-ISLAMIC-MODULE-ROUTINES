*-----------------------------------------------------------------------------
*Subroutine Description: CC Loan Amount Check with Limit Amount
*Subroutine Type       : Validation Routine(DEBIT.AMOUNT)
*Attached To           : Version(FUNDS.TRANSFER,MBL.ACCT.ACTR)
*Attached As           : ROUTINE
*Developed by          : MEHEDI
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
SUBROUTINE CR.MBL.V.ACCT.LN.AMT.CHK
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $USING EB.SystemTables
    $USING FT.Contract
    $USING EB.DataAccess
    $USING AA.Framework
    $USING AA.Settlement
    $USING EB.LocalReferences
    $USING AA.Account
    $USING AC.AccountOpening
    $USING EB.ErrorProcessing
*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
*
RETURN
*-----------------------------------------------------------------------------
*-------
INIT:
*-------
    FN.FT = 'FBNK.FUNDS.TRANSFER'
    F.FT = ''
*
    FN.ACCT = 'F.ACCOUNT'
    F.ACCT = ''
RETURN
*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.ACCT, F.ACCT)
RETURN
*---------
PROCESS:
*---------
*Y.FT.ID = EB.SystemTables.getIdNew()
*-------Debit Account Check----------
    Y.DR.ACCT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
    EB.DataAccess.FRead(FN.ACCT,Y.DR.ACCT  ,REC.ACCT.ID, F.ACCT.ID, ERR.ACCT.ID)
    Y.DR.AA.ID = REC.ACCT.ID<AC.AccountOpening.Account.ArrangementId>
    Y.DR.AMT  = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAmount)
    IF Y.DR.AMT EQ '' THEN
        Y.DR.AMT  = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAmount)
    END
    Y.AA.ID = Y.DR.AA.ID
    GOSUB LN.AMT.CHK
    IF (Y.DR.AMT GT Y.ACCT.LN.AMT) AND Y.ACCT.LN.AMT NE '' THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAmount)
        ETEXT = Y.DR.AMT:' Grater Then Debit Account Limit'
        EB.ErrorProcessing.StoreEndError()
    END
*-------Credit Account Check---------
    Y.CR.ACCT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
    EB.DataAccess.FRead(FN.ACCT,Y.CR.ACCT  ,REC.ACCT.ID, F.ACCT.ID, ERR.ACCT.ID)
    Y.CR.AA.ID = REC.ACCT.ID<AC.AccountOpening.Account.ArrangementId>
    Y.AA.ID = Y.CR.AA.ID
    GOSUB LN.AMT.CHK
    IF (Y.DR.AMT GT Y.ACCT.LN.AMT) AND Y.ACCT.LN.AMT NE '' THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAmount)
        ETEXT = Y.DR.AMT:' Grater Then Credit Account Limit'
        EB.ErrorProcessing.StoreEndError()
    END
RETURN
*-----------
LN.AMT.CHK:
*-----------
    PROP.CLASS.SETT = 'ACCOUNT'
    AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS.SETT,PROPERTY,'',RETURN.IDS.SETT,RETURN.VALUES.SETT,ERR.MSG.SETT)
    REC.SETTLEMENT = RAISE(RETURN.VALUES.SETT)
    ACCT.LN.AMT = "LT.ACCT.LN.AMT"
    ACCT.AMOUNT.POS = ""
    EB.LocalReferences.GetLocRef("AA.ARR.ACCOUNT",ACCT.LN.AMT,ACCT.AMOUNT.POS)
    Y.ACCT.LN.AMT = REC.SETTLEMENT<AA.Account.Account.AcLocalRef,ACCT.AMOUNT.POS>
RETURN
END