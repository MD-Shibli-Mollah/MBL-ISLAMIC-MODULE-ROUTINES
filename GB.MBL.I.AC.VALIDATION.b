* @ValidationCode : MjotMzA3ODMxNDU0OkNwMTI1MjoxNTkyODEzMTc2NDMyOkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Jun 2020 14:06:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.I.AC.VALIDATION
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
*Condition: This Routine is added as input Routine to validate the Retail Account Number
* 1)
*    Date :
*    Modification Description :
*    Modified By  :
*Account checking for Ratails
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
    $USING EB.ErrorProcessing
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
    Y.APPLICATION = EB.SystemTables.getApplication()
    IF Y.APPLICATION EQ 'FUNDS.TRANSFER' THEN
        Y.CR.AC = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
        EB.DataAccess.FRead(FN.AC, Y.CR.AC, R.CR.AC, F.AC, Er.AC)
        Y.CR.AA.ID = R.CR.AC<AC.AccountOpening.Account.ArrangementId>
        EB.DataAccess.FRead(FN.AA, Y.CR.AA.ID, R.CR.AA, F.AA, Er.AA)
        Y.CR.PROD.LINE = R.CR.AA<AA.Framework.Arrangement.ArrProductLine>
        
        IF Y.CR.PROD.LINE NE 'ACCOUNTS' THEN
            IF Y.CR.PROD.LINE NE '' THEN
                GOSUB FT.CR.ERROR.PROCESS
            END
        END
        Y.DR.AC = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
        EB.DataAccess.FRead(FN.AC, Y.DR.AC, R.DR.AC, F.AC, Er.AC)
        Y.DR.AA.ID = R.DR.AC<AC.AccountOpening.Account.ArrangementId>
        EB.DataAccess.FRead(FN.AA, Y.DR.AA.ID, R.DR.AA, F.AA, Er.AA)
        Y.DR.PROD.LINE = R.DR.AA<AA.Framework.Arrangement.ArrProductLine>
        IF Y.DR.PROD.LINE NE 'ACCOUNTS' THEN
            IF Y.DR.PROD.LINE NE '' THEN
                GOSUB FT.DR.ERROR.PROCESS
            END
        END
    END
    IF Y.APPLICATION EQ 'TELLER' THEN
        Y.AC.2 = EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountTwo)
        EB.DataAccess.FRead(FN.AC, Y.AC.2, R.AC, F.AC, Er.AC)
        Y.AA.ID = R.AC<AC.AccountOpening.Account.ArrangementId>
        EB.DataAccess.FRead(FN.AA, Y.AA.ID, R.AA, F.AA, Er.AA)
        Y.PROD.LINE = R.AA<AA.Framework.Arrangement.ArrProductLine>
        IF Y.PROD.LINE NE 'ACCOUNTS' THEN
            IF Y.PROD.LINE NE '' THEN
                GOSUB TT.ERROR.PROCESS
            END
        END
    END
RETURN
*-------------------
FT.CR.ERROR.PROCESS:
*-------------------
    EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditAcctNo)
    Y.CR.OVERR.ID = 'Credit Account is not a Retail Account'
    EB.SystemTables.setEtext(Y.CR.OVERR.ID)
    EB.ErrorProcessing.StoreEndError()
RETURN

*-------------------
FT.DR.ERROR.PROCESS:
*-------------------
    EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAcctNo)
    Y.DR.OVERR.ID = 'Debit Account is not a Retail Account'
    EB.SystemTables.setEtext(Y.DR.OVERR.ID)
    EB.ErrorProcessing.StoreEndError()
RETURN

*----------------
TT.ERROR.PROCESS:
*----------------
    EB.SystemTables.setAf(TT.Contract.Teller.TeAccountTwo)
    Y.TT.OVERR.ID = 'Account is not a Retail Account'
    EB.SystemTables.setEtext(Y.TT.OVERR.ID)
    EB.ErrorProcessing.StoreEndError()
RETURN
END
