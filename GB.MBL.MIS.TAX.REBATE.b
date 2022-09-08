* @ValidationCode : MjotMzQxNTQ3ODQxOkNwMTI1MjoxNTkyNjM3MTI3MzYwOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Jun 2020 13:12:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.MIS.TAX.REBATE(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine calculate Tax reabte amount. if customer preclose any MIS account then bank provide extra pay tax amt
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
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING EB.LocalReferences
    $USING AA.Account
    $USING ST.RateParameters

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

INIT:
    Y.ARR.ID = AA.Framework.getC_aalocarrid()
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
    FN.ARR.ACCOUNT = 'F.AA.ARR.ACCOUNT'
    F.ARR.ACCOUNT = ''
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
    EB.DataAccess.Opf(FN.ARR.ACCOUNT, F.ARR.ACCOUNT)
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
    
    AC.REC = AC.AccountOpening.Account.Read(Y.ACC.NUM, Error)
    Y.CUS.ID = AC.REC<AC.AccountOpening.Account.Customer>
    EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, R.CUS.REC, F.CUS, Er.RR)
    Y.TIN.VAL= R.CUS.REC<ST.Customer.Customer.EbCusTaxId>
    
    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,Y.ARR.ID,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,Y.ARR.ID,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)

    Y.VALUE.DATE = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
    IF Y.VALUE.DATE EQ '' THEN
        Y.VALUE.DATE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
    END

    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    R.REC1 = RAISE(Returnconditions1)
    Y.TERM.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>

    PROP.CLASS = 'INTEREST'
    AA.Framework.GetArrangementConditions(Y.ARR.ID, PROP.CLASS, Idproperty, Effectivedate, Returnids, R.INTEREST.DATA, Returner)
    REC.INT = RAISE(R.INTEREST.DATA)
    Y.INT.RATE.MAIN =REC.INT<AA.Interest.Interest.IntFixedRate>
    IF Y.INT.RATE.MAIN EQ '' THEN
        Y.INT.RATE.MAIN =REC.INT<AA.Interest.Interest.IntPeriodicRate>
    END

    Y.TODAY = EB.SystemTables.getToday()
    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.TAX.MARK = 'LT.AC.TAX.RATE'
    Y.TAX.MARK.POS =''
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.TAX.MARK,Y.TAX.MARK.POS)
    PROP.CLASS2 = 'ACCOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID,PROP.CLASS2,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES)
    Y.TAX.RATE = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.TAX.MARK.POS>
    
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
                Y.CNT = Y.CNT + 1
            END
        END
    NEXT I
* Y.CNT = Y.CNT-1 ;* for reduce 1 month becouse of when account preclose or mature principal baance shuold be pay
    GOSUB ACTUAL.PROFIT
    GOSUB ONE.MONTH.PROFIT
    Y.TOTAL.PAY.CUS = (Y.ONE.M.PFT * Y.CNT) + LAST.ACCRUDE.INT
    
    IF Y.TAX.RATE EQ '' THEN
        IF Y.TIN.VAL EQ '' THEN
            Y.PER.MONT.TAX = (Y.ONE.M.PFT*15)/100
            Y.BROKEN.M.TAX = (LAST.ACCRUDE.INT*15)/100
        END ELSE
            Y.PER.MONT.TAX = (Y.ONE.M.PFT*10)/100
            Y.BROKEN.M.TAX = (LAST.ACCRUDE.INT*10)/100
        END
    END ELSE
        Y.PER.MONT.TAX = (Y.ONE.M.PFT*Y.TAX.RATE)/100
        Y.BROKEN.M.TAX = (LAST.ACCRUDE.INT*Y.TAX.RATE)/100
    END
    Y.TOT.PRINCIPAL = 0
    Y.TOT.PROFIT = 0
    GOSUB ORGINAL.DAYS
    Y.DAYS = AccrDays

    IF Y.ACTIVITY.ID EQ 'DEPOSITS-REDEEM-ARRANGEMENT' THEN
        BEGIN CASE
            CASE Y.DAYS LT 360
                TOT.ACC.AMT = 0
                balanceAmount = (Y.PER.MONT.TAX * Y.CNT) + Y.BROKEN.M.TAX
*--------------------------------------------PREMATURE PROFIT----------------------------------------------
            CASE Y.DAYS GE 360 AND Y.DAYS LT 1800
                GOSUB GET.SVR.FIND.INTEREST
                GOSUB PREMATURE.PROFIT
                IF Y.TAX.RATE EQ '' THEN
                    IF Y.TIN.VAL EQ '' THEN
                        Y.CUS.PAY.TAX = (Y.PRE.PROFIT*15)/100
                    END ELSE
                        Y.CUS.PAY.TAX = (Y.PRE.PROFIT*10)/100
                    END
                END ELSE
                    Y.CUS.PAY.TAX = (Y.PRE.PROFIT*Y.TAX.RATE)/100
                END
                balanceAmount = (((Y.PER.MONT.TAX * Y.CNT) + Y.BROKEN.M.TAX) - Y.CUS.PAY.TAX)
        END CASE
    END
    
RETURN
ONE.MONTH.PROFIT:
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
*AA.Framework.GetEcbBalanceAmount(Y.ACC.NUM, 'CURACCOUNT', Y.TODAY, TOT.CUR.AMT, RetError)
    ReqdDate = EB.SystemTables.getToday()
    RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'  ;* Projected Movements requierd
    RequestType<4> = 'ECB'  ;* Balance file to be used
    RequestType<4,2> = 'END'
    BaseBalance = Y.BASE.BAL
    AA.Framework.GetPeriodBalances(Y.ACC.NUM, BaseBalance, RequestType, ReqdDate, EndDate, SystemDate, BalDetails, ErrorMessage)
    LAST.ACCRUDE.INT =   BalDetails<2>
*Y.ACT.PROFIT = TOT.CUR.AMT + LAST.ACCRUDE.INT
RETURN
END

