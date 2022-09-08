* @ValidationCode : MjoxOTQ0OTYzNDA6Q3AxMjUyOjE1OTM2ODM4NzA5NjA6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 02 Jul 2020 15:57:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.I.FUNDING
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
* 1)
*    Date :
*    Modification Description :
*    Modified By  :
*Total Withdrawal Amount Calcuate
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING FT.Contract
    $USING TT.Contract
    $USING AA.TermAmount
    $USING EB.ErrorProcessing
    $USING EB.Foundation
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*----
INIT:
*----
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    EB.Foundation.MapLocalFields('FUNDS.TRANSFER','LT.AC.CHEQUE.DT',Y.CHEQUE.DATE.POS)
RETURN
*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.AC, F.AC)
    EB.DataAccess.Opf(FN.AA, F.AA)
RETURN
*-------
PROCESS:
*-------
    Y.APPLICATION = EB.SystemTables.getApplication()
    IF Y.APPLICATION EQ 'FUNDS.TRANSFER' THEN
        Y.CR.AC = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
        Y.TXN.AMT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAmount)
        IF Y.TXN.AMT EQ '' THEN
            Y.TXN.AMT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAmount)
        END
        EB.DataAccess.FRead(FN.AC, Y.CR.AC, R.CR.AC, F.AC, Er.AC)
        Y.CR.AA.ID = R.CR.AC<AC.AccountOpening.Account.ArrangementId>
        EB.DataAccess.FRead(FN.AA, Y.CR.AA.ID, R.CR.AA, F.AA, Er.AA)
        Y.CR.PROD.GROUP = R.CR.AA<AA.Framework.Arrangement.ArrProductGroup>
        Y.CR.PROD.LINE = R.CR.AA<AA.Framework.Arrangement.ArrProductLine>
        
        IF Y.CR.PROD.LINE NE 'DEPOSITS' THEN
            GOSUB FT.CR.ERROR.PROCESS
        END
        IF Y.CR.PROD.LINE EQ 'DEPOSITS' AND Y.CR.PROD.GROUP NE 'IS.MBL.MMSP.DP' THEN
            GOSUB FT.CR.PROCESS
        END
        Y.DR.AC = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
        EB.DataAccess.FRead(FN.AC, Y.DR.AC, R.DR.AC, F.AC, Er.AC)
        Y.DR.AA.ID = R.DR.AC<AC.AccountOpening.Account.ArrangementId>
        EB.DataAccess.FRead(FN.AA, Y.DR.AA.ID, R.DR.AA, F.AA, Er.AA)
        Y.DR.PROD.GROUP = R.CR.AA<AA.Framework.Arrangement.ArrProductGroup>
        Y.DR.PROD.LINE = R.DR.AA<AA.Framework.Arrangement.ArrProductLine>
        IF Y.DR.PROD.LINE EQ 'DEPOSITS' THEN
            GOSUB FT.DR.ERROR.PROCESS
        END
        IF Y.DR.PROD.LINE EQ 'DEPOSITS' AND Y.DR.PROD.GROUP NE 'IS.MBL.MMSP.DP' THEN
            GOSUB FT.DR.PROCESS
        END
        Y.CHEQUE.NO = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChequeNumber)
        Y.CHEQUE.DATE = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,Y.CHEQUE.DATE.POS>
        IF Y.CHEQUE.NO NE '' AND Y.CHEQUE.DATE EQ '' THEN
            GOSUB CHEQUE.ERROR.PROCESS
        END
    END
    IF Y.APPLICATION EQ 'TELLER' THEN
        Y.AC.2 = EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
        Y.TT.TXN.AMT = EB.SystemTables.getRNew(TT.Contract.Teller.TeAmountLocalOne)
        IF Y.TT.TXN.AMT EQ '' THEN
            Y.TT.TXN.AMT = EB.SystemTables.getRNew(TT.Contract.Teller.TeAmountFcyOne)
        END
        EB.DataAccess.FRead(FN.AC, Y.AC.2, R.AC, F.AC, Er.AC)
        Y.AA.ID = R.AC<AC.AccountOpening.Account.ArrangementId>
        EB.DataAccess.FRead(FN.AA, Y.AA.ID, R.AA, F.AA, Er.AA)
        Y.PROD.GROUP = R.AA<AA.Framework.Arrangement.ArrProductGroup>
        Y.PROD.LINE = R.AA<AA.Framework.Arrangement.ArrProductLine>
        IF Y.PROD.LINE NE 'DEPOSITS' THEN
            GOSUB TT.ERROR.PROCESS
        END
        IF Y.PROD.LINE EQ 'DEPOSITS' AND Y.PROD.GROUP NE 'IS.MBL.MMSP.DP' THEN
            GOSUB TT.PROCESS
        END
    END
