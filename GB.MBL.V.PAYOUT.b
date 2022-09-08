* @ValidationCode : MjoxNjQ2NzM2NDQyOkNwMTI1MjoxNTk0MTg5MTM3MzY5OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 08 Jul 2020 12:18:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.V.PAYOUT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
* 1)
*    Date :
*    Modification Description :
*    Modified By  :
*Total Payable Amount Calculate when Arrangement Expired
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING FT.Contract
    $USING TT.Contract
    $USING AA.TermAmount
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN



*----
INIT:
*----
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    Y.AC.NO = EB.SystemTables.getComi()
RETURN

*---------
OPENFILES:
*---------
    EB.DataAccess.Opf(FN.AC, F.AC)
    EB.DataAccess.Opf(FN.AA, F.AA)
RETURN

*-------
PROCESS:
*-------
    EB.DataAccess.FRead(FN.AC, Y.AC.NO, R.AC, F.AC, Er.AC)
    Y.AA.ID = R.AC<AC.AccountOpening.Account.ArrangementId>
    EB.DataAccess.FRead(FN.AA, Y.AA.ID, R.AA, F.AA, Er.AA)
    Y.ARR.STATUS = R.AA<AA.Framework.Arrangement.ArrArrStatus>
    Y.PROD.GROUP = R.AA<AA.Framework.Arrangement.ArrProductGroup>
    IF Y.ARR.STATUS EQ 'EXPIRED' THEN
        BaseBalance = 'PAYISACCOUNT'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(Y.AC.NO,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
        Y.CUR.AMT = BalDetails<4>
        BaseBalance = 'PAYDEPOSITPFT'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(Y.AC.NO,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
        Y.PFT.AMT = BalDetails<4>
        BaseBalance = 'PAYTAXREBATE'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(Y.AC.NO,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
        Y.REBATE.AMT = BalDetails<4>
        Y.PAYOUT.AMT = Y.CUR.AMT + Y.PFT.AMT + Y.REBATE.AMT
        IF Y.PAYOUT.AMT EQ '' THEN
            Y.PAYOUT.AMT = 0
        END
        IF EB.SystemTables.getApplication() EQ 'FUNDS.TRANSFER' THEN
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitAmount, Y.PAYOUT.AMT)
        END ELSE
            EB.SystemTables.setRNew(TT.Contract.Teller.TeAmountLocalOne, Y.PAYOUT.AMT)
        END
    END ELSE
        IF Y.PROD.GROUP EQ 'IS.MBL.MMMA.DP' THEN
            BaseBalance = 'PAYDEPOSITPFT'
            RequestType<2> = 'ALL'
            RequestType<3> = 'ALL'
            RequestType<4> = 'ECB'
            RequestType<4,2> = 'END'
            Y.SYSTEMDATE = EB.SystemTables.getToday()
            AA.Framework.GetPeriodBalances(Y.AC.NO,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
            Y.PAY.AMT = BalDetails<4>
            IF EB.SystemTables.getApplication() EQ 'FUNDS.TRANSFER' THEN
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitAmount, Y.PAY.AMT)
            END ELSE
                EB.SystemTables.setRNew(TT.Contract.Teller.TeAmountLocalOne, Y.PAY.AMT)
            END
        END
    END
RETURN

END
