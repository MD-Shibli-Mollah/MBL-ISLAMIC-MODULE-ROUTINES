* @ValidationCode : MjotNzg3Njg3Njc1OkNwMTI1MjoxNTg4NDk5MTc0ODY5OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 03 May 2020 15:46:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.B.ED.RETAIL.SETTLE.SELECT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.GB.MBL.B.ED.RETAIL.SETTLE.COMMON
    
    $USING AA.Framework
    $USING EB.Service
    $USING EB.DataAccess
*-----------------------------------------------------------------------------
    GOSUB SEL.LIST
RETURN

*********
SEL.LIST:
*********
    SEL.CMD="SELECT ":FN.BD.CHG:" WITH @ID LIKE ...EXCISEDUTYFEE... AND OS.DUE.AMT NE 0"
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.REC,E.RR)
    EB.Service.BatchBuildList('',SEL.LIST)
RETURN
END
