* @ValidationCode : MjozMjI5MDI1MjQ6Q3AxMjUyOjE1OTI3NjAwODc2NjY6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Jun 2020 23:21:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.AMC.CALC(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
* 1)
*    Date :
*    Modification Description :
*    Modified By  :
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.BD.CHG.INFORMATION
    $INSERT I_GTS.COMMON
    
    $USING EB.SystemTables
    $USING AA.Framework
    $USING EB.DataAccess
    $USING LI.Config
    $USING AA.Account
    $USING AC.AccountOpening
    $USING EB.Interface
    $USING EB.Updates
    $USING EB.TransactionControl
    $USING ST.ChargeConfig
    $USING EB.API
    $USING AA.ActivityRestriction
*-----------------------------------------------------------------------------
    IF EB.SystemTables.getVFunction() EQ 'I' THEN RETURN
    IF EB.SystemTables.getVFunction() EQ 'V' THEN RETURN
    IF EB.SystemTables.getVFunction() EQ 'A' THEN RETURN
    IF (OFS$OPERATION EQ 'VALIDATE' OR OFS$OPERATION EQ 'PROCESS') AND c_aalocCurrActivity EQ 'LENDING-ISSUEBILL-SCHEDULE*DISBURSEMENT.%' THEN RETURN
   
    FLD.POS = ''
    APPLICATION.NAME = 'LIMIT':FM:'AA.ARR.ACCOUNT'
    LOCAL.FIELDS = 'LT.AMC.CHECK':FM:'LT.AMC.WAIVE':VM:'LT.AMC.APPLY'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME, LOCAL.FIELDS, FLD.POS)
    Y.AMC.CHECK.POS = FLD.POS<1,1>
    Y.AMC.WAIVE.POS = FLD.POS<2,1>
    Y.AMC.APPLY.POS = FLD.POS<2,2>
    APP.NAME = 'AA.ARR.ACCOUNT'
    EB.API.GetStandardSelectionDets(APP.NAME, R.SS)
    Y.FIELD.NAME = 'LOCAL.REF'
    LOCATE Y.FIELD.NAME IN R.SS<AA.Account.Account.AcLocalRef> SETTING Y.POS THEN
    END
    CALL AA.GET.ACCOUNT.RECORD(R.PROPERTY.RECORD, PROPERTY.ID)
    TMP.DATA = R.PROPERTY.RECORD<1,Y.POS>
    Y.AMC.WAIVE = FIELD(TMP.DATA,SM,Y.AMC.WAIVE.POS)
    Y.AMC.APPLY = FIELD(TMP.DATA,SM, Y.AMC.APPLY.POS)
    IF Y.AMC.WAIVE EQ 'YES' THEN
        RETURN
    END
    GOSUB INIT
    GOSUB OPENFILES
*IF c_aalocCurrActivity EQ 'DEPOSITS-REDEEM-ARRANGEMENT' OR c_aalocCurrActivity EQ 'DEPOSITS-CLOSE-ARRANGEMENT' OR c_aalocCurrActivity EQ 'DEPOSITS-MATURE-ARRANGEMENT' OR c_aalocCurrActivity EQ 'ACCOUNTS-CLOSE-ARRANGEMENT' THEN
    IF c_aalocCurrActivity EQ 'ACCOUNTS-CLOSE-ARRANGEMENT' THEN
        GOSUB CHRG.PROCESS
    END
*IF c_aalocCurrActivity EQ 'ACCOUNTS-CAPITALISE-SCHEDULE' OR c_aalocCurrActivity EQ 'DEPOSITS-MAKEDUE-SCHEDULE' OR c_aalocCurrActivity EQ 'LENDING-MAKEDUE-SCHEDULE' THEN
    IF c_aalocCurrActivity EQ 'ACCOUNTS-CAPITALISE-SCHEDULE' THEN
        GOSUB PROCESS
    END
RETURN

*-----------------------------------------------------------------------------

