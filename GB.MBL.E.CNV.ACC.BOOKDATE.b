* @ValidationCode : MjotNzg4MzQ4NDA0OkNwMTI1MjoxNTk0MjM0MjQ3MTU4OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 09 Jul 2020 00:50:47
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

*THIS CONVERSION ROUTINE TAKES DATE TIME THEN CONVERT THE DATE ONLY TO REGULAR DATE FORMET******

SUBROUTINE GB.MBL.E.CNV.ACC.BOOKDATE
    
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $USING EB.Reports
    $USING ST.CompanyCreation

    GOSUB PROCESS
RETURN

*--------------------------------------------------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------------------------------------------------
*   ST.CompanyCreation.LoadCompany('BNK')
    Y.DATE=''
    Y.DATE.1=''
    Y.F.DATE.2=''
    Y.DATE=EB.Reports.getOData()
    Y.DATE.LEN = LEN(Y.DATE)
    
    IF Y.DATE.LEN GT 8 THEN
        Y.F.DATE = Y.DATE[1,8]
        Y.F.DATE.1=ICONV(Y.F.DATE,'D4')
        Y.F.DATE.2=OCONV(Y.F.DATE.1,'D')
***************************************************************************
        Y.L.DATE = Y.DATE[10,17]
        Y.L.DATE.1=ICONV(Y.L.DATE,'D4')
        Y.L.DATE.2=OCONV(Y.L.DATE.1,'D')
        Y.BOOK.DATE = Y.F.DATE.2:' to ':Y.L.DATE.2
    
        EB.Reports.setOData(Y.BOOK.DATE)
    END
RETURN
END