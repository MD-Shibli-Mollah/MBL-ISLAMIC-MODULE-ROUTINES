* @ValidationCode : MjotMTQyMzIzNjg4NTpDcDEyNTI6MTU5MjE1MjQ5MTk2MDpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 14 Jun 2020 22:34:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.B.ED.RETAIL.SETTLE.LOAD
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.BD.CHG.INFORMATION
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.GB.MBL.B.ED.RETAIL.SETTLE.COMMON
    
    $USING AA.Framework
    $USING EB.DataAccess
    $USING ST.ChargeConfig
    $USING AC.AccountOpening
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
    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    FN.COM = 'F.COMPANY'
    F.COM = ''
RETURN

**********
OPENFILES:
**********
    EB.DataAccess.Opf(FN.BD.CHG,F.BD.CHG)
    EB.DataAccess.Opf(FN.AA,F.AA)
    EB.DataAccess.Opf(FN.AC,F.AC)
    EB.DataAccess.Opf(FN.COM,F.COM)
RETURN
END