*****
INIT:
*****
    
    FN.BD.CHG = 'F.BD.CHG.INFORMATION'
    F.BD.CHG = ''
    FN.LI = 'F.LIMIT'
    F.LI = ''
    FN.FTCT = 'F.FT.COMMISSION.TYPE'
    F.FTCT = ''
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    arrangementId = ''
    accountId = ''
    requestDate = ''
    balanceAmount = ''
    retError = ''
    UnAccrued = ''
    Rate = ''
    POS = ''
    BaseBalance = ''
    RequestType = ''
    ReqdDate = ''
    EndDate = ''
    SystemDate = ''
    BalDetails = ''
    ErrorMessage = ''
    CHARGE.AMOUNT = 0
    Y.WORKING.BALANCE = 0
    Y.AVG.BAL = 0
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
    EB.DataAccess.Opf(FN.LI,F.LI)
    EB.DataAccess.Opf(FN.AC,F.AC)
    EB.DataAccess.Opf(FN.FTCT,F.FTCT)
RETURN

********
PROCESS:
********

    ArrangementId = arrId
    AA.Framework.GetArrangementAccountId(ArrangementId, accountId, Currency, ReturnError)   ;*To get Arrangement Account
    AA.Framework.GetArrangementProduct(ArrangementId, EffDate, ArrRecord, ProductId, PropertyList)  ;*Arrangement record
    Y.PRODUCT.LINE = ArrRecord<AA.Framework.Arrangement.ArrProductLine>
    Y.PRODUCT.GROUP = ArrRecord<AA.Framework.Arrangement.ArrProductGroup>
    AA.Framework.GetBaseBalanceList(ArrangementId, arrProp, ReqdDate, ProductId, BaseBalance)
    
    RequestType<2> = 'ALL'      ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'      ;* Projected Movements requierd
    RequestType<4> = 'ECB'      ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    
    Y.END.DATE = EB.SystemTables.getToday()
    Y.END.MNTH = Y.END.DATE[5,2] 'R%2'
    IF Y.END.MNTH LE '06' THEN
        Y.START.DATE = Y.END.DATE[1,4]:'0101'
        Y.END.DATE = Y.END.DATE[1,4]:'0630'
    END ELSE
        Y.START.DATE = Y.END.DATE[1,4]:'0701'
        Y.END.DATE = Y.END.DATE[1,4]:'1231'
    END
    IF Y.PRODUCT.GROUP EQ 'MBL.SD.GRP.AC' OR Y.PRODUCT.GROUP EQ 'IS.MBL.MSD.AC' THEN
        GOSUB AVG.BAL.CALC
    END
    IF Y.AVG.BAL LT 0 THEN
        RETURN
    END
    Y.PROP.CLASS.IN = 'ACTIVITY.RESTRICTION'
    AA.Framework.GetArrangementConditions(ArrangementId,Y.PROP.CLASS.IN,PROPERTY,'',RETURN.IDS,RETURN.VALUES.IN,ERR.MSG)
    Y.R.REC.IN = RAISE(RETURN.VALUES.IN)
    Y.PERIODIC.ATTRIBUTE = Y.R.REC.IN<AA.ActivityRestriction.ActivityRestriction.AcrPeriodicAttribute>
    Y.PRIODIC.VALUE = Y.R.REC.IN<AA.ActivityRestriction.ActivityRestriction.AcrPeriodicValue>

    Y.PR.ATTRIBUTE = 'MINIMUM.BAL'
    LOCATE Y.PR.ATTRIBUTE IN Y.PERIODIC.ATTRIBUTE<1,1> SETTING POS THEN
        Y.MIN.BAL=Y.R.REC.IN<AA.ActivityRestriction.ActivityRestriction.AcrPeriodicValue,POS>
    END ELSE
        Y.MIN.BAL=0
    END
    Y.AC.REC = AC.AccountOpening.Account.Read(accountId, Error)
    Y.BALANCE =  Y.AC.REC<AC.AccountOpening.Account.WorkingBalance>
    Y.W.BALANCE = ABS(Y.BALANCE - Y.MIN.BAL)
    Y.CUSTOMER = Y.AC.REC<AC.AccountOpening.Account.Customer>
    Y.LIMIT = Y.AC.REC<AC.AccountOpening.Account.LimitRef>
    IF Y.LIMIT NE '' THEN
        IF LEN(Y.LIMIT) LE 7 THEN
            Y.LIMIT = Y.LIMIT 'R%10'
        END ELSE
            Y.LEN = LEN(Y.LIMIT)+3
            Y.LIMIT = Y.LIMIT 'R%Y.LEN'
        END
    END
      
    IF Y.AMC.APPLY EQ 'PRODUCT' THEN
        Y.LIMIT.ID = Y.CUSTOMER:'.':Y.LIMIT
        EB.DataAccess.FRead(FN.LI,Y.LIMIT.ID, R.LI, F.LI, LI.ERROR)
        READU R.LI FROM F.LI,Y.LIMIT.ID LOCKED
            SLEEP 10
            RETURN
        END ELSE
            EB.DataAccess.FRelease(FN.LI,Y.LIMIT.ID,F.LI)
        END
        Y.AMC.CHECK =  R.LI<LI.Config.Limit.LocalRef,Y.AMC.CHECK.POS>
        IF EB.SystemTables.getToday()[5,2] GE '01' AND EB.SystemTables.getToday()[5,2] LE '06' THEN
            IF Y.AMC.CHECK EQ '' THEN
                GOSUB CHRGPROCESS
                Y.AMC.CHECK = EB.SystemTables.getToday()[1,4]:'06'
                R.LI<LI.Config.Limit.LocalRef,Y.AMC.CHECK.POS> = Y.AMC.CHECK
                EB.DataAccess.FWrite(FN.LI,Y.LIMIT.ID,R.LI)
                EB.TransactionControl.JournalUpdate(Y.LIMIT.ID)
            END
            IF Y.AMC.CHECK EQ EB.SystemTables.getToday()[1,4]:'06' THEN
            END
            IF Y.AMC.CHECK NE EB.SystemTables.getToday()[1,4]:'06' THEN
                GOSUB CHRGPROCESS
                Y.AMC.CHECK = EB.SystemTables.getToday()[1,4]:'06'
                R.LI<LI.Config.Limit.LocalRef,Y.AMC.CHECK.POS> = Y.AMC.CHECK
                EB.DataAccess.FWrite(FN.LI,Y.LIMIT.ID,R.LI)
                EB.TransactionControl.JournalUpdate(Y.LIMIT.ID)
            END
        END
        IF EB.SystemTables.getToday()[5,2] GE '07' AND EB.SystemTables.getToday()[5,2] LE '12' THEN
            IF Y.AMC.CHECK EQ '' THEN
                GOSUB CHRGPROCESS
                Y.AMC.CHECK = EB.SystemTables.getToday()[1,4]:'12'
                R.LI<LI.Config.Limit.LocalRef,Y.AMC.CHECK.POS> = Y.AMC.CHECK
                EB.DataAccess.FWrite(FN.LI,Y.LIMIT.ID,R.LI)
                EB.TransactionControl.JournalUpdate(Y.LIMIT.ID)
            END
            IF Y.AMC.CHECK EQ EB.SystemTables.getToday()[1,4]:'12' THEN
            END
            IF Y.AMC.CHECK NE EB.SystemTables.getToday()[1,4]:'12' THEN
                GOSUB CHRGPROCESS
                Y.AMC.CHECK = EB.SystemTables.getToday()[1,4]:'12'
                R.LI<LI.Config.Limit.LocalRef,Y.AMC.CHECK.POS> = Y.AMC.CHECK
                EB.DataAccess.FWrite(FN.LI,Y.LIMIT.ID,R.LI)
                EB.TransactionControl.JournalUpdate(Y.LIMIT.ID)
            END
        END
    END ELSE
        GOSUB CHRGPROCESS
    END
