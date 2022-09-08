* @ValidationCode : MjotODY1Nzk1Nzk0OkNwMTI1MjoxNTkyNzUyOTcwNDk3OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Jun 2020 21:22:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.V.CHECK.NOMINEE.PERCENT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Subroutine Description: This routine Nominee percent check
*Subroutine Type       : API routine
*Attached To           :  ACTIVITY.API
*Attached As           :  ROUTINE
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
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING AA.Account
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.Foundation
*-----------------------------------------------------------------------------
    APPLICATION.NAME = 'AA.PRD.DES.ACCOUNT'
    LOCAL.FIELDS = 'LT.AC.NM.SHARE'
    EB.Foundation.MapLocalFields(APPLICATION.NAME, LOCAL.FIELDS, FLD.POS)
    Y.NOM.PERCENT.POS = FLD.POS<1,1>
    
    Y.NOM.PERCENT = EB.SystemTables.getRNew(AA.Account.Account.AcLocalRef)<1,Y.NOM.PERCENT.POS>
*    Y.LEN = DCOUNT(Y.NOM.PERCENT,VM)
*    FOR I = 1 TO Y.LEN
*        Y.VALUE.CHK = Y.NOM.PERCENT<1,I>
*        IF Y.VALUE.CHK LE 0 THEN
*            EB.SystemTables.setEtext("Nominee Percent should be GT 0 for every nominee")
*            EB.SystemTables.setAf(AA.Account.Account.AcLocalRef)
*            EB.SystemTables.setAv(Y.NOM.PERCENT.POS)
*            EB.ErrorProcessing.StoreEndError()
*        END ELSE
*            Y.TOT.NOMINEE.VAL = Y.TOT.NOMINEE.VAL + Y.VALUE.CHK
*        END
*    NEXT I

    IF SUM(Y.NOM.PERCENT) NE 100 THEN
        EB.SystemTables.setEtext("Total Nominee Percent should be 100")
        EB.SystemTables.setAf(AA.Account.Account.AcLocalRef)
        EB.SystemTables.setAv(Y.NOM.PERCENT.POS)
        EB.ErrorProcessing.StoreEndError()
    END
    

END
