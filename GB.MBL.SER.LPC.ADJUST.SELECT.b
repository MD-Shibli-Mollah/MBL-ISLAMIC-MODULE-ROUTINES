* @ValidationCode : MjotMjQ4MjczNDY6Q3AxMjUyOjE1ODYyNTU2NzkxMTE6REVMTDotMTotMTowOjA6ZmFsc2U6Ti9BOkRFVl8yMDE3MTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 07 Apr 2020 16:34:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.SER.LPC.ADJUST.SELECT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine adjust LPC due
*Subroutine Type       : Service
*Attached To           : 
*Attached As           : 
*Developed by          : S.M. Sayeed
*Designation           : Technical Consultant
*Email                 : s.m.sayeed@fortress-global.com
*Incoming Parameters   :
*Outgoing Parameters   :
*-----------------------------------------------------------------------------
* Modification History :
* 1)
*    Date :
*    Modification Description :
*    Modified By  :
*
*-----------------------------------------------------------------------------
*
*1/S----Modification Start
*
*1/E----Modification End
*-----------------------------------------------------------------------------
    $INSERT I_F.GB.MBL.SER.LPC.ADJUST.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.BD.MBL.LPC.CHARGE.REC
     
    $USING EB.Service
    $USING EB.DataAccess
*-----------------------------------------------------------------------------
    GOSUB SELECT.LIST
RETURN
   
SELECT.LIST:
    SEL.CMD = 'SELECT ':FN.LPC.CRG:' WITH TOT.DUE.AMT GT 0'
    EB.DataAccess.Readlist(SEL.CMD, SEL.LIST, '', NO.OF.REC, EB.ERR)
    
    GOSUB BATCH.RUN
RETURN

BATCH.RUN:
    EB.Service.BatchBuildList('', SEL.LIST)
RETURN

END
