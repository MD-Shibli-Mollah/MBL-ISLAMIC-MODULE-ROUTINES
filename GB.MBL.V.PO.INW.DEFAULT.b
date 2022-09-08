* @ValidationCode : MjotMTEzNzQ1MDE1OkNwMTI1MjoxNTkyNjg1MzM5NDU4OlphaGlkIEZEUzotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Jun 2020 02:35:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : Zahid FDS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0

SUBROUTINE GB.MBL.V.PO.INW.DEFAULT
*-----------------------------------------------------------------------------
*Developed By: Md. Zahid Hasan
*Project Name: MBL Islamic
*Details: This routine default the value of payee name, pay order amount,
*   pay order currency, debit account no, credit account no during validation
*   stage (during inputting pay order number)
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    $USING ST.ChqSubmit
    $USING FT.Contract
    $USING EB.SystemTables
    $USING EB.DataAccess
    
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB GET.VALUES
RETURN

INIT:
    FN.CHQ.SUPP = 'F.CHEQUE.REGISTER.SUPPLEMENT'
    F.CHQ.SUPP = ''
    R.CHQ.SUPP = ''
    
    FN.FT = 'F.FUNDS.TRANSFER'
    F.FT = ''
    R.FT = ''
    
    PayOrderNo = EB.SystemTables.getComi()
    BranchCode = EB.SystemTables.getIdCompany()
    GetBrCode = BranchCode[6,4]
    DrAccountNo = 'BDT152610001':GetBrCode
    CrAccountNo = 'BDT140310001':GetBrCode
RETURN

OPENFILES:
    EB.DataAccess.Opf(FN.CHQ.SUPP, F.CHQ.SUPP)
    EB.DataAccess.Opf(FN.FT, F.FT)
RETURN

GET.VALUES:
    ChqRegSupID = 'PO.BDT152610001':GetBrCode:'.':PayOrderNo
   
    EB.DataAccess.FRead(FN.CHQ.SUPP, ChqRegSupID, R.CHQ.SUPP, F.CHQ.SUPP, ChqRegSupEr)
    
    PayeeName = R.CHQ.SUPP<ST.ChqSubmit.ChequeRegisterSupplement.CcCrsPayeeName>
    PoAmt = R.CHQ.SUPP<ST.ChqSubmit.ChequeRegisterSupplement.CcCrsAmount>
    PoCcy = R.CHQ.SUPP<ST.ChqSubmit.ChequeRegisterSupplement.CcCrsCurrency>
    GOSUB SET.VALUES
        
RETURN
   
SET.VALUES:

    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.PayeeName, PayeeName)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitAmount, PoAmt)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitCurrency, PoCcy)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitAcctNo, DrAccountNo)
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAcctNo, CrAccountNo)

RETURN
    
END
