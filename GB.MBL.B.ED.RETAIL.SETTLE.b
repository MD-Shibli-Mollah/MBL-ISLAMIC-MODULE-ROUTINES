* @ValidationCode : MjotMTE5MTE2OTY2NDpDcDEyNTI6MTU5MjYyNDE1NzMyMDpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Jun 2020 09:35:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.B.ED.RETAIL.SETTLE(Y.BD.CHG.ID)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_BATCH.FILES
    $INSERT I_GTS.COMMON
    $INSERT I_F.GB.MBL.B.ED.RETAIL.SETTLE.COMMON
    $INSERT I_F.BD.CHG.INFORMATION
    
    $USING AA.ProductFramework
    $USING AA.Framework
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.Interface
    $USING EB.TransactionControl
    $USING AC.AccountOpening
    $USING AA.ActivityRestriction
    $USING AA.TermAmount
    $USING ST.CompanyCreation
*-----------------------------------------------------------------------------
    GOSUB PROCESS
RETURN

********
PROCESS:
********
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,E.BD.RR)
    Y.DUE.AMOUNT = R.BD.CHG<BD.OS.DUE.AMT>
    Y.TOT.TXN.DATE = R.BD.CHG<BD.CHG.TXN.DATE>
    Y.TOT.TXN.DUE.AMT = R.BD.CHG<BD.CHG.TXN.DUE.AMT>
    Y.PRODUCT.GROUP = R.BD.CHG<BD.PRODUCT.GROUP>
    Y.COMPANY = R.BD.CHG<BD.CO.CODE>
    EB.DataAccess.FRead(FN.COM, Y.COMPANY, R.COM, F.COM, Er.COM)
    Y.MNE = R.COM<ST.CompanyCreation.Company.EbComFinancialMne>
    IF Y.MNE EQ 'BNK' THEN
        BaseBalance = 'CURBALANCE'
    END
    IF Y.MNE EQ 'BNK' AND Y.PRODUCT.GROUP EQ 'MBL.FDR.GRP.DP' THEN
        Y.DP.PROD.GROUP = 'MBL.FDR.GRP.DP'
        BaseBalance = 'CURACCOUNT'
    END
    IF Y.MNE EQ 'ISL' THEN
        BaseBalance = 'CURISBALANCE'
    END
    IF Y.MNE EQ 'ISL' AND Y.PRODUCT.GROUP EQ 'IS.MBL.MTD.DP' THEN
        Y.DP.PROD.GROUP = 'IS.MBL.MTD.DP'
        BaseBalance = 'CURISACCOUNT'
    END
    IF Y.PRODUCT.GROUP NE '' THEN
        IF Y.PRODUCT.GROUP NE Y.DP.PROD.GROUP THEN
            RETURN
        END
    END
    accountId = FIELD(Y.BD.CHG.ID,'-',1)
    EB.DataAccess.FRead(FN.AC, accountId, R.AC, F.AC, E.AC)
    Y.AA.ID = R.AC<AC.AccountOpening.Account.ArrangementId>
    Y.AC.REC = AC.AccountOpening.Account.Read(accountId, Error)
    Y.CURRENCY =  Y.AC.REC<AC.AccountOpening.Account.Currency>
    Y.PROP.CLASS.IN = 'ACTIVITY.RESTRICTION'
    AA.Framework.GetArrangementConditions(Y.AA.ID,Y.PROP.CLASS.IN,PROPERTY,'',RETURN.IDS,RETURN.VALUES.IN,ERR.MSG)
    Y.R.REC.IN = RAISE(RETURN.VALUES.IN)
    Y.PERIODIC.ATTRIBUTE = Y.R.REC.IN<AA.ActivityRestriction.ActivityRestriction.AcrPeriodicAttribute>
    Y.PRIODIC.VALUE = Y.R.REC.IN<AA.ActivityRestriction.ActivityRestriction.AcrPeriodicValue>
    
    RequestType<2> = 'ALL'
    RequestType<3> = 'ALL'
    RequestType<4> = 'ECB'
    RequestType<4,2> = 'END'
    Y.SYSTEMDATE = EB.SystemTables.getToday()
    AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
    Y.BALANCE = BalDetails<4>
            
    Y.PR.ATTRIBUTE = 'MINIMUM.BAL'
    LOCATE Y.PR.ATTRIBUTE IN Y.PERIODIC.ATTRIBUTE<1,1> SETTING POS THEN
        Y.MIN.BAL=Y.R.REC.IN<AA.ActivityRestriction.ActivityRestriction.AcrPeriodicValue,POS>
    END ELSE
        Y.MIN.BAL=0
    END
    Y.WORKING.BALANCE = Y.BALANCE - Y.MIN.BAL
    PROP.CLASS = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.REC = RAISE(RETURN.VALUES)
    Y.TERM.AMT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
    IF Y.DP.PROD.GROUP EQ Y.PRODUCT.GROUP THEN
        Y.WORKING.BALANCE = Y.WORKING.BALANCE - Y.TERM.AMT
    END
    
    Y.DCOUNT = DCOUNT(Y.TOT.TXN.DATE,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.TXN.DATE = R.BD.CHG<BD.CHG.TXN.DATE,I>
        Y.TXN.DUE.AMT = R.BD.CHG<BD.CHG.TXN.DUE.AMT,I>
        IF Y.TXN.DUE.AMT GT 0 THEN
            IF Y.WORKING.BALANCE GE Y.TXN.DUE.AMT THEN
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + Y.TXN.DUE.AMT
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> - Y.TXN.DUE.AMT
                R.BD.CHG<BD.CHG.TXN.DUE.AMT,I> = 0
                EB.DataAccess.FWrite(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG)
                GOSUB OFS.PROCESS
            END
            Y.WORKING.BALANCE = Y.WORKING.BALANCE - Y.TXN.DUE.AMT
        END
    NEXT I
RETURN

************
OFS.PROCESS:
************
    GOSUB OFS.STRING
    OFS.SOURCE = 'MBL.PRE.OFS'
    OFS.MSG.ID = ''
    Y.FT.ID = ''
    OFS.MSG = 'FUNDS.TRANSFER,MBL.ED.RETAIL':'/I/PROCESS,//':Y.COMPANY:',':Y.FT.ID:',':Y.OFS.STR
    EB.Interface.OfsPostMessage(OFS.MSG, OFS.MSG.ID, OFS.SOURCE, OPTIONS)
    EB.TransactionControl.JournalUpdate('')
RETURN

***********
OFS.STRING:
***********
    Y.DEBIT.THEIR.REF = 'Excise duty'
    Y.CREDIT.THEIR.REF = 'Excise duty'
    Y.ORDERING.BANK = 'MBL'
    Y.CR.ACC.N0 = 'BDT17280'
    
    Y.OFS.STR = ''
    Y.OFS.STR = 'TRANSACTION.TYPE::=AC':','
    Y.OFS.STR := 'DEBIT.CURRENCY::=':Y.CURRENCY:','
    Y.OFS.STR := 'DEBIT.ACCT.NO::=':accountId:','
    Y.OFS.STR := 'DEBIT.AMOUNT::=':Y.TXN.DUE.AMT:','
    Y.OFS.STR := 'DEBIT.VALUE.DATE::=':EB.SystemTables.getToday():','
    Y.OFS.STR := 'DEBIT.THEIR.REF::=':Y.DEBIT.THEIR.REF:','
    Y.OFS.STR := 'CREDIT.ACCT.NO::=':Y.CR.ACC.N0:','
    Y.OFS.STR := 'CREDIT.VALUE.DATE::=':EB.SystemTables.getToday():','
    Y.OFS.STR := 'CREDIT.THEIR.REF::=':Y.CREDIT.THEIR.REF:','
    Y.OFS.STR := 'ORDERING.BANK:1:1=':Y.ORDERING.BANK
RETURN
END
