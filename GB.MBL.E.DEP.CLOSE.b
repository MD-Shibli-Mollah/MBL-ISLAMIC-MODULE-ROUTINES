* @ValidationCode : MjotNzkxNDE4NjcxOkNwMTI1MjoxNTkzNTAyNTMzOTQzOnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Jun 2020 13:35:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0

*Subroutine Description: This is a nofile enquiry routine where All the Closed deposits will be shown here.
*Subroutine Type : NOFILE ENQUIRY ROUTINE
*Attached To :
*Attached As : ROUTINE
*Developed by : MD Shibli Mollah
*Designation : Software Engineer
*Email : smollah@fortress-global.com
*Incoming Parameters : CUSTOMER.ID, ACC.NO, Y.START.DATE, Y.END.DATE
*Outgoing Parameters : ACCOUNT.NO,CUSTOMER.ID,PRODUCT,CURRENCY,PRINCIPAL.AMOUNT,VALUE.DATE,MATURITY.DATE,INTEREST.RATE,ROLLOVER.TERM,CO.CODE
*-----------------------------------------------------------------------------
* Modification History :
* 1)
* Date :
* Modification Description :
* Modified By :
*
*-----------------------------------------------------------------------------
*
*1/S----Modification Start
*
*1/E----Modification End
*-----------------------------------------------------------------------------

SUBROUTINE GB.MBL.E.DEP.CLOSE(Y.DATA)
*PROGRAM GB.MBL.E.DEP.CLOSE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*List of Closed deposit accounts for given period
*-----------------------------------------------------------------------------
     
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.DataAccess
    $USING EB.SystemTables
    $INSERT I_ENQUIRY.COMMON
    $USING AA.Framework
    $USING AA.Account
    $USING AC.AccountOpening
    $USING AA.TermAmount
    $USING AA.Interest
    $USING AA.PaymentSchedule
    $USING AA.ChangeProduct
    $USING EB.API
    $USING EB.Reports
    $USING ST.CompanyCreation
    
    GOSUB INIT
*
    GOSUB OPENFILES
*
    GOSUB PROCESS
RETURN
 
INIT:
*
*   ST.CompanyCreation.LoadCompany('BNK')
    Y.COMP = EB.SystemTables.getIdCompany()
    Y.TODAY = EB.SystemTables.getToday()
    
    FN.COMP = 'F.COMPANY'
    F.COMP = ''
    
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    
    FN.ACC = 'F.ACCOUNT'
    F.ACC = ''
    
    FN.AC.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AC.DETAILS = ''
*
    Y.REPAYMENT.TYPE = ''
     
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.COMP, F.COMP)
    EB.DataAccess.Opf(FN.AC.DETAILS, F.AC.DETAILS)
    EB.DataAccess.Opf(FN.AA.ARR, F.AA.ARR)
    EB.DataAccess.Opf(FN.ACC, F.ACC)
RETURN

PROCESS:
*
    LOCATE "CUSTOMER.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING CUS.POS THEN
        Y.CUS.ID = EB.Reports.getEnqSelection()<4, CUS.POS>
    END
    
    LOCATE "ACC.NO" IN EB.Reports.getEnqSelection()<2,1> SETTING ACC.POS THEN
        Y.AC.NO = EB.Reports.getEnqSelection()<4, ACC.POS>
    END
    
    LOCATE "Y.START.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING SDATE.POS THEN
        Y.ST.DT = EB.Reports.getEnqSelection()<4, SDATE.POS>
    END
    
    LOCATE "Y.END.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING EDATE.POS THEN
        Y.END.DT = EB.Reports.getEnqSelection()<4, EDATE.POS>
    END

*    Y.CUS.ID = '100117'
*   Y.DT = '20200404'

*------------------------READ COMPANY----------------------------------------------------
    EB.DataAccess.FRead(FN.COMP, Y.COMP, REC.COMP, F.COMP, Er)
    Y.COMP.FINMNE = REC.COMP<ST.CompanyCreation.Company.EbComFinancialMne>
*-----------------------------end--------------------------------------------------------

    SEL.CMD = 'SELECT ':FN.AC.DETAILS:' WITH MATURITY.DATE GE ':Y.ST.DT:' AND MATURITY.DATE LE ':Y.END.DT
*
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, SystemReturnCode)
*
    LOOP
        REMOVE Y.AA.ID FROM SEL.LIST SETTING POS
    WHILE Y.AA.ID:POS
        EB.DataAccess.FRead(FN.AA.ARR, Y.AA.ID, REC.AA, F.AA.ARR, Er)
*
        Y.PRODUCT.LINE = REC.AA<AA.Framework.Arrangement.ArrProductLine>
        Y.ARR.STATUS = REC.AA<AA.Framework.Arrangement.ArrArrStatus>
        Y.AA.CUS.ID = REC.AA<AA.Framework.Arrangement.ArrCustomer>
        Y.CO.CODE = REC.AA<AA.Framework.Arrangement.ArrCoCode>
*
*ARR.STATUS EQ CURRENT'--- DEPOSITS/LENDING
        IF Y.PRODUCT.LINE EQ "DEPOSITS" AND Y.ARR.STATUS EQ "CLOSE" AND Y.CO.CODE EQ Y.COMP THEN

            Y.PRODUCT = REC.AA<AA.Framework.Arrangement.ArrProduct>
            Y.CURRENCY = REC.AA<AA.Framework.Arrangement.ArrCurrency>
         
