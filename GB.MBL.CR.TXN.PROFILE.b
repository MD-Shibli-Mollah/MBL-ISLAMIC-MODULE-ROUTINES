* @ValidationCode : MjoxOTc2NDMxOTkzOkNwMTI1MjoxNTkyODAxODYxMDA2OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Jun 2020 10:57:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.CR.TXN.PROFILE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed By- Akhter Hossain
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MBL.TXN.PROFILE
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING ST.Customer
    $USING AC.AccountOpening

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN

INIT:

    FN.TXN.PROF = 'F.MBL.TXN.PROFILE'
    F.TXN.PROF = ''

    FN.AC = 'F.ACCOUNT'
    F.AC = ''
RETURN

OPEN.FILES:
***********
    EB.DataAccess.Opf(FN.TXN.PROF, F.TXN.PROF)
    EB.DataAccess.Opf(FN.AC,F.AC)
RETURN

PROCESS:
   
    Y.AC.ID = EB.SystemTables.getIdNew()
    EB.DataAccess.FRead(FN.AC, Y.AC.ID, R.AC, F.AC, AC.ERR)
    Y.AC.TITLE.1 = R.AC<AC.AccountOpening.Account.AccountTitleOne>
    Y.AC.TITLE.2 = R.AC<AC.AccountOpening.Account.AccountTitleTwo>
    Y.AC.TITLE = Y.AC.TITLE.1 : " " :Y.AC.TITLE.2
    EB.SystemTables.setRNew(MB.TP.ACCOUNT.TITLE, Y.AC.TITLE)
RETURN


END
