* @ValidationCode : Mjo4MDQ0ODg5MTY6Q3AxMjUyOjE1OTI1ODAyNjgyNzE6WmFoaWQgRkRTOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Jun 2020 21:24:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : Zahid FDS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0

SUBROUTINE GB.MBL.CR.STOCK.ENTRY
*-----------------------------------------------------------------------------
*Developed By: Md. Zahid Hasan
*Project Name: MBL Islamic
*Details: This routine default the value of FROM.REGISTER(STOCK.REGISTER record)
*   during input stage. Default value is "DRAFT." logged in company code
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    $USING EB.SystemTables
    $USING ST.ChqStockControl
    $USING EB.DataAccess

    FN.ST.ENTRY = 'F.STOCK.ENTRY'
    F.ST.ENTRY = ''

    EB.DataAccess.Opf(FN.ST.ENTRY, F.ST.ENTRY)

    Y.CO.CODE = EB.SystemTables.getIdCompany()

    Y.TO.REG = 'DRAFT.':Y.CO.CODE
    EB.SystemTables.setRNew(ST.ChqStockControl.StockEntry.StoEntToRegister,Y.TO.REG)
    

RETURN

END
