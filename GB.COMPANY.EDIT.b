* @ValidationCode : MjotMTg4OTg0MjA2OkNwMTI1MjoxNTc1Njk4NDE4NzM5OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 07 Dec 2019 12:00:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.COMPANY.EDIT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING ST.CompanyCreation
    $USING EB.DataAccess
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*****
INIT:
*****
    FN.COM = 'F.COMPANY'
    F.COM = ''
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.COM,F.COM)
RETURN

********
PROCESS:
********
    SEL.CMD = 'SELECT ':FN.COM
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.REC,SEL.ERR)
    LOOP
        REMOVE Y.COM.ID FROM SEL.LIST SETTING Y.COM.POS
    WHILE Y.COM.ID:Y.COM.POS
        EB.DataAccess.FRead(FN.COM,Y.COM.ID,R.COM,F.COM,COM.ERR)
        R.COM<ST.CompanyCreation.Company.EbComAcctCheckdigType> =  '@CM.MBL.ID.AC.GENERATE'
        R.COM<ST.CompanyCreation.Company.EbComAccountMask> = '#-###-########-#'
        EB.DataAccess.FWrite(FN.COM,Y.COM.ID,R.COM)
        EB.TransactionControl.JournalUpdate(Y.COM.ID)
        CRT Y.COM.ID
    REPEAT
RETURN

END
