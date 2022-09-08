* @ValidationCode : MjoxMzE5MjY2MjIxOkNwMTI1MjoxNTkyNjM3NTE4ODA4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Jun 2020 13:18:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.TERM.DP.TAX.CALC( PASS.CUSTOMER, PASS.DEAL.AMOUNT, PASS.DEAL.CCY, PASS.CCY.MKT, PASS.CROSS.RATE, PASS.CROSS.CCY, PASS.DWN.CCY, PASS.DATA, PASS.CUST.CDN,R.TAX,TAX.AMOUNT)
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
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING AA.Framework
    $USING EB.API
    $USING ST.Customer
    $USING AC.AccountOpening
    $INSERT I_F.ACCOUNT
    $USING AA.Customer
    $INSERT I_F.AA.CUSTOMER
    $USING EB.DataAccess
    $USING EB.LocalReferences
    $USING EB.SystemTables
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_EB.EXTERNAL.COMMON
    $USING AA.Interest
    $USING EB.Updates
    $USING AA.TermAmount
    $USING AA.PaymentSchedule
    $USING AC.Fees
    $USING AA.Account
    $USING ST.RateParameters
    
    $INSERT I_F.LIMIT
    $INSERT I_F.AA.SETTLEMENT
    $INSERT I_F.PERIODIC.INTEREST

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
    
RETURN


INIT:
    FN.INT.ACC='F.AA.INTEREST.ACCRUALS'
    F.INT.ACC=''
    Y.ID = AA.Framework.getC_aalocarrid()
    Y.ACTIVITY.ID = AA.Framework.getC_aaloccurractivity()
    ACC.NUMBER = AA.Framework.getC_aaloclinkedaccount()
    Y.TODAY = EB.SystemTables.getToday()
    FN.CUS= 'F.CUSTOMER'
    F.CUS = ''
*--------------------------------------------------
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
    FN.ARR.ACCOUNT = 'F.AA.ARR.ACCOUNT'
    F.ARR.ACCOUNT = ''
    FN.BASIC.INT = 'FBNK.BASIC.INTEREST'
    F.BASIC.INT = ''
*-----------------------------------------------------------
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.INT.ACC, F.INT.ACC)
    EB.DataAccess.Opf(FN.CUS,F.CUS)
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    EB.DataAccess.Opf(FN.AA.ACC.DETAILS,F.AA.ACC.DETAILS)
    EB.DataAccess.Opf(FN.AA.INT.ACCR,F.AA.INT.ACCR)
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    EB.DataAccess.Opf(FN.AA.ARR,F.AA.ARR)
    EB.DataAccess.Opf(FN.ARR.ACCOUNT, F.ARR.ACCOUNT)
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
    
    Y.CUS.TOT = PASS.CUSTOMER
    Y.CUS.ID = Y.CUS.TOT<1,1>
    EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, R.CUS.REC, F.CUS, Er.RR)
    Y.TIN.VAL= R.CUS.REC<ST.Customer.Customer.EbCusTaxId>
    
    PropertyClass1 = 'TERM.AMOUNT'
    AA.Framework.GetArrangementConditions(Y.ID, PropertyClass1, Idproperty, Effectivedate, Returnids, Returnconditions1, Returnerror) ;* Product conditions with activities
    R.REC1 = RAISE(Returnconditions1)
    Y.TERM.AMOUNT = R.REC1<AA.TermAmount.TermAmount.AmtAmount>
    TAX.AMOUNT = 0
    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.TAX.MARK = 'LT.AC.TAX.RATE'
    Y.TAX.MARK.POS =''
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.TAX.MARK,Y.TAX.MARK.POS)
    PROP.CLASS2 = 'ACCOUNT'
    AA.Framework.GetArrangementConditions(Y.ID,PROP.CLASS2,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES)
    Y.TAX.RATE = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.TAX.MARK.POS>

    IF Y.ACTIVITY.ID EQ 'DEPOSITS-REDEEM-ARRANGEMENT' THEN
        EB.DataAccess.FRead(FN.AA.ACC.DETAILS,Y.ID,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
        EB.DataAccess.FRead(FN.AA.ARR,Y.ID,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)

        Y.TOT.LAST.RENEW = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdLastRenewDate>
        NO.OF.RENEW.DT = DCOUNT(Y.TOT.LAST.RENEW,VM)
        Y.LAST.RENEW.DT = Y.TOT.LAST.RENEW<1,NO.OF.RENEW.DT>
*        Y.RENEW.OR.NOT = Y.LAST.RENEW.DT
        IF Y.LAST.RENEW.DT EQ '' THEN
            Y.LAST.RENEW.DT = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
        END ELSE
            AA.Framework.GetEcbBalanceAmount(ACC.NUMBER, Y.CUR.ACC, Y.TODAY, TOT.CUR.AMT, RetError)
            Y.TERM.AMOUNT = TOT.CUR.AMT
        END
        GOSUB GET.SVR.FIND.INTEREST
        Y.TODAY = EB.SystemTables.getToday()
        GOSUB ORGINAL.DAYS
        Y.DAYS = AccrDays
        IF Y.DAYS LT 30 THEN
*NO CALCULATION
            TOT.ACC.AMT = 0
        END

        IF Y.DAYS GE 30 AND Y.DAYS LT 1080 THEN
*PREMATURE PROFIT
            GOSUB PREMATURE.PROFIT
            TOT.ACC.AMT = Y.PRE.PROFIT
        END
*-----------------------15% TAX DEDUCTION------------------------------------
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
*-----------------------------MATURE PRODUCT-------------------------
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
*---------------------------END----------------------
RETURN
*-------------------------------------------------------

PREMATURE.PROFIT:
    Y.PRE.PROFIT = DROUND((Y.DAYS * Y.TERM.AMOUNT *Y.INT.RATE)/(100*360),2)
RETURN

ORGINAL.DAYS:
    StartDate = Y.LAST.RENEW.DT
    EndDate = Y.TODAY
    Rates = 0
    BaseAmts = 0
    InterestDayBasis = 'A'
    Ccy = 'BDT'
    AC.Fees.EbInterestCalc(StartDate, EndDate, Rates, BaseAmts, IntAmts, AccrDays, InterestDayBasis, Ccy, RoundAmts, RoundType, Customer)
RETURN
GET.SVR.FIND.INTEREST:
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
END
