* @ValidationCode : MjotOTc2ODQzNzMzOkNwMTI1MjoxNTkzNDIyMjc3NjA0OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Jun 2020 15:17:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE MBL.TXN.PROFILE.PARAM.ID
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.SystemTables
*-----------------------------------------------------------------------------
    Y.ID = EB.SystemTables.getComi()
    IF Y.ID NE 'SYSTEM' THEN
        EB.SystemTables.setE('ID MUST BE SYSTEM')
        RETURN
    END
END
