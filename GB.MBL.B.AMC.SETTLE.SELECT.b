* @ValidationCode : MjotMTM5MzI5ODYxMTpDcDEyNTI6MTU5MjU1MDI0MTc2NDpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Jun 2020 13:04:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.B.AMC.SETTLE.SELECT
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
    $INSERT I_BATCH.FILES
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.GB.MBL.B.AMC.SETTLE.COMMON
    
    $USING AA.Framework
    $USING EB.Service
    $USING EB.DataAccess
*-----------------------------------------------------------------------------
    GOSUB SEL.LIST
RETURN

*********
SEL.LIST:
*********
    SEL.CMD="SELECT ":FN.BD.CHG:" WITH @ID LIKE ...AMCFEE... AND OS.DUE.AMT NE 0"
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.REC,E.RR)
    EB.Service.BatchBuildList('',SEL.LIST)
RETURN
END
