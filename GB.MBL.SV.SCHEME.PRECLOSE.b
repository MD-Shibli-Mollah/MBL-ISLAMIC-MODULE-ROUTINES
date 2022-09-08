* @ValidationCode : Mjo3MTE5NDYyMDQ6Q3AxMjUyOjE1OTI2MzczOTQ1Mjc6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Jun 2020 13:16:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.SV.SCHEME.PRECLOSE(arrId,arrProp,arrCcy,arrRes,balanceAmount,perDat)
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
    $USING AA.ProductManagement
    $USING EB.LocalReferences
    $USING AA.Account
    $INSERT I_F.BD.MBL.MSS.MATURE.VAL

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

INIT:
    Y.ARR.ID = arrId
    Y.ACTIVITY.ID = AA.Framework.getC_aalocactivityid()
    Y.ACC.NUM = AA.Framework.getC_aaloclinkedaccount()
    
    FN.AA.ACC.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACC.DETAILS = ''
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    
    FN.AA.INT = 'FBNK.AA.PRD.DES.INTEREST'
    F.AA.INT = ''
    
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
    Y.BILL.TYPE = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillType>
    Y.BILL.STATUS = R.AA.AC.REC<AA.PaymentSchedule.AccountDetails.AdBillStatus>
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
    Y.PRD.START.DATE = Y.VALUE.DATE
    Y.TOT.PRINCIPAL = 0
    Y.TOT.PROFIT = 0
    Y.PRE.PRINCIPAL = 0
    Y.PRE.INTEREST = 0
    Y.ACT.PROFIT = 0
    Y.TODAY = EB.SystemTables.getToday()
* GOSUB ORGINAL.DAYS
*    Y.DAYS = AccrDays
    Y.PAID.INS.NO = Y.CNT
    BEGIN CASE
*        CASE Y.DAYS LT 360
*            balanceAmount = 0
*--------------------------------------------PREMATURE PROFIT----------------------------------------------
        CASE Y.PAID.INS.NO GE 12 AND Y.PAID.INS.NO LT 36
            GOSUB ACTUAL.PROFIT
            GOSUB GET.SVR.FIND.INTEREST
            GOSUB PREMATURE.INTEREST
            balanceAmount = Y.ACT.PROFIT - (Y.PRE.PRINCIPAL + Y.PRE.INTEREST)
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
            END ELSE
                Y.PRE.PRINCIPAL = Y.INSTALL.AMT*(Y.CNT-Y.MATURE.MONTH)
            END
            balanceAmount = (Y.ACT.PROFIT) - (Y.MATURE.INT+Y.PRE.INTEREST+Y.PRE.PRINCIPAL)
            
*--------------------------------------------AFTER 5 YEARS PROFIT----------------------------------------------
        CASE Y.PAID.INS.NO GE 60 AND Y.PAID.INS.NO LT 96
            GOSUB ACTUAL.PROFIT
            Y.MATURE.MONTH = 60
            GOSUB GET.SLAB.INTEREST
            Y.REMAINING.REPAY = Y.CNT - 60
            IF Y.REMAINING.REPAY GE 12 THEN
                Y.CNT = Y.CNT - 60
                GOSUB GET.SVR.FIND.INTEREST
                GOSUB PREMATURE.INTEREST
            END ELSE
                Y.PRE.PRINCIPAL = Y.INSTALL.AMT*(Y.CNT-Y.MATURE.MONTH)
            END
            balanceAmount = (Y.ACT.PROFIT) - (Y.MATURE.INT+Y.PRE.INTEREST+Y.PRE.PRINCIPAL)
            
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
            END ELSE
                Y.PRE.PRINCIPAL = Y.INSTALL.AMT*(Y.CNT-Y.MATURE.MONTH)
            END
            balanceAmount = (Y.ACT.PROFIT) - (Y.MATURE.INT+Y.PRE.INTEREST+Y.PRE.PRINCIPAL)

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
            END ELSE
                Y.PRE.PRINCIPAL = Y.INSTALL.AMT*(Y.CNT-Y.MATURE.MONTH)
            END
            balanceAmount = (Y.ACT.PROFIT) - (Y.MATURE.INT+Y.PRE.INTEREST+Y.PRE.PRINCIPAL)
    END CASE
    
RETURN

GET.SLAB.INTEREST: ;* this Gosub use for slab interest
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