*----------------------ACCOUNT PROPERTY READ-----------------------------------------------------------
            PROP.CLASS.1 = 'ACCOUNT'
            CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS.1,PROPERTY,'',RETURN.IDS,RETURN.VALUES.1,ERR.MSG)
            R.ACC.REC = RAISE(RETURN.VALUES.1)
            Y.ACC.NO = R.ACC.REC<AA.Account.Account.AcAccountReference>
            EB.DataAccess.FRead(FN.ACC, Y.ACC.NO, REC.ACC, F.ACC, Er.RRR)
            Y.ACC.CATEGORY = REC.ACC<AC.AccountOpening.Account.Category>
            
*----------------------------------END----------------------------------------------------
   
*-----------------------Principal--------------------------------
            RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
            RequestType<3> = 'ALL'  ;* Projected Movements requierd
            RequestType<4> = 'ECB'  ;* Balance file to be used
            RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    
            IF Y.COMP.FINMNE EQ 'BNK' THEN
                BaseBalance = 'CURACCOUNT'
            END
     
            IF Y.COMP.FINMNE EQ 'ISL' THEN
                BaseBalance = 'CURISACCOUNT'
            END
            Y.PAYMENT.DATE = Y.TODAY
            AA.Framework.GetPeriodBalances(Y.ACC.NO, BaseBalance, RequestType, Y.PAYMENT.DATE, Y.PAYMENT.DATE, Y.PAYMENT.DATE, BalDetails, ErrorMessage)
*
            Y.CREDIT.MVMT = BalDetails<2>
            Y.DEBIT.MVMT = BalDetails<3>
            Y.AMT = BalDetails<4>
*----------------------------------END----------------------------------------------------
            EB.DataAccess.FRead(FN.AC.DETAILS, Y.AA.ID, REC.ACC.DET, F.AC.DETAILS, Er)
            Y.ACC.VALUE.DATE = REC.ACC.DET<AA.PaymentSchedule.AccountDetails.AdBaseDate>
            Y.AD.MATURITY.INS = REC.ACC.DET<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
*
*----------------------RENEWAL PROPERTY READ-----------------------------------------------------------
            PROP.CLASS.3 = 'CHANGE.PRODUCT'
            CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS.3,PROPERTY,'',RETURN.IDS,RETURN.VALUES.3,ERR.MSG)
            R.ACC.TERM = RAISE(RETURN.VALUES.3)
            Y.ROLLLOVER.TERM = R.ACC.TERM<AA.ChangeProduct.ChangeProduct.CpChangePeriod>
*----------------------------------END----------------------------------------------------
*---------------------------INTEREST PROPERTY READ-----------------------------------------------
            PROP.CLASS.2 = 'INTEREST'
            CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,PROP.CLASS.2,PROPERTY,'',RETURN.IDS,RETURN.VALUES.2,ERR.MSG)
            R.ACC.INT = RAISE(RETURN.VALUES.2)
            Y.INTEREST.RATE = R.ACC.INT<AA.Interest.Interest.IntEffectiveRate>
*--------------------------------------------------------------------------------------------------
            IF Y.AC.NO EQ Y.ACC.NO AND Y.CUS.ID EQ Y.AA.CUS.ID THEN
                Y.DATA<-1> = Y.ACC.NO:'*':Y.AA.CUS.ID:'*':Y.PRODUCT:'*':Y.CURRENCY:'*':Y.AMT:'*':Y.ACC.VALUE.DATE:'*':Y.AD.MATURITY.INS:'*':Y.INTEREST.RATE:'*':Y.ROLLLOVER.TERM:'*':Y.CO.CODE
*                                1              2            3              4             5               6                7                    8                        9              10
            END
            
            ELSE IF Y.AC.NO EQ "" AND Y.CUS.ID EQ Y.AA.CUS.ID THEN
                Y.DATA<-1> = Y.ACC.NO:'*':Y.AA.CUS.ID:'*':Y.PRODUCT:'*':Y.CURRENCY:'*':Y.AMT:'*':Y.ACC.VALUE.DATE:'*':Y.AD.MATURITY.INS:'*':Y.INTEREST.RATE:'*':Y.ROLLLOVER.TERM:'*':Y.CO.CODE
            END
            ELSE IF Y.AC.NO EQ Y.ACC.NO AND Y.CUS.ID EQ "" THEN
                Y.DATA<-1> = Y.ACC.NO:'*':Y.AA.CUS.ID:'*':Y.PRODUCT:'*':Y.CURRENCY:'*':Y.AMT:'*':Y.ACC.VALUE.DATE:'*':Y.AD.MATURITY.INS:'*':Y.INTEREST.RATE:'*':Y.ROLLLOVER.TERM:'*':Y.CO.CODE
            END
            ELSE IF Y.AC.NO EQ "" AND Y.CUS.ID EQ "" THEN
                Y.DATA<-1> = Y.ACC.NO:'*':Y.AA.CUS.ID:'*':Y.PRODUCT:'*':Y.CURRENCY:'*':Y.AMT:'*':Y.ACC.VALUE.DATE:'*':Y.AD.MATURITY.INS:'*':Y.INTEREST.RATE:'*':Y.ROLLLOVER.TERM:'*':Y.CO.CODE
            END
*
        END
    REPEAT
*
RETURN
END