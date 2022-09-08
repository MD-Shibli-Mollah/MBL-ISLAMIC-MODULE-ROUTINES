* @ValidationCode : Mjo3MTgwNzk1ODM6Q3AxMjUyOjE1OTI2Mzc0MjY5NTc6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Jun 2020 13:17:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.SV.SCHEME.TAX.CALC( PASS.CUSTOMER, PASS.DEAL.AMOUNT, PASS.DEAL.CCY, PASS.CCY.MKT, PASS.CROSS.RATE, PASS.CROSS.CCY, PASS.DWN.CCY, PASS.DATA, PASS.CUST.CDN,R.TAX,TAX.AMOUNT)
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
    $USING AA.PaymentSchedule
    $USING AA.Framework
    $USING AA.Fees
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AC.Fees
    $USING AA.Interest
    $USING AA.TermAmount
    $USING ST.RateParameters
    $USING AA.ProductManagement
    $USING EB.LocalReferences
    $USING AA.Account
    $USING ST.Customer
    $INSERT I_F.BD.MBL.MSS.MATURE.VAL

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
    
    FN.CUS= 'F.CUSTOMER'
    F.CUS = ''
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    
    FN.AA.INT = 'FBNK.AA.PRD.DES.INTEREST'
    F.AA.INT = ''
    
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    
    FN.ARR.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.ARR.ACTIVITY = ''
    
    FN.BASIC.INT = 'FBNK.BASIC.INTEREST'
    F.BASIC.INT = ''
    
    FN.MATURE.VAL = 'F.BD.MBL.MSS.MATURE.VAL'
    F.MATURE.VAL = ''

RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.AA.INT,F.AA.INT)
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    EB.DataAccess.Opf(FN.AA.ACC.DETAILS,F.AA.ACC.DETAILS)
    EB.DataAccess.Opf(FN.AA.ARR,F.AA.ARR)
    EB.DataAccess.Opf(FN.ARR.ACTIVITY, F.ARR.ACTIVITY)
    EB.DataAccess.Opf(FN.BASIC.INT, F.BASIC.INT)
    EB.DataAccess.Opf(FN.MATURE.VAL, F.MATURE.VAL)
    EB.DataAccess.Opf(FN.CUS,F.CUS)
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
   
    EB.DataAccess.FRead(FN.AA.ACC.DETAILS,Y.ARR.ID,R.AA.AC.REC,F.AA.ACC.DETAILS,Y.ERR)
    EB.DataAccess.FRead(FN.AA.ARR,Y.ARR.ID,R.AA.ARR,F.AA.ARR,Y.ARR.ERR)
    Y.VALUE.DATE = R.AA.ARR<AA.Framework.Arrangement.ArrOrigContractDate>
    IF Y.VALUE.DATE EQ '' THEN
        Y.VALUE.DATE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBaseDate>
    END
    PROP.CLASS = 'TERM.AMOUNT'
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.ARR.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    RR.REC = RAISE(RETURN.VALUES)
    Y.INSTALL.AMT = RR.REC<AA.TermAmount.TermAmount.AmtAmount>
    Y.ARR.TERM = RR.REC<AA.TermAmount.TermAmount.AmtTerm>
    Y.TRM.LEN = LEN(Y.ARR.TERM)
    Y.MAIN.TRM = Y.ARR.TERM[1,Y.TRM.LEN-1]
    
    Y.BILL.TYPE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillType>
    Y.BILL.STATUS = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillStatus>
    CONVERT SM TO VM IN Y.BILL.TYPE
    CONVERT SM TO VM IN Y.BILL.STATUS
    Y.DCOUNT = DCOUNT(Y.BILL.TYPE,VM)
    FOR I = 1 TO Y.DCOUNT
        Y.BILL =  Y.BILL.TYPE<1,I>
        Y.STATUS =  Y.BILL.STATUS<1,I>
        IF Y.BILL EQ 'EXPECTED' AND Y.STATUS EQ 'SETTLED' THEN
            Y.CNT = Y.CNT + 1
        END
    NEXT I
    
    Y.CUS.TOT = PASS.CUSTOMER
    Y.CUS.ID = Y.CUS.TOT<1,1>
    EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, R.CUS.REC, F.CUS, Er.RR)
    Y.TIN.VAL= R.CUS.REC<ST.Customer.Customer.EbCusTaxId>
    TAX.AMOUNT = 0
    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.TAX.MARK = 'LT.AC.TAX.RATE'
    Y.TAX.MARK.POS =''
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.TAX.MARK,Y.TAX.MARK.POS)
    PROP.CLASS2 = 'ACCOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID,PROP.CLASS2,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES)
    Y.TAX.RATE = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.TAX.MARK.POS>
       
    Y.PRD.START.DATE = Y.VALUE.DATE
    Y.TOT.PRINCIPAL = 0
    Y.TOT.PROFIT = 0
    Y.TODAY = EB.SystemTables.getToday()
    Y.PAID.INS.NO = Y.CNT
    IF Y.ACTIVITY.ID EQ 'DEPOSITS-REDEEM-ARRANGEMENT' THEN
        BEGIN CASE