RETURN

*-------------------
FT.CR.ERROR.PROCESS:
*-------------------
    EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditAcctNo)
    Y.CR.OVERR.ID = 'Credit Account Does not Belongs to Deposits product Line'
    EB.SystemTables.setEtext(Y.CR.OVERR.ID)
    EB.ErrorProcessing.StoreEndError()
RETURN

*-------------------
FT.DR.ERROR.PROCESS:
*-------------------
    EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAcctNo)
    Y.DR.OVERR.ID = 'Debit not Allowed from Deposit Account'
    EB.SystemTables.setEtext(Y.DR.OVERR.ID)
    EB.ErrorProcessing.StoreEndError()
RETURN

*----------------
TT.ERROR.PROCESS:
*----------------
    EB.SystemTables.setAf(TT.Contract.Teller.TeAccountTwo)
    Y.TT.OVERR.ID = 'Account Does not Belongs to Deposits product Line'
    EB.SystemTables.setEtext(Y.TT.OVERR.ID)
    EB.ErrorProcessing.StoreEndError()
RETURN

*--------------------
CHEQUE.ERROR.PROCESS:
*--------------------
    EB.SystemTables.setAf(FT.Contract.FundsTransfer.LocalRef)
    EB.SystemTables.setAv(Y.CHEQUE.DATE.POS)
    Y.DR.OVERR.ID = 'Cheque Date Required'
    EB.SystemTables.setEtext(Y.DR.OVERR.ID)
    EB.ErrorProcessing.StoreEndError()
RETURN


*-------------
FT.CR.PROCESS:
*-------------
    BaseBalance = 'CURISACCOUNT'
    RequestType<2> = 'ALL'
    RequestType<3> = 'ALL'
    RequestType<4> = 'ECB'
    RequestType<4,2> = 'END'
    Y.SYSTEMDATE = EB.SystemTables.getToday()
    AA.Framework.GetPeriodBalances(Y.CR.AC,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
    Y.CUR.AMT = BalDetails<4>
    IF Y.CUR.AMT NE '' THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditAcctNo)
        Y.CUR.OVERR.ID = 'Already Deposited in this Account'
        EB.SystemTables.setEtext(Y.CUR.OVERR.ID)
        EB.ErrorProcessing.StoreEndError()
    END ELSE
        PROP.CLASS = 'TERM.AMOUNT'
        AA.Framework.GetArrangementConditions(Y.CR.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
        R.REC = RAISE(RETURN.VALUES)
        Y.COMMIT.AMT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
        IF Y.TXN.AMT NE Y.COMMIT.AMT THEN
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAmount)
            Y.CR.TXN.OVERR.ID = 'Transaction amount must be Commitment Amount'
            EB.SystemTables.setEtext(Y.CR.TXN.OVERR.ID)
            EB.ErrorProcessing.StoreEndError()
        END
    END
RETURN
*-------------
FT.DR.PROCESS:
*-------------
    EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAcctNo)
    Y.DR.TXN.OVERR.ID = 'Debit not Allowed from Deposit Account'
    EB.SystemTables.setEtext(Y.DR.TXN.OVERR.ID)
    EB.ErrorProcessing.StoreEndError()
RETURN
*----------
TT.PROCESS:
*----------
    BaseBalance = 'CURISACCOUNT'
    RequestType<2> = 'ALL'
    RequestType<3> = 'ALL'
    RequestType<4> = 'ECB'
    RequestType<4,2> = 'END'
    Y.SYSTEMDATE = EB.SystemTables.getToday()
    AA.Framework.GetPeriodBalances(Y.AC.2,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
    Y.TT.CUR.AMT = BalDetails<4>
    IF Y.TT.CUR.AMT NE '' THEN
        EB.SystemTables.setAf(TT.Contract.Teller.TeAmountLocalOne)
        Y.CUR.OVERR.ID = 'Already Deposited in this Account ':Y.AC.2
        EB.SystemTables.setEtext(Y.CUR.OVERR.ID)
        EB.ErrorProcessing.StoreEndError()
    END ELSE
        PROP.CLASS = 'TERM.AMOUNT'
        AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
        R.REC = RAISE(RETURN.VALUES)
        Y.COMMIT.AMT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
        IF Y.TT.TXN.AMT NE Y.COMMIT.AMT THEN
            EB.SystemTables.setAf(TT.Contract.Teller.TeAmountLocalOne)
            Y.TT.TXN.OVERR.ID = 'Transaction amount must be Commitment Amount'
            EB.SystemTables.setEtext(Y.TT.TXN.OVERR.ID)
            EB.ErrorProcessing.StoreEndError()
        END
    END
RETURN

END
