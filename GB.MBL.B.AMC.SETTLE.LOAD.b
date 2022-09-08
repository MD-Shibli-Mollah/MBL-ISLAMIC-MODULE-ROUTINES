* @ValidationCode : MjoxMTkyNDI4MDQ4OkNwMTI1MjoxNTkyNTUwMjU5MjU5OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Jun 2020 13:04:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.B.AMC.SETTLE.LOAD
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
* 1)
*    Date :
*    Modification Description :
*    Modified By  :
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BD.CHG.INFORMATION
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.FT.CHARGE.TYPE
    $INSERT I_F.GB.MBL.B.AMC.SETTLE.COMMON
    
    $USING AA.Framework
    $USING EB.DataAccess
    $USING ST.ChargeConfig
    $USING ST.CompanyCreation
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPENFILES
RETURN

*****
INIT:
*****
    FN.BD.CHG = 'F.BD.CHG.INFORMATION'
    F.BD.CHG = ''
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    FN.FTCT = 'F.FT.COMMISSION.TYPE'
    F.FTCT = ''
    FN.CHARGE = 'F.FT.CHARGE.TYPE'
    F.CHARGE = ''
    FN.TAX.CODE = 'F.TAX'
    F.TAX.CODE = ''
    FN.COM = 'F.COMPANY'
    F.COM = ''
RETURN
**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.FTCT,F.FTCT)
    EB.DataAccess.Opf(FN.CHARGE,F.CHARGE)
    EB.DataAccess.Opf(FN.TAX.CODE,F.TAX.CODE)
    EB.DataAccess.Opf(FN.COM,F.COM)
RETURN
END