RETURN

************
CHRGPROCESS:
************
    Y.BD.CHG.ID = accountId:'-':arrProp
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
    
***************************AVERAGE BALANCE Consider for Savings Account *****************************************************
    IF Y.PRODUCT.GROUP EQ 'MBL.SD.GRP.AC' OR Y.PRODUCT.GROUP EQ 'IS.MBL.MSD.AC' THEN
        Y.FTCT.ID = 'AMCCHG'
        EB.DataAccess.FRead(FN.FTCT,Y.FTCT.ID,R.FTCT,F.FTCT,FT.CT.ERR)
        Y.UPTO.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouUptoAmt>
        Y.MIN.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouMinimumAmt>
        CONVERT SM TO VM IN Y.UPTO.AMT
        CONVERT SM TO VM IN Y.MIN.AMT
        Y.DCOUNT = DCOUNT(Y.UPTO.AMT,VM)
        FOR I = 1 TO Y.DCOUNT
            Y.AMT = Y.UPTO.AMT<1,I>
            IF Y.AVG.BAL LE Y.AMT THEN
                BREAK
            END
        NEXT I
        CHARGE.AMOUNT = Y.MIN.AMT<1,I>
    END ELSE
        CHARGE.AMOUNT = 500
    END
****************************************************************************************************************************
    IF Y.W.BALANCE LE CHARGE.AMOUNT THEN
        Y.VAT.VALUE = (Y.W.BALANCE*15)/100
        Y.WORKING.BALANCE = ABS(Y.W.BALANCE - Y.VAT.VALUE)
    END ELSE
        Y.VALUE = Y.W.BALANCE - (CHARGE.AMOUNT*15)/100
        IF Y.VALUE LT  CHARGE.AMOUNT THEN
            Y.VAT.VALUE = (Y.VALUE*15)/100
            Y.WORKING.BALANCE = ABS(Y.W.BALANCE - Y.VAT.VALUE)
        END ELSE
            Y.VAT.VALUE = (CHARGE.AMOUNT*15)/100
            Y.WORKING.BALANCE = ABS(Y.W.BALANCE - Y.VAT.VALUE)
        END
    END
