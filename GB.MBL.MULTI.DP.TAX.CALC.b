* @ValidationCode : MjotMzQzNjY0NDEwOkNwMTI1MjoxNTkyNjM3MzAwMDI4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Jun 2020 13:15:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.MULTI.DP.TAX.CALC(PASS.CUSTOMER, PASS.DEAL.AMOUNT, PASS.DEAL.CCY, PASS.CCY.MKT, PASS.CROSS.RATE, PASS.CROSS.CCY, PASS.DWN.CCY, PASS.DATA, PASS.CUST.CDN,R.TAX,TAX.AMOUNT)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine calculate TAX amount based on TIN given or not and attached in CALC.ROUTINE field of TAX Application
*Subroutine Type       : AA.SOURCE.CALC.TYPE ROUTINE
*Attached To           :  CALCULATION SOURCE
*Attached As           :  ROUTINE
*Developed by          : S.M. Sayeed
*Designation           : Technical Consultant
*Email                 : s.m.sayeed@fortress-global.com
*Incoming Parameters   : PASS.CUSTOMER, PASS.DEAL.AMOUNT
*Outgoing Parameters   : TAX.AMOUNT
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
* This routine calculate TAX amount based on TIN given or not and attached in CALC.ROUTINE field of TAX Application
* Condition 1 : If TIN given then Tax will be 10%
* Condition 2 : If TIN not given then Tax will be 15%
* Condition 3 : Bank can set 0% or 5% for special customer
* Condition 4 : If Arrangement preclose then interest should be calculate as per bank decision
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
    $USING EB.LocalReferences
*-----------------------------------------------------------------------------

    GOSUB INIT ;*Opens and Initialise variables
    GOSUB OPENFILES
    GOSUB PROCESS;*Main process of calculation

RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    Y.ARR.ID = AA.Framework.getC_aalocarrid()
    Y.ACTIVITY.ID = AA.Framework.getC_aaloccurractivity()
    ACC.NUMBER = AA.Framework.getC_aaloclinkedaccount()
    Y.TODAY = EB.SystemTables.getToday()
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
    
    FN.CUS='F.CUSTOMER'
    F.CUS=''
    
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
*-----------------------------------------------------------------------------
OPENFILES:
*-----------------------------------------------------------------------------
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    EB.DataAccess.Opf(FN.AA.ACC.DETAILS,F.AA.ACC.DETAILS)
    EB.DataAccess.Opf(FN.AA.INT.ACCR,F.AA.INT.ACCR)
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    EB.DataAccess.Opf(FN.AA.ARR,F.AA.ARR)
    EB.DataAccess.Opf(FN.PERIODIC.INTEREST,F.PERIODIC.INTEREST)
    EB.DataAccess.Opf(FN.BASIC.INT, F.BASIC.INT)
RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.MNEMONIC = FN.AA.ACC.DETAILS[2,3]
    Y.CUS.TOT = PASS.CUSTOMER
    Y.CUS.ID = Y.CUS.TOT<1,1>
    EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, R.CUS.REC, F.CUS, Er.RR)
    Y.TIN.VAL= R.CUS.REC<ST.Customer.Customer.EbCusTaxId>
  
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    R.REC1 = RAISE(Returnconditions1)
    Y.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    
    TAX.AMOUNT = 0
    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.TAX.MARK = 'LT.AC.TAX.RATE'
    Y.TAX.MARK.POS =''
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.TAX.MARK,Y.TAX.MARK.POS)
    PROP.CLASS2 = 'ACCOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID,PROP.CLASS2,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES)
    Y.TAX.RATE = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.TAX.MARK.POS>
    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,Y.ARR.ID,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,Y.ARR.ID,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)
    Y.PRODUCT.NAME = R.AA.ARR<AA.Framework.Arrangement.ArrActiveProduct>
    Y.VALUE.DATE = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
    
    IF Y.VALUE.DATE EQ '' THEN
        Y.VALUE.DATE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
    END
    GOSUB ORGINAL.DAYS
    Y.DAYS = AccrDays
    IF Y.ACTIVITY.ID EQ 'DEPOSITS-REDEEM-ARRANGEMENT' THEN
        GOSUB GET.SVR.FIND.INTEREST
        IF Y.PRODUCT.NAME EQ 'MBL.SSS.DP' THEN
            BEGIN CASE
                CASE Y.DAYS LT 360
                    TOT.ACC.AMT = 0
                CASE Y.DAYS GE 360
                    GOSUB PREMATURE.PROFIT
                    TOT.ACC.AMT = Y.PRE.PROFIT
            END CASE
        END ELSE
            BEGIN CASE
                CASE Y.DAYS LT 360
                    TOT.ACC.AMT = 0
                CASE Y.DAYS GE 360
                    GOSUB PREMATURE.PROFIT
                    TOT.ACC.AMT = Y.PRE.PROFIT
            END CASE
        END
        IF Y.TAX.RATE EQ '' THEN
            IF Y.TIN.VAL EQ '' THEN
                TAX.AMOUNT = (TOT.ACC.AMT*15)/100
            END ELSE
                TAX.AMOUNT = (TOT.ACC.AMT*10)/100
            END
        END ELSE
            TAX.AMOUNT = (TOT.ACC.AMT*Y.TAX.RATE)/100
        END
    END ELSE
        TOT.ACC.AMT = PASS.DEAL.AMOUNT
        
        IF Y.TAX.RATE EQ '' THEN
            IF Y.TIN.VAL EQ '' THEN
                TAX.AMOUNT = (TOT.ACC.AMT*15)/100
            END ELSE
                TAX.AMOUNT = (TOT.ACC.AMT*10)/100
            END
        END ELSE
            TAX.AMOUNT = (TOT.ACC.AMT*Y.TAX.RATE)/100
        END
    END
  
RETURN
    
PREMATURE.PROFIT: ;* This Gosub use for calculate premature interest
    Y.PRE.PROFIT = DROUND(((Y.MONTH * Y.AMOUNT*(Y.INT.RATE))/(12*100)),2)
RETURN

ORGINAL.DAYS: ;*This Gosub use only for calculate orginal days by using interest day basis. how many days old of this account
    StartDate = Y.VALUE.DATE
    EndDate = Y.TODAY
    Rates = (Y.INT.RATE+0.75)
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
