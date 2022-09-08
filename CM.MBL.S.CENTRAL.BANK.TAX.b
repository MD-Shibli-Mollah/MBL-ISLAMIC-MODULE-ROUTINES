SUBROUTINE CM.MBL.S.CENTRAL.BANK.TAX( PASS.CUSTOMER, PASS.DEAL.AMOUNT, PASS.DEAL.CCY, PASS.CCY.MKT, PASS.CROSS.RATE, PASS.CROSS.CCY, PASS.DWN.CCY, PASS.DATA, PASS.CUST.CDN,R.TAX,TAX.AMOUNT)
*-----------------------------------------------------------------------------
* This routine calculate TAX amount based on TIN given or not and attached in CALC.ROUTINE field of TAX Application
* Developed By-
*1. 0%=> Indetified by Bank(Manual)
*2. 5%=> Identified by Bank(Manual)
*3. 10%> Balance LT 1,00,000 for Saving Account or ( SND/CD/SB if  TIN available)
*4. 15%=> Balance GE 1,00,000 for Saving Account and TIN ID not available( SND/SB/CD)
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*Subroutine Description:
*Subroutine Type:
*Attached To    : AA.ARR.ACCOUNT,MBL.AA.AR
*Attached As    : TAX ROUTINE AT TAX CODE
*-----------------------------------------------------------------------------
* Modification History :
* 14/06/2020 -                            Retrofit   - MD. KAMRUL HASAN,
*                                                 FDS Bangladesh Limited
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
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
    $USING AA.Account
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
************************************
INIT:
************************************
    FN.CUS= 'F.CUSTOMER'
    F.CUS = ''
   
    APPLICATION.NAME = 'AA.ARR.ACCOUNT'
    Y.TAX.MARK = 'LT.AC.TAX.RATE'
    Y.TAX.MARK.POS =''
    
    Y.MAX.AMT.ORIG=''
    Y.MAX.AMT.TEMP=''
    Y.TIN.AMOUNT=100000
    Y.ETIN = ''
RETURN
************************************
OPENFILES:
************************************
    EB.DataAccess.Opf(FN.CUS,F.CUS)
RETURN
************************************
PROCESS:
************************************
    Y.CUS.NO = c_aalocArrangementRec<AA.Framework.Arrangement.ArrCustomer>
    EB.DataAccess.FRead(FN.CUS,Y.CUS.NO,R.CUS,F.AA, ERR)
    Y.TIN.VAL=R.CUS<ST.Customer.Customer.EbCusTaxId>

    Y.END.DATE = EB.SystemTables.getToday()
    Y.END.MNTH = Y.END.DATE[5,2] 'R%2'
    IF Y.END.MNTH LE '06' THEN
        Y.START.DATE = Y.END.DATE[1,4]:'0101'
    END ELSE
        Y.START.DATE = Y.END.DATE[1,4]:'0701'
    END
    
    Y.ARR.ID = PASS.CUSTOMER<5>

    AA.Framework.GetArrangementAccountId(Y.ARR.ID, AccountId, Currency, ReturnError)
    AA.Framework.GetArrAccountProductLine(AccountId, ProductLine, ReturnError)
    Y.PRODUCT.LINE = ProductLine
    BaseBalance = 'CURBALANCE'
    RequestType<2> = 'ALL'  ;* Unauthorised Movements required.
    RequestType<3> = 'ALL'  ;* Projected Movements requierd
    RequestType<4> = 'ECB'  ;* Balance file to be used
    RequestType<4,2> = 'END'    ;* Balance required as on TODAY - though Activity date can be less than today
    AA.Framework.GetPeriodBalances(AccountId , BaseBalance, RequestType, Y.START.DATE, Y.END.DATE, SystemDate, BalDetails, ErrorMessage)
    Y.MAX.AMT.ORIG = MAXIMUM(BalDetails<4,2>)
***********************************************************
 
    EB.LocalReferences.GetLocRef(APPLICATION.NAME,Y.TAX.MARK,Y.TAX.MARK.POS)
    PROP.CLASS2 = 'ACCOUNT'
    AA.Framework.GetArrangementConditions(Y.ARR.ID, PROP.CLASS2, PROPERTY, Effectivedate, RETURN.IDS, RETURN.VALUES, ERR.MSG)
    R.ACC.REC = RAISE(RETURN.VALUES)
    Y.TAX.RATE = R.ACC.REC<AA.Account.Account.AcLocalRef,Y.TAX.MARK.POS>
    IF Y.TAX.RATE EQ '' THEN
        IF Y.TIN.VAL THEN
            TAX.AMOUNT=(PASS.DEAL.AMOUNT*10)/100
        END
        ELSE
            IF Y.MAX.AMT.ORIG GE Y.TIN.AMOUNT THEN
                TAX.AMOUNT=(PASS.DEAL.AMOUNT*15)/100
            END
            ELSE
                TAX.AMOUNT=(PASS.DEAL.AMOUNT*10)/100
            END
        END
    END ELSE
        TAX.AMOUNT = (PASS.DEAL.AMOUNT*Y.TAX.RATE)/100
    END
    
RETURN

END
