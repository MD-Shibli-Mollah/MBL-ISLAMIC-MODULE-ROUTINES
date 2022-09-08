* @ValidationCode : MjoxOTc3ODg0NDI5OkNwMTI1MjoxNTkyODAxODk3NDk4OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Jun 2020 10:58:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.ID.TXN.PROFILE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed By- Akhter Hossain
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING AC.AccountOpening

    FN.AC='F.ACCOUNT'
    F.AC=''
   
    EB.DataAccess.Opf(FN.AC, F.AC)
  
    Y.ID = EB.SystemTables.getComi()
    
    Y.USR.COMP = EB.SystemTables.getIdCompany()

    EB.DataAccess.FRead(FN.AC, Y.ID, R.AC, F.AC, Err.AC)
    
    IF R.AC THEN
        IF R.AC<AC.AccountOpening.Account.CoCode> NE Y.USR.COMP THEN
            EB.SystemTables.setE('OTHER BRANCH ACCOUNT')
            RETURN
        END
    END
    ELSE
        EB.SystemTables.setE('WRONG ACCOUNT NUMBER')
        RETURN
    END
   

RETURN
END
