* @ValidationCode : MjotMTY3NjMzMDMzMzpDcDEyNTI6MTU5MjYzNzA2MDYzNDpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Jun 2020 13:11:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.CRG.MIS.PRECLOSE(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine calculate premature interest amount and early redemtption charge
*Subroutine Type       : AA.SOURCE.CALC.TYPE ROUTINE
*Attached To           :  CALCULATION SOURCE
*Attached As           :  ROUTINE
*Developed by          : S.M. Sayeed
*Designation           : Technical Consultant
*Email                 : s.m.sayeed@fortress-global.com
*Incoming Parameters   : arrId, arrProp, arrCcy
*Outgoing Parameters   : balanceAmount
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
    $USING AA.PaymentSchedule
    $USING AA.Framework
    $USING AA.Fees
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AC.Fees
    $USING AA.Interest
    $USING AA.TermAmount
    $USING ST.RateParameters

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

INIT:
    Y.ARR.ID = arrId
    Y.ACTIVITY.ID = AA.Framework.getC_aaloccurractivity()
    Y.ACC.NUM = AA.Framework.getC_aaloclinkedaccount()
    
    FN.AA.ACC.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACC.DETAILS = ''
    
    FN.AA.INT = 'FBNK.AA.PRD.DES.INTEREST'
    F.AA.INT = ''
    
    FN.BILL.DET = 'F.AA.BILL.DETAILS'
    F.BILL.DET = ''
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    
    FN.AA.BIL.DET = 'F.AA.BILL.DETAILS'
    F.AA.BIL.DET = ''
    
    FN.ARR.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.ARR.ACTIVITY = ''
    
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    
    FN.BASIC.INT = 'FBNK.BASIC.INTEREST'
    F.BASIC.INT = ''
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    EB.DataAccess.Opf(FN.AA.ACC.DETAILS,F.AA.ACC.DETAILS)
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    EB.DataAccess.Opf(FN.BILL.DET, F.BILL.DET)
    EB.DataAccess.Opf(FN.AA.ARR,F.AA.ARR)
    EB.DataAccess.Opf(FN.AA.BIL.DET,F.AA.BIL.DET)
    EB.DataAccess.Opf(FN.ARR.ACTIVITY, F.ARR.ACTIVITY)
    EB.DataAccess.Opf(FN.CUS, F.CUS)
    EB.DataAccess.Opf(FN.BASIC.INT, F.BASIC.INT)
RETURN

PROCESS:
    
    Y.MNEMONIC = FN.AA.ACC.DETAILS[2,3]
    IF Y.MNEMONIC EQ 'BNK' THEN
        Y.CUR.ACC = 'CURACCOUNT'
        Y.BASE.BAL = 'ACCDEPOSITINT'
        Y.INT.PROPERTY = 'DEPOSITINT'
    END
    IF Y.MNEMONIC EQ 'ISL' THEN
        Y.CUR.ACC = 'CURISACCOUNT'
        Y.BASE.BAL = 'ACCDEPOSITPFT'
        Y.INT.PROPERTY = 'DEPOSITPFT'
    END
    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,Y.ARR.ID,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,Y.ARR.ID,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)
    
    Y.TOT.LAST.RENEW = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdLastRenewDate>
    NO.OF.RENEW.DT = DCOUNT(Y.TOT.LAST.RENEW,VM)
    Y.LAST.RENEW.DT = Y.TOT.LAST.RENEW<1,NO.OF.RENEW.DT>
    IF Y.LAST.RENEW.DT EQ '' THEN
        Y.VALUE.DATE = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
        IF Y.VALUE.DATE EQ '' THEN
            Y.VALUE.DATE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
        END
    END ELSE
        Y.VALUE.DATE = Y.LAST.RENEW.DT
    END

    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    R.REC1 = RAISE(Returnconditions1)
    Y.TERM.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    Y.PRODUCT.GROUP = R.AA.ARR<AA.Framework.Arrangement.ArrProductGroup>
*    IF Y.PRODUCT.GROUP EQ 'EXIM.MMBS.GRP.DP' THEN
*        PROP.CLASS = 'INTEREST'
*        AA.Framework.GetArrangementConditions(Y.ARR.ID, PROP.CLASS, Idproperty, Effectivedate, Returnids, R.INTEREST.DATA, Returner)
*        REC.INT = RAISE(R.INTEREST.DATA)
*        Y.INT.RATE.MAIN =REC.INT<AA.Interest.Interest.IntPeriodicRate>
*    END ELSE
    PROP.CLASS = 'INTEREST'
    AA.Framework.GetArrangementConditions(Y.ARR.ID, PROP.CLASS, Idproperty, Effectivedate, Returnids, R.INTEREST.DATA, Returner)
    REC.INT = RAISE(R.INTEREST.DATA)
    Y.INT.RATE.MAIN =REC.INT<AA.Interest.Interest.IntFixedRate>
    IF Y.INT.RATE.MAIN EQ '' THEN
        Y.INT.RATE.MAIN =REC.INT<AA.Interest.Interest.IntPeriodicRate>
    END
