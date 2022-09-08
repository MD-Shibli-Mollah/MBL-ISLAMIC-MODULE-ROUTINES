* @ValidationCode : MjoxMTAxNjU0MzU1OkNwMTI1MjoxNTkyODg4NjgzMjYyOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 23 Jun 2020 11:04:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.ED.DUE.CALC(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
* Developed By- s.azam@fortress-global.com
* Condition  : This Routine will deduct the Excise Duty yearly as per Payment Schedule frequency
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Modification History :
* 1)
*    Date : 2020/06/20
*    Modification Description : calculate accured interest without redeemption fee fro deposit product
*    Modified By  : S.M. Sayeed
*    Designation  : Technical Consultant
*    Email        : s.m.sayeed@fortress-global.com
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.BD.CHG.INFORMATION
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_GTS.COMMON
    $INSERT I_F.BD.MBL.MSS.MATURE.VAL
    
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING EB.Interface
    $USING EB.TransactionControl
    $USING EB.Updates
    $USING EB.API
    $USING AA.TermAmount
    $USING AA.Account
    $USING LI.Config
    $USING AC.Config
    $USING ST.ChargeConfig
    $USING AA.PaymentSchedule
    $USING AA.ActivityRestriction
    $USING ST.CompanyCreation
    $USING AA.Interest
    $USING ST.RateParameters
    $USING AC.Fees
*-----------------------------------------------------------------------------
    IF EB.SystemTables.getVFunction() EQ 'I' THEN RETURN
    IF EB.SystemTables.getVFunction() EQ 'V' THEN RETURN
    IF EB.SystemTables.getVFunction() EQ 'A' THEN RETURN
    IF (OFS$OPERATION EQ 'VALIDATE' OR OFS$OPERATION EQ 'PROCESS') AND c_aalocCurrActivity EQ 'LENDING-ISSUEBILL-SCHEDULE*DISBURSEMENT.%' THEN RETURN
 
    FLD.POS = ''
    APPLICATION.NAME = 'LIMIT':FM:'AA.ARR.ACCOUNT'
    LOCAL.FIELDS = 'LT.ED.CHECK':FM:'LT.ED.WAIVE':VM:'LT.ED.APPLY'
    EB.Updates.MultiGetLocRef(APPLICATION.NAME, LOCAL.FIELDS, FLD.POS)
    Y.ED.CHECK.POS = FLD.POS<1,1>
    Y.ED.WAIVE.POS = FLD.POS<2,1>
    Y.ED.APPLY.POS = FLD.POS<2,2>
    TMP.DATA = ''
    Y.ED.WAIVE = ''
    Y.ED.APPLY = ''
    APP.NAME = 'AA.ARR.ACCOUNT'
    EB.API.GetStandardSelectionDets(APP.NAME, R.SS)
    Y.FIELD.NAME = 'LOCAL.REF'
    LOCATE Y.FIELD.NAME IN R.SS<AA.Account.Account.AcLocalRef> SETTING Y.POS THEN
    END
    CALL AA.GET.ACCOUNT.RECORD(R.PROPERTY.RECORD, PROPERTY.ID)
    TMP.DATA = R.PROPERTY.RECORD<1,Y.POS>
    Y.ED.WAIVE = FIELD(TMP.DATA,SM,Y.ED.WAIVE.POS)
    Y.ED.APPLY = FIELD(TMP.DATA,SM, Y.ED.APPLY.POS)
    IF Y.ED.WAIVE EQ 'YES' THEN
        RETURN
    END
    
    GOSUB INIT
    GOSUB OPENFILES
* This if part is for Deposit Redeem, Close, Matured and Account Close
    IF c_aalocCurrActivity EQ 'DEPOSITS-REDEEM-ARRANGEMENT' OR c_aalocCurrActivity EQ 'DEPOSITS-CLOSE-ARRANGEMENT' OR c_aalocCurrActivity EQ 'DEPOSITS-MATURE-ARRANGEMENT' OR c_aalocCurrActivity EQ 'ACCOUNTS-CLOSE-ARRANGEMENT' THEN
        GOSUB CHRG.PROCESS
    END
* This if part is for Schedule wise Excise Duty Deduction
    IF c_aalocCurrActivity EQ 'ACCOUNTS-CAPITALISE-SCHEDULE' OR c_aalocCurrActivity EQ 'DEPOSITS-MAKEDUE-SCHEDULE' OR c_aalocCurrActivity EQ 'LENDING-MAKEDUE-SCHEDULE' THEN
        GOSUB PROCESS
    END
    
RETURN

*****
INIT:
*****
    FN.BD.CHG = 'F.BD.CHG.INFORMATION'
    F.BD.CHG = ''
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    FN.AC.CLASS = 'F.ACCOUNT.CLASS'
    F.AC.CLASS = ''
    FN.LI = 'F.LIMIT'
    F.LI = ''
    FN.FTCT = 'F.FT.COMMISSION.TYPE'
    F.FTCT = ''
    FN.AA.AC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.AC = ''
    FN.COM = 'F.COMPANY'
    F.COM = ''
    FN.AA.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ACTIVITY = ''
    FN.MATURE.VAL = 'F.BD.MBL.MSS.MATURE.VAL'
    F.MATURE.VAL = ''
    FN.AA.INT = 'FBNK.AA.PRD.DES.INTEREST'
    F.AA.INT = ''
    FN.BASIC.INT = 'FBNK.BASIC.INTEREST'
    F.BASIC.INT = ''
    Y.MAX.AMT = 0
    
    Y.END.DATE = ''
    Y.START.DATE = ''
    ArrangementId = ''
    Y.PRODUCT.LINE = ''
    Y.BD.CHG.ID = ''
    RequestType = ''
    Y.WORKING.BALANCE = ''
    Y.LIMIT = ''
    Y.LIMIT.ID = ''
    Y.LEN = ''
    Y.ED.CHECK = ''
    Y.MAX.AMT = ''
    Y.MIN.AMT = ''
    CHARGE.AMOUNT = 0
    Y.BD.CHG.ID = ''
    
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
    EB.DataAccess.Opf(FN.AC.CLASS,F.AC.CLASS)
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.LI,F.LI)
    EB.DataAccess.Opf(FN.FTCT,F.FTCT)
    EB.DataAccess.Opf(FN.AA.AC,F.AA.AC)
    EB.DataAccess.Opf(FN.COM,F.COM)
    EB.DataAccess.Opf(FN.AA.ACTIVITY,F.AA.ACTIVITY)
    EB.DataAccess.Opf(FN.MATURE.VAL, F.MATURE.VAL)
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    EB.DataAccess.Opf(FN.BASIC.INT, F.BASIC.INT)
RETURN

