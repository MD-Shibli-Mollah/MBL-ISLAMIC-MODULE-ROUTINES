* @ValidationCode : MjotMTcwOTUwNjE1NDpDcDEyNTI6MTU5MjQ4MzYyMTA2OTp1c2VyOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Jun 2020 18:33:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
* @AUTHOR         : MD SHIBLI MOLLAH

SUBROUTINE GB.MBL.V.STOCK.REG
*PROGRAM GB.MBL.V.STOCK.REG

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING EB.SystemTables

    Y.COM = EB.SystemTables.getIdCompany()
    Y.STOCK.REG = "DRAFT.":Y.COM
    COMI = Y.STOCK.REG
    
RETURN
END