*    END
    Y.TODAY = EB.SystemTables.getToday()
    Y.BILL.TYPE= R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillType>
    Y.BILL.STATUS = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdPayMethod>
    Y.BILL.ID.LIST = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillId>
    Y.BILL.DATE.LIST = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillDate>
    CONVERT SM TO VM IN Y.BILL.TYPE
    CONVERT SM TO VM IN Y.BILL.STATUS
    CONVERT SM TO VM IN Y.BILL.ID.LIST
    CONVERT SM TO VM IN Y.BILL.DATE.LIST
    Y.DCOUNT = DCOUNT(Y.BILL.TYPE,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.BILL =  Y.BILL.TYPE<1,I>
        Y.STATUS =  Y.BILL.STATUS<1,I>
        Y.BILL.DAY = Y.BILL.DATE.LIST<1,I>
        IF Y.BILL EQ 'PAYMENT' AND Y.STATUS EQ 'PAY' AND Y.BILL.DAY GT Y.VALUE.DATE THEN
            Y.BILL.ID = Y.BILL.ID.LIST<1,I>
            EB.DataAccess.FRead(FN.BILL.DET, Y.BILL.ID, REC.BILL.DET, F.BILL.DET, Er.BILL)
            Y.BILL.PROPERTY = REC.BILL.DET<AA.PaymentSchedule.BillDetails.BdProperty>
            Y.DEPOSIT.PFT = Y.BILL.PROPERTY<1,1>
            IF Y.DEPOSIT.PFT EQ Y.INT.PROPERTY AND Y.BILL.DAY NE Y.TODAY THEN
                Y.CNT = Y.CNT + 1 ;* Y.CNT is how many month customer taking interest from bank
            END
        END
    NEXT I
*Y.CNT = Y.CNT-1 ;* for reduce 1 month becouse of when account preclose or mature principal baance shuold be pay
    GOSUB ACTUAL.PROFIT
    GOSUB ONE.MONTH.PROFIT
    Y.TOTAL.PAY.CUS = (Y.ONE.M.PFT * Y.CNT) + LAST.ACCRUDE.INT
    Y.TOT.PRINCIPAL = 0
    Y.TOT.PROFIT = 0
    GOSUB ORGINAL.DAYS
    Y.DAYS = AccrDays
    BEGIN CASE
        CASE Y.DAYS LT 360
            balanceAmount = Y.TOTAL.PAY.CUS
*--------------------------------------------PREMATURE PROFIT----------------------------------------------
        CASE Y.DAYS GE 360
            GOSUB GET.SVR.FIND.INTEREST
            GOSUB PREMATURE.PROFIT
            balanceAmount = Y.TOTAL.PAY.CUS - Y.PRE.PROFIT
    END CASE
    
RETURN
ONE.MONTH.PROFIT: ;* This Gosub use for One Month interest amount
    Y.ONE.M.PFT = DROUND(((30*Y.TERM.AMOUNT*Y.INT.RATE.MAIN)/(100*360)),2)
RETURN
PREMATURE.PROFIT: ;* This Gosub use for calculate premature interest
    Y.PRE.PROFIT = DROUND(((Y.DAYS*Y.TERM.AMOUNT*Y.INT.RATE)/(100*360)),2)
RETURN
ORGINAL.DAYS: ;*This Gosub use only for calculate orginal days by using interest day basis. how many days old of this account
    StartDate = Y.VALUE.DATE
    EndDate = Y.TODAY
    Rates = 0
    BaseAmts = 0
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
RETURN
GET.SVR.FIND.INTEREST: ;* This Gosub use for finding saving interest
    IF Y.MNEMONIC EQ 'ISL' THEN
        SEL.CMD = 'SELECT ':FN.AA.INT:' WITH @ID LIKE IS.MBL.PROFIT.MSD.GEN-BDT...'
        EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.BASIC, ERR.INT)
        Y.AA.INT.SAV.ID = SEL.LIST<NO.OF.BASIC>
        EB.DataAccess.FRead(FN.AA.INT,Y.AA.INT.SAV.ID,R.AA.INT,F.AA.INT,E.INT.ERR)
        Y.INT.RATE = R.AA.INT<AA.Interest.Interest.IntFixedRate>
    END ELSE
        Y.SRC.ID = '11BDT' ;* 11BDT FIXED FOR SAVINGS ACCOUNT INTEREST
        Y.PRD.DATE = Y.VALUE.DATE
        SEL.CMD = 'SELECT ':FN.BASIC.INT:' WITH @ID LIKE ':Y.SRC.ID:'...'
        EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.BASIC, ERR.INT)
        Y.SEPARATE.ID.1 = SEL.LIST<NO.OF.BASIC>
        EB.DataAccess.FRead(FN.BASIC.INT, Y.SEPARATE.ID.1, REC.BASIC, F.BASIC.INT, Er.RR.BASIC)
        Y.INT.RATE = REC.BASIC<ST.RateParameters.BasicInterest.EbBinInterestRate>
    END
RETURN
ACTUAL.PROFIT: ;* This gosub only use for calculate orginal interest+principal amount that system generate
    ReqdDate = EB.SystemTables.getToday()
    RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'  ;* Projected Movements requierd
    RequestType<4> = 'ECB'  ;* Balance file to be used
    RequestType<4,2> = 'END'
    BaseBalance = Y.BASE.BAL
    AA.Framework.GetPeriodBalances(Y.ACC.NUM, BaseBalance, RequestType, ReqdDate, EndDate, SystemDate, BalDetails, ErrorMessage)
    LAST.ACCRUDE.INT = BalDetails<2>
RETURN
END