****************************************************************************************************************************
    IF R.BD.CHG EQ '' THEN
        IF Y.PRODUCT.GROUP EQ 'MBL.SD.GRP.AC' OR Y.PRODUCT.GROUP EQ 'IS.MBL.MSD.AC' THEN
            R.BD.CHG<BD.CHG.BASE.AMT> = Y.AVG.BAL
        END ELSE
            R.BD.CHG<BD.CHG.BASE.AMT> = Y.WORKING.BALANCE
        END
        R.BD.CHG<BD.TOTAL.CHG.AMT> = CHARGE.AMOUNT
        R.BD.CHG<BD.CHG.TXN.DATE> = perDat
        IF Y.WORKING.BALANCE GT 0 THEN
            IF  Y.WORKING.BALANCE GE CHARGE.AMOUNT THEN
                R.BD.CHG<BD.CHG.SLAB.AMT> =  CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.REFNO> = c_aalocTxnReference
                R.BD.CHG<BD.CHG.TXN.AMT> =  CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.DUE.AMT> = 0
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.OS.DUE.AMT> = 0
                R.BD.CHG<BD.CHG.TXN.FLAG> = 'Schedule'
            END
            IF Y.WORKING.BALANCE LT CHARGE.AMOUNT THEN
                R.BD.CHG<BD.CHG.SLAB.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.REFNO> = c_aalocTxnReference
                CHARGE.AMOUNT = Y.WORKING.BALANCE
                R.BD.CHG<BD.CHG.TXN.AMT> =  CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.DUE.AMT> = R.BD.CHG<BD.CHG.SLAB.AMT> - R.BD.CHG<BD.CHG.TXN.AMT>
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.CHG.TXN.AMT>
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + (R.BD.CHG<BD.CHG.SLAB.AMT> - R.BD.CHG<BD.CHG.TXN.AMT>)
                R.BD.CHG<BD.CHG.TXN.FLAG> = 'Schedule'
            END
        END
        IF Y.WORKING.BALANCE EQ 0 OR Y.WORKING.BALANCE EQ '' THEN
            R.BD.CHG<BD.CHG.SLAB.AMT> = CHARGE.AMOUNT
            R.BD.CHG<BD.CHG.TXN.REFNO> = c_aalocTxnReference
            R.BD.CHG<BD.CHG.TXN.AMT> =  0
            R.BD.CHG<BD.CHG.TXN.DUE.AMT> = R.BD.CHG<BD.CHG.SLAB.AMT> - R.BD.CHG<BD.CHG.TXN.AMT>
            R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + 0
            R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + R.BD.CHG<BD.CHG.SLAB.AMT>
            CHARGE.AMOUNT = 0
        END
    END
    ELSE
        Y.DCOUNT = DCOUNT(R.BD.CHG<BD.CHG.TXN.DATE>,VM) + 1
        IF Y.PRODUCT.GROUP EQ 'MBL.SD.GRP.AC' OR Y.PRODUCT.GROUP EQ 'IS.MBL.MSD.AC' THEN
            R.BD.CHG<BD.CHG.BASE.AMT,Y.DCOUNT> = Y.AVG.BAL
        END ELSE
            R.BD.CHG<BD.CHG.BASE.AMT,Y.DCOUNT> = Y.WORKING.BALANCE
        END
        R.BD.CHG<BD.TOTAL.CHG.AMT> = R.BD.CHG<BD.TOTAL.CHG.AMT> + CHARGE.AMOUNT
        R.BD.CHG<BD.CHG.TXN.DATE,Y.DCOUNT> = perDat
        IF Y.WORKING.BALANCE GT 0 THEN
            IF  Y.WORKING.BALANCE GE CHARGE.AMOUNT THEN
                R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> =  CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.REFNO,Y.DCOUNT> = c_aalocTxnReference
                R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT> =  CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.DUE.AMT> = R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> - R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT>
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + CHARGE.AMOUNT
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + 0
                R.BD.CHG<BD.CHG.TXN.FLAG,Y.DCOUNT> = 'Schedule'
            END
            IF Y.WORKING.BALANCE LT CHARGE.AMOUNT THEN
                R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.REFNO,Y.DCOUNT> = c_aalocTxnReference
                Y.DUE.AMT = CHARGE.AMOUNT - Y.WORKING.BALANCE
                CHARGE.AMOUNT = Y.WORKING.BALANCE
                R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT> =  CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.DUE.AMT> = R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> - R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT>
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + CHARGE.AMOUNT
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + Y.DUE.AMT
                R.BD.CHG<BD.CHG.TXN.FLAG,Y.DCOUNT> = 'Schedule'
            END
        END
        IF Y.WORKING.BALANCE EQ 0 OR Y.WORKING.BALANCE EQ '' THEN
            R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = CHARGE.AMOUNT
            R.BD.CHG<BD.CHG.TXN.REFNO,Y.DCOUNT> = c_aalocTxnReference
            R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT> =  0
            R.BD.CHG<BD.CHG.TXN.DUE.AMT,Y.DCOUNT> = R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> - R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT>
            R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + 0
            R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + CHARGE.AMOUNT
            CHARGE.AMOUNT = 0
        END
    END
    R.BD.CHG<BD.INPUTTER> = EB.SystemTables.getOperator()
    R.BD.CHG<BD.AUTHORISER> = EB.SystemTables.getOperator()
    R.BD.CHG<BD.CO.CODE> = EB.SystemTables.getIdCompany()
    EB.DataAccess.FWrite(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG)
    EB.TransactionControl.JournalUpdate(Y.BD.CHG.ID)
    balanceAmount = CHARGE.AMOUNT

