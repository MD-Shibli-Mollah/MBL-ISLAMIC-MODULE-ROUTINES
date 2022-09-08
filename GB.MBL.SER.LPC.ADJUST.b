* @ValidationCode : MjoyMDkzNjEwNjkzOkNwMTI1MjoxNTkyODk2MjY5ODMzOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 23 Jun 2020 13:11:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.SER.LPC.ADJUST(Y.AA.ID)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_F.GB.MBL.SER.LPC.ADJUST.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.BD.MBL.LPC.CHARGE.REC
    
    $USING AA.Account
    $USING AA.Framework
    $USING EB.DataAccess
    $USING EB.LocalReferences
    $USING AA.Settlement
    $USING RE.ConBalanceUpdates
    $USING EB.SystemTables
    $USING EB.TransactionControl
    $USING EB.Interface
    
    GOSUB PROCESS
RETURN

PROCESS:
    PROP.CLASS = 'SETTLEMENT'
    AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.REC = RAISE(RETURN.VALUES)
    Y.PAY.IN.ACC = R.REC<AA.Settlement.Settlement.SetPayinAccount>
    IF Y.PAY.IN.ACC THEN
        EB.DataAccess.FRead(FN.AA, Y.AA.ID, REC.AA, F.AA, Er.AA)
        Y.CR.ACC.NUM = REC.AA<AA.Framework.Arrangement.ArrLinkedApplId>
        Y.ECB.BAL = RE.ConBalanceUpdates.EbContractBalances.Read(Y.PAY.IN.ACC, Error)
        Y.SET.AC.BAL = Y.ECB.BAL<RE.ConBalanceUpdates.EbContractBalances.EcbWorkingBalance>
*Y.LOCK.AMT = Y.ECB.BAL<RE.ConBalanceUpdates.EbContractBalances.EcbLockedAmt>
*Y.SET.AC.BAL = Y.SET.AC.BAL - Y.LOCK.AMT
        IF Y.SET.AC.BAL GT 0 THEN
            OFS.SOURCE = 'MBL.PRE.OFS'
            OFS.ERR = ''
            OFS.MSG.ID = ''
            EB.DataAccess.FRead(FN.LPC.CRG, Y.AA.ID, REC.LPC, F.LPC.CRG, REC.ERROR)
            Y.DUE.AMT = REC.LPC<LPC.TOT.DUE.AMT>
            Y.COMPANY = EB.SystemTables.getIdCompany()
            Y.DEBIT.ACCT.ID = Y.PAY.IN.ACC
            Y.ORD.BNK  = 'MBL'
            IF Y.SET.AC.BAL GT Y.DUE.AMT THEN
                Y.MESSAGE="FUNDS.TRANSFER,MBL.AA.MSS.FUND.OFS/I/PROCESS,//":Y.COMPANY:",,TRANSACTION.TYPE=ACLP,DEBIT.ACCT.NO=":Y.DEBIT.ACCT.ID:",DEBIT.CURRENCY=":EB.SystemTables.getLccy():",DEBIT.AMOUNT=":Y.DUE.AMT:",DEBIT.VALUE.DATE=":EB.SystemTables.getToday():",CREDIT.VALUE.DATE=":EB.SystemTables.getToday():",CREDIT.ACCT.NO=":Y.CR.ACC.NUM:",ORDERING.BANK=":Y.ORD.BNK:",DEBIT.THEIR.REF=":"Lpc Adjust Amt":",CREDIT.THEIR.REF=":"Lpc Adjust Amt"
                EB.Interface.OfsPostMessage(Y.MESSAGE, OFS.MSG.ID, OFS.SOURCE, OPTIONS)
                EB.TransactionControl.JournalUpdate('')
                SENSITIVITY = ''
            END ELSE
                Y.MESSAGE="FUNDS.TRANSFER,MBL.AA.MSS.FUND.OFS/I/PROCESS,//":Y.COMPANY:",,TRANSACTION.TYPE=ACLP,DEBIT.ACCT.NO=":Y.DEBIT.ACCT.ID:",DEBIT.CURRENCY=":EB.SystemTables.getLccy():",DEBIT.AMOUNT=":Y.SET.AC.BAL:",DEBIT.VALUE.DATE=":EB.SystemTables.getToday():",CREDIT.VALUE.DATE=":EB.SystemTables.getToday():",CREDIT.ACCT.NO=":Y.CR.ACC.NUM:",ORDERING.BANK=":Y.ORD.BNK:",DEBIT.THEIR.REF=":"Lpc Adjust Amt":",CREDIT.THEIR.REF=":"Lpc Adjust Amt"
                EB.Interface.OfsPostMessage(Y.MESSAGE, OFS.MSG.ID, OFS.SOURCE, OPTIONS)
                EB.TransactionControl.JournalUpdate('')
                SENSITIVITY = ''
            END
        END
    END
    
RETURN

END
