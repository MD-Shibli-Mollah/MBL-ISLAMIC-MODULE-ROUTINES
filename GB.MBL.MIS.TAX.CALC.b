* @ValidationCode : MjoxODY3Njc5MzcxOkNwMTI1MjoxNTkyNTA0OTg4MDU1OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Jun 2020 00:29:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.MIS.TAX.CALC( PASS.CUSTOMER, PASS.DEAL.AMOUNT, PASS.DEAL.CCY, PASS.CCY.MKT, PASS.CROSS.RATE, PASS.CROSS.CCY, PASS.DWN.CCY, PASS.DATA, PASS.CUST.CDN,R.TAX,TAX.AMOUNT)
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
    $USING AC.AccountOpening
    $USING ST.Customer
    $USING EB.LocalReferences
    $USING AA.Account

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
INIT:
    
    Y.ARR.ID = AA.Framework.getC_aalocarrid()
    Y.ACTIVITY.ID = AA.Framework.getC_aalocactivityid()
    Y.ACC.NUM = AA.Framework.getC_aaloclinkedaccount()
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    
    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    
    FN.ARR.ACCOUNT = 'F.AA.ARR.ACCOUNT'
    F.ARR.ACCOUNT = ''
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.CUS, F.CUS)
    EB.DataAccess.Opf(FN.ACCOUNT,F.ACCOUNT)
    EB.DataAccess.Opf(FN.ARR.ACCOUNT, F.ARR.ACCOUNT)
RETURN

PROCESS:
    
    TAX.AMOUNT = 0
    TOT.ACC.AMT = PASS.DEAL.AMOUNT
    AC.REC = AC.AccountOpening.Account.Read(Y.ACC.NUM, Error)
    Y.CUS.ID = AC.REC<AC.AccountOpening.Account.Customer>
    EB.DataAccess.FRead(FN.CUS, Y.CUS.ID, R.CUS.REC, F.CUS, Er.RR)
    Y.TIN.VAL= R.CUS.REC<ST.Customer.Customer.EbCusTaxId>

    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.TAX.MARK = 'LT.AC.TAX.RATE'
    Y.TAX.MARK.POS =''
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.TAX.MARK,Y.TAX.MARK.POS)
    PROP.CLASS2 = 'ACCOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID, PROP.CLASS2, PROPERTY, Effectivedate, RETURN.IDS, RETURN.VALUES, ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES)
    Y.TAX.RATE = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.TAX.MARK.POS>
    IF Y.TAX.RATE EQ '' THEN
        IF Y.TIN.VAL EQ '' THEN
            TAX.AMOUNT = (TOT.ACC.AMT*15)/100
        END ELSE
            TAX.AMOUNT = (TOT.ACC.AMT*10)/100
        END
    END ELSE
        TAX.AMOUNT = (TOT.ACC.AMT*Y.TAX.RATE)/100
    END
RETURN
END