RETURN

*************
AVG.BAL.CALC:
*************
    Y.TOTAL.BAL = 0
    Y.OPEN.BAL = 0
    CALL AA.GET.PERIOD.BALANCES(accountId, BaseBalance,"",Y.START.DATE,"", "", BAL.DETAILS, ERROR.MESSAGE)
    Y.NO.OF.DAY="C"
    IF Y.START.DATE AND Y.END.DATE THEN
        CALL CDD("", Y.START.DATE,Y.END.DATE,Y.NO.OF.DAY)
    END
    IF BAL.DETAILS THEN
        Y.OPEN.BAL = FIELD(BAL.DETAILS,FM,4)
    END
    CALL AA.GET.PERIOD.BALANCES(accountId, BaseBalance,"",Y.START.DATE,Y.END.DATE,"", BAL.DETAILS, ERROR.MESSAGE)
    IF BAL.DETAILS THEN
        Y.TRAN.DATES = FIELD(BAL.DETAILS,FM,1)
        Y.DATES =FIELD(Y.TRAN.DATES,VM,1)
        Y.TRAN.BAL=FIELD(BAL.DETAILS,FM,4)
        Y.CNT.TRAN = DCOUNT(Y.TRAN.BAL,VM)
        IF Y.DATES = Y.START.DATE  THEN
            Y.OPEN.BAL = FIELD(Y.TRAN.BAL,VM,1)
        END
        IF Y.OPEN.BAL = 0 THEN
            Y.OPEN.BAL = FIELD(Y.TRAN.BAL,VM,1)
        END
    END
    FOR Y.VAR.I = 2 TO Y.CNT.TRAN
        Y.BAL = FIELD(Y.TRAN.BAL,VM,Y.VAR.I)
        Y.DATES = FIELD(Y.TRAN.DATES,VM,Y.VAR.I)
        IF (Y.VAR.I EQ 2) AND (Y.DATES EQ Y.START.DATE) THEN
            Y.START.DATE =Y.DATES
            Y.OPEN.BAL = Y.BAL
        END
        ELSE
            Y.DIF.DAYS ="C"
            IF Y.START.DATE AND Y.DATES THEN
                CALL CDD("",Y.START.DATE,Y.DATES,Y.DIF.DAYS)
            END
            
            Y.OPEN.BAL.MUL = Y.OPEN.BAL * Y.DIF.DAYS
            Y.TOTAL.BAL =Y.TOTAL.BAL + Y.OPEN.BAL.MUL
            Y.OPEN.BAL=Y.BAL
            Y.START.DATE=Y.DATES
        END
    NEXT Y.VAR.I
    IF Y.END.DATE NE Y.DATES THEN
        Y.DIF.DAYS ="C"
        
        IF Y.START.DATE AND Y.END.DATE THEN
            CALL CDD("",Y.START.DATE,Y.END.DATE,Y.DIF.DAYS)
        END
        Y.DIFF.DATE.ADD = Y.DIF.DAYS + 1
        Y.OPEN.BAL.MUL = Y.OPEN.BAL*Y.DIFF.DATE.ADD
        Y.TOTAL.BAL =Y.TOTAL.BAL + Y.OPEN.BAL.MUL
        Y.OPEN.BAL=Y.TOTAL.BAL
        Y.START.DATE= EB.SystemTables.getToday()
    END
    ELSE
        Y.TOTAL.BAL = Y.TOTAL.BAL + Y.OPEN.BAL
    END
    Y.AVERAGE.BAL=Y.TOTAL.BAL/(Y.NO.OF.DAY+1)
    Y.AVG.BAL=DROUND(Y.AVERAGE.BAL,2)
