* @ValidationCode : MjotMzYxMTE5NTMzOkNwMTI1MjoxNTkyNjM2NjM2Mzc3OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Jun 2020 13:03:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.CRG.MULTI.DP.PRECLOSE(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
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
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AA.Framework
    $USING AA.Interest
    $USING AC.AccountOpening
    $USING AA.Account
    $USING AA.TermAmount
    $USING AA.PaymentSchedule
    $USING EB.API
    $USING AC.Fees
    $USING ST.Customer
    $USING ST.RateParameters
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------

    GOSUB INIT ;*Opens and Initialise variables
    GOSUB OPENFILES
    GOSUB PROCESS;*Main process of calculation

RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
INIT:
    
    arrangementId = ''
    balanceAmount = ''
    R.REC = ''
    Y.ACC = ''
    AC.REC = ''
    Y.CNT = 0
    Y.PRE.PROFIT = 0
    Y.TOT.ACCRUAL = 0
    Y.MAT.PROFIT   = 0
    Y.ADD.PROFIT = 0
    Y.AMOUNT = 0
    MAT.AMOUNT = 0
    PR.AMOUNT = 0
    WORKING.BALANCE = 0
    Y.ORIG.CONTRACT.DATE = ''

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    
    FN.AA.ACC.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACC.DETAILS = ''

    FN.AA.INT.ACCR = 'F.AA.INTEREST.ACCRUALS'
    F.AA.INT.ACCR = ''
    
    FN.AA.INT = 'FBNK.AA.PRD.DES.INTEREST'
    F.AA.INT = ''
    
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    
    FN.PERIODIC.INTEREST = 'F.PERIODIC.INTEREST'
    F.PERIODIC.INTEREST = ''
    
    FN.BASIC.INT = 'FBNK.BASIC.INTEREST'
    F.BASIC.INT = ''
    
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    EB.DataAccess.Opf(FN.AA.ACC.DETAILS,F.AA.ACC.DETAILS)
    EB.DataAccess.Opf(FN.AA.INT.ACCR,F.AA.INT.ACCR)
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    EB.DataAccess.Opf(FN.AA.ARR,F.AA.ARR)
    EB.DataAccess.Opf(FN.PERIODIC.INTEREST,F.PERIODIC.INTEREST)
    EB.DataAccess.Opf(FN.BASIC.INT, F.BASIC.INT)
RETURN

PROCESS:
    Y.MNEMONIC = FN.AA.ACC.DETAILS[2,3]
    IF Y.MNEMONIC EQ 'BNK' THEN
        Y.CUR.ACC = 'CURACCOUNT'
        Y.BASE.BAL = 'ACCDEPOSITINT'
    END
    IF Y.MNEMONIC EQ 'ISL' THEN
        Y.CUR.ACC = 'CURISACCOUNT'
        Y.BASE.BAL = 'ACCDEPOSITPFT'
    END
    
    ArrangementId = arrId   ;*Arrangement ID
    
    AA.Framework.GetArrangementAccountId(ArrangementId, accountId, Currency, ReturnError)   ;*To get Arrangement Account
    
    Y.CURRENCY = Currency
    
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(ArrangementId, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    
    R.REC1 = RAISE(Returnconditions1)

    Y.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    Y.TERM = R.REC1<AA.TermAmount.TermAmount.AmtTerm>
    
    AccId = accountId
    AC.REC = AC.AccountOpening.Account.Read(AccId, Error)
    
    WORKING.BALANCE = AC.REC<AC.AccountOpening.Account.WorkingBalance>

    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,ArrangementId,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,ArrangementId,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)
    
    Y.VALUE.DATE = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
    IF Y.VALUE.DATE EQ '' THEN
        Y.VALUE.DATE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
    END
    GOSUB GET.SVR.FIND.INTEREST
    Y.PRODUCT.NAME = R.AA.ARR<AA.Framework.Arrangement.ArrActiveProduct>
    Y.TODAY = EB.SystemTables.getToday()
    GOSUB ORGINAL.DAYS
    Y.DAYS = AccrDays
    IF Y.PRODUCT.NAME EQ 'MBL.SSS.DP' THEN
        BEGIN CASE
            CASE Y.DAYS LT 360
                balanceAmount = 0
            CASE Y.DAYS GE 360
                GOSUB ACTUAL.PROFIT
                GOSUB PREMATURE.PROFIT
                balanceAmount = Y.ACT.PROFIT - (Y.PRE.PROFIT + Y.AMOUNT)
        END CASE
    END ELSE
        BEGIN CASE
            CASE Y.DAYS LT 360
                balanceAmount = 0
            CASE Y.DAYS GE 360
                GOSUB ACTUAL.PROFIT
                GOSUB PREMATURE.PROFIT
                balanceAmount = Y.ACT.PROFIT - (Y.PRE.PROFIT + Y.AMOUNT)
        END CASE
    END
    
RETURN

PREMATURE.PROFIT: ;* This Gosub use for calculate premature interest
    Y.PRE.PROFIT = DROUND(((Y.MONTH * Y.AMOUNT*(Y.INT.RATE))/(12*100)),2)
RETURN
ACTUAL.PROFIT: ;* This gosub only use for calculate orginal interest+principal amount that system generate
    AA.Framework.GetEcbBalanceAmount(AccId, Y.CUR.ACC, Y.TODAY, TOT.CUR.AMT, RetError)
    ReqdDate = EB.SystemTables.getToday()
    RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'  ;* Projected Movements requierd
    RequestType<4> = 'ECB'  ;* Balance file to be used
    RequestType<4,2> = 'END'
    BaseBalance = Y.BASE.BAL
    AA.Framework.GetPeriodBalances(AccId, BaseBalance, RequestType, ReqdDate, EndDate, SystemDate, BalDetails, ErrorMessage)
    LAST.ACCRUDE.INT =   BalDetails<4>
    Y.ACT.PROFIT = TOT.CUR.AMT + LAST.ACCRUDE.INT
RETURN
ORGINAL.DAYS: ;*This Gosub use only for calculate orginal days by using interest day basis. how many days old of this account
    StartDate = Y.VALUE.DATE
    EndDate = Y.TODAY
    Rates = (Y.INT.RATE)
    BaseAmts = Y.AMOUNT
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
    Y.MONTH = AccrDays/30
    Y.MONTH = FIELD(Y.MONTH,'.',1)
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
END
