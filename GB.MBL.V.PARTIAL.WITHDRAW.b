* @ValidationCode : Mjo1Mjc3MjcwOTg6Q3AxMjUyOjE1OTQxODkwMDM1MzI6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 08 Jul 2020 12:16:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.V.PARTIAL.WITHDRAW
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
* 1)
*    Date :
*    Modification Description :
*    Modified By  :
*Total Withdrawal Amount Calcuate
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
    Y.PROD.GROUP = R.AA<AA.Framework.Arrangement.ArrProductGroup>
    IF Y.PROD.GROUP EQ 'IS.MBL.MTD.DP' THEN
        PROP.CLASS = 'TERM.AMOUNT'
        AA.Framework.GetArrangementConditions(Y.AA.ID,PROP.CLASS,PROPERTY,'',RETURN.IDS,RETURN.VALUES,ERR.MSG)
        R.REC = RAISE(RETURN.VALUES)
        Y.COMMIT.AMT = R.REC<AA.TermAmount.TermAmount.AmtAmount>
        BaseBalance = 'CURISACCOUNT'
        RequestType<2> = 'ALL'
        RequestType<3> = 'ALL'
        RequestType<4> = 'ECB'
        RequestType<4,2> = 'END'
        Y.SYSTEMDATE = EB.SystemTables.getToday()
        AA.Framework.GetPeriodBalances(Y.AC.NO,BaseBalance,RequestType,Y.SYSTEMDATE,Y.SYSTEMDATE,Y.SYSTEMDATE,BalDetails,ErrorMessage)    ;*Balance left in the balance Type
        Y.CUR.AMT = BalDetails<4>
        IF Y.CUR.AMT GT Y.COMMIT.AMT THEN
            Y.PAR.W.AMT = Y.CUR.AMT - Y.COMMIT.AMT
            IF EB.SystemTables.getApplication() EQ 'FUNDS.TRANSFER' THEN
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitAmount, Y.PAR.W.AMT)
            END ELSE
                EB.SystemTables.setRNew(TT.Contract.Teller.TeAmountLocalOne, Y.PAR.W.AMT)
            END
        END
    END
RETURN
END