RETURN
*************
CHRG.PROCESS:
*************
    Y.END.DATE = EB.SystemTables.getToday()
    Y.START.DATE = Y.END.DATE[1,4]:'0101'
    AA.Framework.GetBaseBalanceList(arrId, arrProp, ReqdDate, ProductId, BaseBalance)
    AA.Framework.GetArrangementAccountId(arrId, accountId, Currency, ReturnError)
    AA.Framework.GetArrangementProduct(arrId, EffDate, ArrRecord, ProductId, PropertyList)  ;*Arrangement record
    Y.PRODUCT.GROUP = ArrRecord<AA.Framework.Arrangement.ArrProductGroup>
    RequestType<2> = 'ALL'      ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'      ;* Projected Movements requierd
    RequestType<4> = 'ECB'      ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    AA.Framework.GetPeriodBalances(accountId, BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)    ;*Balance left in the balance Type
    Y.CUR.AMT = BalDetails<4>
    IF Y.PRODUCT.GROUP EQ 'MBL.SD.GRP.AC' OR Y.PRODUCT.GROUP EQ 'IS.MBL.MSD.AC' THEN
        Y.FTCT.ID = 'AMCCHG'
        EB.DataAccess.FRead(FN.FTCT,Y.FTCT.ID,R.FTCT,F.FTCT,FT.CT.ERR)
        Y.UPTO.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouUptoAmt>
        Y.MIN.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouMinimumAmt>
        CONVERT SM TO VM IN Y.UPTO.AMT
        CONVERT SM TO VM IN Y.MIN.AMT
        Y.DCOUNT = DCOUNT(Y.UPTO.AMT,VM)
        FOR I = 1 TO Y.DCOUNT
            Y.AMT = Y.UPTO.AMT<1,I>
            IF Y.CUR.AMT LE Y.AMT THEN
                BREAK
            END
        NEXT I
        CHARGE.AMOUNT = Y.MIN.AMT<1,I>
    END
    ELSE
        CHARGE.AMOUNT = '500'
    END
    Y.BD.CHG.ID = accountId:'-':arrProp
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
    balanceAmount = R.BD.CHG<BD.OS.DUE.AMT> + CHARGE.AMOUNT
RETURN
END