********
PROCESS:
********

    EB.DataAccess.FRead(FN.AA.ACTIVITY,c_aalocTxnReference,R.AA.ACTIVITY,F.AA.ACTIVITY,E.AA.ACTIVITY)
    Y.REC.STATUS = R.AA.ACTIVITY<AA.Framework.ArrangementActivity.ArrActRecordStatus>
 
    IF Y.REC.STATUS EQ 'REVE' OR Y.REC.STATUS EQ 'RNAU' THEN
        RETURN
    END
    
    Y.END.DATE = EB.SystemTables.getToday()
    Y.START.DATE = Y.END.DATE[1,4]:'0101'
    
    EB.DataAccess.FRead(FN.AA.AC,arrId,R.AA.AC,F.AA.AC,E.AA.AC)
    Y.RENEW.DATE =R.AA.AC<AA.PaymentSchedule.AccountDetails.AdRenewalDate>
    Y.activityrecord = AA.Framework.getC_aalocarractivityrec()
    Y.ACTIVITY.DATE = Y.activityrecord<AA.Framework.ArrangementActivity.ArrActEffectiveDate>
    
    IF Y.RENEW.DATE EQ Y.ACTIVITY.DATE THEN RETURN
**********************************************************************************************
    Y.MAT.DATE =R.AA.AC<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
    Y.PROP.CLASS = 'PAYMENT.SCHEDULE'
    AA.Framework.GetArrangementConditions(arrId,Y.PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.REC = RAISE(RETURN.VALUES)
    Y.PROPERTY.LIST = R.REC<AA.PaymentSchedule.PaymentSchedule.PsProperty>
    Y.DUE.FREQ.LIST = R.REC<AA.PaymentSchedule.PaymentSchedule.PsDueFreq>
    LOCATE arrProp IN Y.PROPERTY.LIST<1,1> SETTING Y.PROP.POS THEN
        Y.DUE.FREQ = Y.DUE.FREQ.LIST<1,Y.PROP.POS>
    END
    Y.MN = FIELD(Y.DUE.FREQ,' ',2)[2,2]
    Y.DAY = FIELD(Y.DUE.FREQ,' ',4)[2,2]
    Y.M.CHECK = ISDIGIT(Y.MN)
    Y.D.CHECK = ISDIGIT(Y.DAY)
    IF Y.M.CHECK EQ 0 THEN
        Y.MN = '0':FIELD(Y.DUE.FREQ,' ',2)[2,1]
    END
    IF Y.D.CHECK EQ 0 THEN
        Y.DAY = '0':FIELD(Y.DUE.FREQ,' ',4)[2,1]
    END
    Y.MNDD =  Y.MN:Y.DAY
    IF Y.MAT.DATE EQ perDat AND Y.MNDD NE Y.MAT.DATE[5,4] THEN RETURN
**********************************************************************************************
    ArrangementId = arrId
    AA.Framework.GetArrangementAccountId(ArrangementId, accountId, Currency, ReturnError)   ;*To get Arrangement Account
    AA.Framework.GetArrangementProduct(ArrangementId, EffDate, ArrRecord, ProductId, PropertyList)  ;*Arrangement record
    Y.PRODUCT.LINE = ArrRecord<AA.Framework.Arrangement.ArrProductLine>
    Y.PRODUCT.GROUP = ArrRecord<AA.Framework.Arrangement.ArrProductGroup>
    AA.Framework.GetBaseBalanceList(ArrangementId, arrProp, ReqdDate, ProductId, BaseBalance)
    
    Y.AC.REC = AC.AccountOpening.Account.Read(accountId, Error)
    Y.BALANCE =  Y.AC.REC<AC.AccountOpening.Account.WorkingBalance>
    Y.CATEGORY = Y.AC.REC<AC.AccountOpening.Account.Category>
    Y.CUSTOMER = Y.AC.REC<AC.AccountOpening.Account.Customer>
    Y.LIMIT = Y.AC.REC<AC.AccountOpening.Account.LimitRef>
**********************************************************************************************
    RequestType<2> = 'ALL'      ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'      ;* Projected Movements requierd
    RequestType<4> = 'ECB'      ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    AA.Framework.GetPeriodBalances(accountId,BaseBalance,RequestType,Y.START.DATE,Y.END.DATE,SystemDate,BalDetails,ErrorMessage)
    Y.BALANC.GET = BalDetails<4>
**********************************************************************************************
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
    Y.WORKING.BALANCE = ABS(Y.BALANCE - Y.MIN.BAL)
   
    IF Y.LIMIT NE '' THEN
        IF LEN(Y.LIMIT) LE 7 THEN
            Y.LIMIT = Y.LIMIT 'R%10'
        END ELSE
            Y.LEN = LEN(Y.LIMIT)+3
            Y.LIMIT = Y.LIMIT 'R%Y.LEN'
        END
    END
* This part is for Product wise lending Product Excise Duty Calculation
    IF Y.ED.APPLY EQ 'PRODUCT' THEN
        Y.LIMIT.ID = Y.CUSTOMER:'.':Y.LIMIT
        EB.DataAccess.FRead(FN.LI,Y.LIMIT.ID, R.LI, F.LI, LI.ERROR)
        READU R.LI FROM F.LI,Y.LIMIT.ID LOCKED
            SLEEP 10
            RETURN
        END ELSE
            EB.DataAccess.FRelease(FN.LI,Y.LIMIT.ID,F.LI)
        END
        Y.ED.CHECK =  R.LI<LI.Config.Limit.LocalRef,Y.ED.CHECK.POS>

        IF Y.ED.CHECK EQ '' OR Y.ED.CHECK NE EB.SystemTables.getToday() THEN
            Y.LIMIT.ACCOUNT = R.LI<LI.Config.Limit.Account>
            Y.COUNT = DCOUNT(Y.LIMIT.ACCOUNT,VM)
            FOR I = 1 TO Y.COUNT
                Y.AC.ID = Y.LIMIT.ACCOUNT<1,I>
*                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)
*                Y.MIN.AMT += MINIMUM(BalDetails<4>)
*                Y.MAX.AMT = ABS(Y.MIN.AMT)
                BaseBalance1 = BaseBalance
                BaseBalance2 = 'DUEACCOUNT'
                BaseBalance3 = 'UNDACCOUNT'
                BaseBalance4 = 'SUBACCOUNT'
                BaseBalance5 = 'STDACCOUNT'
                BaseBalance6 = 'SMAACCOUNT'
                BaseBalance7 = 'DOFACCOUNT'
                BaseBalance8 = 'DUEACCOUNT'
                BaseBalance9 = 'GRCACCOUNT'
                BaseBalance10 = 'DELACCOUNT'
                BaseBalance11 = 'NABACCOUNT'
                BaseBalance12 = 'PAYACCOUNT'
                BaseBalance13 = 'ACCDEFERREDPFT'
                BaseBalance14 = 'ACCGRACEPFT'
                BaseBalance15 = 'ACCGRCDEFERREDPFT'
                BaseBalance16 = 'ACCPENALTYPFT'
                BaseBalance17 = 'ACCPRINCIPALPFT'
                BaseBalance18 = 'ACCSUSPFT'
                BaseBalance19 = 'DUEPRINCIPALPFT'
                BaseBalance20 = 'GRCPRINCIPALPFT'
                BaseBalance21 = 'NABPRINCIPALPFT'
            
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance1, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails1, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance2, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails2, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance3, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails3, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance4, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails4, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance5, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails5, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance6, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails6, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance7, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails7, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance8, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails8, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance9, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails9, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance10, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails10, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance11, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails11, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance12, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails12, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance13, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails13, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance14, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails14, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance15, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails15, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance16, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails16, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance17, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails17, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance18, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails18, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance19, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails19, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance20, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails20, ErrorMessage);
                AA.Framework.GetPeriodBalances(Y.AC.ID, BaseBalance21, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails21, ErrorMessage);
          
            
                balanceAmount1 =   ABS(MINIMUM(BalDetails1<4>))
                balanceAmount2 =   ABS(MINIMUM(BalDetails2<4>))
                balanceAmount3 =   ABS(MINIMUM(BalDetails3<4>))
                balanceAmount4 =   ABS(MINIMUM(BalDetails4<4>))
                balanceAmount5 =   ABS(MINIMUM(BalDetails5<4>))
                balanceAmount6 =   ABS(MINIMUM(BalDetails6<4>))
                balanceAmount7 =   ABS(MINIMUM(BalDetails7<4>))
                balanceAmount8 =   ABS(MINIMUM(BalDetails8<4>))
                balanceAmount9 =   ABS(MINIMUM(BalDetails9<4>))
                balanceAmount10 =   ABS(MINIMUM(BalDetails10<4>))
                balanceAmount11 =   ABS(MINIMUM(BalDetails11<4>))
                balanceAmount12 =   ABS(MINIMUM(BalDetails12<4>))
                balanceAmount13 =   ABS(MINIMUM(BalDetails13<4>))
                balanceAmount14 =   ABS(MINIMUM(BalDetails14<4>))
                balanceAmount15 =   ABS(MINIMUM(BalDetails15<4>))
                balanceAmount16 =   ABS(MINIMUM(BalDetails16<4>))
                balanceAmount17 =   ABS(MINIMUM(BalDetails17<4>))
                balanceAmount18 =   ABS(MINIMUM(BalDetails18<4>))
                balanceAmount19 =   ABS(MINIMUM(BalDetails19<4>))
                balanceAmount20 =   ABS(MINIMUM(BalDetails20<4>))
                balanceAmount21 =   ABS(MINIMUM(BalDetails21<4>))
            
                Y.MIN.AMT += balanceAmount1 + balanceAmount2 + balanceAmount3 + balanceAmount4 + balanceAmount5 + balanceAmount6 + balanceAmount7 + balanceAmount8 + balanceAmount9 + balanceAmount10 + balanceAmount11 + balanceAmount12 + balanceAmount13 + balanceAmount14 + balanceAmount15 + balanceAmount16 + balanceAmount17 + balanceAmount18 + balanceAmount19 + balanceAmount20 + balanceAmount21
                Y.MAX.AMT = Y.MIN.AMT
            NEXT I
            GOSUB EDPROCESS
            Y.ED.CHECK = EB.SystemTables.getToday()
            R.LI<LI.Config.Limit.LocalRef,Y.ED.CHECK.POS> = Y.ED.CHECK
            EB.DataAccess.FWrite(FN.LI,Y.LIMIT.ID,R.LI)
            EB.TransactionControl.JournalUpdate(Y.LIMIT.ID)
        END
    END ELSE
        AA.Framework.GetPeriodBalances(accountId, BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)    ;*Balance left in the balance Type
        Y.MAX.AMT = ABS(MAXIMUM(BalDetails<4>))
        IF  Y.PRODUCT.GROUP EQ 'MBL.BS.GRP.DP' OR Y.PRODUCT.GROUP EQ 'IS.MBL.MMMA.DP' THEN
            GOSUB INT.AMOUNT.INCOME.SCHEME
            Y.INT.AMT = Y.ONE.M.PFT
            Y.MAX.AMT = Y.MAX.AMT + Y.INT.AMT
        END
        IF Y.PRODUCT.LINE EQ 'LENDING' THEN
            BaseBalance1 = BaseBalance
            BaseBalance2 = 'DUEACCOUNT'
            BaseBalance3 = 'UNDACCOUNT'
            BaseBalance4 = 'SUBACCOUNT'
            BaseBalance5 = 'STDACCOUNT'
            BaseBalance6 = 'SMAACCOUNT'
            BaseBalance7 = 'DOFACCOUNT'
            BaseBalance8 = 'DUEACCOUNT'
            BaseBalance9 = 'GRCACCOUNT'
            BaseBalance10 = 'DELACCOUNT'
            BaseBalance11 = 'NABACCOUNT'
            BaseBalance12 = 'PAYACCOUNT'
            BaseBalance13 = 'ACCDEFERREDPFT'
            BaseBalance14 = 'ACCGRACEPFT'
            BaseBalance15 = 'ACCGRCDEFERREDPFT'
            BaseBalance16 = 'ACCPENALTYPFT'
            BaseBalance17 = 'ACCPRINCIPALPFT'
            BaseBalance18 = 'ACCSUSPFT'
            BaseBalance19 = 'DUEPRINCIPALPFT'
            BaseBalance20 = 'GRCPRINCIPALPFT'
            BaseBalance21 = 'NABPRINCIPALPFT'
            
            AA.Framework.GetPeriodBalances(accountId, BaseBalance1, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails1, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance2, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails2, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance3, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails3, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance4, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails4, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance5, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails5, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance6, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails6, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance7, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails7, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance8, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails8, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance9, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails9, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance10, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails10, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance11, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails11, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance12, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails12, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance13, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails13, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance14, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails14, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance15, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails15, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance16, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails16, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance17, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails17, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance18, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails18, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance19, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails19, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance20, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails20, ErrorMessage);
            AA.Framework.GetPeriodBalances(accountId, BaseBalance21, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails21, ErrorMessage);
          
            
            balanceAmount1 =   ABS(MINIMUM(BalDetails1<4>))
            balanceAmount2 =   ABS(MINIMUM(BalDetails2<4>))
            balanceAmount3 =   ABS(MINIMUM(BalDetails3<4>))
            balanceAmount4 =   ABS(MINIMUM(BalDetails4<4>))
            balanceAmount5 =   ABS(MINIMUM(BalDetails5<4>))
            balanceAmount6 =   ABS(MINIMUM(BalDetails6<4>))
            balanceAmount7 =   ABS(MINIMUM(BalDetails7<4>))
            balanceAmount8 =   ABS(MINIMUM(BalDetails8<4>))
            balanceAmount9 =   ABS(MINIMUM(BalDetails9<4>))
            balanceAmount10 =   ABS(MINIMUM(BalDetails10<4>))
            balanceAmount11 =   ABS(MINIMUM(BalDetails11<4>))
            balanceAmount12 =   ABS(MINIMUM(BalDetails12<4>))
            balanceAmount13 =   ABS(MINIMUM(BalDetails13<4>))
            balanceAmount14 =   ABS(MINIMUM(BalDetails14<4>))
            balanceAmount15 =   ABS(MINIMUM(BalDetails15<4>))
            balanceAmount16 =   ABS(MINIMUM(BalDetails16<4>))
            balanceAmount17 =   ABS(MINIMUM(BalDetails17<4>))
            balanceAmount18 =   ABS(MINIMUM(BalDetails18<4>))
            balanceAmount19 =   ABS(MINIMUM(BalDetails19<4>))
            balanceAmount20 =   ABS(MINIMUM(BalDetails20<4>))
            balanceAmount21 =   ABS(MINIMUM(BalDetails21<4>))
                
            Y.MAX.AMT  = balanceAmount1 + balanceAmount2 + balanceAmount3 + balanceAmount4 + balanceAmount5 + balanceAmount6 + balanceAmount7 + balanceAmount8 + balanceAmount9 + balanceAmount10 + balanceAmount11 + balanceAmount12 + balanceAmount13 + balanceAmount14 + balanceAmount15 + balanceAmount16 + balanceAmount17 + balanceAmount18 + balanceAmount19 + balanceAmount20 + balanceAmount21
        END
        GOSUB EDPROCESS
    END