*--------------------------------------------PREMATURE PROFIT----------------------------------------------
            CASE Y.PAID.INS.NO GE 12 AND Y.PAID.INS.NO LT 36
                GOSUB ACTUAL.PROFIT
                GOSUB GET.SVR.FIND.INTEREST
                GOSUB PREMATURE.INTEREST
                TOT.ACC.AMT = Y.PRE.INTEREST
*--------------------------------------------AFTER 3 YEARS PROFIT----------------------------------------------
            CASE Y.PAID.INS.NO GE 36 AND Y.PAID.INS.NO LT 60
                GOSUB ACTUAL.PROFIT
                Y.MATURE.MONTH = 36
                GOSUB GET.SLAB.INTEREST
                Y.REMAINING.REPAY = Y.CNT - 36
                IF Y.REMAINING.REPAY GE 12 THEN
                    Y.CNT = Y.CNT - 36 ;* after 3 years
                    GOSUB GET.SVR.FIND.INTEREST
                    GOSUB PREMATURE.INTEREST
                END
                TOT.ACC.AMT = (Y.MATURE.INT+Y.PRE.INTEREST) - Y.MATURE.PRIN
            
*--------------------------------------------AFTER 5 YEARS PROFIT----------------------------------------------
            CASE Y.PAID.INS.NO GE 60 AND Y.PAID.INS.NO LT 96
                GOSUB ACTUAL.PROFIT
                Y.MATURE.MONTH = 60
                GOSUB GET.SLAB.INTEREST
                Y.REMAINING.REPAY = Y.CNT - 60
                IF Y.REMAINING.REPAY GE 12 THEN
                    Y.CNT = Y.CNT - 60 ;* after 5 years
                    GOSUB GET.SVR.FIND.INTEREST
                    GOSUB PREMATURE.INTEREST
                END
                TOT.ACC.AMT = (Y.MATURE.INT+Y.PRE.INTEREST) - Y.MATURE.PRIN
            
*--------------------------------------------AFTER 8 YEARS PROFIT----------------------------------------------
            CASE Y.PAID.INS.NO GE 96 AND Y.PAID.INS.NO LT 120
                GOSUB ACTUAL.PROFIT
                Y.MATURE.MONTH = 96
                GOSUB GET.SLAB.INTEREST
                Y.REMAINING.REPAY = Y.CNT - 96
                IF Y.REMAINING.REPAY GE 12 THEN
                    Y.CNT = Y.CNT - 96
                    GOSUB GET.SVR.FIND.INTEREST
                    GOSUB PREMATURE.INTEREST
                END
                TOT.ACC.AMT = (Y.MATURE.INT+Y.PRE.INTEREST) - Y.MATURE.PRIN

*--------------------------------------------AFTER 10 YEARS PROFIT----------------------------------------------
            CASE Y.PAID.INS.NO GE 120
                GOSUB ACTUAL.PROFIT
                Y.MATURE.MONTH = 120
                GOSUB GET.SLAB.INTEREST
                Y.REMAINING.REPAY = Y.CNT - 120
                IF Y.REMAINING.REPAY GE 12 THEN
                    Y.CNT = Y.CNT - 120
                    GOSUB GET.SVR.FIND.INTEREST
                    GOSUB PREMATURE.INTEREST
                END
                TOT.ACC.AMT = (Y.MATURE.INT+Y.PRE.INTEREST) - Y.MATURE.PRIN
        END CASE
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
    
RETURN

GET.SLAB.INTEREST:
    Y.PRD.DATE = Y.VALUE.DATE
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
    Y.MATURE.PRIN = Y.INSTALL.AMT * Y.MATURE.MONTH
RETURN
PREMATURE.INTEREST: ;* This Gosub use for calculate premature interest
    Y.PRE.INTEREST = (Y.CNT*(Y.CNT+1)*Y.INSTALL.AMT*Y.INT.RATE)/2400
    Y.PRE.PRINCIPAL = Y.CNT * Y.INSTALL.AMT
RETURN

ACTUAL.PROFIT: ;* This gosub only use for calculate orginal interest+principal amount that system generate
    AA.Framework.GetEcbBalanceAmount(Y.ACC.NUM, Y.CUR.ACC, Y.TODAY, TOT.CUR.AMT, RetError)
    ReqdDate = EB.SystemTables.getToday()
    RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'  ;* Projected Movements requierd
    RequestType<4> = 'ECB'  ;* Balance file to be used
    RequestType<4,2> = 'END'
    BaseBalance = Y.BASE.BAL
    AA.Framework.GetPeriodBalances(Y.ACC.NUM, BaseBalance, RequestType, ReqdDate, EndDate, SystemDate, BalDetails, ErrorMessage)
    LAST.ACCRUDE.INT =   BalDetails<4>
    Y.ACT.PROFIT = TOT.CUR.AMT + LAST.ACCRUDE.INT
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