RETURN

**********
EDPROCESS:
**********
    IF Y.MAX.AMT LE 0 THEN
        RETURN
    END
    Y.FTCT.ID = 'EDCHG'
    EB.DataAccess.FRead(FN.FTCT,Y.FTCT.ID,R.FTCT,F.FTCT,FT.CT.ERR)
    Y.UPTO.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouUptoAmt>
    Y.MIN.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouMinimumAmt>
    CONVERT SM TO VM IN Y.UPTO.AMT
    CONVERT SM TO VM IN Y.MIN.AMT
    Y.DCOUNT = DCOUNT(Y.UPTO.AMT,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.AMT = Y.UPTO.AMT<1,I>
        IF Y.MAX.AMT LE Y.AMT THEN
            BREAK
        END
    NEXT I
    CHARGE.AMOUNT = Y.MIN.AMT<1,I>
********Update the Local Template********************************
    Y.BD.CHG.ID = accountId:'-':arrProp
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
*******************************************************
    IF R.BD.CHG NE '' THEN
        Y.TXN.DATE = R.BD.CHG<BD.CHG.TXN.DATE>
        LOCATE perDat IN Y.TXN.DATE<1,1> SETTING Y.TXN.DATE.POS THEN
            RETURN
        END
    END
*******************************************************
    IF Y.PRODUCT.LINE EQ 'ACCOUNTS' THEN
        IF R.BD.CHG EQ '' THEN
            R.BD.CHG<BD.CHG.BASE.AMT> = Y.MAX.AMT
            R.BD.CHG<BD.TOTAL.CHG.AMT> = CHARGE.AMOUNT
            R.BD.CHG<BD.CHG.TXN.DATE > = perDat
            IF Y.WORKING.BALANCE GE CHARGE.AMOUNT THEN
                R.BD.CHG<BD.CHG.TXN.REFNO> = c_aalocTxnReference
                R.BD.CHG<BD.CHG.SLAB.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.AMT> =  CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.DUE.AMT> = 0
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + CHARGE.AMOUNT
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + 0
                R.BD.CHG<BD.CHG.TXN.FLAG> = 'Schedule'
            END ELSE
                R.BD.CHG<BD.CHG.TXN.REFNO> = c_aalocTxnReference
                R.BD.CHG<BD.CHG.SLAB.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.AMT> =  0
                R.BD.CHG<BD.CHG.TXN.DUE.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + 0
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + CHARGE.AMOUNT
                CHARGE.AMOUNT = 0
            END
        END ELSE
            Y.DCOUNT =DCOUNT(R.BD.CHG<BD.CHG.TXN.DATE>,VM) + 1
            R.BD.CHG<BD.CHG.BASE.AMT,Y.DCOUNT> = Y.MAX.AMT
            R.BD.CHG<BD.TOTAL.CHG.AMT> = R.BD.CHG<BD.TOTAL.CHG.AMT> + CHARGE.AMOUNT
            R.BD.CHG<BD.CHG.TXN.DATE,Y.DCOUNT> = perDat
            IF Y.WORKING.BALANCE GE CHARGE.AMOUNT THEN
                R.BD.CHG<BD.CHG.TXN.REFNO,Y.DCOUNT> = c_aalocTxnReference
                R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.DUE.AMT,Y.DCOUNT> = 0
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + CHARGE.AMOUNT
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + 0
                R.BD.CHG<BD.CHG.TXN.FLAG,Y.DCOUNT> = 'Schedule'
            END ELSE
                R.BD.CHG<BD.CHG.TXN.REFNO,Y.DCOUNT> = c_aalocTxnReference
                R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT> = 0
                R.BD.CHG<BD.CHG.TXN.DUE.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + 0
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + CHARGE.AMOUNT
                CHARGE.AMOUNT = 0
            END
        END
    END
    IF Y.PRODUCT.LINE EQ 'LENDING' THEN
        IF R.BD.CHG EQ '' THEN
            R.BD.CHG<BD.CHG.BASE.AMT> = Y.MAX.AMT
            R.BD.CHG<BD.TOTAL.CHG.AMT> = CHARGE.AMOUNT
            R.BD.CHG<BD.CHG.TXN.DATE > = perDat
            R.BD.CHG<BD.CHG.TXN.REFNO> = c_aalocTxnReference
            R.BD.CHG<BD.CHG.SLAB.AMT> = CHARGE.AMOUNT
            R.BD.CHG<BD.CHG.TXN.AMT> = CHARGE.AMOUNT
            R.BD.CHG<BD.CHG.TXN.DUE.AMT> = 0
            R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + CHARGE.AMOUNT
            R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + 0
            R.BD.CHG<BD.CHG.TXN.FLAG> = 'Schedule'
        END ELSE
            Y.DCOUNT =DCOUNT(R.BD.CHG<BD.CHG.TXN.DATE>,@VM) + 1
            R.BD.CHG<BD.CHG.BASE.AMT,Y.DCOUNT> = Y.MAX.AMT
            R.BD.CHG<BD.TOTAL.CHG.AMT> = R.BD.CHG<BD.TOTAL.CHG.AMT> + CHARGE.AMOUNT
            R.BD.CHG<BD.CHG.TXN.DATE,Y.DCOUNT> = perDat
            R.BD.CHG<BD.CHG.TXN.REFNO,Y.DCOUNT> = c_aalocTxnReference
            R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = CHARGE.AMOUNT
            R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT> = CHARGE.AMOUNT
            R.BD.CHG<BD.CHG.TXN.DUE.AMT,Y.DCOUNT> = 0
            R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + CHARGE.AMOUNT
            R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + 0
            R.BD.CHG<BD.CHG.TXN.FLAG,Y.DCOUNT> = 'Schedule'
        END
    END

    IF Y.PRODUCT.LINE EQ 'DEPOSITS' THEN
        R.BD.CHG<BD.PRODUCT.GROUP> = Y.PRODUCT.GROUP
        Y.AC.CLASS.ID = 'U-ED.DP'
        EB.DataAccess.FRead(FN.AC.CLASS,Y.AC.CLASS.ID,R.AC.CLASS,F.AC.CLASS,AC.CLASS.ER)
        Y.CATEGORY.LIST = R.AC.CLASS<AC.Config.AccountClass.ClsCategory>
        LOCATE Y.CATEGORY IN Y.CATEGORY.LIST<1,1> SETTING Y.CATEG.POS THEN
*********************************************************************************************
            IF R.BD.CHG EQ '' THEN
                R.BD.CHG<BD.CHG.BASE.AMT> = Y.MAX.AMT
                R.BD.CHG<BD.TOTAL.CHG.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.DATE > = perDat
                R.BD.CHG<BD.CHG.SLAB.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.REFNO> = c_aalocTxnReference
                R.BD.CHG<BD.CHG.TXN.AMT> =  0
                R.BD.CHG<BD.CHG.TXN.DUE.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.OS.DUE.AMT> = 0
                R.BD.CHG<BD.CHG.TXN.FLAG> = 'Schedule'
            END ELSE
                Y.DCOUNT =DCOUNT(R.BD.CHG<BD.CHG.TXN.DATE>,VM) + 1
                R.BD.CHG<BD.CHG.BASE.AMT,Y.DCOUNT> = Y.MAX.AMT
                R.BD.CHG<BD.TOTAL.CHG.AMT> = R.BD.CHG<BD.TOTAL.CHG.AMT> + CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.DATE ,Y.DCOUNT> = perDat
                R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.REFNO,Y.DCOUNT> = c_aalocTxnReference
                R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT> = 0
                R.BD.CHG<BD.CHG.TXN.DUE.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + CHARGE.AMOUNT
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + 0
                R.BD.CHG<BD.CHG.TXN.FLAG,Y.DCOUNT> = 'Schedule'
            END
        END ELSE ; * Issue 5
            IF R.BD.CHG EQ '' THEN
                R.BD.CHG<BD.CHG.BASE.AMT> = Y.MAX.AMT
                R.BD.CHG<BD.TOTAL.CHG.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.DATE> = perDat
                R.BD.CHG<BD.CHG.SLAB.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.REFNO> = c_aalocTxnReference
                R.BD.CHG<BD.CHG.TXN.AMT> = 0
                R.BD.CHG<BD.CHG.TXN.DUE.AMT> = CHARGE.AMOUNT
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + 0
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + CHARGE.AMOUNT
                CHARGE.AMOUNT = 0
            END ELSE
                Y.DCOUNT =DCOUNT(R.BD.CHG<BD.CHG.TXN.DATE>,VM) + 1
                R.BD.CHG<BD.CHG.BASE.AMT,Y.DCOUNT> = Y.MAX.AMT
                R.BD.CHG<BD.TOTAL.CHG.AMT> = R.BD.CHG<BD.TOTAL.CHG.AMT> + CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.DATE,Y.DCOUNT> = perDat
                R.BD.CHG<BD.CHG.SLAB.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.CHG.TXN.REFNO,Y.DCOUNT> = c_aalocTxnReference
                R.BD.CHG<BD.CHG.TXN.AMT,Y.DCOUNT> = 0
                R.BD.CHG<BD.CHG.TXN.DUE.AMT,Y.DCOUNT> = CHARGE.AMOUNT
                R.BD.CHG<BD.TOTAL.REALIZE.AMT> = R.BD.CHG<BD.TOTAL.REALIZE.AMT> + 0
                R.BD.CHG<BD.OS.DUE.AMT> = R.BD.CHG<BD.OS.DUE.AMT> + CHARGE.AMOUNT
                CHARGE.AMOUNT = 0
            END
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
CHRG.PROCESS:
*************
    EB.DataAccess.FRead(FN.AA,arrId,R.AA.ARR,F.AA,Y.ARR.ERR)
    Y.MNEMONIC = FN.AA.AC[2,3]
    Y.PRODUCT.GROUP = R.AA.ARR<AA.Framework.Arrangement.ArrProductGroup>
    Y.END.DATE = EB.SystemTables.getToday()
    Y.START.DATE = Y.END.DATE[1,4]:'0101'
    AA.Framework.GetBaseBalanceList(arrId, arrProp, ReqdDate, ProductId, BaseBalance)
    AA.Framework.GetArrangementAccountId(arrId, accountId, Currency, ReturnError)
    RequestType<2> = 'ALL'      ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'      ;* Projected Movements requierd
    RequestType<4> = 'ECB'      ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    AA.Framework.GetPeriodBalances(accountId, BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)    ;*Balance left in the balance Type
    Y.CUR.AMT = MAXIMUM(ABS(BalDetails<4>))
****************************************************************
    Y.BD.CHG.ID = accountId:'-':arrProp
    EB.DataAccess.FRead(FN.BD.CHG,Y.BD.CHG.ID,R.BD.CHG,F.BD.CHG,BD.CHG.ER)
    IF Y.PRODUCT.GROUP EQ 'MBL.BS.GRP.DP' OR Y.PRODUCT.GROUP EQ 'IS.MBL.MMMA.DP' THEN
        GOSUB INT.AMOUNT.INCOME.SCHEME
        Y.INT.AMT = Y.ONE.M.PFT
    END ELSE
        IF Y.MNEMONIC EQ 'ISL' THEN
            BaseBalance = 'ACCDEPOSITPFT'
        END
        IF Y.MNEMONIC EQ 'BNK' THEN
            BaseBalance = 'ACCDEPOSITINT'
        END
        ReqdDate = EB.SystemTables.getToday()
        RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
        RequestType<3> = 'ALL'  ;* Projected Movements requierd
        RequestType<4> = 'ECB'  ;* Balance file to be used
        RequestType<4,2> = 'END'
        AA.Framework.GetPeriodBalances(accountId, BaseBalance, RequestType, ReqdDate, EndDate, SystemDate, BalDetails, ErrorMessage)
        Y.INT.AMT = ABS(BalDetails<4>)
        IF Y.INT.AMT EQ 0 THEN
            Y.INT.AMT = ABS(BalDetails<3>)
        END
    END
       
*----edit by sayeed for calculate accured interest without redeemption fee---------------------------
    IF c_aalocCurrActivity EQ 'DEPOSITS-REDEEM-ARRANGEMENT' THEN
        GOSUB GET.SVR.FIND.INTEREST
        EB.DataAccess.FRead(FN.AA,arrId,R.AA.ARR,F.AA,Y.ARR.ERR)
        Y.MNEMONIC = FN.AA.AC[2,3]
        Y.PRODUCT.GROUP = R.AA.ARR<AA.Framework.Arrangement.ArrProductGroup>
        BEGIN CASE
            CASE Y.PRODUCT.GROUP EQ 'MBL.FDR.GRP.DP' OR Y.PRODUCT.GROUP EQ 'IS.MBL.MTD.DP'
                EB.DataAccess.FRead(FN.AA.AC,arrId,R.AA.AC,F.AA.AC,E.AA.AC)
                Y.TOT.LAST.RENEW = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdLastRenewDate>
                NO.OF.RENEW.DT = DCOUNT(Y.TOT.LAST.RENEW,VM)
                Y.LAST.RENEW.DT = Y.TOT.LAST.RENEW<1,NO.OF.RENEW.DT>
                IF Y.LAST.RENEW.DT EQ '' THEN
                    Y.LAST.RENEW.DT = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
                END
                Y.TODAY = EB.SystemTables.getToday()
                GOSUB ORGINAL.DAYS
                Y.DAYS = AccrDays
                IF Y.DAYS GT 30 THEN
                    Y.TERM.AMOUNT = Y.CUR.AMT
                    Y.PRE.PROFIT = DROUND(((Y.DAYS*Y.TERM.AMOUNT*Y.INT.RATE)/(100*360)),2)
                    Y.INT.AMT = Y.PRE.PROFIT
                END ELSE
                    Y.INT.AMT = 0
                END
            CASE Y.PRODUCT.GROUP EQ 'MBL.BS.GRP.DP' OR Y.PRODUCT.GROUP EQ 'IS.MBL.MMMA.DP'
                GOSUB ORGINAL.DAYS
                Y.DAYS = AccrDays
                IF Y.DAYS LE 30 THEN
                    Y.INT.AMT = 0
                END ELSE
                    GOSUB INT.AMOUNT.INCOME.SCHEME
                    Y.INT.AMT = Y.ONE.M.PFT
                END
            CASE Y.PRODUCT.GROUP EQ 'MBL.MP.GRP.DP' OR Y.PRODUCT.GROUP EQ 'IS.MBL.MDBS.DP'
                EB.DataAccess.FRead(FN.AA.AC,arrId,R.AA.AC,F.AA.AC,E.AA.AC)
                Y.LAST.RENEW.DT = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
                IF Y.LAST.RENEW.DT EQ '' THEN
                    Y.LAST.RENEW.DT = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
                END
                Y.TODAY = EB.SystemTables.getToday()
                GOSUB ORGINAL.DAYS
                Y.DAYS = AccrDays
                IF Y.DAYS GT 360 THEN
                    Y.MONTH = AccrDays/30
                    Y.MONTH = FIELD(Y.MONTH,'.',1)
                    Y.PRE.PROFIT = DROUND(((Y.MONTH * Y.CUR.AMT * (Y.INT.RATE))/(12*100)),2)
                    Y.INT.AMT = Y.PRE.PROFIT
                END ELSE
                    Y.INT.AMT = 0
                END
            CASE Y.PRODUCT.GROUP EQ 'IS.MBL.MMSP.DP' OR Y.PRODUCT.GROUP EQ 'MBL.SP.GRP.DP'
                EB.DataAccess.FRead(FN.AA.AC,arrId,R.AA.AC,F.AA.AC,E.AA.AC)
                Y.LAST.RENEW.DT = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
                IF Y.LAST.RENEW.DT EQ '' THEN
                    Y.LAST.RENEW.DT = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
                END
                Y.TODAY = EB.SystemTables.getToday()
                GOSUB ORGINAL.DAYS
                Y.DAYS = AccrDays
                PROP.CLASS = 'TERM.AMOUNT'
                CALL AA.GET.ARRANGEMENT.CONDITIONS(arrId,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
                RR.REC = RAISE(RETURN.VALUES)
                Y.INSTALL.AMT = RR.REC<AA.TermAmount.TermAmount.AmtAmount>
                Y.BILL.TYPE = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillType>
                Y.BILL.STATUS = R.AA.AC<AA.PaymentSchedule.AccountDetails.AdBillStatus>
                CONVERT SM TO VM IN Y.BILL.TYPE
                CONVERT SM TO VM IN Y.BILL.STATUS
                Y.DCOUNT = DCOUNT(Y.BILL.TYPE,VM)
                FOR I = 1 TO Y.DCOUNT
                    Y.BILL =  Y.BILL.TYPE<1,I>
                    Y.STATUS =  Y.BILL.STATUS<1,I>
                    IF Y.BILL EQ 'EXPECTED' AND Y.STATUS EQ 'SETTLED' THEN
                        Y.CNT = Y.CNT + 1 ;* Y.CNT is how many installment customer already paid
                    END
                NEXT I
                Y.PAID.INS.NO = Y.CNT
                BEGIN CASE
                    CASE Y.DAYS LT 360
                        Y.INT.AMT = 0
                    CASE Y.PAID.INS.NO GE 12 AND Y.PAID.INS.NO LT 36
                        GOSUB PREMATURE.INTEREST
                        Y.INT.AMT = Y.PRE.INTEREST
                    CASE Y.PAID.INS.NO GE 36 AND Y.PAID.INS.NO LT 60
                        Y.MATURE.MONTH = 36
                        GOSUB GET.SLAB.INTEREST
                        Y.REMAINING.REPAY = Y.CNT - 36
                        IF Y.REMAINING.REPAY GE 12 THEN
                            Y.CNT = Y.CNT - 36 ;* after 3 years
                            GOSUB PREMATURE.INTEREST
                            Y.INT.AMT = (Y.PRE.INTEREST)+(Y.MATURE.INT - (Y.INSTALL.AMT * Y.MATURE.MONTH))
                        END ELSE
                            Y.INT.AMT = Y.MATURE.INT - (Y.INSTALL.AMT * Y.MATURE.MONTH)
                        END
                    CASE Y.PAID.INS.NO GE 60 AND Y.PAID.INS.NO LT 96
                        Y.MATURE.MONTH = 60
                        GOSUB GET.SLAB.INTEREST
                        Y.REMAINING.REPAY = Y.CNT - 60
                        IF Y.REMAINING.REPAY GE 12 THEN
                            Y.CNT = Y.CNT - 60 ;* after 5 years
                            GOSUB PREMATURE.INTEREST
                            Y.INT.AMT = (Y.PRE.INTEREST)+(Y.MATURE.INT - (Y.INSTALL.AMT * Y.MATURE.MONTH))
                        END ELSE
                            Y.INT.AMT = Y.MATURE.INT - (Y.INSTALL.AMT * Y.MATURE.MONTH)
                        END
                    CASE Y.PAID.INS.NO GE 96 AND Y.PAID.INS.NO LT 120
                        Y.MATURE.MONTH = 96
                        GOSUB GET.SLAB.INTEREST
                        Y.REMAINING.REPAY = Y.CNT - 96
                        IF Y.REMAINING.REPAY GE 12 THEN
                            Y.CNT = Y.CNT - 96 ;* after 8 years
                            GOSUB PREMATURE.INTEREST
                            Y.INT.AMT = (Y.PRE.INTEREST)+(Y.MATURE.INT - (Y.INSTALL.AMT * Y.MATURE.MONTH))
                        END ELSE
                            Y.INT.AMT = Y.MATURE.INT - (Y.INSTALL.AMT * Y.MATURE.MONTH)
                        END
                    CASE Y.PAID.INS.NO GE 120
                        Y.MATURE.MONTH = 120
                        GOSUB GET.SLAB.INTEREST
                        Y.REMAINING.REPAY = Y.CNT - 120
                        IF Y.REMAINING.REPAY GE 12 THEN
                            Y.CNT = Y.CNT - 120 ;* after 10 years
                            GOSUB PREMATURE.INTEREST
                            Y.INT.AMT = (Y.PRE.INTEREST)+(Y.MATURE.INT - (Y.INSTALL.AMT * Y.MATURE.MONTH))
                        END ELSE
                            Y.INT.AMT = Y.MATURE.INT - (Y.INSTALL.AMT * Y.MATURE.MONTH)
                        END
                END CASE
        END CASE
      
    END
*-----------------end-------------------------------------------------------------------------
    Y.MAX.AMT = Y.CUR.AMT + Y.INT.AMT
*******************************************************************
    Y.FTCT.ID = 'EDCHG'
    EB.DataAccess.FRead(FN.FTCT,Y.FTCT.ID,R.FTCT,F.FTCT,FT.CT.ERR)
    Y.UPTO.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouUptoAmt>
    Y.MIN.AMT = R.FTCT<ST.ChargeConfig.FtCommissionType.FtFouMinimumAmt>
    CONVERT SM TO VM IN Y.UPTO.AMT
    CONVERT SM TO VM IN Y.MIN.AMT
    Y.DCOUNT = DCOUNT(Y.UPTO.AMT,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.AMT = Y.UPTO.AMT<1,I>
        IF Y.MAX.AMT LE Y.AMT THEN
            BREAK
        END
    NEXT I
    CHARGE.AMOUNT = Y.MIN.AMT<1,I>
    balanceAmount = R.BD.CHG<BD.OS.DUE.AMT> + CHARGE.AMOUNT
    
RETURN
*----edit by sayeed for calculate accured interest without redeemption fee---------------------------
GET.SVR.FIND.INTEREST: ;* This Gosub use for finding saving interest
    IF Y.MNEMONIC EQ 'ISL' THEN
        SEL.CMD = 'SELECT ':FN.AA.INT:' WITH @ID LIKE IS.MBL.PROFIT.MSD.GEN-BDT...'
        EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.BASIC, ERR.INT)
        Y.AA.INT.SAV.ID = SEL.LIST<NO.OF.BASIC>
        EB.DataAccess.FRead(FN.AA.INT,Y.AA.INT.SAV.ID,R.AA.INT,F.AA.INT,E.INT.ERR)
        Y.INT.RATE = R.AA.INT<AA.Interest.Interest.IntFixedRate>
    END ELSE
        Y.SRC.ID = '11BDT' ;* 11BDT FIXED FOR SAVINGS ACCOUNT INTEREST
        Y.PRD.DATE = Y.LAST.RENEW.DT
        SEL.CMD = 'SELECT ':FN.BASIC.INT:' WITH @ID LIKE ':Y.SRC.ID:'...'
        EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.BASIC, ERR.INT)
        Y.SEPARATE.ID.1 = SEL.LIST<NO.OF.BASIC>
        EB.DataAccess.FRead(FN.BASIC.INT, Y.SEPARATE.ID.1, REC.BASIC, F.BASIC.INT, Er.RR.BASIC)
        Y.INT.RATE = REC.BASIC<ST.RateParameters.BasicInterest.EbBinInterestRate>
    END
RETURN
ORGINAL.DAYS:  ;*This Gosub use only for calculate orginal days by using interest day basis. how many days old of this account
    StartDate = Y.LAST.RENEW.DT
    EndDate = Y.TODAY
    Rates = 0
    BaseAmts = 0
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
RETURN

PREMATURE.INTEREST: ;* This Gosub use for calculate premature interest
    Y.PRE.INTEREST = (Y.CNT*(Y.CNT+1)*Y.INSTALL.AMT*Y.INT.RATE)/2400
    Y.PRE.PRINCIPAL = Y.CNT * Y.INSTALL.AMT
RETURN
GET.SLAB.INTEREST: ;* this Gosub use for slab interest
    Y.PRD.DATE = Y.LAST.RENEW.DT
    Y.SRC.ID = '-MSS':Y.MATURE.MONTH:'M'
    SEL.CMD = 'SELECT ':FN.MATURE.VAL:' WITH @ID LIKE ...':Y.SRC.ID
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.BASIC, ERR.INT)
    FOR I = 1 TO NO.OF.BASIC
        Y.SEPARATE.ID.1 = SEL.LIST<I>
        Y.FIRST.DATE = Y.SEPARATE.ID.1[1,8]
        IF Y.PRD.DATE GE Y.FIRST.DATE THEN
            IF I = NO.OF.BASIC THEN
                Y.SEPARATE.ID.1 = SEL.LIST<I>
                EB.DataAccess.FRead(FN.MATURE.VAL, Y.SEPARATE.ID.1, REC.BASIC, F.MATURE.VAL, Er.RR.BASIC)
                Y.INSTALL.SIZE.TOT = REC.BASIC<MBL.INSTAL.SIZE>
                Y.MATURE.INT.TOT = REC.BASIC<MBL.MATURE.VALUE>
            END
        END ELSE
            IF NO.OF.BASIC EQ '1' THEN
                Y.SEPARATE.ID.1 = SEL.LIST<I>
            END ELSE
                Y.SEPARATE.ID.1 = SEL.LIST<I-1>
            END
            EB.DataAccess.FRead(FN.MATURE.VAL, Y.SEPARATE.ID.1, REC.BASIC, F.MATURE.VAL, Er.RR.BASIC)
            Y.INSTALL.SIZE.TOT = REC.BASIC<MBL.INSTAL.SIZE>
            Y.MATURE.INT.TOT = REC.BASIC<MBL.MATURE.VALUE>
        END
    NEXT I
    NO.OF.INSTAL = DCOUNT(Y.INSTALL.SIZE.TOT,VM)
    FOR X = 1 TO NO.OF.INSTAL
        Y.TEMP.AMT = Y.INSTALL.SIZE.TOT<1,X>
        IF Y.INSTALL.AMT EQ Y.TEMP.AMT THEN
            Y.POS = X
            BREAK
        END
    NEXT X
    Y.MATURE.INT = Y.MATURE.INT.TOT<1,Y.POS>
RETURN
INT.AMOUNT.INCOME.SCHEME:
    PROP.CLASS = 'INTEREST'
    AA.Framework.GetArrangementConditions(arrId, PROP.CLASS, Idproperty, Effectivedate, Returnids, R.INTEREST.DATA, Returner)
    REC.INT = RAISE(R.INTEREST.DATA)
    Y.INT.RATE.MAIN =REC.INT<AA.Interest.Interest.IntFixedRate>
    IF Y.INT.RATE.MAIN EQ '' THEN
        Y.INT.RATE.MAIN =REC.INT<AA.Interest.Interest.IntPeriodicRate>
    END
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(arrId, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    R.REC1 = RAISE(Returnconditions1)
    Y.TERM.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    Y.ONE.M.PFT = DROUND(((30*Y.TERM.AMOUNT*Y.INT.RATE.MAIN)/(100*360)),2)
RETURN
*----edit by sayeed for calculate accured interest without redeemption fee---------------------------
END
